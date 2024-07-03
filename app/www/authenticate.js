/*function storeRefreshToken(refreshToken){
  localStorage.setItem("refreshToken", refreshToken);
}

function setIdToken(idToken){
  Shiny.setInputValue("idToken", idToken);
}

function handleAuthResponse(data){
  var idToken = data.id_token;
  var refreshToken = data.refresh_token;
  setIdToken(idToken);
  storeRefreshToken(refreshToken);
}

function tryAuth(body){
  fetch('https://scrapeable.auth.us-east-2.amazoncognito.com/oauth2/token/', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: body
  })
  .then(response => response.json())
  .then(data => handleAuthResponse(data))
  .catch(error => {
    console.log('Error:', error)
  })
}
*/

Shiny.addCustomMessageHandler("refreshToken", function(message) {
  const refreshToken = localStorage.getItem("refreshToken");
  if (!refreshToken) {
    Shiny.setInputValue("refreshTokenError", "No refresh token found");
    return;
  }

  const body = new URLSearchParams({
    grant_type: 'refresh_token',
    client_id: '4u1auln0l9c8n3f0cjfaq6gpa1', // Your client ID
    refresh_token: refreshToken
  }).toString();

  tryAuth(body)
    .then(data => {
      Shiny.setInputValue("refreshTokenSuccess", true);
    })
    .catch(error => {
      Shiny.setInputValue("refreshTokenError", error.toString());
    });
});

function tryAuth(body) {
  return fetch('https://scrapeable.auth.us-east-2.amazoncognito.com/oauth2/token/', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: body
  })
  .then(response => {
    return response.json().then(data => ({status: response.status, body: data}));
  })
  .then(({status, body}) => {
    if (status !== 200) {
      throw new Error(JSON.stringify(body));
    }
    handleAuthResponse(body);
    return body;
  })
  .catch(error => {
    throw error;
  });
}

function handleAuthResponse(data) {
  var idToken = data.id_token;
  var refreshToken = data.refresh_token;
  Shiny.setInputValue("idToken", idToken);
  if (refreshToken) {
    localStorage.setItem("refreshToken", refreshToken);
  }
}
