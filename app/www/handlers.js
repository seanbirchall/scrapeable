// put code to digitial ocean
Shiny.addCustomMessageHandler("put_code", function(inputId, message) {
  const payload = message.payload;
  fetch('https://reprex.org/put/code', {
    method: 'POST',
    credentials: 'include',
    body: JSON.stringify(payload),
  })
  .then(response => {
    if (!response.ok) {
      throw new Error('Network response was not ok');
    }
    return response.json();
  })
  .then(data => {
    Shiny.setInputValue(inputId, Date.now());
  })
  .catch(error => {
    console.error('Error:', error);
    Shiny.setInputValue(inputId, -Date.now());
  });
});

// check for refresh token
Shiny.addCustomMessageHandler('check_refresh_token', function(inputId, message) {
  fetch('https://reprex.org/auth/refresh', {
    method: 'GET',
    credentials: 'include'
  })
  .then(response => {
    if (response.status === 200) {
      console.log('refreshed successfully');
      Shiny.setInputValue(inputId, true);
    } else {
      // Refresh failed
      console.log('refresh failed');
      Shiny.setInputValue(inputId, false);
    }
  })
  .catch(error => {
    console.error('refresh error:', error);
    Shiny.setInputValue(inputId, false);
  });
});

// query duckdb directly with sql - subhandler
Shiny.addCustomMessageHandler("duckdb_sql", function(message) {
  executeSql(message.sql, message.id);
});

// query duckdb using r - subhandler
Shiny.addCustomMessageHandler("duckdb_r", function(message) {
  runQuery(message.query, message.url, message.id);
});

// view object using df_viewer
Shiny.addCustomMessageHandler("view", function(message) {
  Shiny.setInputValue('view', {object: message.obj, id: Date.now()})
});
