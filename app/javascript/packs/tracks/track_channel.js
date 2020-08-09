import  "./track_control.js"
import consumer from "./consumer"

consumer.subscriptions.create("TrackChannel", {
  connected() {
    window.selected_track = 1;
    update_track(track_list[selected_track - 1]);
    var subscription = this;
    document.querySelectorAll('.track_button').forEach(function(link){
      link.addEventListener('click', (event) =>{
        event.preventDefault();
        window.selected_track = link.getAttribute("track_id");
        update_track(track_list[selected_track - 1]);
      })
    })
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log(data);
    window.track_list = data["current"];
    check_update(track_list[selected_track - 1]);
  },

  update: function(message) {
    return this.perform('update');
  }
});
