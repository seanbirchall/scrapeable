// listen for keyboard shortcuts
document.addEventListener("keydown", function(event) {
  if(event.ctrlKey && event.key === "i"){
    event.preventDefault();
    document.getElementById("editor-import").click();
  }
  if(event.ctrlKey && event.shiftKey && event.key === "Enter"){
    event.preventDefault();
    document.getElementById("editor-run").click();
  }
  if (event.ctrlKey && event.key === "Enter") {
    event.preventDefault();
    const applyButton = document.getElementById("modal-modal_df_viewer-apply");
    if (applyButton) {
      applyButton.click();
    }
  }
  //if(event.ctrlKey && event.key === "s"){
  //  event.preventDefault();
  //  document.getElementById("share").click();
  //}
});

// listen for click
window.addEventListener('click', function(event) {
  const dropdowns = document.getElementsByClassName('dropdown-content');
  for (let dropdown of dropdowns) {
    if (dropdown.classList.contains('show')) {
      dropdown.classList.remove('show');
    }
  }
});

// set active menu
$(document).ready(function() {
  var activeTabId = 'control-tab_environment';
  $('#control-tab_environment, #control-tab_viewer').click(function() {
    $('#' + activeTabId).removeClass('active-tab');
    $(this).addClass('active-tab');
    activeTabId = $(this).attr('id');
  });
  $('#control-tab_environment').click();
});
