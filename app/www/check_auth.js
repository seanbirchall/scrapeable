Shiny.addCustomMessageHandler('check_auth', function(message) {
  fetch('https://reprex.org/auth/refresh', {
    method: 'GET',
    credentials: 'include'
  })
  .then(response => {
    if (response.status === 200) {
      console.log('refreshed successfully');
      Shiny.setInputValue('is_logged_in', true);
    } else {
      // Refresh failed
      console.log('refresh failed');
      Shiny.setInputValue('is_logged_in', false);
    }
  })
  .catch(error => {
    console.error('refresh error:', error);
    Shiny.setInputValue('is_logged_in', false);
  });
});
