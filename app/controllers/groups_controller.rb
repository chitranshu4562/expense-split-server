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

  def fetch_groups
    groups = Group.joins(:users).joins("inner join users AS creators ON creators.id = groups.created_by_id")

    group_id = params[:group_id].presence
    if group_id.present?
      groups = groups.where(id: group_id)
    end

    name = params[:name].presence
    if name.present?
      groups = groups.where("groups.name ILIKE ?", "%#{name}%")
    end

    groups = groups.group("groups.id, groups.name, creators.name")
    groups = groups.select("groups.id, groups.name AS group_name, creators.name AS creator_name,
       json_agg(json_build_object('user_id', users.id, 'user_name', users.name)) AS group_members")
    render json: { data: groups, message: 'Groups is fetched successfully.' }, status: 200
  end

  def remove_users
    group_id = params[:group_id].presence
    raise BadRequest, 'Group ID is required' if group_id.blank?

    user_ids = Array(params[:users]).compact_blank
    raise BadRequest, 'There is no user to remove in group' if user_ids.blank?

    GroupUser.where(group_id: group_id, user_id: user_ids).destroy_all
    render json: { message: 'User is removed successfully.' }, status: :ok
  end

  def delete_group
    group_id = params[:group_id].presence
    raise BadRequest, 'Group ID is required' if group_id.blank?

    group = Group.find_by(id: group_id)
    raise RecordNotFound, 'Group not found' if group.nil?

    group.destroy!
    render json: { message: 'Group is deleted successfully.' }, status: :ok
  end

  def get_group_expense_overview
    group_id = params[:group_id].presence
    raise BadRequest, 'Group ID is required' if group_id.blank?

    group_users = GroupUser.joins(:user).where(group_id: group_id)
    group_users = group_users.joins("LEFT JOIN (SELECT expenses.group_id AS group_id, expenses.paid_by_id AS user_id, SUM(expenses.amount) AS paid_amount from expenses
                            GROUP BY expenses.group_id, expenses.paid_by_id) AS user_paid_amounts ON user_paid_amounts.group_id = group_users.group_id AND user_paid_amounts.user_id = group_users.user_id")

    group_users = group_users.joins("LEFT JOIN (SELECT expenses.group_id AS group_id, expense_splits.user_id AS user_id, SUM(expense_splits.share) AS split_amount FROM expenses INNER JOIN expense_splits ON expense_splits.expense_id = expenses.id
                            GROUP BY expenses.group_id, expense_splits.user_id) AS user_split_amounts ON user_split_amounts.group_id = group_users.group_id AND user_split_amounts.user_id = group_users.user_id")

    group_users = group_users.select("users.id, users.name AS user_name, COALESCE(user_paid_amounts.paid_amount, 0) AS user_paid_amount, COALESCE(user_split_amounts.split_amount, 0) AS user_split_amount")

    overview = []
    group_users.each do |row|
      overview << {
        user_id: row['id'],
        user_name: row['user_name'],
        user_paid_amount: row['user_paid_amount'],
        user_split_amount: row['user_split_amount'],
        user_balance: row['user_paid_amount'] - row['user_split_amount']
      }
    end

    render json: { message: 'Group expense overview fetched successfully', data: overview }, status: :ok
  end
end