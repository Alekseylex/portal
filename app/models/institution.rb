class Institution < ApplicationRecord
  belongs_to :branch
  has_many   :children_groups
  has_many   :supplier_order_products
  has_many   :receipts
  has_many   :menu_requirements
  has_many   :institution_orders
  has_many   :price_products
  has_many   :timesheets
  has_many   :suppliers_packages
  has_many   :users, as: :userable, source_type: 'Institution'
end
