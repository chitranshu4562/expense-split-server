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

  def update_personal_expense
    expense_id = params[:expense_id].presence
    raise BadRequest, 'Expense id cannot be blank' if expense_id.blank?

    expense = Expense.find_by(id: expense_id)
    raise RecordNotFound, 'Expense not found' if expense.nil?

    description = params[:description].presence

    amount = params[:amount].presence

    spent_at = params[:spent_at].presence
    spent_at = Time.current if spent_at.blank?

    expense.description = description if description.present?
    expense.amount = amount if amount.present?
    expense.spent_at = spent_at if spent_at.present?
    expense.save!
    render json: { success: true, data: expense, message: 'Expense updated!' }, status: 200
  end

  def delete_personal_expense
    expense_id = params[:expense_id].presence
    raise BadRequest, 'Expense id cannot be blank' if expense_id.blank?

    expense = Expense.find_by(id: expense_id)
    raise RecordNotFound, 'Expense not found' if expense.nil?

    expense.destroy!
    render json: { success: true, message: 'Expense deleted!' }, status: 200
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

    unless group.is_member?(paid_by.id)
      raise BadRequest, 'User(who paid bill) is not a member of group'
    end

    unless group.is_member?(current_user.id)
      raise BadRequest, 'You are not a member of group'
    end

    users_split_amount = Array(params[:users_split_amount]).compact_blank
    raise BadRequest, 'Split data cannot be blank' if users_split_amount.blank?

    users_split_amount.each do |split|
      unless group.is_member?(split[:user_id])
        raise BadRequest, "User(#{split[:user_id]}) is not a member of group"
      end
    end

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

  def update_group_expense
    expense_id = params[:expense_id].presence
    raise BadRequest, 'Expense id cannot be blank' if expense_id.blank?

    expense = Expense.find_by(id: expense_id)
    raise RecordNotFound, 'Expense not found' if expense.nil?

    description = params[:description].presence

    amount = params[:amount].presence

    spent_at = params[:spent_at].presence
    spent_at = Time.current if spent_at.blank?

    group_id = params[:group_id].presence
    raise BadRequest, 'Group cannot be blank' if group_id.blank?

    group = Group.find_by(id: group_id)
    raise RecordNotFound, 'Group not found' if group.nil?

    paid_by_id = params[:paid_by_id].presence

    paid_by = User.find_by(id: paid_by_id) if paid_by_id.present?

    if paid_by.present?
      raise BadRequest, 'User(who paid bill) is not a member of group' unless group.is_member?(paid_by.id)
    end

    expense.description = description if description.present?
    expense.amount = amount if amount.present?
    expense.spent_at = spent_at if spent_at.present?
    expense.paid_by = paid_by if paid_by.present?
    expense.save!

    users_split_amount = Array(params[:users_split_amount]).compact_blank

    if users_split_amount.any?
      users_split_amount.each do |split|
        unless group.is_member?(split[:user_id])
          raise BadRequest, "User(#{split[:user_id]}) is not a member of group"
        end
      end

      total_split_amount = users_split_amount.sum { |split| split[:share] }
      unless amount == total_split_amount
        raise BadRequest, 'Total split amount is not equal to expenses amount'
      end

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
    end

    render json: { success: true, message: 'Expense Split updated!' }, status: 200
  end


  def get_group_expense_details
    group_id = params[:group_id].presence
    raise BadRequest, 'Group id cannot be blank' if group_id.blank?

    group = Group.find_by(id: group_id)
    raise RecordNotFound, 'Group not found' if group.nil?

    expense_id = params[:expense_id].presence
    raise BadRequest, 'Expense id cannot be blank' if expense_id.blank?

    expenses = Expense.joins(expense_splits: :user)
    expenses = expenses.joins("INNER JOIN users AS creators ON creators.id = expenses.created_by_id")
    expenses = expenses.joins("INNER JOIN users AS spenders ON spenders.id = expenses.paid_by_id")
    expenses = expenses.where(group_id: group_id, id: expense_id)

    expenses = expenses.group("expenses.id, expenses.description, expenses.amount, spenders.name, creators.name, expenses.spent_at")
    expenses = expenses.select("expenses.id, expenses.description, expenses.amount, spenders.name AS spender_name, creators.name AS creator_name, expenses.spent_at,
       json_agg(json_build_object('user_id', users.id, 'user_name', users.name, 'share', expense_splits.share)) AS split_data")

    render json: { message: 'Expense details fetched successfully', data: expenses }, status: :ok
  end
  def delete_group_expense
    expense_id = params[:expense_id].presence
    raise BadRequest, 'Expense id cannot be blank' if expense_id.blank?

    expense = Expense.find_by(id: expense_id)
    raise RecordNotFound, 'Expense not found' if expense.nil?

    expense.destroy!
    render json: { success: true, message: 'Expense Split deleted!' }, status: 200
  end
end