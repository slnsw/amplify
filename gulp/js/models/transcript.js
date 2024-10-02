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
    return API_URL + '/transcripts/'+id+'.json?share_token='+shareToken;
  }

});
