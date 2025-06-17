# frozen_string_literal: true

class DefaultController < ApplicationController
  include IndexTemplate

  def index
    render file: environment_index_file
  end
end
