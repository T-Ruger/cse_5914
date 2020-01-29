require "json"
require "ibm_watson/authenticators"
require "ibm_watson/assistant_v2"
include IBMWatson

class RoomMessagesController < ApplicationController
  before_action :load_entities

  def create
    @room_message = RoomMessage.create user: current_user,
                                       room: @room,
                                       message: params.dig(:room_message, :message)

   RoomChannel.broadcast_to @room, @room_message
   
   #@watson_message = WatsonMessage.create room: @room,
   #																				message: "test"
   																				
	 #RoomChannel.broadcast_to @room, @watson_message
	 
	 authenticator = Authenticators::IamAuthenticator.new(
  		apikey: @room.apikey
		)
		
		assistant = AssistantV2.new(
  		version: "2019-02-28",
  		authenticator: authenticator
		)
		
		response = assistant.message(
			assistant_id: @room.assistantid,
			session_id: @room.sessionid,
			input: {
				text: @room_message.message
			}
		)
	 
	 @watson_message = RoomMessage.create user: current_user,
	 																						room: @room,
	 																						message: response.result["output"]["generic"][0]["text"]
	 RoomChannel.broadcast_to @room, @watson_message
  end

  protected

  def load_entities
    @room = Room.find params.dig(:room_message, :room_id)
  end
end
