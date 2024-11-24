const express = require('express');
const crypto = require('crypto');
const { exec } = require('child_process');
const app = express();

// Middleware to capture raw body
app.use((req, res, next) => {
    req.rawBody = '';
    req.on('data', (chunk) => {
        req.rawBody += chunk;
    });
    req.on('end', () => {
        next();
    });
});

// Middleware to parse JSON bodies (required after raw body middleware)
app.use(express.json());

// Function to compute HMAC and compare the signature
function verifySignature(req) {
    const signature = req.headers['x-hub-signature-256'];
    console.log('received: ', signature);

    if (!signature) {
        console.error('No signature received');
        return false;
    }

    try {
        // Compute the HMAC signature using raw body
        const payload = req.rawBody; // Raw body is captured in middleware
        const hmac = crypto.createHmac('sha256', process.env.WEBHOOK_TOKEN);
        hmac.update(payload);
        const computedSignature = `sha256=${hmac.digest('hex')}`;
        console.log('computed: ', computedSignature);
        return signature === computedSignature;
    } catch (error) {
        console.error('Error computing signature:', error);
        return false;
    }
}

// Function to execute shell script
function runScript() {
    return new Promise((resolve, reject) => {
        exec('/var/www/html/scrapeable/deploy.sh', (error, stdout, stderr) => {
            if (error) {
                console.error('Error executing script:', error);
                reject(error);
                return;
            }
            console.log('Script output:', stdout);
            resolve(stdout);
        });
    });
}

// Webhook endpoint
app.post('/webhook', async (req, res) => {
    try {
        if (!verifySignature(req)) {
            console.error('Invalid GitHub signature');
            return res.status(401).send('Unauthorized');
        }

        const payload = JSON.parse(req.rawBody); // Use raw body for parsing
        const branch = payload.ref;

        if (branch !== 'refs/heads/main') {
            console.log(`Ignoring changes from branch: ${branch}`);
            return res.status(200).send('Ignored non-main branch changes');
        }

        console.log('GitHub webhook verified');
        await runScript();
        res.status(200).send('Success');
    } catch (error) {
        console.error('Webhook processing error:', error);
        res.status(500).send('Internal Server Error');
    }
});

// Start the server
app.listen(3000, () => {
    console.log(`git service running on port 3000`);
});