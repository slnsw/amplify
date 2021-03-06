// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function(){
  var collectionId = 0;
  var institutionId = 0;
  var sortId = '';
  var searchText = '';
  var firstTimeLoad = true;
  var theme = '';

  $('#reset').on('click', function(){
    collectionId = 0;
    institutionId = 0;
    sortId = '';
    searchText = '';
    firstTimeLoad = true;
    theme = '';
    preventDefault();
    loadTranscripts();

  });

  $("select").on("change", function(){
    id = $(this).attr('id')
    switch (id) {
      case "themes":
        theme = this.value;
        break;
      case "institutions":
        institutionId = this.value;
        if (institutionId == 0) {
          collectionId = 0;
        }
        break;
      case "collections":
        collectionId = this.value;
        if (collectionId == 0) {
          institutionId = 0;
        }
        break;
      case "sorting":
        sortId = this.value;
        break;
    }
    loadTranscripts();
  })

  $("#search-form").submit(function(event){
    searchText = $('#search').val()
    event.preventDefault();
    loadTranscripts()
  })

  $("#search").on('keyup',function(e){
    if (($(this).val() == "") && (e.keyCode == 8)){
      searchText = "";
      loadTranscripts()
    }
  })

  $(".change-speaker").on('click', function(e){
    e.preventDefault();
    $(this).toggleClass('active');
  })

  function scrollUp(){
    var target  = $('.search_field').offset().top;
    $('html, body').animate({
      scrollTop: target
    }, 1000);
  }

  function legacyThumbnails() {
    console.log(Modernizr, Modernizr.testProp('objectFit'));
    if (Modernizr && !Modernizr.testProp('objectFit')) {
      console.log($('img.transcript_item__image').length);
      $('img.transcript_item__image').each(function () {
        var imageSrc = $(this).attr('src');
        $(this).replaceWith('<div class="transcript_item__image object-fit-compat" style="background-image: url(' + imageSrc + ');"></div>')
      });
    }
  }

  function loadTranscripts(){
    data = {
      institution_id: institutionId,
      collection_id: collectionId,
      sort_id: sortId,
      text: searchText,
      theme: theme
    };
    $(".transcript-list").html('<div class="loading"></div>')
    $.ajax({
        type: "POST",
        url: "/home/transcripts",
        data: {data: data},
      success: function(data, textStatus, jqXHR){
        if (!firstTimeLoad) {
          scrollUp()
        }
        firstTimeLoad = false;
        legacyThumbnails();
      },
      error: function(jqXHR, textStatus, errorThrown){

      }
    })
  }
  loadTranscripts()
})
