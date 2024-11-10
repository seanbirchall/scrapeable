(function() {
  function initializeWidget() {
    if (typeof HTMLWidgets !== 'undefined' && typeof Shiny !== 'undefined') {
      HTMLWidgets.widget({
        name: 'df_viewer',
        type: 'output',
        factory: function(el, width, height) {
          var hotElement = document.createElement('div');
          el.appendChild(hotElement);

          return {
            renderValue: function(x) {
              if (el.hot && el.hot.destroy) {
                el.hot.destroy();
              }

              // Simply use el.id and append '_action'
              const elementId = el.id;
              const inputId = elementId + '_action';

              // Function to process menu items from R
              function processMenuItems(items) {
                const processedItems = {};
                Object.entries(items).forEach(([key, item]) => {
                  if (item.submenu) {
                    // Handle submenu with array of items
                    processedItems[key] = {
                      name: item.name,
                      submenu: {
                        items: item.submenu.map(subItem => ({
                          key: subItem.key,
                          name: subItem.name,
                          callback: subItem.value ? function(key, options) {
                            Shiny.setInputValue(inputId, {
                              action: subItem.value,
                              id: new Date().getTime(),
                              column: this.getColHeader(this.getSelected()[0][1])
                            });
                          } : undefined
                        }))
                      }
                    };
                  } else {
                    // Handle regular menu items
                    processedItems[key] = {
                      name: item.name,
                      callback: item.value ? function(key, options) {
                        Shiny.setInputValue(inputId, {
                          action: item.value,
                          id: new Date().getTime(),
                          column: this.getColHeader(this.getSelected()[0][1])
                        });
                      } : undefined
                    };
                  }
                });
                return processedItems;
              }

              const items = processMenuItems(x.menuItems);

              // Initialize Handsontable with processed menu items
              el.hot = new Handsontable(hotElement, {
                data: x.data,
                colHeaders: x.colHeaders,
                rowHeaders: x.rowHeaders,
                licenseKey: 'non-commercial-and-evaluation',
                height: '100%',
                width: '100%',
                manualColumnResize: true,
                manualRowResize: true,
                wordWrap: false,
                readOnly: true,
                dropdownMenu: {
                  items: items
                },
                contextMenu: {
                  items: items,
                  callback: function(key, selection) {
                    // Context menu callback if needed
                    console.log('Context menu:', key, selection);
                  }
                },
                afterInit: function() {
                  this.selectCell(0, 0);
                }
              });
            },

            resize: function(width, height) {
              // Resize the widget
              if (el.hot && el.hot.updateSettings) {
                el.hot.updateSettings({
                  width: width,
                  height: height
                });
              }
            }
          };
        }
      });
    } else {
      // If dependencies aren't loaded yet, try again in 100ms
      setTimeout(initializeWidget, 100);
    }
  }

  // Start the initialization process
  initializeWidget();
})();
