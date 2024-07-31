const express = require('express');
const bodyParser = require('body-parser');
const { default: axios } = require('axios');

const app = express();
const PORT = 3000;

app.use(bodyParser.json());

app.get( '/', (req, res) => {
    res.send('Ello World');
});

app.post('/get-timeframes', async (req, res) => {
    const { stadium_id, date, duration, pitch_id } = req.body;
    try {
        const response = await axios.post('https://api.malaebapp.com/api/v2/stadiums/timeframe', {
            stadium_id,
            date,
            duration,
            pitch_id
        }, {
            headers: {
                'Content-Type': 'application/json',
            }
        });
        res.json(response.data);
    } catch (err){
        console.error('Error occured: ', err);
        res.status(500).json({ error: 'Failed to load timeframes'});
    }
});

app.listen(PORT, () => {
    console.log('Server is running in port: ', PORT);
});