# frozen_string_literal: true

# TODO: This seems to be no longer used?
class DefaultController < ApplicationController
  include IndexTemplate

  def index
    render file: environment_file('index')
  end
end
