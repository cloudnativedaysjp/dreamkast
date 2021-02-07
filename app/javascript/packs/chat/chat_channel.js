import consumer from "./consumer"

const appRoom = consumer.subscriptions.create("ChatChannel", {
  connected() {
    console.log('connected')
    document.getElementById('send_message').addEventListener('click', (event) => {
      event.preventDefault();
      console.log('clicked')
      var message = document.getElementById('message')
      appRoom.post(message.value);
      message.value = '';
    })
  },

  disconnected() {
    console.log('disconnected')
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log('received ' + data)
    $('#chat').append(`<p class="chat_message" id="${data['id']}">${data['body']}</p>`)

    // Called when there's incoming data on the websocket for this channel
  },

  post: function(data) {
    console.log('post ', JSON.stringify(data))
    console.log(data)
    return this.perform('post', {body: data});
  }
});

window.hoge = function() {
  console.log('hoge')
}

