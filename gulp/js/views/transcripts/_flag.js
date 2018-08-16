app.views.TranscriptLineFlag = app.views.Base.extend({

  id: "transcript-line-flag",
  className: "modal-wrapper",

  template: _.template(TEMPLATES['transcript_line_flag.ejs']),

  events: {
    "click .option": "select",
    "click .submit": "submit",
    "click .toggle-play": "togglePlay",
    "click .view-flags": "viewFlags",
    "click .view-add-flag": "viewForm"
  },

  initialize: function(data){
    var _this = this;

    // for storing line data
    this.lines = {};

    this.data = _.extend({}, data);
    this.data.title = this.data.title || "Flag this transcript line";
    this.data.active = this.data.active || false;

    PubSub.subscribe('transcript.flags.load', function(ev, data) {
      _this.onLoad(data);
    });
  },

  onLoad: function(data){
    if (!this.lines[data.line.id]) {
      var line = _.extend({}, data.line);
      this.lines[data.line.id] = line;
    }
    this.data.transcript_id = data.transcript_id;
    this.data.flags = data.flags;
    this.data.flag_types = data.flag_types;
    this.data.line = this.lines[data.line.id];

    this.show();
  },

  render: function(){
    this.$el.html(this.template(this.data));
  },

  select: function(e){
    e.preventDefault();

    var $options = this.$('.option'),
        $option = $(e.currentTarget),
        type_id = parseInt($option.attr('type-id'));

    $options.not('[type-id="'+type_id+'"]').removeClass('active').attr('aria-checked', 'false');
    $option.toggleClass('active');

    // set selected flag type as active
    var flag_type_id = 0;
    if ($option.hasClass('active')) {
      $option.attr('aria-checked', 'true');
      flag_type_id = type_id;
    }
    this.data.line.user_flag.flag_type_id = flag_type_id;
  },

  show: function(){
    this.render();
    PubSub.publish('modal.invoke', this.id);
  },

  submit: function(e){
    e && e.preventDefault();
    var _this = this;

    this.data.line.user_flag.text = this.$('.input-text').val();
    this.lines[this.data.line.id] = _.extend({}, this.data.line);

    var data = {
      flag_type_id: this.data.line.user_flag.flag_type_id,
      text: this.data.line.user_flag.text,
      transcript_line_id: this.data.line.id,
      transcript_id: this.data.transcript_id
    };

    // user haven't seleted a flag type
    if (data['flag_type_id'] == 0){
      _this.$('.message').addClass('active').html('<p>Please select one of the above options to submit your flag.</p>');
       return;
    }

    $.post(API_URL + "/flags.json", {flag: data}, function(resp) {
      _this.$('.message').addClass('active').html('<p>Thank you for flagging this line. We will be periodically reviewing and correcting flagged errors.</p>');
      setTimeout(function(){
        PubSub.publish('modals.dismiss', true);
      }, 3000)

    });
  },

  togglePlay: function(e){
    e && e.preventDefault();

    PubSub.publish('player.toggle-play', true);
  },

  viewFlags: function(e){
    e && e.preventDefault();

    this.$('footer .button, .flag-content').removeClass('active');
    this.$('.view-add-flag, #flag-index').addClass('active');
  },

  viewForm: function(e){
    e && e.preventDefault();

    this.$('footer .button, .flag-content').removeClass('active');
    this.$('.submit, .view-flags, #flag-add').addClass('active');
  }

});
