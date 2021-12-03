$(document).ready(function(){
  $('#institution_id').change(function(){
    loadStatsForInstitution();
  });

  $('#start_date, #end_date').change(function() {
    loadStatsForInstitution();
  });

  function loadStatsForInstitution(){
    var institutionId = $("#institution_id").val() || 0
    let start_date = $("#start_date").val() || 0;
    let end_date = $("#end_date").val() || 0;

    $.ajax({
      url: "/admin/stats/" + institutionId + "/institution",
      data: {
        start_date: start_date,
        end_date: end_date
      },
    });
  }
})
