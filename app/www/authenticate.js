function storeRefreshToken(refreshToken){
  localStorage.setItem("refreshToken", refreshToken);
}

function setIdToken(idToken){
  Shiny.setInputValue("idToken", idToken);
}

function handleAuthResponse(data){
  var idToken = data.id_token;
  var refreshToken = data.refresh_token;
  setCognitoAuth(idToken);
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
