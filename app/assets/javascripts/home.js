// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function() {
  $(document).mouseup(function(e) {
    var container = $("#data_theme_");
    var container2 = $("#data_collection_id_");
    var handler = $("#theme-filter:not('.open')");
    var handler2 = $("#collection-filter:not('.open')");

    if (!container.is(e.target) && container.has(e.target).length === 0) {
      $("#theme-filter").removeClass('open');
      container.hide();
    }

    if (!container2.is(e.target) && container2.has(e.target).length === 0) {
      $("#collection-filter").removeClass('open');
      container2.hide();
    }

    if (handler.is(e.target) || handler.has(e.target).length > 0) {
      handler.addClass('open');
      container.show();
    }

    if (handler2.is(e.target) || handler2.has(e.target).length > 0) {
      handler2.addClass('open');
      container2.show();
    }
  });

  $(".home-form").submit(function(event){
    $(this).find(":input").filter(function(){ return !this.value; }).attr("disabled", "disabled");
    $("#transcript-results").html('<div class="lds-ripple"><div></div><div></div></div>');
  })

  function setSelect2() {
    $("select:not([multiple=multiple])").select2({
      theme: "amplify",
      minimumResultsForSearch: Infinity
    });
  }

  function scrollDown() {
    var results = $('#transcript-results');
    if (results.length > 0) {
      console.log('starting scroll to');
      setTimeout(function () {
        document.querySelector('#transcript-results').scrollIntoView({
          block: 'start',
          inline: 'start',
          behavior: 'smooth',
        });
      }, 0);
      // var target  = results.offset().top;
      // $('html, body').animate({
      //   scrollTop: (target - 200)
      // }, 1000);
    }
  }

  setSelect2();
  window.legacyThumbnails();
  if (window.location.search.length > 0) {
    scrollDown();
  }

  $('#institution').change(function() {
    $(this.form).submit();
  });
})
