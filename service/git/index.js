// app.js
const express = require('express');
const fs = require('fs').promises;
const { exec } = require('child_process');
const app = express();

// Middleware to parse JSON bodies
app.use(express.json());

// Read token from file
async function getStoredToken() {
    try {
        const token = await fs.readFile('/path/to/token.txt', 'utf8');
        return token.trim();
    } catch (error) {
        console.error('Error reading token file:', error);
        return null;
    }
}

// Execute shell script
function runScript() {
    return new Promise((resolve, reject) => {
        exec('/path/to/your/script.sh', (error, stdout, stderr) => {
            if (error) {
                console.error('Error executing script:', error);
                reject(error);
                return;
            }
            resolve(stdout);
        });
    });
}

// Webhook endpoint
app.post('/git', async (req, res) => {
    try {
        const receivedToken = req.headers['x-webhook-token'];
        const storedToken = await getStoredToken();

        if (!receivedToken || !storedToken || receivedToken !== storedToken) {
            console.error('Invalid token received');
            return res.status(401).send('Unauthorized');
        }

        await runScript();
        res.status(200).send('Success');
    } catch (error) {
        console.error('Webhook processing error:', error);
        res.status(500).send('Internal Server Error');
    }
});

app.listen(3000, () => {
    console.log(`Server running on port 3000`);
});