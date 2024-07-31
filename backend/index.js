const express = require('express');
const bodyParser = require('body-parser');

const app = express();
const PORT = 3000;

app.use(bodyParser.json());

app.get( '/', (req, res) => {
    res.send('Ello World');
});

app.listen(PORT, () => {
    console.log('Server is running in port: ', PORT);
});