class Product < ApplicationRecord

	belongs_to :category
	has_many :order_products
	has_many :orders, through: :order_products, :dependent => :destroy


	has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
	validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
	validates :name, presence: true
	validates :price, presence: true
	self.per_page = 5
end
WillPaginate.per_page = 5
