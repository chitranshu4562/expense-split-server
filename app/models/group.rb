class Group < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :group_users, dependent: :destroy
  has_many :users, through: :group_users
  belongs_to :creator, class_name: 'User', foreign_key: :created_by_id
  has_many :expenses, dependent: :destroy


  def add_user(user_id)
    group_users.find_or_create_by(user_id: user_id)
  end

  def is_member?(user)
    group_users.exists?(user_id: user.id)
  end
end