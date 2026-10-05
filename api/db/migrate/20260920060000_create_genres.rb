class CreateGenres < ActiveRecord::Migration[7.0]
  # ジャンルマスタ（docs/06-genre.md）。
  # これまでスプレッドシート（GENRE_SHEET）から CSV 出力のたびに読んでいたものを DB に移す。
  #
  # id は業務側が意味を持たせて付番している（1〜19=Soul/Funk系、101〜117=Jazz、
  # 201〜208=Reggae、2000/3000/4000/5000=その他）。products.genre はこの id を
  # "1_19" のように "_" で連結して保持する。
  #
  # AUTO_INCREMENT は付けない。products.SKU で「未記入の行が毎回新規採番される」
  # 事故が起きたのと同じ構図を避けるため（README の「既知の注意点」参照）。
  def change
    create_table :genres, id: false do |t|
      t.integer :id, null: false
      t.string :main, null: false
      t.string :sub, null: false
      t.string :yahoo_path, null: false
      t.string :tags # スプレッドシート上で8件（Reggae と World Music）が空のため NULL 許可
      t.timestamps
    end

    reversible do |dir|
      dir.up { execute 'ALTER TABLE genres ADD PRIMARY KEY (id)' }
    end
  end
end
