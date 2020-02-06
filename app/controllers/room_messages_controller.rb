require "json"
require "ibm_watson/authenticators"
require "ibm_watson/assistant_v2"
include IBMWatson

class RoomMessagesController < ApplicationController
  before_action :load_entities

  def create
    @room_message = RoomMessage.create user: current_user,
                                       room: @room,
                                       watsonmsg: false,
                                       message: params.dig(:room_message, :message)

   RoomChannel.broadcast_to @room, @room_message
	 get_response
  end

  protected

  def load_entities
    @room = Room.find params.dig(:room_message, :room_id)
  end
  
  #send message text to Watson, get Watson response
  def get_response
		authenticator = Authenticators::IamAuthenticator.new(
  		apikey: @room.apikey
		)
		
		assistant = AssistantV2.new(
  		version: "2019-02-28",
  		authenticator: authenticator
		)
		
		error = false
		begin
			response = assistant.message(
				assistant_id: @room.assistantid,
				session_id: @room.sessionid,
				input: {
					text: @room_message.message
				}
			)
			
			#check if session is expired
			rescue IBMWatson::ApiException => ex
				error = true
				@watson_message = RoomMessage.create user: current_user,
	 																						room: @room,
	 																						watsonmsg: true,
	 																						message: "The session has expired. Starting a new chat."
	 			RoomChannel.broadcast_to @room, @watson_message
				
				authenticator = Authenticators::IamAuthenticator.new(
					apikey: @room.apikey
				)
				assistant = AssistantV2.new(
					version: "2019-02-28",
					authenticator: authenticator
				)
				assistant.service_url = @room.serviceurl	
				response = assistant.create_session(
					assistant_id: @room.assistantid
				)
				@room.sessionid = response.result["session_id"]
				@room.save
				
				@welcome_message = RoomMessage.create user: current_user,
	 																						room: @room,
	 																						watsonmsg: true,
	 																						message: "Welcome to Movie On Rails! How can I help you?"
	 			RoomChannel.broadcast_to @room, @welcome_message
		end
		
		if(!error) then
			interpret_response(response)
		end
  end
  
  def interpret_response(response)
  	puts JSON.pretty_generate(response.result)
  	response_text = response.result["output"]["generic"][0]["text"]
  	
		@watson_message = RoomMessage.create user: current_user,
	 																						room: @room,
	 																						watsonmsg: true,
	 																						message: response_text
	 	RoomChannel.broadcast_to @room, @watson_message
  end
end
