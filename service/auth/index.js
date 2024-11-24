// app.js
require('dotenv').config();
const express = require('express');
const axios = require('axios');
const cookieParser = require('cookie-parser');

const app = express();
app.use(cookieParser());

// AWS Cognito Config
const config = {
    COGNITO_DOMAIN: process.env.COGNITO_DOMAIN,
    CLIENT_ID: process.env.CLIENT_ID,
    CLIENT_SECRET: process.env.CLIENT_SECRET,
    REDIRECT_URI: process.env.REDIRECT_URI,
    COOKIE_DOMAIN: process.env.COOKIE_DOMAIN || 'localhost',
    FRONTEND_URL: process.env.FRONTEND_URL || 'http://localhost:3000'
};

// Cookie configuration
const cookieConfig = {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production', // true in production
    sameSite: 'lax',
    domain: config.COOKIE_DOMAIN,
    path: '/',
    maxAge: 7 * 24 * 60 * 60 * 1000 // 7 days
};

// Exchange authorization code for tokens
async function getTokensFromCode(code) {
    const params = new URLSearchParams({
        grant_type: 'authorization_code',
        client_id: config.CLIENT_ID,
        client_secret: config.CLIENT_SECRET,
        code: code,
        redirect_uri: config.REDIRECT_URI
    });

    try {
        const response = await axios.post(
            `${config.COGNITO_DOMAIN}/oauth2/token`,
            params.toString(),
            {
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            }
        );

        return response.data;
    } catch (error) {
        console.error('Error exchanging code for tokens:', error.response?.data || error.message);
        throw error;
    }
}

// Refresh token endpoint
app.post('/auth/refresh', async (req, res) => {
    const refreshToken = req.cookies.refreshToken;

    if (!refreshToken) {
        return res.status(401).json({ error: 'No refresh token found' });
    }

    try {
        const params = new URLSearchParams({
            grant_type: 'refresh_token',
            client_id: config.CLIENT_ID,
            client_secret: config.CLIENT_SECRET,
            refresh_token: refreshToken
        });

        const response = await axios.post(
            `${config.COGNITO_DOMAIN}/oauth2/token`,
            params.toString(),
            {
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            }
        );

        // Set new access token cookie
        res.cookie('accessToken', response.data.access_token, cookieConfig);
        
        res.json({ success: true });
    } catch (error) {
        console.error('Error refreshing token:', error.response?.data || error.message);
        res.clearCookie('accessToken', cookieConfig);
        res.clearCookie('refreshToken', cookieConfig);
        res.status(401).json({ error: 'Failed to refresh token' });
    }
});

// Callback endpoint
app.get('/auth/callback', async (req, res) => {
    const { code, error } = req.query;

    if (error) {
        console.error('OAuth error:', error);
        return res.redirect(`${config.FRONTEND_URL}/login?error=${error}`);
    }

    try {
        const tokens = await getTokensFromCode(code);

        // Set cookies
        res.cookie('accessToken', tokens.access_token, cookieConfig);
        res.cookie('refreshToken', tokens.refresh_token, {
            ...cookieConfig,
            maxAge: 30 * 24 * 60 * 60 * 1000 // 30 days for refresh token
        });

        // Redirect to frontend
        res.redirect(config.FRONTEND_URL);
    } catch (error) {
        console.error('Callback error:', error);
        res.redirect(`${config.FRONTEND_URL}/login?error=callback_failed`);
    }
});

// Logout endpoint
app.post('/auth/logout', (req, res) => {
    res.clearCookie('accessToken', cookieConfig);
    res.clearCookie('refreshToken', cookieConfig);
    res.json({ success: true });
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'healthy' });
});

app.listen(4000, () => {
    console.log(`Auth server running on port 4000`);
});