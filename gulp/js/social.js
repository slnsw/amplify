// Social media integration.
window.app.socialIntegration = function() {
  this.intervalStage1 = null;
  this.intervalStage2 = null;
  this.initialised = false;
  this.attempts = 0;
  this.maxAttempts = 100;
  this.shown = false;

  // Tests whether social media JS has loaded and initialised.
  var readyForSocial = function(win) {
    return (
      !!win.twttr &&
      !!win.twttr.widgets &&
      !!win.twttr.widgets.load &&
      !!win.FB &&
      !!win.FB.XFBML &&
      !!win.FB.XFBML.parse
    );
  };

  // Shows social media widgets.
  // Must be called after readyForSocial resolves to TRUE.
  this.showSocialWidgets = function() {
    window.twttr.widgets.load();
    FB.XFBML.parse();
    this.shown = true;
  };

  // Checks the progress of the loader so far.
  this.runIntervalStage2 = function() {
    // Short circuit.
    if (this.shown) {
      return;
    }

    // Check to see if we are ready to display.
    var ready = readyForSocial(window);
    if (!!ready) {
      clearInterval(this.socialLoadIntId);
      this.showSocialWidgets();
      return;
    }

    // Check to see if we've let it go on too long.
    this.attempts++;
    if (this.attempts >= this.maxAttempts) {
      console.error('Gave up on loading social widgets.');
      clearInterval(this.socialLoadIntId);
      return;
    }
  };

  // Load Facebook.
  this.initFacebook = function(d, s, id, fbAppId) {
    // Check for existence of fb-root first.
    if (!document.getElementById('fb-root')) {
      return false;
    }
    var js, fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) {
      return;
    }
    js = d.createElement(s);
    js.id = id;
    js.src = "https://connect.facebook.net/en_GB/sdk.js#xfbml=1&version=v2.8&appId=" + fbAppId;
    fjs.parentNode.insertBefore(js, fjs);
    return true;
  };

  // Load Twitter.
  this.initTwitter = function(d, s, id) {
    var js,
    fjs = d.getElementsByTagName(s)[0],
    t = window.twttr || {};
    if (d.getElementById(id)) {
      return t;
    }
    js = d.createElement(s);
    js.id = id;
    js.src = "https://platform.twitter.com/widgets.js";
    fjs.parentNode.insertBefore(js, fjs);
    t._e = [];
    t.ready = function(f) {
      t._e.push(f);
    };
    return t;
  };

  // Initialise social media external Javascript,
  // and set up any HTML scaffolding.
  this.initSocialScripts = function() {
    // Insert fb-root element.
    if (!document.getElementById('fb-root')) {
      var body = document.getElementsByTagName('body')[0];
      var fbRoot = document.createElement('div');
      fbRoot.setAttribute('id', 'fb-root');
      body.insertBefore(fbRoot, body.firstChild);
    }

    // Insert Facebook script.
    if (typeof(facebookAppId) !== 'undefined') {
      window.fbLoad = this.initFacebook(document, 'script', 'facebook-jssdk', facebookAppId);
    }

    // Insert Twitter script.
    window.twttr = this.initTwitter(document, "script", "twitter-wjs");

    // Minimum initialisation prerequisites.
    this.initialised = (
      !!document.getElementById('fb-root') &&
      !!window.fbLoad &&
      !!window.twttr
    );
    return;
  };

  // Once the social scripts have been initialised,
  // show the widgets.
  this.completeStage1 = function() {
    this.attempts = 0;
    this.shown = false;
    if (!!this.intervalStage2) {
      clearInterval(this.intervalStage2);
    }
    this.intervalStage2 = setInterval(this.runIntervalStage2.bind(this), 250);
  };

  // Stage 1: Initialise social scripts, and don't continue until we have.
  this.runIntervalStage1 = function() {
    if (!!this.initialised) {
      clearInterval(this.intervalStage1);
      this.completeStage1();
    }
    else {
      this.initSocialScripts();
    }  
  };

  // Initialises entire social widget stack.
  this.init = function() {
    if (!!this.intervalStage1) {
      clearInterval(this.intervalStage1);
    }
    this.intervalStage1 = setInterval(this.runIntervalStage1.bind(this), 250);
  };
};

window.app.social = new window.app.socialIntegration();
document.addEventListener("DOMContentLoaded", function(event) {
  window.app.social.init();
});
