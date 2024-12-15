Shiny.addCustomMessageHandler("put_code", function(message) {
  const payload = message.payload;
  const token = message.token;
  // fetch('https://z8s5j8qy9h.execute-api.us-east-2.amazonaws.com/production/code', {
  fetch('https://reprex.org/put/code', {
    method: 'POST',
    credentials: 'include',
    body: JSON.stringify(payload)
  //  headers: {
  //    'Content-Type': 'application/json',
  //    'Authorization': 'Bearer ' + token
  //  },
  })
  .then(response => {
    if (!response.ok) {
      throw new Error('Network response was not ok');
    }
    return response.json();
  })
  .then(data => {
    Shiny.setInputValue('code_received', Date.now());
  })
  .catch(error => {
    console.error('Error:', error);
    Shiny.setInputValue('code_received', -Date.now());
  });
});
