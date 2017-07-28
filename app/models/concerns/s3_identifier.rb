module S3Identifier
  def s3_collection_uid
    model.is_a?(Collection) ? model.uid : model.collection.uid
  end
end
