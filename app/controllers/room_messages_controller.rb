require "json"
require "ibm_watson/authenticators"
require "ibm_watson/assistant_v2"
require "ibm_watson/tone_analyzer_v3"
require "ibm_watson/natural_language_understanding_v1"
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
   
   #check if user is currently reviewing a movie or taking quiz. If they are, send message to sentiment analysis and update rating
   if @room.lastIntent == "already_seen" then
   	puts "\n\n\n The message you just sent was a review: " + @room_message.message.to_s + "\n\n\n" #debugging
   	#send @room_message to sentiment analysis
   	#set rating for movie
   	rate_movie
	  
	  #clear lastIntent
	  @room.lastIntent = ""
	  @room.save
   #check if user is answering quiz question
	 elsif @room.lastIntent == "start_quiz" then
	  take_quiz
	  
	  #clear lastIntent
	  @room.lastIntent = ""
	  @room.save
	 #otherwise, get response from watson 
   else
	 	get_response
	 end
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
  	intents = response.result["output"]["intents"]
  	intent = ""
  	#check for irrelevant messages
  	if intents[0] != nil then
  		intent = intents[0]["intent"]
		else
  		@watson_message = RoomMessage.create user: current_user,
		 																						room: @room,
		 																						watsonmsg: true,
		 																						message: "Sorry, I didn't understand that.",
		 																						params: @room.params
			RoomChannel.broadcast_to @room, @watson_message
		end
		
  	i = 0
  	found_entities = Hash.new
  	
  	#set up params JSON
  	params = @room.params
  	params_json = JSON.parse(params)
  	
  	while i < response.result["output"]["entities"].size do
  		entity = response.result["output"]["entities"][i]["entity"]
  		value = response.result["output"]["entities"][i]["value"]
  		
  		#confidence used when watson detects multiple possibilities for entity
  		confidence = response.result["output"]["entities"][i]["confidence"]
  		
  		#update room param values
  		if confidence.to_f > found_entities[entity].to_f then
  			found_entities[entity] = confidence.to_f
				puts found_entities[entity]
				case entity
					when "genre"
						if intent == "request_genre" then
							params_json["with_genres"] = value.to_s
						end
						
					when "sys-person"
						#push to people array or create it
						if intent == "request_person" then
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
						if intent == "request_time_period" then
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
						end
					#before/after date	
					when "sys-date"
						case intent
							when "request_before_year"
								params_json["primary_release_date.lte"] = value.to_s
							when
								params_json["primary_release_date.gte"] = value.to_s
						end	
					end
  		end
  		i+=1
  	end
  	
  	#check for intents without entities
		case intent
			when "sort_popularity_desc"
				params_json["sort_by"] = "popularity.desc"
			when "sort_popularity_asc"
				params_json["sort_by"] = "popularity.asc"
			when "sort_release_desc"
				params_json["sort_by"] = "release_date.desc"
			when "sort_release_asc"
				params_json["sort_by"] = "release_date.asc"
			when "sort_rating_desc"
				params_json["sort_by"] = "vote_average.desc"
			when "sort_rating_asc"
				params_json["sort_by"] = "vote_average.asc"
			when "sort_revenue_desc"
				params_json["sort_by"] = "revenue.desc"
			when "sort_revenue_asc"
				params_json["sort_by"] = "revenue.asc"
			when "request_next_page"
				page = params_json["page"].to_i
				if page == 0 then page = 1 end
				params_json["page"] = (page + 1).to_s
			when "clear_params"
				params_json = "{}"
			else
				
		end
		#replace "=>" with ":" because javascript is dumb
		@room.params = params_json.to_s.gsub("=>", ":")
		@room.save
		
  	@room.lastIntent = intent
  	@room.save
  		
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
					response_text += " with " + params_json["with_people"].to_s
				end
				
				response_text += "."
				return "I recommend these movies."
  end
  
  #get user's opinion on a movie that they've watched
  def rate_movie
  	review = @room_message.message
  	#TODO perform sentiment analysis on review text
		authenticator = Authenticators::IamAuthenticator.new(
			apikey: "ZnDzX8FfmZu92lPaf_ut1kmzir3S66geHAgYheIQvSkH"
		)
		
		natural_language_understanding = NaturalLanguageUnderstandingV1.new(
			version: "2019-07-12",
			authenticator: authenticator
		)

		natural_language_understanding.service_url = "https://api.us-south.natural-language-understanding.watson.cloud.ibm.com/instances/b63a4323-b4d7-412e-8c11-263319d1b818"

		response = natural_language_understanding.analyze(
			text: review,
			features: {
				emotion: {
				  emotion: true,
				  sentiment: true,
				}
			}
		)

		#calculate rating
		emotions = response.result["emotion"]["document"]["emotion"]
		puts JSON.pretty_generate(emotions)
		
		positive = emotions["joy"] * 1.25
		negative = emotions["sadness"] + emotions["disgust"] + emotions["anger"]
		total = positive + negative
		rating = (positive * 10 / total).round(1)
		
  	#TODO update user's rating for movie based on sentiment
  	
  	#set response message
  	response_msg = ""
  	rating_data = ""
  	if(rating >= 8)
  		response_msg = "Sounds like you really loved the movie! "
  		rating_data = "like"
  	elsif(rating >= 6)
  		response_msg = "Sounds like you enjoyed the movie! "
  		rating_data = "like"
  	elsif(rating >= 4)
  		response_msg = "Sounds like you were neutral on this movie. "
  		rating_data = "eh"
  	elsif(rating >= 2)
  		response_msg = "Sounds like you disliked this movie. "
  		rating_data = "dislike"
  	else
  		response_msg = "Sounds like you really disliked this movie. "
  		rating_data = "dislike"
  	end
  	
  	
  	#send response message
  	@watson_message = RoomMessage.create user:current_user,
   																			 room: @room,
   																			 watsonmsg: true,
   																			 message: response_msg + " (" + rating.to_s + "/10). I'll use this for future recommendations.", #replace with message based on rating
   																			 params: @room.params
	RoomChannel.broadcast_to @room, @watson_message
	url = 'https://api.themoviedb.org/3/movie/'+ current_user.movie_id.to_s + '?api_key=305ae312343163e9a891637b00d624c9&language=en-US'
	uri = URI(url)
	response = Net::HTTP.get(uri)
	jsonStr = JSON.parse(response)
    movies = Movie.where(movie_id: current_user.movie_id)
    movie = movies.first
    viewings = Viewing.where(user_id: current_user.id, movie_id: current_user.movie_id)
    viewings.first.rating = rating_data
    viewings.first.save
  end
  
  #take personality quiz
  def take_quiz 
  	quiz_answer = @room_message.message
  	#send quiz answer to language analysis
		authenticator = Authenticators::IamAuthenticator.new(
			apikey: "ZnDzX8FfmZu92lPaf_ut1kmzir3S66geHAgYheIQvSkH"
		)
		
		natural_language_understanding = NaturalLanguageUnderstandingV1.new(
			version: "2019-07-12",
			authenticator: authenticator
		)

		natural_language_understanding.service_url = "https://api.us-south.natural-language-understanding.watson.cloud.ibm.com/instances/b63a4323-b4d7-412e-8c11-263319d1b818"

		response = natural_language_understanding.analyze(
			text: quiz_answer,
			features: {
				emotion: {
				  emotion: true,
				  sentiment: true,
				}
			}
		)
		
		puts response
		#calculate emotional response
		emotions = response.result["emotion"]["document"]["emotion"]
		puts JSON.pretty_generate(emotions)
		
		joy = emotions["joy"]
		sadness = emotions["sadness"]
		disgust = emotions["disgust"]
		anger = emotions["anger"]
		fear = emotions["fear"]
		
		scores = [joy, sadness, disgust, anger, fear]
		max = scores.max()
		genres = []
		emotion_text = "Your response shows mostly "
		
		#select genre
		if anger == max then
			genres = ["action", "crime", "war", "western", "adventure"]
			emotion_text += "anger."
		elsif disgust == max then
			genres = ["horror", "science fiction", "thriller", "biography"]
			emotion_text += "disgust."
		elsif sadness == max then
			genres = ["mystery", "drama", "documentary", "romance", "history"]
			emotion_text += "sadness."
		elsif fear == max
			genres = ["horror", "drama", "thriller", "family"]
			emotion_text += "fear."
		else
			genres = ["adventure",  "comedy", "animation", "fantasy", "music"]
			emotion_text += "joy."
		end 
		
		genre = genres.sample
		runtime = quiz_answer.length + 60
		if (runtime < 90) then
			runtime = 90
		end
		#set parameters
		params_json = JSON.parse(@room.params)
		params_json["with_genres"] = genre
		params_json["with_runtime.lte"] = runtime
		#replace "=>" with ":" because javascript is dumb
		@room.params = params_json.to_s.gsub("=>", ":")
		@room.save
		
=begin
  	#send response message
  	@watson_message = RoomMessage.create user:current_user,
   																			 room: @room,
   																			 watsonmsg: true,
   																			 message: "Genre: " + genre + ". Response length = " + quiz_answer.length.to_s + ". Joy = " + joy.to_s + ", sadness = " + sadness.to_s + ", disgust = " + disgust.to_s + ", anger = " + anger.to_s + ", fear = " + fear.to_s + ".",
   																			 params: @room.params
		RoomChannel.broadcast_to @room, @watson_message
=end

  	#send response message
  	@watson_message = RoomMessage.create user:current_user,
   																			 room: @room,
   																			 watsonmsg: true,
   																			 message: emotion_text + " Searching for " + genre + " movies less than " +runtime.to_s + " minutes long.",
   																			 params: @room.params
		RoomChannel.broadcast_to @room, @watson_message
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
