window.update_tracks = function(tracks){
    console.log("update_tracks");
    console.log(tracks);
    tracks.forEach(function(track, index) {
        if (track === undefined || track === null) {
            n = index + 1
            document.getElementById("td-" + n + "-speakers").innerHTML = "";
            document.getElementById("td-" + n + "-start-time").innerHTML = "";
            document.getElementById("td-" + n + "-name").innerHTML = "放送なし";
        } else {
            n = index + 1
            document.getElementById("td-" + n + "-speakers").innerHTML = track.speakers;
            document.getElementById("td-" + n + "-start-time").innerHTML = track.start_time;
            document.getElementById("td-" + n + "-name").innerHTML = track.title;
        }
    })
}

window.check_update = function(track){
    if(track != undefined || track != null){
        if(window.selected_talk_id != track.id){
            update_track(track);
        }
    }
}
