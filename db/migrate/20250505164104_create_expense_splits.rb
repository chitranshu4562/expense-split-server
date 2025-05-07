class CreateExpenseSplits < ActiveRecord::Migration[7.0]
  def change
    create_table :expense_splits do |t|
      t.references :expense, null: false, foreign_key: true, index: true
      t.references :user, null: false, foreign_key: true, index: true
      t.decimal :share, null: false, precision: 10, scale: 2
      t.boolean :is_debt, null: false, default: false
      t.timestamps
      t.index [:expense_id, :user_id], unique: true
    end
  end
end
