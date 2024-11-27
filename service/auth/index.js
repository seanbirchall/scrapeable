const express = require('express');
const cookieParser = require('cookie-parser'); // Optional, for parsing cookies
const axios = require('axios'); // For making requests to Cognito
const app = express();

app.use(cookieParser());

// Redirect endpoint
app.get('/callback', async (req, res) => {
    const { code } = req.query; // Get the authorization code from the redirect
    if (!code) {
        console.log('no auth code found');
        return res.status(400).send('Authorization code is missing');
    }

    try {
        // Exchange the authorization code for tokens
        const response = await axios.post(
            process.env.COGNITO_TOKEN_URL,
            new URLSearchParams({
                grant_type: 'authorization_code',
                client_id: process.env.COGNITO_CLIENT_ID,
                client_secret: process.env.COGNITO_CLIENT_SECRET,
                code,
                redirect_uri: 'https://reprex.org/auth/redirect',
            }),
            { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
        );

        const { access_token, refresh_token } = response.data;

        if (!access_token) {
            console.warn('access token is missing');
        }
        if (!refresh_token) {
            console.warn('refresh token is missing');
        }

        if(access_token) {
            res.cookie('access_token', access_token, {
                httpOnly: true,
                secure: true,
                sameSite: 'Strict',
                maxAge: 3600 * 1000, // 1 hour
            });
        }
        if(refresh_token) {
            res.cookie('refresh_token', refresh_token, {
                httpOnly: true,
                secure: true, // Use true in production
                sameSite: 'Strict',
                maxAge: 5 * 24 * 3600 * 1000, // 7 days
            });
        }

        // redirect to reprex ide
        res.redirect('/index.html');
    } catch (error) {
        console.error('error exchanging code for tokens:', error.response?.data || error.message);
        res.status(500).send('Authentication failed');
    }
});

app.get('/logout', async (req, res) => {
    // Clear cookies
    res.clearCookie('access_token');
    res.clearCookie('refresh_token');

    // Redirect to Cognito logout
    const logoutUrl = `${process.env.COGNITO_DOMAIN}/logout?` +
        `client_id=${process.env.COGNITO_CLIENT_ID}&` +
        `logout_uri=${encodeURIComponent('https://reprex.org')}`;
    
    res.redirect(logoutUrl);
});

app.get('/refresh', async (req, res) => {
    const refreshToken = req.cookies.refresh_token;

    try {
        // Attempt to get a new access token using the refresh token
        const response = await axios.post(
            process.env.COGNITO_TOKEN_URL,
            new URLSearchParams({
                grant_type: 'refresh_token',
                client_id: process.env.COGNITO_CLIENT_ID,
                client_secret: process.env.COGNITO_CLIENT_SECRET,
                refresh_token: refreshToken
            }),
            { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
        );

        const { access_token } = response.data;

        // Set new access token cookie
        res.cookie('access_token', access_token, {
            httpOnly: true,
            secure: true,
            sameSite: 'Strict',
            maxAge: 3600 * 1000, // 1 hour
        });

    } catch (error) {
        // Refresh token is invalid or expired
        res.clearCookie('access_token');
        res.clearCookie('refresh_token');
    }
});

// Start the server
app.listen(3001, () => {
    console.log('auth service is running on 3001');
});