class Book < ApplicationRecord
  enum sales_status: {
      reservation: 0, # 予約受付
      now_on_sale: 1, # 発売中
      end_of_print: 2 # 販売終了
  }

  scope :costly, -> { where("price > ?", 3000) }
  scope :written_about, ->(theme) { where("name like ?", "%#{theme}%") }

  belongs_to :publisher
  has_many :book_authors
  has_many :authors, through: :book_authors

  validates :name, presence: true
  validates :name, length: { maximum: 25 }
  # 数字が5以上であるか
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  # 独自にバリデーションを設定
  validate do |book|
    if book.name.include?("exercise")
      book.errors[:name] << "I don't like exercise."
    end
  end

  # 本の名前に「Cat」が含まれていた場合、「lovely Cat」という文字に置き換えるコールバックを設定
  before_validation do
    self.name = self.name.gsub(/Cat/) do |matched|
      "lovely #{matched}"
    end
  end

  # Bookモデルを削除したとき、削除されたデータの内容をログに書き込むコールバックを設定
  after_destroy do
    Rails.logger.info "Book is deleted: #{self.attributes}"
  end

  # 価格が5,000円以上のBookモデルをdestroyした場合に、警告のログが吐き出されるようにするコールバックを設定
  after_destroy :if => :high_price? do
    Rails.logger.warn "Book with high price is deleted: #{self.attributes}"
    Rails.logger.warn "Please check!!"
  end

  def high_price?
    price >= 5000
  end
end
