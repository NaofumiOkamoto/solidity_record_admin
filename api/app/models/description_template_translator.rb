require 'net/http'

# 定型文の日本語から英語を作る（docs/07-description-template.md の「英訳」）。
# 「定型文」画面の「英訳を作る」から呼ばれ、結果は入力欄に入るだけ（保存は人が確かめてから）。
#
# Gemini API（Google）を使う。無料枠で足りる量（定型文を1件ずつ訳すだけ）のため。
# 一般的な翻訳サービスだと「The A-side label is damaged.」のような英語になり、既存の定型文
# （「Some damage on A side label.」）と書き方がそろわない。そこで同じ対象（盤 / ジャケット）の
# 定型文のうち、訳す日本語に似ているものを EXAMPLE_COUNT 件だけ例として渡し、言い回しを合わせてもらう。
# 全件（盤で約2.4万文字）を送ると無料枠の消費が多く、似ていない例は言い回し合わせにもあまり効かないため。
# 編集中の定型文そのものは例から外す（入れると既存の英文をそのまま返し、訳し直しにならない）。
#
# 環境変数
#   GEMINI_API_KEY  必須。Google AI Studio で作る。開発中は開発側のキー、本番はクライアントのキーに差し替える
#   GEMINI_MODEL    任意。既定は DEFAULT_MODEL。モデルの提供終了や無料枠の変更があったらここで切り替える
#   GEMINI_FALLBACK_MODEL 任意。既定は FALLBACK_MODEL。GEMINI_MODEL が混雑・回数制限のときに使う
#
# 無料枠ではモデルの混雑（503）がよく起きる。混雑なら少し待って1回やり直し、それでもだめなら
# 予備のモデルで訳す。回数制限（429）はモデルごとなので、こちらもすぐ予備のモデルに切り替える。
#
# 無料枠では、送った内容（定型文の文）が Google のサービス改善に使われる。送るのは定型文だけで、
# 商品や価格の情報は送らない。
class DescriptionTemplateTranslator
  # 2026-11-13 に試したとき、3.8 Flash は混雑（503）と30秒超えのタイムアウトが続き、
  # 3.5 Flash-Lite は2秒前後で既存の言い回しどおりの訳を返した。短い定型文なら Flash-Lite で足りる
  DEFAULT_MODEL = 'gemini-3.5-flash-lite'.freeze
  FALLBACK_MODEL = 'gemini-3.8-flash'.freeze
  ENDPOINT = 'https://generativelanguage.googleapis.com/v1beta/models/%<model>s:generateContent'.freeze
  TIMEOUT = 20
  RETRY_WAIT = 2 # 混雑のときにやり直すまでの秒数
  EXAMPLE_COUNT = 30 # 例として渡す定型文の数

  # 画面にそのまま出すメッセージを持つ
  class Error < StandardError; end
  # 混雑・回数制限など、時間をおくか別のモデルなら通りそうなもの
  class Unavailable < Error; end

  def initialize(api_key: ENV['GEMINI_API_KEY'],
                 model: ENV['GEMINI_MODEL'].presence || DEFAULT_MODEL,
                 fallback_model: ENV['GEMINI_FALLBACK_MODEL'].presence || FALLBACK_MODEL)
    @api_key = api_key
    @models = [model, fallback_model].uniq
  end

  # target: 'record' / 'cover'、jp: 日本語の定型文（{面} を含んでよい）、exclude_id: 編集中の定型文の id
  # 戻り値: { en:, en_both: }。jp に {面} が無いときの en_both は空文字
  def translate(target:, jp:, exclude_id: nil)
    raise Error, '翻訳の API キー（GEMINI_API_KEY）が設定されていません' if @api_key.blank?

    side = jp.include?(DescriptionTemplate::SIDE_JP)
    result = parse(request_with_fallback(prompt(target, jp, side, exclude_id)))
    {
      en: result['en'].to_s.strip,
      en_both: side ? result['en_both'].to_s.strip : '',
    }
  end

  private

  def prompt(target, jp, side, exclude_id)
    examples = similar_templates(target, jp, exclude_id).map do |template|
      { jp: template.jp, en: template.en, en_both: template.en_both.to_s }.to_json
    end

    <<~PROMPT
      You translate Japanese condition notes for used vinyl records into English for an online record shop.
      The notes are about the #{target == 'record' ? 'disc and its labels (record condition)' : 'cover, OBI, inserts and sleeves (cover condition)'}.

      Match the shop's existing wording as closely as possible. Reuse the same phrases, word order and vocabulary as the examples
      (e.g. "Some damage" for ダメージ, "Slight" for 若干, "brown stains" for シミ, "But doesn't affect playing." for プレイOK).
      Keep it short and end every sentence with a period. If the Japanese has two sentences, write two English sentences.

      The placeholder {面} in Japanese stands for the side of the record (A面 / B面 / 両面).
      #{side_rules(side)}

      Existing notes similar to this one (one JSON per line):
      #{examples.join("\n")}

      Translate this note:
      #{jp}
    PROMPT
  end

  # 訳す日本語に似ている定型文。似ているかは、2文字ずつの組（「ラベ」「ベル」…）がどれだけ重なるかで測る。
  # {面} と句読点は、どの文にもあって似ている度合いをかさ上げするので外して比べる
  def similar_templates(target, jp, exclude_id)
    words = bigrams(jp)
    DescriptionTemplate.where(target: target).where.not(id: exclude_id).ordered.to_a
                       .each_with_index
                       .max_by(EXAMPLE_COUNT) { |template, index| [overlap(words, bigrams(template.jp)), -index] }
                       .map(&:first)
  end

  def bigrams(text)
    plain = text.gsub(DescriptionTemplate::SIDE_JP, '').gsub(/[。、]/, '')
    plain.chars.each_cons(2).map(&:join).to_set
  end

  def overlap(a, b)
    return 0.0 if a.empty? || b.empty?

    (a & b).size.fdiv((a | b).size)
  end

  def side_rules(side)
    unless side
      return 'This note has no {面}. Do not use the placeholder {side} anywhere, and return an empty string for en_both.'
    end

    <<~RULES.strip
      This note contains {面}, so return two versions:
      - en: the version for a single side. Write the placeholder {side} where "A side" or "B side" goes (e.g. "Some damage on {side} label.").
      - en_both: the version for both sides, written out in full without any placeholder. Use plurals where needed
        (e.g. "Some damage on both side labels.", "Slight noise on both sides.").
    RULES
  end

  # 1つ目のモデルは混雑なら1回やり直す。だめなら次のモデル。全部だめなら最後のエラーを返す
  def request_with_fallback(text)
    last_error = nil
    @models.each_with_index do |model, index|
      attempts = index.zero? ? 2 : 1
      attempts.times do |attempt|
        return request(text, model)
      rescue Unavailable => e
        last_error = e
        # 回数制限とタイムアウトは、待ってやり直しても通りにくいので次のモデルへ
        break if e.message.include?('回数制限') || e.message.include?('タイムアウト')

        sleep(RETRY_WAIT) if attempt < attempts - 1
      end
    end
    raise last_error
  end

  def request(text, model)
    uri = URI(format(ENDPOINT, model: model))
    body = {
      contents: [{ role: 'user', parts: [{ text: text }] }],
      generationConfig: {
        temperature: 0.2,
        responseMimeType: 'application/json',
        responseSchema: {
          type: 'OBJECT',
          properties: { en: { type: 'STRING' }, en_both: { type: 'STRING' } },
          required: %w[en en_both],
        },
      },
    }

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: TIMEOUT, read_timeout: TIMEOUT) do |http|
      http.post(uri.path, body.to_json, 'Content-Type' => 'application/json', 'x-goog-api-key' => @api_key)
    end
    handle_error(response, model) unless response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)
  rescue Net::OpenTimeout, Net::ReadTimeout
    Rails.logger.warn("[DescriptionTemplateTranslator] #{model} timeout")
    raise Unavailable, '翻訳がタイムアウトしました。時間をおいて再度お試しください'
  # 名前解決や接続の失敗は一時的なことが多い（2026-11-13 に一度起き、直後には繋がった）ので、混雑と同じくやり直す
  rescue SocketError, SystemCallError, IOError, OpenSSL::SSL::SSLError => e
    Rails.logger.warn("[DescriptionTemplateTranslator] #{model} #{e.class}: #{e.message}")
    raise Unavailable, '翻訳サービスに接続できませんでした。時間をおいて再度お試しください'
  end

  def handle_error(response, model)
    Rails.logger.warn("[DescriptionTemplateTranslator] #{model} #{response.code} #{response.body.to_s.truncate(500)}")
    case response.code.to_i
    when 429
      raise Unavailable, '翻訳の回数制限（無料枠）に達しました。少し待ってから再度お試しください'
    when 500, 502, 503, 504
      raise Unavailable, '翻訳サービスが混み合っています。少し待ってから再度お試しください'
    when 400, 403
      raise Error, "翻訳の API キーかモデル（#{model}）の設定に問題があります"
    when 404
      raise Error, "翻訳のモデル（#{model}）が見つかりません。GEMINI_MODEL を確認してください"
    else
      raise Error, '翻訳に失敗しました。時間をおいて再度お試しください'
    end
  end

  def parse(json)
    text = json.dig('candidates', 0, 'content', 'parts', 0, 'text')
    raise Error, '翻訳の結果を読み取れませんでした' if text.blank?

    JSON.parse(text)
  rescue JSON::ParserError
    raise Error, '翻訳の結果を読み取れませんでした'
  end
end
