# frozen_string_literal: true

module PageHelper
  def themes_checked?(box)
    return unless @build_params[:themes].is_a? Array

    @build_params[:themes].include?(box.object.name.to_s)
  end

  def collection_checked?(box)
    return unless @build_params[:collections].is_a? Array

    @build_params[:collections].include?(box.object.title.to_s)
  end

  def search_themes_checked?(box)
    return unless params.dig(:data, :theme).is_a? Array

    params.dig(:data, :theme).include?(box.object.name.to_s)
  end

  def search_collection_checked?(box)
    return unless params.dig(:data, :collection_id).is_a? Array

    params.dig(:data, :collection_id).include?(box.object.id.to_s)
  end
end
