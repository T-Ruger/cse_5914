require "json"
require "ibm_watson/authenticators"
require "ibm_watson/assistant_v2"
include IBMWatson

class RoomsController < ApplicationController
  # Loads:
  # @rooms = all rooms
  # @room = current room when applicable
  before_action :load_entities

  def index
    @rooms = Room.all
  end

  def new
    @room = Room.new
  end

  def create
  	#watson session setup
    @room = Room.new permitted_parameters
		@room.apikey = "tR-_ntZkOUpqFIKbGjJae69dqCWOOQ8wKCQaCuaDASiA"
		@room.assistantid = "b6d443ee-862a-4377-9f66-959b144757d2"
		@room.serviceurl = "https://api.us-south.assistant.watson.cloud.ibm.com/instances/f965de9f-b2e3-4673-90ca-598d335efba8"
		@welcome_message_text = "Welcome to Movie On Rails! How can I help you?"
				
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
		
		#send welcome message when room is created
		@welcome_message = RoomMessage.create user: current_user,
	 																						room: @room,
	 																						watsonmsg: true,
	 																						message: @welcome_message_text
	 	RoomChannel.broadcast_to @room, @welcome_message
		
    if @room.save
      flash[:success] = "Room #{@room.name} was created successfully"
      redirect_to(@room)
    else
      render :new
    end
  end

  def show
    @room_message = RoomMessage.new room: @room
    @room_messages = @room.room_messages.includes(:user)
  end

  def edit
  end

  def update
    if @room.update_attributes(permitted_parameters)
      flash[:success] = "Room #{@room.name} was updated successfully"
      redirect_to action:"show"
    else
      render :new
    end
  end

  protected

  def load_entities
    @rooms = Room.all
    @room = Room.find(params[:id]) if params[:id]
  end

  def permitted_parameters
    #params.require(:room).permit(:name)
  end
end
