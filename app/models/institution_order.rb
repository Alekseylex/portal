class InstitutionOrder < ApplicationRecord
  #
  belongs_to :institution

  has_many :io_corrections, dependent: :destroy

  has_many :institution_order_products,
     -> { select( :id, :institution_order_id, :product_id, :date, :count, :description, :code, :name )
            .joins( :product ) },
    dependent: :destroy
  #
  before_save :set_default_value

  def set_default_value
    institution = Institution.find( institution_id )
    institution_order = InstitutionOrder.select( :number ).where( institution: institution ).last
    prefix_length = institution.prefix.strip.length;

    if institution_order
      number = institution_order.number[prefix_length +1..-1 ].to_i + 1
    else
      number = 1
    end

    self.number ||= "#{ institution.prefix }-#{ number.to_s.rjust(InstitutionOrder.columns_hash["number"].limit-1-prefix_length, '0' ) }"
    self.date ||= self.date_start ||=  self.date_end ||= Date.today
  end
end