class WatsonMessage < ApplicationRecord
	belongs_to :room, inverse_of: :watson_messages
	
	def as_json(options)
    super(options).merge(user_avatar_url: user.gravatar_url)
  end
end
