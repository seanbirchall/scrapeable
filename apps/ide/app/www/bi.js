$(document).ready(function() {
  var activeMenuId = 'explore-menu_data';
  $('#explore-menu_data, #explore-menu_visual, #explore-menu_model, #explore-menu_step').click(function() {
    $('#' + activeMenuId).removeClass('active-menu');
    $(this).addClass('active-menu');
    activeMenuId = $(this).attr('id');
  });
  $('#explore-menu_data').click();
});