// Waston specification
const AssistantV2 = require('ibm-watson/assistant/v2');
const { IamAuthenticator } = require('ibm-watson/auth');
const ApiKey = 'gGF1v8vT0y7By-h7eHoooCMMHGG4GZmqC1YrDSWEgAVo'
const Url = 'https://api.au-syd.assistant.watson.cloud.ibm.com/instances/bfd8b663-c23b-4217-8bdb-a46e41cc5f12'
const AssistantId = '6ce25092-cf3d-4997-859b-4ef4ab67dab8'
const assistant = new AssistantV2({
  version: '2019-02-28',
  authenticator: new IamAuthenticator({
    apikey: 'gGF1v8vT0y7By-h7eHoooCMMHGG4GZmqC1YrDSWEgAVo',
  }),
  url: 'https://api.au-syd.assistant.watson.cloud.ibm.com/instances/bfd8b663-c23b-4217-8bdb-a46e41cc5f12',
});

// Chatbox specification
var app = require('express')();
var http = require('http').createServer(app);
var io = require('socket.io')(http);

app.get('/', function(req, res){
  res.sendFile(__dirname + '/index.html');
});

http.listen(3001, function(){
  console.log('listening on *:3001');
});

// Start chat
assistant.createSession({
  assistantId: AssistantId
})
  .then(res => {
    console.log(res.result.session_id);
    io.on('connection', function(socket){

      // connection
  	  console.log('a user connected');
  	  socket.on('disconnect', function(){
  	    console.log('user disconnected');
      });

      // send message
  	  socket.on('chat message', function(msg){
  	    console.log('message: ' + msg);
  	    io.emit('chat message', msg);

        // send message to waston
        assistant.message({
          assistantId: AssistantId,
          sessionId: res.result.session_id,
          input: {
            'message_type': 'text',
            'text': msg
            }
        })
        .then(res => {
          console.log(res.result.output.generic[0].text);
          io.emit('chat message', res.result.output.generic[0].text);
        })
        .catch(err => {
          console.log(err);
        });
      });
    });


  })
  .catch(err => {
    console.log(err);
  });





