// edit w2ui tab name
function makeTabEditable(tabId) {
    let tab = w2ui['tabs'].get(tabId);
    if (!tab) {
        console.log(`Tab ${tabId} not found`);
        return;
    }

    // Function to check if the new tab name has a valid extension
    function hasValidExtension(name) {
        return /\.(R|rmd|qmd|md|app|api|db|sql|js)$/i.test(name);
    }

    // Prompt the user for a new tab name until a valid one is entered
    let newText = prompt("Edit file name: (must end with valid extension)", tab.text);
    while (newText !== null && !hasValidExtension(newText)) {
        newText = prompt("Valid extension: .R, .RMD, .QMD, .MD, .APP, .API, .DB, .JS or .SQL", tab.text);
    }

    // If the user cancels the prompt (newText is null), do nothing
    if (newText !== null) {
        w2ui['tabs'].get(tabId).text = newText;
        w2ui['tabs'].refresh();
        Shiny.setInputValue('tab_edit', { tabId: tabId, newName: newText });
    }
}

// toggle header dropdown
function toggleDropdown(event) {
  event.stopPropagation();
  const dropdownContent = document.getElementById('fileDropdownContent');
  dropdownContent.classList.toggle('show');
}

// handle header dropdown click
function handleMenuClick(action) {
  Shiny.setInputValue('menuAction', action);
  document.getElementById('fileDropdownContent').classList.remove('show');
}

// copy html text
function copy_by_id(id, isConsole) {
  if (isConsole) {
    // Get the div by its ID
    var consoleDiv = document.getElementById(id);
    // Check if the div exists
    if (!consoleDiv) {
      console.error('Div with id "' + id + '" not found.');
      return;
    }

    // Get all span elements within the div
    var spanElements = consoleDiv.getElementsByTagName('span');
    // Concatenate the text content of all span elements
    var textToCopy = '';
    for (var i = 0; i < spanElements.length; i++) {
      textToCopy += spanElements[i].textContent + '\n';
    }
    // Create a temporary textarea element to copy the text
    var tempTextArea = document.createElement('textarea');
    tempTextArea.value = textToCopy;
    document.body.appendChild(tempTextArea);
    // Select the text in the textarea
    tempTextArea.select();
    tempTextArea.setSelectionRange(0, 99999); // For mobile devices
    // Copy the text inside the textarea
    navigator.clipboard.writeText(tempTextArea.value).then(function() {
      console.log('Text copied to clipboard');
    }, function(err) {
      console.error('Could not copy text: ', err);
    });
    // Remove the temporary textarea element
    document.body.removeChild(tempTextArea);
  } else {
    // Get the text field by its ID
    var copyText = document.getElementById(id);
    // Check if the text field exists
    if (!copyText) {
      console.error('Element with id "' + id + '" not found.');
      return;
    }
    // Select the text field
    copyText.select();
    copyText.setSelectionRange(0, 99999); // For mobile devices
    // Copy the text inside the text field
    navigator.clipboard.writeText(copyText.value).then(function() {
      console.log('Text copied to clipboard');
    }, function(err) {
      console.error('Could not copy text: ', err);
    });
  }
}
