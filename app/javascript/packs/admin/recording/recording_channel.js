import consumer from "./consumer"

consumer.subscriptions.create("RecordingChannel", {
  connected() {
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log(data)
    window.location.reload()
  },

  update: function(message) {
    return this.perform('update');
  }
});
