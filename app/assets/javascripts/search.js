// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function(){
  var collectionId = 0;
  var institutionId = 0;
  var sortId = '';
  var searchText = '';
  var firstTimeLoad = true;
  var theme = '';


  $('.select.collection').click(function(){
    $(this).toggleClass( "active" )
  });

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

  $('#collection_search').on('click', '.select-option', function(){
    collectionId = $(this).attr('data-id')
    if (collectionId == 0) {
      institutionId = 0;
    }
    loadTranscripts();
  });

  $('#institution_search').on('click', '.select-option', function(){
    institutionId = $(this).attr('data-id')
    if (institutionId == 0) {
      collectionId = 0;
    }
    loadTranscripts();
  });

  $('.select-option').on('click', function(){
    if (this.classList.contains('menu-item')) {
      return true
    }
    if ($(this).attr('data-filter') === 'collection'){
      collectionId = $(this).attr('data-id');
    }
    if ($(this).attr('data-filter') === 'institution'){
      institutionId = $(this).attr('data-id');
      // when institution changes, reset the collection id
      collectionId = 0;
    }
    if ($(this).attr('data-filter') === 'theme'){
      theme = $(this).attr('data-id');
    }

    loadTranscripts();
  })

  $("#keyword").on('keyup',function(e){
    if (($(this).val() == "") && (e.keyCode == 8)){
      searchText = "";
      loadTranscripts()
    }
  })


  function scrollUp(){
    var target  = $('#search-form').offset().top;
    $('html, body').animate({
      scrollTop: target
    }, 1000);
  }

  $("#search-form").submit(function(event){
    searchText = $('#keyword').val()
    event.preventDefault();
    loadTranscripts()
    scrollUp()
  })


  function loadTranscripts(){
    data = {
      institution_id: institutionId,
      collection_id: collectionId,
      q: searchText,
      theme: theme
    };

    $(".search_results").html('<div class="lds-ripple"><div></div><div></div></div>')
    $.ajax({
        url: "/search/query",
        data: {data: data},
      success: function(data, textStatus, jqXHR){
        if (!firstTimeLoad) {
          scrollUp()
        }
        firstTimeLoad = false;
        var instance = new Mark(".search_item");
        if (instance) {
          instance.mark(searchText)
        }
      }
    })
  }
  loadTranscripts()
})
