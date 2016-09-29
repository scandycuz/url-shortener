class ShortenedUrl < ActiveRecord::Base
  validates :long_url, :short_url, presence: true, uniqueness: true

  def self.random_code
    temp_short_url = nil
    until temp_short_url && !ShortenedUrl.exists?(short_url: temp_short_url)
      temp_short_url = SecureRandom::urlsafe_base64
    end

    temp_short_url
  end

  def self.create_for_user_and_long_url!(user, long_url)
    ShortenedUrl.create!(user_id: user.id, long_url: long_url, short_url: self.random_code)
  end

  belongs_to :submitter, {
    primary_key: :id,
    foreign_key: :user_id,
    class_name: :User
  }

  has_many :visits, {
    primary_key: :id,
    foreign_key: :shortened_url_id,
    class_name: :Visit
  }

  has_many :visitors,
    Proc.new { distinct },
    through: :visits,
    source: :user


  def num_clicks
    visits.count
  end

  def num_uniques
    visitors.count
  end

  def num_recent_uniques
    visits.select(:user_id).where("shortened_url_id = :shortened_url_id and created_at > :created_at", shortened_url_id: self.id, created_at: 10.minutes.ago).count
  end

end
