class ChangeDefaultsOfIsDebtInExpenseSplits < ActiveRecord::Migration[7.0]
  def change
    change_column_default :expense_splits, :is_debt, from: false, to: true
    change_column_null :expense_splits, :is_debt, true
  end
end
