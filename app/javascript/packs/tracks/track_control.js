window.update_track = function(track){
    document.getElementById("video").contentWindow.location.replace("https://player.vimeo.com/video/" + track.url);
    document.querySelector("#track_information h2").innerHTML = track.title;
    document.querySelector("#track_information h3").innerHTML = track.abstract;
}