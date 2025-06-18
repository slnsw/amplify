class Pua
  def initialize(_options = {})
    @client = _getClient
  end

  def createAudioFile(transcript, pua_item)
    # add an Audio File
    unless transcript[:audio_url].empty?
      @client.create_audio_file(pua_item, {
                                  remote_file_url: transcript[:audio_url],
                                })
      # update status to audio-uploaded
      transcript_status = TranscriptStatus.find_by(name: "audio_uploaded")
      transcript.update(transcript_status_id: transcript_status[:id])
      puts "Uploaded audio file #{transcript[:audio_url]} to Pop Up Archive"
    end
  end

  def createCollection(collection)
    resp = post("/collections", {
                  title: collection[:title],
                  description: collection[:description],
                  items_visible_by_default: false,
                })
    collection.update(vendor_identifier: resp["id"])
    collection
  end

  def createItem(transcript)
    # get collection
    collection = @client.get_collection(transcript.collection[:vendor_identifier])
    item = nil

    # create a new Pop Up Archive item if identifier does not exist
    if transcript[:vendor_identifier].empty?
      item = @client.create_item(collection, {
                                   title: transcript[:title],
                                   description: transcript[:description],
                                 })

      # update transcript vendor identifier
      transcript.update(vendor_identifier: item["id"])
      puts "Created new item #{transcript[:title]} in Pop Up Archive with id: #{item['id']}"

      # attempt to upload file
      createAudioFile(transcript, item)

    # otherwise, retrieve the item from Pop Up Archive
    else
      item = getItem(transcript)

      # upload audio file if no audio files found
      if item && item["audio_files"].length <= 0
        puts "No audio files found; submitting audio files for #{item['id']}"
        createAudioFile(transcript, item)
      end
    end

    item
  end

  def get(path, params = {})
    resp = @client.get(path, params)
    resp.http_resp.body
  end

  def getCollections
    resp = get("/collections")
    resp["collections"]
  end

  def getCollection(collection)
    @client.get_collection(collection[:vendor_identifier])
  end

  def getItem(transcript)
    getItemByIds(transcript.collection[:vendor_identifier], transcript[:vendor_identifier])
  end

  def getItemByIds(collection_vendor_identifier, transcript_vendor_identifier)
    @client.get_item(collection_vendor_identifier, transcript_vendor_identifier)
  end

  def post(path, data)
    resp = @client.post(path, JSON.generate(data))
    resp.http_resp.body
  end

  def _getClient
    ::Popuparchive::Client.new(
      id: ENV["PUA_CLIENT_ID"],
      secret: ENV["PUA_CLIENT_SECRET"],
      debug: false,
    )
  end
end
