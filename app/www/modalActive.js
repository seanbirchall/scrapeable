$(document).ready(function() {
  var activeModalId = 'environment-envir_str';
  $('#environment-envir_str, #environment-envir_table, #environment-envir_list').click(function() {
    $('#' + activeModalId).removeClass('active-tab');
    $(this).addClass('active-tab');
    activeModalId = $(this).attr('id');
  });
  $('#environment-envir_str').click();
});