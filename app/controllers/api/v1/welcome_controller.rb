class Api::V1::WelcomeController < ApplicationController
  before_filter :authenticate_user!
  layout 'api'
end