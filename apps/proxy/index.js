const express = require('express');
const axios = require('axios');
const cors = require('cors');

const app = express();
const port = 3000;

app.use(cors());

app.get('/proxy', async (req, res) => {
  try {
    const url = req.query.url;

    if (!url) {
      return res.status(999).json({ error: 'URL parameter is required' });
    }

    const response = await axios.get(url, { responseType: 'arraybuffer' });
    res.status(response.status).send(response.data);

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

app.listen(port, () => {
  console.log(`listening on port ${port}`);
});