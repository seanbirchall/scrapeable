Split(['#pane-code', '#pane-control'], {
  direction: 'horizontal',
  minSize: 200,
  gutterSize: 6
});

Split(['#pane-editor', '#pane-console'], {
  direction: 'vertical',
  minSize: 100,
  gutterSize: 6
});

$(document).ready(function() {
  var activeTabId = 'control-tab_environment';
  $('#control-tab_environment, #control-tab_viewer').click(function() {
    $('#' + activeTabId).removeClass('active-tab');
    $(this).addClass('active-tab');
    activeTabId = $(this).attr('id');
  });
  $('#control-tab_environment').click();
});


