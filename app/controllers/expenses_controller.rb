class ExpensesController < ApplicationController
  def add_personal_expense
    description = params[:description].presence
    raise BadRequest, 'Description cannot be blank' if description.blank?

    amount = params[:amount].presence
    raise BadRequest, 'Amount cannot be blank' if amount.blank?

    spent_at = params[:spent_at].presence
    spent_at = Time.current if spent_at.blank?

    Expense.create!(amount: amount, description: description, spent_at: spent_at, paid_by_id: current_user.id, created_by_id: current_user.id)
    render json: { message: 'Expense added!' }, status: 200
  end

  def add_group_expense
    description = params[:description].presence
    raise BadRequest, 'Description cannot be blank' if description.blank?

    amount = params[:amount].presence
    raise BadRequest, 'Amount cannot be blank' if amount.blank?

    spent_at = params[:spent_at].presence
    spent_at = Time.current if spent_at.blank?

    group_id = params[:group_id].presence
    raise BadRequest, 'Group cannot be blank' if group_id.blank?

    group = Group.find_by(id: group_id)
    raise RecordNotFound, 'Group not found' if group.nil?

    paid_by_id = params[:paid_by_id].presence
    raise BadRequest, 'Paid by id is blank' if paid_by_id.blank?

    paid_by = User.find_by(id: paid_by_id)
    raise RecordNotFound, 'User(who paid bill) not found' if paid_by.nil?

    unless group.is_member?(paid_by)
      raise BadRequest, 'User(who paid bill) is not a member of group'
    end

    unless group.is_member?(current_user)
      raise BadRequest, 'You are not a member of group'
    end

    users_split_amount = Array(params[:users_split_amount]).compact_blank
    raise BadRequest, 'Split data cannot be blank' if users_split_amount.blank?

    total_split_amount = users_split_amount.sum { |split| split[:share] }
    unless amount == total_split_amount
      raise BadRequest, 'Total split amount is not equal to expenses amount'
    end

    expense = Expense.create!(description:, amount:, paid_by_id:, group_id:, created_by_id: current_user.id, spent_at:)

    expense_splits = users_split_amount.map do |split|
      {
        expense_id: expense.id,
        user_id: split[:user_id],
        share: split[:share],
        is_debt: true,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    ExpenseSplit.insert_all(expense_splits)
    render json: { message: 'Expense Split added!' }, status: 200
  end
end