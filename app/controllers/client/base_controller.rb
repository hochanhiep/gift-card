module Client
  class BaseController < ApplicationController
    before_action { require_role!(:client) }
  end
end
