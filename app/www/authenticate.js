Shiny.addCustomMessageHandler("refreshToken", function(message) {
  try {
    const refreshToken = localStorage.getItem("ScrapeableRefreshToken");
    if (!refreshToken) {
      throw new Error("No refresh token found");
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
        throw error;
      });
  } catch (error) {
    Shiny.setInputValue("refreshTokenError", error.toString());
  }
});

Shiny.addCustomMessageHandler("authenticate", function(body) {
  try {
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
    });
  } catch (error) {
    console.error("Authentication error:", error);
    throw error;
  }
});

function tryAuth(body) {
  try {
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
    });
  } catch (error) {
    console.error("tryAuth error:", error);
    throw error;
  }
}

function handleAuthResponse(data) {
  try {
    var idToken = data.id_token;
    var refreshToken = data.refresh_token;
    Shiny.setInputValue("idToken", idToken);
    if (refreshToken) {
      localStorage.setItem("ScrapeableRefreshToken", refreshToken);
    }
  } catch (error) {
    console.error("handleAuthResponse error:", error);
    throw error;
  }
}
