class Session < ApplicationRecord
  scoped_to_organization through: :user

  belongs_to :user
end
