app.views.Dashboard = app.views.Base.extend({

  template: _.template(TEMPLATES['user_dashboard.ejs']),

  el: '#main',

  initialize: function(data){
    this.data = data;
    this.secondsPerLine = 5;
    this.listenForAuth();
  },

  listenForAuth: function(){
    var _this = this;

    // check auth validation
    PubSub.subscribe('auth.validation.success', function(ev, user) {
      _this.loadData(user);
    });
  },

  loadData: function(user){
    var _this = this;

    this.data.transcripts = [];

    $.getJSON("/transcript_edits.json", {user_id: user.id}, function(data) {
      if (data.edits && data.edits.length) {
        _this.parseEdits(data.edits, data.transcripts);
      }
      _this.render();
    });
  },

  parseEdits: function(edits, transcripts){
    var _this = this;

    var transcripts = _.map(transcripts, function(transcript, i){
      var t = _.clone(transcript);
      t.index = i;
      t.edits = _.filter(edits, function(e){ return e.transcript_id == transcript.id; });
      t.edit_count = t.edits.length;
      t.seconds_edited = t.edits.length * _this.secondsPerLine;
      console.log("transcript_id: " + t.id);
      console.log("seconds_edited: " + t.seconds_edited);
      return t;
    });

    this.data.transcripts = transcripts;
    this.data.edit_count = edits.length;
    this.data.seconds_edited = edits.length * this.secondsPerLine;
  },

  render: function() {
    this.$el.html(this.template(this.data));
    this.$el.removeClass('loading');

    return this;
  }

});
