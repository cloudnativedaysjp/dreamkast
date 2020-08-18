window.update_track = function(track){
    clearInterval(window.timer);
    if(track === undefined || track === null){
        document.getElementById("video").contentWindow.location.replace("/cndt2020/tracks/blank");
        document.getElementById("chat").contentWindow.location.replace("/cndt2020/tracks/blank");
        document.getElementById("slido").contentWindow.location.replace("/cndt2020/tracks/blank");
        document.getElementById("title").innerHTML = "放送なし";
        document.getElementById("abstract").innerHTML = "";
        document.getElementById("speakers").innerHTML = "";
        document.getElementById("time").innerHTML = "";
        window.selected_talk_id = "0";
    }else{
        document.getElementById("video").contentWindow.location.replace("https://player.vimeo.com/video/" + track.video_id + "?autoplay=1&loop=0&autopause=0");
        document.getElementById("chat").contentWindow.location.replace("https://vimeo.com/live-chat/" + track.video_id);
        document.getElementById("slido").contentWindow.location.replace("https://app.sli.do/event/" + track.slido_id);
        document.getElementById("title").innerHTML = track.title;
        document.getElementById("abstract").innerHTML = track.abstract;
        document.getElementById("speakers").innerHTML = track.speakers;
        document.getElementById("time").innerHTML = track.start_time + "-" + track.end_time;
        window.selected_talk_id = track.id;
        window.timer = setInterval(function(){
            console.log(track)
            tracker.track("watch_video", {
                track_name: track.track_name,
                talk_id: track.id,
                datetime: new Date(),
            });
        }, 120 * 1000);
    }
    document.querySelectorAll(".track_button").forEach(function(a){a.classList.remove('active')});
    document.querySelector('a[track_id="' + selected_track + '"]').classList.toggle('active');
}

window.check_update = function(track){
    if(track != undefined || track != null){
        if(window.selected_talk_id != track.id){
            update_track(track);
        }
    }
}
