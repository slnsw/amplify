app.models.Transcript = Backbone.Model.extend({

  parse: function(resp){
    return resp;
  },

  url: function(){
    // Select the meta tag with name="share_token"
    const shareTokenMeta = document.querySelector('meta[name="share_token"]');
    // Get the value of the content attribute
    const shareToken = shareTokenMeta ? shareTokenMeta.getAttribute('content') : null;

    var id = this.get('uid') || this.id;
    const urlObj = new URL('/transcripts/'+id+'.json', API_URL);
    if (typeof shareToken === 'string' && shareToken.length > 0) {
      urlObj.searchParams.set('share_token', shareToken);
    }
    return urlObj.toString();
  }

});
