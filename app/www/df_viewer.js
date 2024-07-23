(function() {
  function initializeWidget() {
    if (typeof HTMLWidgets !== 'undefined' && typeof Shiny !== 'undefined') {
      HTMLWidgets.widget({
      name: 'df_viewer',
      type: 'output',
      factory: function(el, width, height) {
        // Create the Handsontable container
        var hotElement = document.createElement('div');
        el.appendChild(hotElement);

        return {
          renderValue: function(x) {

            // Initialize Handsontable
            if (el.hot && el.hot.destroy) {
              el.hot.destroy();
            }

            var counter = 1
            var hot = new Handsontable(hotElement, {
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
                items: {
                    'h0': {
                      name: '---------'
                    },
                    'rename': {
                      name: 'Rename',
                      callback: function(key, options) {
                        if (typeof Shiny !== 'undefined') {
                          counter++
                          Shiny.setInputValue('df_viewer_modal', {action: 'rename', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                        }
                      }
                    },
                    'select': {
                      name: 'Select Columns (Remove)',
                      callback: function(key, options) {
                        if (typeof Shiny !== 'undefined') {
                          counter++
                          Shiny.setInputValue('df_viewer_modal', {action: 'select', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                        }
                      }
                    },
                    'reorder': {
                      name: 'Reorder Columns',
                      submenu: {
                        items: [
                          {
                            key: 'reorder:asc',
                            name: 'Ascending Order',
                            callback: function(key, options) {
                              if (typeof Shiny !== 'undefined') {
                                counter++
                                Shiny.setInputValue('df_viewer_modal', {action: 'reorder:asc', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                              }
                            }
                          },
                          {
                            key: 'reorder:desc',
                            name: 'Descending Order',
                            callback: function(key, options) {
                              if (typeof Shiny !== 'undefined') {
                                counter++
                                Shiny.setInputValue('df_viewer_modal', {action: 'reorder:desc', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                              }
                            }
                          },
                          {
                            key: 'reorder:maual',
                            name: 'Manual Order',
                            callback: function(key, options) {
                              if (typeof Shiny !== 'undefined') {
                                counter++
                                Shiny.setInputValue('df_viewer_modal', {action: 'reorder:manual', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                              }
                            }
                          },
                        ]
                      }
                    },
                    'h1': {
                      name: '---------'
                    },
                    'filter': {
                      name: 'Filter',
                      submenu: {
                        items: [
                          {
                            key: 'filter:isequalto',
                            name: 'Is Equal To',
                            callback: function(key, options) {
                              if (typeof Shiny !== 'undefined') {
                                counter++
                                Shiny.setInputValue('df_viewer_modal', {action: 'filter:isequalto', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                              }
                            }
                          },
                          {
                            key: 'filter:isnotequalto',
                            name: 'Is Not Equal To',
                            callback: function(key, options) {
                              if (typeof Shiny !== 'undefined') {
                                counter++
                                Shiny.setInputValue('df_viewer_modal', {action: 'filter:isnotequalto', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                              }
                            }
                          },
                          {
                            key: 'filter:isin',
                            name: 'Is In (Multiple Values)',
                            callback: function(key, options) {
                              if (typeof Shiny !== 'undefined') {
                                counter++
                                Shiny.setInputValue('df_viewer_modal', {action: 'filter:isin', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                              }
                            }
                          },
                          {
                            key: 'filter:isnotin',
                            name: 'Is Not In (Multiple Values)',
                            callback: function(key, options) {
                              if (typeof Shiny !== 'undefined') {
                                counter++
                                Shiny.setInputValue('df_viewer_modal', {action: 'filter:isnotin', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                              }
                            }
                          },
                          {
                            key: 'filter:contain',
                            name: 'Contains',
                            callback: function(key, options) {
                              if (typeof Shiny !== 'undefined') {
                                counter++
                                Shiny.setInputValue('df_viewer_modal', {action: 'filter:contain', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                              }
                            }
                          },
                          {
                            key: 'filter:doesnotcontain',
                            name: 'Does Not Contain',
                            callback: function(key, options) {
                              if (typeof Shiny !== 'undefined') {
                                counter++
                                Shiny.setInputValue('df_viewer_modal', {action: 'filter:doesnotcontain', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                              }
                            }
                          },
                        ]
                      }
                    },
                    'distinct': {
                      name: 'Distinct (Unique Rows)',
                      callback: function(key, options) {
                        if (typeof Shiny !== 'undefined') {
                          counter++
                          Shiny.setInputValue('df_viewer_modal', {action: 'distinct', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                        }
                      }
                    },
                    'groupby': {
                      name: 'Group By',
                      callback: function(key, options) {
                        if (typeof Shiny !== 'undefined') {
                          counter++
                          Shiny.setInputValue('df_viewer_modal', {action: 'groupby', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                        }
                      }
                    },
                    'summarize': {
                      name: 'Summarize (Aggregate)',
                      callback: function(key, options) {
                        if (typeof Shiny !== 'undefined') {
                          counter++
                          Shiny.setInputValue('df_viewer_modal', {action: 'summarize', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                        }
                      }
                    },
                    'calc': {
                      name: 'Create Calculation',
                      callback: function(key, options) {
                        if (typeof Shiny !== 'undefined') {
                          counter++
                          Shiny.setInputValue('df_viewer_modal', {action: 'calc', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                        }
                      }
                    },
                    'windowcalc': {
                      name: 'Create Window Calculation',
                      callback: function(key, options) {
                        if (typeof Shiny !== 'undefined') {
                          counter++
                          Shiny.setInputValue('df_viewer_modal', {action: 'windowcalc', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                        }
                      }
                    },
                    'arrange': {
                      name: 'Arrange (Sort)',
                      submenu: {
                        items: [
                          {
                            key: 'arrange:asc',
                            name: 'Ascending Order',
                            callback: function(key, options) {
                              if (typeof Shiny !== 'undefined') {
                                counter++
                                Shiny.setInputValue('df_viewer_modal', {action: 'arrange:asc', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                              }
                            }
                          },
                          {
                            key: 'arrange:desc',
                            name: 'Descending Order',
                            callback: function(key, options) {
                              if (typeof Shiny !== 'undefined') {
                                counter++
                                Shiny.setInputValue('df_viewer_modal', {action: 'arrange:desc', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                              }
                            }
                          }
                        ]
                      }
                    },
                    'h2': {
                      name: '---------'
                    },
                    'join': {
                      name: 'Join with DF (Add Columns)',
                      callback: function(key, options) {
                        if (typeof Shiny !== 'undefined') {
                          counter++
                          Shiny.setInputValue('df_viewer_modal', {action: 'join', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                        }
                      }
                    },
                    'append': {
                      name: 'Append (Add Rows)',
                      callback: function(key, options) {
                        if (typeof Shiny !== 'undefined') {
                          counter++
                          Shiny.setInputValue('df_viewer_modal', {action: 'append', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                        }
                      }
                    },
                    'pivotlonger': {
                      name: 'Pivot Longer (Wide to Long)',
                      callback: function(key, options) {
                        if (typeof Shiny !== 'undefined') {
                          counter++
                          Shiny.setInputValue('df_viewer_modal', {action: 'pivotlonger', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                        }
                      }
                    },
                    'pivotwider': {
                      name: 'Pivot Wider (Long to Wide)',
                      callback: function(key, options) {
                        if (typeof Shiny !== 'undefined') {
                          counter++
                          Shiny.setInputValue('df_viewer_modal', {action: 'pivotwider', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                        }
                      }
                    },
                    'separate': {
                      name: 'Separate (Text to Columns)',
                      callback: function(key, options) {
                        if (typeof Shiny !== 'undefined') {
                          counter++
                          Shiny.setInputValue('df_viewer_modal', {action: 'separate', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                        }
                      }
                    },
                    'unite': {
                      name: 'Unite (Columns)',
                      callback: function(key, options) {
                        if (typeof Shiny !== 'undefined') {
                          counter++
                          Shiny.setInputValue('df_viewer_modal', {action: 'unite', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                        }
                      }
                    },
                    'cross': {
                      name: 'Crossing (Cartesian Product)',
                      callback: function(key, options) {
                        if (typeof Shiny !== 'undefined') {
                          counter++
                          Shiny.setInputValue('df_viewer_modal', {action: 'cross', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                        }
                      }
                    },
                    'h3': {
                      name: '---------'
                    },
                    'change': {
                      name: 'Change Data Type',
                      submenu: {
                        items: [
                          {
                            key: 'change:numeric',
                            name: 'Numeric',
                            callback: function(key, options) {
                              if (typeof Shiny !== 'undefined') {
                                counter++
                                Shiny.setInputValue('df_viewer_modal', {action: 'change:numeric', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                              }
                            }
                          },
                          {
                            key: 'change:date',
                            name: 'Date',
                            callback: function(key, options) {
                              if (typeof Shiny !== 'undefined') {
                                counter++
                                Shiny.setInputValue('df_viewer_modal', {action: 'change:date', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                              }
                            }
                          },
                          {
                            key: 'change:time',
                            name: 'Time',
                            callback: function(key, options) {
                              if (typeof Shiny !== 'undefined') {
                                counter++
                                Shiny.setInputValue('df_viewer_modal', {action: 'change:time', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                              }
                            }
                          },
                          {
                            key: 'change:character',
                            name: 'Character',
                            callback: function(key, options) {
                              if (typeof Shiny !== 'undefined') {
                                counter++
                                Shiny.setInputValue('df_viewer_modal', {action: 'change:character', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                              }
                            }
                          },
                          {
                            key: 'change:logical',
                            name: 'Logical',
                            callback: function(key, options) {
                              if (typeof Shiny !== 'undefined') {
                                counter++
                                Shiny.setInputValue('df_viewer_modal', {action: 'change:logical', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                              }
                            }
                          },
                          {
                            key: 'change:factor',
                            name: 'Factor',
                            callback: function(key, options) {
                              if (typeof Shiny !== 'undefined') {
                                counter++
                                Shiny.setInputValue('df_viewer_modal', {action: 'change:factor', hit: counter, column: hot.getColHeader(hot.getSelected()[0][1])});
                              }
                            }
                          }
                        ]
                      }
                    },
                    'replace': {
                      name: 'Replace Values'
                    },
                  }
                }
            });

            // Store the Handsontable instance
            el.hot = hot;
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
      // If HTMLWidgets is not defined, wait and try again
      setTimeout(initializeWidget, 100);
    }
  }

  // Start the initialization process
  initializeWidget();
})();
