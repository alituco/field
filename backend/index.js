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
        const timeframes = response.data.data.slots_status.map(slot => ({
            time: slot.time,
            status: slot.status,
            pitch_id: slot.pitch_id,
            time_am_pm: slot.time_am_pm,
            price: slot.price,
            end_time: slot.end_time,
            is_female_slot: slot.is_female_slot,
            is_upfront_slot: slot.is_upfront_slot,
            is_online_payment_slot: slot.is_online_payment_slot,
            price_after_discount: slot.price_after_discount,
            is_special_offer: slot.is_special_offer,
            is_lowest_price: slot.is_lowest_price,
          }));
      
          res.json({ timeframes });
    } catch (err){
        console.error('Error occured: ', err);
        res.status(500).json({ error: 'Failed to load timeframes'});
    }
});

app.listen(PORT, () => {
    console.log('Server is running in port: ', PORT);
});