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
