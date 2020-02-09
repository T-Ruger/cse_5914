require "json"
require "ibm_watson/authenticators"
require "ibm_watson/assistant_v2"
include IBMWatson

class RoomMessagesController < ApplicationController
  before_action :load_entities
	after_action :get_response, only: [:create]
	
  def create
    @room_message = RoomMessage.create user: current_user,
                                       room: @room,
                                       watsonmsg: false,
                                       message: params.dig(:room_message, :message)

   RoomChannel.broadcast_to @room, @room_message
	 #get_response
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
				refresh_session
		end
		
		if(!error) then
			interpret_response(response)
		end
  end
  
  def interpret_response(response)
  	puts JSON.pretty_generate(response.result)
  	
  	#parse entities
  	intent = response.result["output"]["intents"][0]["intent"]
  	i = 0
  	found_entities = Hash.new
  	while i < response.result["output"]["entities"].size do
  		entity = response.result["output"]["entities"][i]["entity"]
  		value = response.result["output"]["entities"][i]["value"]
  		confidence = response.result["output"]["entities"][i]["confidence"]
  		
  		
  		#update room entity values
  		if confidence.to_f > found_entities[entity].to_f then
  			found_entities[entity] = confidence.to_f
				puts found_entities[entity]
				case entity
					when "genre"
						if @room.genre == nil || @room.genre == "" || intent == "request_genre" then
							@room.genre = value
						end
					when "director"
						if @room.director == nil || @room.director == "" || intent == "request_director" then
							@room.director = value
						end
					when "time_period"
						if @room.timeperiod == nil || @room.timeperiod == "" || intent == "request_time_period" then
							@room.timeperiod = value
						end
					when "length"
						if @room.length == nil || @room.length == "" || intent == "request_length" then
							@room.length = value
						end
				end
				@room.save
  		end
  		i+=1
  	end
  	
  	@attributes = generate_hash
  		
  	#parse response text, write text response to chat
  	i = 0
  	while i < response.result["output"]["generic"].size do
  		response_text = response.result["output"]["generic"][i]["text"]
  		
  		if response_text != nil then
				@watson_message = RoomMessage.create user: current_user,
		 																						room: @room,
		 																						watsonmsg: true,
		 																						message: response_text
		 		RoomChannel.broadcast_to @room, @watson_message
	 		end
	 		i+=1
  	end
  end
  
  #generate a hash of all current entities and their values
  def generate_hash
  	entity_hash = Hash.new
  	
  	if @room.genre != nil && @room.genre != "" then
  		entity_hash["with_genres"] = @room.genre
  	end
  	
  	if @room.director != nil && @room.director != "" then
  		entity_hash["director"] = @room.director
  	end
  	
  	if @room.length != nil && @room.length != "" then
  		entity_hash["with_runtime.lte"] = @room.length
  	end
  	
  	if @room.timeperiod != nil && @room.timeperiod != "" then
  		case @room.timeperiod
  			when "1900s"
  				entity_hash["primary_release_date.gte"] = "1900-01-01"
  				entity_hash["primary_release_date.lte"] = "1999-12-31"
				when "2000s"
  				entity_hash["primary_release_date.gte"] = "2000-01-01"
				when "2010s"
  				entity_hash["primary_release_date.gte"] = "2010-01-01"
  				entity_hash["primary_release_date.lte"] = "2019-12-31"
				when "2020s"
  				entity_hash["primary_release_date.gte"] = "2020-01-01"
  				entity_hash["primary_release_date.lte"] = "2029-12-31"
				when "30s"
  				entity_hash["primary_release_date.gte"] = "1930-01-01"
  				entity_hash["primary_release_date.lte"] = "1939-12-31"
				when "40s"
  				entity_hash["primary_release_date.gte"] = "1940-01-01"
  				entity_hash["primary_release_date.lte"] = "1949-12-31"
				when "50s"
  				entity_hash["primary_release_date.gte"] = "1950-01-01"
  				entity_hash["primary_release_date.lte"] = "1959-12-31"
				when "60s"
  				entity_hash["primary_release_date.gte"] = "1960-01-01"
  				entity_hash["primary_release_date.lte"] = "1969-12-31"
				when "70s"
  				entity_hash["primary_release_date.gte"] = "1970-01-01"
  				entity_hash["primary_release_date.lte"] = "1979-12-31"
				when "80s"
  				entity_hash["primary_release_date.gte"] = "1980-01-01"
  				entity_hash["primary_release_date.lte"] = "1989-12-31"
				when "90s"
  				entity_hash["primary_release_date.gte"] = "1990-01-01"
  				entity_hash["primary_release_date.lte"] = "1999-12-31"
  		end
  		
  	end
  	
  	puts "\n\n" + entity_hash.to_s + "\n\n"
  	return entity_hash
  end
  
  #get new session id for room if session is expired
  def refresh_session
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
end
