Split(['#pane-code', '#pane-control'], {
  direction: 'horizontal',
  minSize: 200
});

Split(['#pane-editor', '#pane-console'], {
  direction: 'vertical',
  minSize: 100
});

$(document).ready(function() {
  var activeTabId = 'controls-tab_environment';
  $('#controls-tab_environment, #controls-tab_viewer, #controls-tab_explore').click(function() {
    $('#' + activeTabId).removeClass('active-tab');
    $(this).addClass('active-tab');
    activeTabId = $(this).attr('id');
  });
  $('#controls-tab_environment').click();
});


