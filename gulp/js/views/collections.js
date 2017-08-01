app.views.Collections = app.views.Base.extend({

  el: '#main',
  template: _.template(TEMPLATES['collections_index.ejs']),

  initialize: function(data){
    var defaults = {
      queryParams: {}
    };

    this.data = _.extend({}, defaults, data);

    this.render();
  },

  onCollectionsLoaded: function(collection){
    var data = collection.toJSON();
    this.$el.html(this.template({collections: data}));
    this.$el.removeClass('loading');
  },

  render: function() {
    document.title = app.pageTitle('Collections');

    this.collections = this.collections || new app.collections.Collections({
      endpoint: '/collections.json'
    });

    this.collections.fetch({
      success: this.onCollectionsLoaded.bind(this),
      error: function(collection, response, options){
        $(window).trigger('alert', ['Whoops! We seem to have trouble loading our transcripts. Please try again by refreshing your browser or come back later!']);
      }
    });

    return this;
  }

});
