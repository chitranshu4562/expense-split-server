class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true, uniqueness: true
  has_many :user_tokens, dependent: :destroy
  has_many :group_users, dependent: :destroy
  has_many :groups, through: :group_users
  has_many :created_groups, class_name: 'Group', foreign_key: :created_by_id
  has_many :expenses, class_name: 'Expense', foreign_key: :paid_by_id, dependent: :destroy
  has_many :expense_splits, through: :expenses
  has_many :created_expense, class_name: 'Expense', foreign_key: :created_by_id, dependent: :destroy

  def create_user_token(jti)
    self.user_tokens.create!(user_id: self.id, jti: jti)
  end
end