class CreateExpenses < ActiveRecord::Migration[7.0]
  def change
    create_table :expenses do |t|
      t.string :description, null: false
      t.integer :amount, null: false
      t.references :paid_by, null: false, foreign_key: { to_table: :users }, index: true
      t.references :group, null: true, foreign_key: { to_table: :groups }, index: true
      t.timestamps
    end
  end
end
