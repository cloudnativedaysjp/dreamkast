window.update_track = function(track){
    document.getElementById("video").contentWindow.location.replace("https://player.vimeo.com/video/" + track.video_id + "?autoplay=1&loop=0&autopause=0");
    document.getElementById("chat").contentWindow.location.replace("https://vimeo.com/live-chat/" + track.video_id);
    document.getElementById("slido").contentWindow.location.replace("https://app.sli.do/event/" + track.slido_id);
    
    ;
    document.getElementById("title").innerHTML = track.title;
    document.getElementById("abstract").innerHTML = track.abstract;
    document.getElementById("speakers").innerHTML = track.speakers;
    document.getElementById("time").innerHTML = track.start_time + "-" + track.end_time;
}