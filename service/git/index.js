const express = require('express');
const crypto = require('crypto');
const { exec } = require('child_process');
const app = express();

// Use JSON parser for incoming payload
app.use(express.json());

// Function to compute HMAC and compare the signature
function verifySignature(req) {
    const signature = req.headers['x-hub-signature-256'];
    console.log('Received signature: ', signature);

    if (!signature) {
        console.error('No signature received');
        return false;
    }

    // Compute the HMAC signature
    const payload = JSON.stringify(req.body); // Ensure body is parsed as JSON string
    const hmac = crypto.createHmac('sha256', process.env.WEBHOOK_TOKEN);
    hmac.update(payload);
    const computedSignature = `sha256=${hmac.digest('hex')}`;
    // console.log('Computed signature: ', computedSignature);
    return signature === computedSignature;
}

// Function to execute shell script
function runScript() {
    return new Promise((resolve, reject) => {
        // Run the command with sudo explicitly
        const command = 'sudo -u sean /bin/bash /var/www/html/scrapeable/deploy.sh';
        
        console.log('Executing command:', command);
        
        exec(command, {
            shell: true,
            cwd: '/var/www/html/scrapeable',
        }, (error, stdout, stderr) => {
            if (error) {
                console.error('Error executing script:', error);
                console.error('Stderr:', stderr);
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

        // console.log('Payload:', req.body);

        // Check the branch
        const branch = req.body.ref;
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

// Start server
app.listen(3000, () => {
    console.log('GitHub webhook service running on port 3000');
});