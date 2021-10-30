$(function(){
  clearInterval(window.media_live_timer);
  console.log("media_live_timer activated");

  window.media_live_timer = setInterval(function() {
    console.log('update')
    $.ajax({
      url: location.href,
      type: 'GET',
      dataType: 'script'
    })
  }, 10000);
});

function update_debug_info(data) {
  document.getElementById("debug_channel_state").innerHTML = 'Channel State: ' + data.state;
  document.getElementById("debug_channel_destination").innerHTML = 'Channel Destination: ' + data.destinations[0].settings[0].url;
}