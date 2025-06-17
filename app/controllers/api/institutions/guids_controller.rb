# frozen_string_literal: true

module Api
  module Institutions
    class GuidsController < ApplicationController
      before_action :authenticate_request

      def index
        data = Institution.all.select(:slug, :guid).map { |i| { UID: i.slug, GUID: i.guid } }

        render json: data
      end

      private

      def authenticate_request
        token = extract_bearer_token
        render json: { error: 'Unauthorized' }, status: :unauthorized if token != ENV['LOOKER_STUDIO_EXTERNAL_SECRET']
      end

      def extract_bearer_token
        auth_header = request.headers['Authorization']
        auth_header.split(' ').last if auth_header&.start_with?('Bearer ')
      end
    end
  end
end
