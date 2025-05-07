class AddCreatedByIdAndSpentAtInExpenses < ActiveRecord::Migration[7.0]
  def change
    add_reference :expenses, :created_by, null: false, foreign_key: { to_table: :users }, index: true
    add_column :expenses, :spent_at, :datetime
  end
end
