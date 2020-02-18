require "json"
require "ibm_watson/authenticators"
require "ibm_watson/assistant_v2"
include IBMWatson

class RoomMessagesController < ApplicationController
  before_action :load_entities, only: [:create]
	#after_action :get_response, only: [:create]
	#after_action :update_list, only: [:get_response]
	
  def create
    @room_message = RoomMessage.create user: current_user,
                                       room: @room,
                                       watsonmsg: false,
                                       message: params.dig(:room_message, :message),
                                       params: @room.params

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
				refresh_session
		end
		
		interpret_response(response) if !error
  end
  
  def interpret_response(response)
  	puts JSON.pretty_generate(response.result)
  	
  	#parse entities
  	intent = response.result["output"]["intents"][0]["intent"]
  	i = 0
  	found_entities = Hash.new
  	
  	#set up params JSON
  	params = @room.params
  	params_json = JSON.parse(params)
  	
  	while i < response.result["output"]["entities"].size do
  		entity = response.result["output"]["entities"][i]["entity"]
  		value = response.result["output"]["entities"][i]["value"]
  		confidence = response.result["output"]["entities"][i]["confidence"]
  		
  		#update room param values
  		if confidence.to_f > found_entities[entity].to_f then
  			found_entities[entity] = confidence.to_f
				puts found_entities[entity]
				case entity
					when "genre"
						if params_json["with_genres"] == nil || params_json["with_genres"] == "" || intent == "request_genre" then
							params_json["with_genres"] = value.to_s
						end
						
					when "person"
						#push to people array or create it
						if params_json["with_people"] == nil || params_json["with_people"] == "" || intent == "request_person" then
							people = params_json["with_people"]
							if people == nil || people == "" then
								people = Array.new
							end
							
							people.push(value.to_s)
							params_json["with_people"] = people
							puts "\n\n" + people.to_s + "\n\n"
						end
						
					when "time_period"
						#set time period
						case value.to_s
							when "1900s"
								params_json["primary_release_date.gte"] = "1900-01-01"
								params_json["primary_release_date.lte"] = "1999-12-31"
							when "2000s"
								params_json["primary_release_date.gte"] = "2000-01-01"
							when "2010s"
								params_json["primary_release_date.gte"] = "2010-01-01"
								params_json["primary_release_date.lte"] = "2019-12-31"
							when "2020s"
								params_json["primary_release_date.gte"] = "2020-01-01"
								params_json["primary_release_date.lte"] = "2029-12-31"
							when "30s"
								params_json["primary_release_date.gte"] = "1930-01-01"
								params_json["primary_release_date.lte"] = "1939-12-31"
							when "40s"
								params_json["primary_release_date.gte"] = "1940-01-01"
								params_json["primary_release_date.lte"] = "1949-12-31"
							when "50s"
								params_json["primary_release_date.gte"] = "1950-01-01"
								params_json["primary_release_date.lte"] = "1959-12-31"
							when "60s"
								params_json["primary_release_date.gte"] = "1960-01-01"
								params_json["primary_release_date.lte"] = "1969-12-31"
							when "70s"
								params_json["primary_release_date.gte"] = "1970-01-01"
								params_json["primary_release_date.lte"] = "1979-12-31"
							when "80s"
								params_json["primary_release_date.gte"] = "1980-01-01"
								params_json["primary_release_date.lte"] = "1989-12-31"
							when "90s"
								params_json["primary_release_date.gte"] = "1990-01-01"
								params_json["primary_release_date.lte"] = "1999-12-31"
						end
					when "length"
						
				end
				#replace "=>" with ":" because javascript is dumb
				@room.params = params_json.to_s.gsub("=>", ":")
				@room.save
  		end
  		i+=1
  	end
  		
  	#parse response text, write text response to chat
  	i = 0
  	while i < response.result["output"]["generic"].size do
  		response_text = response.result["output"]["generic"][i]["text"]
  		
  		#construct recommendation message
  		if response_text.include? "Here's" then
  			response_text = construct_recommendation_msg
  		end
  		
  		#broadcast watson responses
  		if response_text != nil && response_text != "" then
				@watson_message = RoomMessage.create user: current_user,
		 																						room: @room,
		 																						watsonmsg: true,
		 																						message: response_text,
		 																						params: @room.params
		 		RoomChannel.broadcast_to @room, @watson_message
	 		end
	 		i+=1
  	end
  end
  
  #construct recommendation message
  def construct_recommendation_msg
  	params_json = JSON.parse(@room.params)
  	response_text = "I recommend this "
  			if params_json["with_runtime.lte"] != nil && params_json["with_runtime.lte"] != "" then
  				response_text += params_json["with_runtime.lte"].to_s + " "
  			end
  			
  			if params_json["with_genres"] != nil && params_json["with_genres"] != "" then
  				response_text += params_json["with_genres"].to_s + " "
				end
				
				response_text += "movie"
				
				if params_json["with_people"] != nil && params_json["with_people"] != "" then
					response_text += " with " + params_json["with_people"]
				end
				
				response_text += "."
				return "I recommend these movies."
  end
  
  #get new session id for room if session is expired
  def refresh_session
  	@watson_message = RoomMessage.create user: current_user,
	 																						room: @room,
	 																						watsonmsg: true,
	 																						message: "The session has expired. Starting a new chat.",
	 																						params: @room.params
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
																					message: "Welcome to Movie On Rails! How can I help you?",
																					params: @room.params
		RoomChannel.broadcast_to @room, @welcome_message
  end
end
