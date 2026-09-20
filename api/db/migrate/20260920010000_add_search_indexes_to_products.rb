class AddSearchIndexesToProducts < ActiveRecord::Migration[7.0]
  # 商品一覧・検索（docs/02-product-list.md）とダッシュボードの集計で使うインデックス。
  # 部分一致（LIKE '%...%'）には効かないが、範囲・完全一致の条件には効く。
  def change
    add_index :products, :registration_date
    add_index :products, :sold_date
    add_index :products, :sales_status
    add_index :products, :sold_site
    add_index :products, :discogs_release_id
  end
end
