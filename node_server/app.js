import { spotify_client_id, spotify_client_secret, spotify_redirect_uri } from './config.js' // Sensitive information - not stored in git repository

const express = require('express'); // Express web server framework
const { Server } = require('ws');
var request = require('request'); // "Request" library
var cors = require('cors');
var querystring = require('querystring');
var cookieParser = require('cookie-parser');

const PORT = 3080; // port for https
var stateKey = 'spotify_auth_state';

// Generate a random string containing numbers and letters
var generateRandomString = function(length) {
    var text = '';
    var possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    for (var i = 0; i < length; i++) {
        text += possible.charAt(Math.floor(Math.random() * possible.length));
    }
    return text;
};

// var server = express();
// server.use(cors())
//     .use(cookieParser())
//     .listen(PORT, () => console.log(`Listening on ${PORT}`));
// // Whenever we receive a GET request at '\login', call this function
// server.get('\login', function(req, res) {
//     var state = generateRandomString(16);
//     res.cookie(stateKey, state);
//     var scope = 'user-read-prive user-read-email';
//     res.redirect('https://acounts.spotify.com/authorize') + 
//     querystring.stringify()

// });

const wss = new Server({ server });

// listen for message event after hearing connection event
wss.on('connection', function(ws, req) {
    console.log('Connected');
    // message callback
    ws.on('message', message => {
        var dataString = message.toString();
        console.log(dataString);
        if (dataString == "Hello there") {
            ws.send("General Kenobi");
        } else {
            ws.send("No hablo ingles");
        }
    })
})

