// app.js
const express = require('express');
const crypto = require('crypto');
const { exec } = require('child_process');
const app = express();

// middleware to parse JSON bodies
app.use(express.json());

// function to compute HMAC and compare the signature
function verifySignature(req) {
    // grab the signature from the request header
    const signature = req.headers['x-hub-signature-256'];
    console.log('received: ', signature);
    // ensure there's a signature
    if (!signature) {
        console.error('No signature received');
        return false;
    }
    // prepare the payload for signature comparison
    const payload = JSON.stringify(req.body);
    const hmac = crypto.createHmac('sha256', process.env.WEBHOOK_TOKEN);
    hmac.update(payload);
    const computedSignature = `sha256=${hmac.digest('hex')}`;
    console.log('computed: ', computedSignature);
    return signature === computedSignature;
}

// execute shell script
function runScript() {
    return new Promise((resolve, reject) => {
        exec('/var/www/html/scrapeable/deploy.sh', (error, stdout, stderr) => {
            if (error) {
                console.error('Error executing script:', error);
                reject(error);
                return;
            }
            resolve(stdout);
        });
    });
}

// webook endpoint
app.post('/webhook', async (req, res) => {
    try {
        if (!verifySignature(req)) {
            console.error('Invalid GitHub signature');
            return res.status(401).send('Unauthorized');
        }

        console.log('GitHub webhook verified');
        await runScript();
        res.status(200).send('Success');
    } catch (error) {
        console.error('Webhook processing error:', error);
        res.status(500).send('Internal Server Error');
    }
});

app.listen(3000, () => {
    console.log(`git service running`);
});