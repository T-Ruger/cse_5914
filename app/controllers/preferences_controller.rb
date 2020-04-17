class PreferencesController < ApplicationController
  def show
    render template: "pages/#{params[:page]}"
  end
  def submit
	current_user.lang = params['lang_sel']
	current_user.max_len = params['max_len']
	current_user.adult = params['adult_sel']
	current_user.sort = params['sort_sel']
	current_user.eyear = params['early_year']
	current_user.save
  end
  def clear
  	current_user.lang = nil
	current_user.max_len = nil
	current_user.adult = nil
	current_user.sort = nil
	current_user.eyear = nil
	current_user.save
	redirect_to('/home')
  end
end
