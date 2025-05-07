class GroupsController < ApplicationController
  def create
    name = params[:name].presence
    raise BadRequest, 'Group name is required' if name.blank?

    user_ids = Array(params[:users]).compact_blank
    user_ids << current_user.id
    raise BadRequest, 'There is no user to add in group' if user_ids.blank?

    group = Group.find_or_create_by(name: name, created_by_id: current_user.id)

    user_ids.each do |user_id|
      group.add_user(user_id)
    end
    render json: { message: 'Group is created successfully.' }, status: 201
  end

  def remove_users
    group_id = params[:group_id].presence
    raise BadRequest, 'Group ID is required' if group_id.blank?

    user_ids = Array(params[:users]).compact_blank
    raise BadRequest, 'There is no user to remove in group' if user_ids.blank?

    GroupUser.where(group_id: group_id, user_id: user_ids).destroy_all
    render json: { message: 'User is removed successfully.' }, status: :ok
  end

  def get_group_expense_overview
    group_expenses = Group.joins(:users).joins(expenses: :expense_splits)

    group_id = params[:group_id].presence
    if group_id.present?
      group_expenses = group_expenses.where(id: group_id)
    end

    group_expenses = group_expenses.group("users.id, users.name")
    group_expenses = group_expenses.select("users.id AS user_id, users.name AS user_name,
       SUM(CASE WHEN expenses.paid_by_id = users.id THEN expenses.amount ELSE 0 END) AS paid_amount, SUM(expense_splits.share) AS split_share")
    group_expenses = group_expenses.order("users.name")

    user_wise_group_expense_data = []
    group_expenses.each do |expense|
      user_wise_group_expense_data << {
        user_id: expense.user_id,
        user_name: expense.user_name,
        user_amount: expense.paid_amount - expense.split_share
      }
    end

    render json: { data: user_wise_group_expense_data, message: 'Data fetched successfully.' }, status: 200
  end
end