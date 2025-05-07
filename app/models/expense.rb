class Expense < ApplicationRecord
  validates :description, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0, message: 'Amount must be positive' }
  belongs_to :paid_by, class_name: 'User', foreign_key: :paid_by_id
  belongs_to :group, optional: true
  has_many :expense_splits, dependent: :destroy
  belongs_to :created_by, class_name: 'User', foreign_key: :created_by_id
end