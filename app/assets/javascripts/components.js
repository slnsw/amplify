// COMPONENTS
var COMPONENTS = (function() {
  function COMPONENTS() {
    this.init();
  }

  COMPONENTS.prototype.init = function(){
    this.selectInit();
    this.alertInit();
    this.scrollInit();
    this.stickyInit();
    this.toggleInit();
    this.toggleSoundInit();
  };

  COMPONENTS.prototype.alert = function(message, flash, target, flashDelay){
    target = target || '#primary-alert';
    flashDelay = flashDelay || 3000;

    var $target = $(target);
    $target.html('<div>'+message+'</div>').addClass('active');

    if (this.timeout) {
      clearTimeout(this.timeout);
    }

    if (flash) {
      this.timeout = setTimeout(function(){
        $target.removeClass('active');
      }, flashDelay);
    }
  };

  COMPONENTS.prototype.alertInit = function(){
    var _this = this;

    $(window).on('alert', function(e, message, flash, target, flashDelay){
      _this.alert(message, flash, target, flashDelay);
    });

    $('.alert').on('click', function(){
      $(this).removeClass('active');
    });
  };

  COMPONENTS.prototype.scrollInit = function(){
    var _this = this;

    $(window).on('scroll-to', function(e, $el, offset, delay){
      _this.scrollTo($el, offset, delay);
    });
  };

  COMPONENTS.prototype.scrollTo = function($el, offset, delay) {
    offset = offset || 0;
    delay = delay || 2000;

    $('html, body').animate({
        scrollTop: $el.offset().top - offset
    }, 2000);
  };

  COMPONENTS.prototype.select = function($selectOption){
    var $menu = $selectOption.closest('.select'),
        $active = $menu.find('.select-active'),
        $options = $menu.find('.select-option'),
        activeText = $selectOption.attr('data-active') || $selectOption.text();

    $options.removeClass('selected').attr('aria-checked', 'false');
    $selectOption.addClass('selected').attr('aria-checked', 'true');
    $active.text(activeText);
    $menu.removeClass('active');
  };

  COMPONENTS.prototype.selectInit = function(){
    console.log("init...")
    var _this = this;

    // select box
    $(document).on('click', '.select-active', function(){
      _this.selectMenu($(this).closest('.select'));
    });

    // select option
    $(document).on('click', '.select-option', function(){
      _this.select($(this));
    });

    // click away
    $(document).on('click', function(e){

      // select box
      if (!$(e.target).closest('.select').length) {
        _this.selectMenusHide();
      }

    });
  };

  COMPONENTS.prototype.selectMenu = function($selectMenu){
    $selectMenu.addClass('active');
  };

  COMPONENTS.prototype.selectMenusHide = function(){
    $('.select').removeClass('active');
  };

  COMPONENTS.prototype.sticky = function(header){
    var $stickies = $('.sticky-on-scroll');

    if (!$stickies.length) return false;

    var offsetTop = header ? $(header).height() : 0;
    var windowTop = $(window).scrollTop();

    $stickies.each(function(){
      var $el = $(this),
          elTop = $el.offset().top;

      if (windowTop > elTop-offsetTop) {
        $($el.attr('data-sticky')).addClass('sticky');
      } else {
        $($el.attr('data-sticky')).removeClass('sticky');
      }
    });
  };

  COMPONENTS.prototype.stickyInit = function(){
    var _this = this;

    $(window).on('sticky-on', function(e, header){
      _this.stickyOn(header);
    });
  };

  COMPONENTS.prototype.stickyOn = function(header){
    if (this.sticky_is_on) return false;
    this.sticky_is_on = true;
    var _this = this;

    $(window).on('scroll', function(){
      _this.sticky(header);
    });
  };

  COMPONENTS.prototype.toggle = function(el){
    $(el).toggleClass('active');
  };

  COMPONENTS.prototype.toggleInit = function(){
    var _this = this;

    // toggle button
    $(document).on('click', '.toggle-active', function(e){
      e.preventDefault();
      _this.toggle($(this).attr('data-target'));
    });
  };

  COMPONENTS.prototype.toggleSound = function($el){
    var media = $el[0];

    if (media && media.muted) {
      media.muted = false;
    } else if (media) {
      media.muted = true;
    }
  };

  COMPONENTS.prototype.toggleSoundInit = function(){
    var _this = this;

    $(document).on('click', '.toggle-sound', function(e){
      e.preventDefault();
      _this.toggleSound($(this));
    });
  };

  return COMPONENTS;

})();

// Load app on ready
$(function() {
  var components = new COMPONENTS();
});
// $(document).on('turbolinks:load',function(){
//   var components = new COMPONENTS();
// });

