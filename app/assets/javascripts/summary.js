$(document).ready(function() {
  $('#institution_id').change(function() {
    $('#collection_select').val('');
    loadSummary();
  });

  $('#collection').on("change", "#collection_select", function() {
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

    let params = (new URL(document.location)).searchParams;
    let start_date = params.get("start_date");
    let end_date = params.get("end_date");

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
