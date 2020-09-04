import  "./tracks_control.js"
import consumer from "./consumer"

consumer.subscriptions.create("TrackChannel", {
  connected() {
    console.log("tracks_channel");
    console.log(track_list);
    update_tracks(track_list);

  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log("received");
    console.log(data);
    window.track_list = data["current"];
    update_tracks(track_list);
  },

  update: function(message) {
    return this.perform('update');
  }
});
