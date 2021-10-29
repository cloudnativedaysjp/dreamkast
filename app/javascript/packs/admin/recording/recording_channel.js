import consumer from "./consumer"

consumer.subscriptions.create("RecordingChannel", {
  connected() {
    console.log('Connected: RecordingChannel')
  },

  disconnected() {
    console.log('Disconnected: RecordingChannel')
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log('Received: ' + JSON.stringify(data))
    window.location.reload()
  },

  update: function(message) {
    return this.perform('update');
  }
});
