let ind = 2;

function makeTabEditable(tabId) {
    let tab = w2ui['tabs'].get(tabId);
    if (!tab) {
        console.log(`Tab ${tabId} not found`);
        return;
    }

    // Function to check if the new tab name has a valid extension
    function hasValidExtension(name) {
        return /\.(R|rmd|qmd|app|api|sql)$/i.test(name);
    }

    // Prompt the user for a new tab name until a valid one is entered
    let newText = prompt("Edit file name: (must end with valid extension)", tab.text);
    while (newText !== null && !hasValidExtension(newText)) {
        newText = prompt("Invalid extension: (must end with .R, .rmd, .qmd, .app, .api, or .sql)", tab.text);
    }

    // If the user cancels the prompt (newText is null), do nothing
    if (newText !== null) {
        w2ui['tabs'].get(tabId).text = newText;
        w2ui['tabs'].refresh();
        Shiny.setInputValue('tab_edit', { tabId: tabId, newName: newText });
    }
}

// Initialize the tabs
new w2tabs({
    box: '#editor-tabs',
    name: 'tabs',
    active: 'tab1',
    reorder: false,
    tabs: [
        { id: 'tab1', text: 'script.R', closable: true },
        { id: 'add', text: '✚' },
    ],
    onClick(event) {
        event.done(() => {
            if (event.target === 'add') {
                let id = 'tab' + ind;
                this.insert('add', { id: id, text: 'script' + ind + '.R', closable: true });
                this.click(id);
                Shiny.setInputValue('tab', id);
                ind++;
            } else {
                Shiny.setInputValue('tab', event.target);
            }
        });
    },
    onClose(event) {
        // Get the tab object
        let tab = w2ui['tabs'].get(event.target);

        // Show confirmation dialog before closing the tab using the tab's text
        if (confirm(`Are you sure you want to close: ${tab.text}?`)) {
            event.done(() => {
              //tabs.clickClose(event.target);
              w2ui['tabs'].remove(event.target); // Remove the tab
              Shiny.setInputValue('tab_close', event.target);
            });
        } else {
            event.preventDefault(); // Cancel the close action
        }
    },
    onDblClick(event) {
        if (event.target !== 'add') {
            makeTabEditable(event.target);
        }
    },
    onReorder(event) {
        if (event.target === 'add') {
            event.preventDefault();
            return;
        }
        this.hide('add');
        event.done(() => {
            this.show('add');
        });
    }
});

// Event delegation for double-click to make tabs editable
$(document).on('dblclick', '.w2ui-tab', function() {
    const dataClick = $(this).attr('data-click');
    const tabIdMatch = dataClick.match(/click\|([^\|]+)\|/);
    const tabId = tabIdMatch ? tabIdMatch[1] : undefined;
    if (tabId !== 'add') {
        makeTabEditable(tabId);
    }
});
