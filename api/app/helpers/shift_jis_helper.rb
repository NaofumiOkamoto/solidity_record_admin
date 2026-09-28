# Yahoo 用 CSV の文字コード変換。
#
# 商品データには Shift_JIS に無い文字（アクセント付きラテン文字や約物）が混ざる。
# そのまま encode すると Encoding::UndefinedConversionError で CSV 出力全体が
# 500 になる。2026-09-28 に `é`（SKU 218174 "Danté And The Evergreens"）で発生した。
#
# 対策は2つ。
#
# 1. Windows-31J（CP932）を使う
#    Ruby の Shift_JIS は JIS X 0208 のみで、`－ ① ㈱ № ㎝` といった NEC 拡張を
#    扱えない。Windows 版 Shift_JIS である CP932 ならこれらが通る。
#    逆に CP932 で扱えないのは `〜`(U+301C) と `—`(U+2014) の2文字だけで、
#    どちらも CP932 側の対応文字と**同じバイト列**になるため置き換えれば出力は変わらない。
#      〜(U+301C) Shift_JIS → 81 60 ＝ ～(U+FF5E) CP932 → 81 60
#      —(U+2014)  Shift_JIS → 81 5C ＝ ―(U+2015) CP932 → 81 5C
#
# 2. それでも変換できない文字は置き換える
#    アクセントは Unicode 正規化で機械的に落とし（é → e）、残りは表で対応する。
#    表記が多少変わっても、出力が落ちるよりはよいという判断。
module ShiftJisHelper
  ENCODING = Encoding::Windows_31J

  SUBSTITUTIONS = {
    # CP932 に無いが Shift_JIS にはある文字。バイト列が同じものへ寄せる
    "〜" => "～", # 〜 → ～
    "—" => "―", # — → ―
    # どちらの符号化方式にも無い文字
    '·' => '・',          # U+00B7 中点
    '•' => '・',          # U+2022 ビュレット
    '–' => '-',           # U+2013 en dash
    'º' => 'o',           # U+00BA 序数標識
    'Ø' => 'O',
    'ø' => 'o',
    'ı' => 'i',           # U+0131 ドット無し i
    '⅓' => '1/3',
    '½' => '1/2',
    '¼' => '1/4',
    "​" => '',       # ゼロ幅スペース
    "‎" => '',       # 左横書き制御文字（不可視）
    "‏" => '',
    "﻿" => '',       # BOM
  }.freeze

  def to_shift_jis(text)
    text.encode(ENCODING, fallback: ->(char) { shift_jis_substitute(char) })
  end

  private

  def shift_jis_substitute(char)
    return SUBSTITUTIONS[char] if SUBSTITUTIONS.key?(char)

    # é → e のようにアクセント（結合文字）を落とす。
    # かなの濁点も NFD では分解されるが、この分岐に来るのは CP932 に
    # 変換できなかった文字だけなので日本語には影響しない。
    stripped = char.unicode_normalize(:nfd).gsub(/\p{Mn}/, '')
    return stripped if stripped != char && encodable?(stripped)

    Rails.logger.warn(
      "Yahoo CSV: 変換できない文字を ? に置換しました #{char.inspect} " \
      "(U+#{format('%04X', char.ord)})。ShiftJisHelper::SUBSTITUTIONS への追加を検討してください"
    )
    '?'
  end

  def encodable?(text)
    text.encode(ENCODING)
    true
  rescue Encoding::UndefinedConversionError
    false
  end
end
