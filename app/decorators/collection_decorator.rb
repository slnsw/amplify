class CollectionDecorator < ApplicationDecorator
  delegate_all

  def transcript_items
    object.transcripts.size
  end

  def path
    "/#{institution.slug}/#{uid}"
  end
end
