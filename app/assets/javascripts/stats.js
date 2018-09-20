$(document).ready(function(){
  $('#institution_id').change(function(){
    var id = $(this).val()
    loadStatsForInstitution(id)
  })

  function loadStatsForInstitution(institutionId){
    id = institutionId || 0
    $.ajax({
        url: "/admin/stats/" + id + "/institution"
    });
  }
})
