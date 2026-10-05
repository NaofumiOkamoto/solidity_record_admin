# ジャンルマスタの状態を点検する（docs/06-genre.md）。
#
# 2026-09-28 にスプレッドシートからの取り込みタスク（genres:import / genres:verify）は
# 廃止した。出力先ごとの設定（mercari_keywords / ebay_category と、意味を広げた yahoo_path）
# がシートに存在せず、シートからは復元できなくなったため。
# 初期データは AddPlatformSettingsToGenres マイグレーションが持っており、
# `rails db:migrate` だけで genres が完成する。
namespace :genres do
  desc 'ジャンルマスタの状態を点検する（本番反映後の確認用）'
  task check: :environment do
    errors = []   # 移行が失敗している。直すまで使えない
    warnings = [] # データ品質の問題。出力は動くが確認したほうがよい

    puts "件数: #{Genre.count}件"

    required = { main: 'main', sub: 'sub', yahoo_path: 'yahoo_path', mercari_keywords: 'mercari_keywords' }
    required.each do |column, label|
      blank = Genre.where(column => [nil, '']).pluck(:id)
      errors << "#{label} が空: id=#{blank.join(', ')}" if blank.any?
    end

    # 商品が参照しているのにマスタに無い id
    master = Genre.pluck(:id).to_set
    used = Hash.new(0)
    Product.where.not(genre: [nil, '']).pluck(:genre).each do |value|
      value.to_s.split('_').each { |id| used[id.to_i] += 1 if id.match?(/\A\d+\z/) }
    end
    orphans = used.reject { |id, _| master.include?(id) }
    if orphans.any?
      # CSV 出力は存在しない id を読み飛ばすため落ちないが、該当商品のジャンルが欠落する
      warnings << "商品が参照しているがマスタに無い id: #{orphans.inspect}"
    end

    # どの商品からも使われていないジャンル（異常ではないが把握しておく）
    unused = master.reject { |id| used.key?(id) }
    puts "どの商品からも使われていないジャンル: #{unused.size}件 #{unused.sort.inspect}" if unused.any?

    puts "--- 出力サンプル（id 昇順の先頭3件）---"
    Genre.order(:id).limit(3).each do |genre|
      puts "  id=#{genre.id} #{genre.main} / #{genre.sub}"
      puts "    yahoo      : #{genre.yahoo_path.split("\n").map { |c| "LP:#{c}" }.join(' , ')}"
      puts "    mercari    : #{genre.mercari_keywords}"
      puts "    ebay       : #{genre.ebay_category.presence || '(未設定)'}"
      puts "    shopify tag: #{genre.tags.presence || '(未設定)'}"
    end

    if warnings.any?
      puts '--- 警告（移行とは別のデータ品質の問題）---'
      warnings.each { |message| puts "  #{message}" }
    end

    if errors.any?
      puts '--- エラー ---'
      errors.each { |message| puts "  #{message}" }
      abort '点検に失敗しました'
    end

    puts warnings.any? ? '移行は正常。上記の警告は別途対応' : '問題なし'
  end
end
