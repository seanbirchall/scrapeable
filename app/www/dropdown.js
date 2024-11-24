function toggleDropdown(event) {
  event.stopPropagation();
  const dropdownContent = document.getElementById('fileDropdownContent');
  dropdownContent.classList.toggle('show');
}

function handleMenuClick(action) {
  Shiny.setInputValue('menuAction', action);
  document.getElementById('fileDropdownContent').classList.remove('show');
}

window.addEventListener('click', function(event) {
  const dropdowns = document.getElementsByClassName('dropdown-content');
  for (let dropdown of dropdowns) {
    if (dropdown.classList.contains('show')) {
      dropdown.classList.remove('show');
    }
  }
});
