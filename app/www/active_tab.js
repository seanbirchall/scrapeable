$(document).ready(function() {
  var activeTabId = 'control-tab_environment';
  $('#control-tab_environment, #control-tab_viewer').click(function() {
    $('#' + activeTabId).removeClass('active-tab');
    $(this).addClass('active-tab');
    activeTabId = $(this).attr('id');
  });
  $('#control-tab_environment').click();
});


