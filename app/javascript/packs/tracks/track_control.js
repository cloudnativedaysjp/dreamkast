window.update_track = function(track){
    //document.getElementById("video").contentWindow.location.replace("https://player.vimeo.com/video/" + track.video_id + "?autoplay=1&loop=0&autopause=0");
    document.getElementById("video").contentWindow.location.replace("https://vimeo.com/event/" + track.video_id + "/embed");
    document.getElementById("chat").contentWindow.location.replace("https://vimeo.com/event/" + track.video_id + "/chat/");
    document.getElementById("slido").contentWindow.location.replace("https://app.sli.do/event/" + track.slido_id);
    document.getElementById("title").innerHTML = track.title;
    document.getElementById("abstract").innerHTML = track.abstract;
    document.getElementById("speakers").innerHTML = track.speakers;
    document.getElementById("time").innerHTML = track.start_time + "-" + track.end_time;
    document.querySelectorAll(".track_button").forEach(function(a){a.classList.remove('active')});
    document.querySelector('a[track_id="' + track.track_id + '"]').classList.toggle('active');
    window.selected_talk_id = track.id;
}

window.check_update = function(track){
    if(window.selected_talk_id != track.id){
        update_track(track);
    }
}