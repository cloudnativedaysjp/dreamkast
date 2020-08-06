import  "./track_control.js"
import consumer from "./consumer"

consumer.subscriptions.create("TrackChannel", {
  connected() {
    window.selected_track = 1;
    this.update();
    var subscription = this;
    document.querySelectorAll('.track_button').forEach(function(link){
      link.addEventListener('click', (event) =>{
        event.preventDefault();
        window.selected_track = link.getAttribute("track_id");
        subscription.update();
      })
    })
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    window.track_list = data["current"];
    console.log(data);
    update_track(track_list[selected_track - 1]);
  },

  update: function(message) {
    return this.perform('update');
  }
});
