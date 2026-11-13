require 'csv'

class CreateDescriptionTemplates < ActiveRecord::Migration[7.0]
  # 説明文の定型文マスタ（docs/07-description-template.md）。
  # 商品詳細（03）の「定型文から選ぶ…」で、record / cover の説明文（日本語・英語）を組み立てるのに使う。
  #
  # 商品の説明文には定型文の id ではなく文そのものを入れる。そのため定型文を編集・削除しても
  # 既存の商品の説明文は変わらない（参照チェックも要らない）。
  #
  # A面・B面・両面だけが違う文は1件にまとめる。jp の {面} を A面 / B面 / 両面 に置き換え、
  # 英語は片面なら en の {side} を A side / B side に、両面なら en_both をそのまま使う
  # （両面は「both side labels」「both sides」のように複数形になり、置き換えでは作れないため）。
  #
  # 初期データは db/data/description_templates.csv（247件）。商品スプレッドシートの Master タブ（盤の説明文）と
  # Master2 タブ（ジャケットの説明文）から、2回以上使われた文を抜き出して分類したもの（2026-11-10）。
  # - 説明文を「。」で文に分け、和文と英文の文の数が同じ行で1文ずつ組にし、英訳は一番多いものを採った（打ち間違いを除くため）
  # - A面・B面・両面だけが違う文は {面} にまとめた。両面でしか使われていない文、1文に面が2回出る文はまとめていない
  # - 英訳が取れなかった十数件は、既存の英文の言い回しに合わせて開発側で作った
  # 中身はクライアントが画面から直す前提。
  SEED_CSV = Rails.root.join('db/data/description_templates.csv')

  def change
    create_table :description_templates do |t|
      t.string :target, null: false # record（盤）か cover（ジャケット）
      t.string :category, null: false # モーダルでの見出し
      t.text :jp, null: false
      t.text :en, null: false # jp に {面} があるときは片面用（{side} を含む）
      t.text :en_both # 両面用の英語。jp に {面} があるときだけ使う
      t.string :note # 定型文を選ぶときの目安。モーダルに出るが説明文には入らない
      # 並び順。モーダルでの表示順で、説明文に並べる順にもなる
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :description_templates, %i[target position]

    reversible do |dir|
      dir.up do
        now = Time.current
        rows = CSV.read(SEED_CSV, headers: true).map do |row|
          [row['target'], row['category'], row['jp'], row['en'], row['en_both'].presence, row['position'].to_i, now, now]
        end
        execute <<~SQL
          INSERT INTO description_templates (target, category, jp, en, en_both, position, created_at, updated_at)
          VALUES #{rows.map { |row| "(#{row.map { |value| connection.quote(value) }.join(', ')})" }.join(', ')}
        SQL
      end
    end
  end
end
