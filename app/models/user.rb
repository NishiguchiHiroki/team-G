class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2, :facebook]

  has_one :address
  has_one :card
  has_many :items
  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :card



  def self.from_omniauth(auth)
    uid = auth.uid
    provider = auth.provider
    snscredential = SnsCredential.where(uid: uid, provider: provider).first
    # require 'byebug'; byebug
    if snscredential.present?
      user = User.where(id: snscredential.user_id).first
    else
      user = User.where(email: auth.info.email).first
      if user.present?
        snscredential = SnsCredential.new(
          uid: uid,
          provider: provider,
          user_id: user.id
        )
      else
        user = User.new(
          nickname: auth.info.name,
          email:    auth.info.email,
          password: Devise.friendly_token[0, 20]
        )
        snscredential = SnsCredential.new(
          uid: uid,
          provider: provider,
          user_id: user.id
        )
      end
    end
    return user
  end


end
