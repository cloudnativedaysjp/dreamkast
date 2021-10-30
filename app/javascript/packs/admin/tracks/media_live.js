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
