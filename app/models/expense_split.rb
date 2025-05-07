class ExpenseSplit < ApplicationRecord
  belongs_to :expense
  belongs_to :user

  def share
    raw_value = read_attribute(:share)
    return unless raw_value

    BigDecimal(raw_value.to_s('F'))
  end

  def as_json(options = {})
    super(options).tap do |h|
      # Override the "share" key in the hash
      h['share'] = share.to_s('F')
    end
  end

  private
  def round_share_to_two_decimal
    return if share.blank?

    big_decimal_value = share.is_a?(BigDecimal) ? share : BigDecimal(share.to_s)
    write_attribute(:share, big_decimal_value)
  end
end