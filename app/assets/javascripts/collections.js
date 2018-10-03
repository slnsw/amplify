// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function() {
  var institutionId = 0;

  $('#institution_search').on('click', '.select-option', function(){
    institutionId = $(this).attr('data-id')
    loadCollections();
  });

  // $('#collection_search').on('click', function(event){
  //   event.preventDefault();
  //   $('.collection-filter').toggle();
  // })


  function loadCollections(){
    data = {
      institution_id: institutionId,
    };
    $(".collect-list").html('<div class="loading"></div>')
    $.ajax({
      type: "POST",
      url: "/collections/list",
      data: {institution_id: institutionId},
      error: function(jqXHR, textStatus, errorThrown){
        $(".collect-list").html('Error when reading collection..')
      }
    })
  }
  loadCollections()
})
