$(document).ready(function() {
  $('#institution_id').change(function() {
    $('#collection_select').val('');
    loadSummary();
  });

  $('#collection').on("change", "#collection_select", function() {
    loadSummary();
  });

  $('#start_date, #end_date').change(function() {
    loadSummary();
  });

  function loadIndicator(show) {
    if (show) {
      $('#summary-stats').attr('aria-busy', 'true')
        .prepend('<h3 id="summary-stats__loading">Loading...</h3>')
    }
    else {
      $('#summary-stats__loading').remove();
      $('#summary-stats').attr('aria-busy', 'false');
    }
  }

  function loadSummary() {
    var institutionId = $("#institution_id").val() || 0
    var collectionId = (
      institutionId === 0 ?
      0 :
      $("#collection_select").val() || 0
    );

    let start_date = $("#start_date").val() || 0;
    let end_date = $("#end_date").val() || 0;

    loadIndicator(true);
    $.ajax({
      method: 'get',
      url: '/admin/summary/details',
      data: {
        institution_id: institutionId,
        collection_id: collectionId,
        start_date: start_date,
        end_date: end_date
      },
      type: 'script',
      success: function(data, testStatus, jqXHR) {
        loadIndicator(false);
      }
    });
  }

  loadSummary();
})
