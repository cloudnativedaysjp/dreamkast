import  "./track_control.js"
import consumer from "./consumer"

consumer.subscriptions.create("WaitingChannel", {
  connected() {
    console.log("waiting connected");
  },

  disconnected() {
  },

  received(data) {
    console.log("received");

    window.location.href = "/cndt2020/tracks";
  },

  update: function(message) {
    return this.perform('update');
  }
});
