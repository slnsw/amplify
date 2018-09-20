$(document).ready(function(){
  $('#institution_id').change(function(){
    loadSummary()
  })

  $('#collection').on("change", "#collection_select", function(){
    loadSummary()
  })


  function loadSummary(){
    var institutionId = $("#institution_id").val() || 0
    var collectionId = $("#collection_select").val() || 0
    $.ajax({
        url: "/admin/summary/details?institution_id=" + institutionId + "&collection_id=" + collectionId
    });
  }
})
