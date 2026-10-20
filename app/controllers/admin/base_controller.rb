module Admin
  class BaseController < ApplicationController
    before_action { require_role!(:admin) }
  end
end
