class ExpenseHistoryController < ApplicationController
  def personal_expense_history
    expenses = Expense
    expenses = expenses.joins("INNER JOIN users AS spenders ON spenders.id = expenses.paid_by_id")
    expenses = expenses.where(paid_by_id: current_user.id, created_by_id: current_user.id)

    amount = params[:amount].presence
    if amount.present?
      expenses = expenses.where(amount: amount)
    end

    descriptions = params[:description].presence
    if descriptions.present?
      expenses = expenses.where("expenses.description ILIKE ?", "%#{descriptions}%")
    end

    expenses = expenses.select("expenses.*, spenders.name AS spender_name")

    render json: { success: true, data: expenses, message: 'Expense history fetched successfully' }, status: :ok
  end

  def group_expense_history
    expenses = Expense.joins(:group)
    expenses = expenses.joins("INNER JOIN users AS spenders ON spenders.id = expenses.paid_by_id")
    expenses = expenses.joins("INNER JOIN users AS creators ON creators.id = expenses.created_by_id")

    group_id = params[:group_id].presence
    if group_id.present?
      expenses = expenses.where(group_id: group_id)
    end

    amount = params[:amount].presence
    if amount.present?
      expenses = expenses.where(amount: amount)
    end

    descriptions = params[:description].presence
    if descriptions.present?
      expenses = expenses.where("expenses.description ILIKE ?", "%#{descriptions}%")
    end

    limit = params[:limit].present? ? params[:limit] : 10
    offset = params[:offset].present? ? params[:offset] : 0

    expenses = expenses.select("expenses.id AS id, expenses.description AS expense_description, expenses.group_id AS group_id,
       expenses.amount AS expense_amount, spenders.id AS spender_id, spenders.name AS spender_name, creators.id AS creator_id, creators.name AS creator_name")
    expenses = expenses.order("expenses.id DESC")

    total_count = expenses.length
    expenses = expenses.limit(limit).offset(offset)
    render json: { success: true, data: expenses, total_count: total_count, message: 'Expense history fetched successfully' }, status: :ok
  end
end