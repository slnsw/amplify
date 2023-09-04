/**
 * @file
 * Manage user-facing list of site alerts.
 */

$(document).ready(function () {
  // Function: Get list of closed site alerts.
  var getClosedIds = function () {
    return (window.localStorage.getItem('site_alerts') || '')
      .split(',')
      .filter(function (id) {
        return id && id.length > 0;
      });
  };

  // Function: Update list of closed site alerts.
  var setClosedIds = function (closedIds) {
    window.localStorage.setItem('site_alerts', closedIds.join(','));
  };

  // Get list of closed site alerts.
  var closedIds = getClosedIds();

  // Hide closed site alerts.
  var validClosedIds = [];
  $(closedIds).each(function (i, id) {
    var alert = $('.site-alert#' + id);
    if (alert.length > 0) {
      alert.hide();
      validClosedIds.push(id);
    }
  });

  // Clean up nonexistent site alerts.
  setClosedIds(validClosedIds);

  // Handle close button for site alerts.
  $('.site-alert__close').click(function (e) {
    var alert = $(e.target).closest('.site-alert');
    var id = alert.attr('id');
    closedIds.push(id);
    setClosedIds(closedIds);
    alert.hide();
  });
});
    