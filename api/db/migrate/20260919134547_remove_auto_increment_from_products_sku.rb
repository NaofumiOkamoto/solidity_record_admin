class RemoveAutoIncrementFromProductsSku < ActiveRecord::Migration[7.0]
  # SKU はスプレッドシート側で採番する業務上の値なので AUTO_INCREMENT は不要。
  # 有効なままだと SKU が NULL の行が upsert されずに採番され、
  # CSV出力のたびに別レコードとして増え続けてしまう。
  # 撤去すると NULL の INSERT がエラーになるため、不正データが黙って入らなくなる。
  def up
    execute 'ALTER TABLE products MODIFY SKU int NOT NULL'
  end

  def down
    execute 'ALTER TABLE products MODIFY SKU int NOT NULL AUTO_INCREMENT'
  end
end
