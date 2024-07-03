$(document).ready(function() {
  var activeModalId = 'environment-environment_str';
  $('#environment-environment_str, #environment-environment_table, #environment-environment_list').click(function() {
    $('#' + activeModalId).removeClass('active-tab');
    $(this).addClass('active-tab');
    activeModalId = $(this).attr('id');
  });
  $('#environment-environment_str').click();
});
