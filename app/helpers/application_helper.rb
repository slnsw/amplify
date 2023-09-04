module ApplicationHelper
  def project_name; end

  def project_description; end

  def data_title_template; end

  # Generates paths for Gulp assets with optional minification.
  def gulp_asset(asset_type, asset_name, minified = false)
    if minified
      fn = gulp_asset_plain(asset_type, asset_name, ".min")
      return fn if fn.length > 0
    end
    gulp_asset_plain(asset_type, asset_name)
  end

  # Generates paths for Gulp assets.
  # Cached to ensure it stays around.
  def gulp_asset_plain(asset_type, asset_name, suffix = "")
    Rails.cache.fetch("gulp_asset_plain:#{asset_type}:#{asset_name}:#{suffix}", expires_in: 12.hours) do
      globbed = Dir.glob(
        Rails.root.join('public', 'assets', asset_type, "#{asset_name}*#{suffix}.#{asset_type}")
      ).sort_by(&:length)
      first = globbed.first
      return "" if first.nil?
      first.gsub(Rails.root.join('public').to_s, "")
    end
  end

  def staging?
    Rails.env.staging?
  end

  def current_user_edits
    return unless current_user
    number = number_to_human(current_user.total_edits, format: "%n%u", units: { thousand: "K+" })
    content_tag :span, number, class: "select-active__admin-score"
  end

  def time_display(start_time)
    time = Time.at((start_time / 1000)).utc.strftime("%M:%S")
    time
  end

  def show_theme?
    @app_config.try(:show_theme?)
  end

  def show_institutions?
    @app_config.try(:show_institutions?)
  end

  def gtm_id
    ENV["GOOGLE_TAG_MANAGER_ID"] if ENV.key?("GOOGLE_TAG_MANAGER_ID")
  end

  # NOTE: format we need
  #       if the title is empty -> 'Amplify'
  #       if the title is not empty -> '<title> | Amplify'
  def page_title
    title = "Amplify"
    title.prepend("#{@page_title} | ") if @page_title
    title
  end

  # FIXME: this needs to be changed to the current time format
  def display_time(secs)
    [[60, :s], [60, :m], [9999, :h]].map do |count, name|
      if secs > 0
        secs, n = secs.divmod(count)

        "#{n.to_i}#{name}" unless n.to_i == 0
      end
    end.compact.reverse.join(' ')
  end

  def footer_link(link)
    return if link.title.blank? || link.url.blank?

    link_to link.title, link.url, target: :_blank
  end

  def conditional_separator(collection, index)
    return unless collection[index + 1] # in case it's the last element

    "/" if display_separator?(collection, index)
  end

  def display_separator?(collection, index)
    (presence_of(collection[index]) && future_element(collection, index + 1))
  end

  def presence_of(element)
    element&.title&.present? && element&.url&.present?
  end

  def future_element(collection, next_index)
    last_index = collection.size - 1

    (next_index..last_index).map do |i|
      presence_of(collection[i])
    end.any?
  end

  def oauth_url(p)
    "/users#{p['path']}?state=#{@transcript.try(:uid)}"
  end

  def site_alerts
    SiteAlert.where(published: true)
  end
end
