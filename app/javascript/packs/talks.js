$(function() {
    clearInterval(window.timer);
    console.log("timer activated");

    window.timer = setInterval(function() {
        console.log("sending logs...");
        tracker.track("watch_video", {
            track_name: "archive",
            talk_id: window.talk_id,
            talk_name: window.talk_name
        });
    }, 120 * 1000);
})

window.tableFilterStripHtml = function(value) {
    return value.replace(/<[^>]+>/g, '').trim();
}

$(document).on('turbolinks:load', function() {
    $('[data-toggle="table"]').bootstrapTable();
});

$(window).resize(function() {
    $('.talks-frame').bootstrapTable('resetView')
})

getVotedIds = function() {
    let votedIds = [];
    document.cookie.split(';').forEach(function(cookie) {
        if (cookie.includes('voted_id=')) {
            votedIds = JSON.parse(cookie.split('=')[1]);
        }
    })
    return votedIds;
}

setVotedId = function(id) {
    let arr = getVotedIds();
    arr.push(id);
    document.cookie = "voted_id=" + JSON.stringify(arr);
}

toggleVoted = function() {
    let btn = document.getElementById('vote');
    btn.disabled = true;
    btn.innerHTML = "投票済み";
}

document.getElementById('vote').addEventListener('click', function() {
    const vote_url = document.getElementById('vote').getAttribute('vote_url')
    fetch(vote_url,{ method: 'POST' })
    setVotedId(parseInt(document.getElementById('vote').getAttribute('talk_id')));
    toggleVoted();
    return false;
});

window.addEventListener('DOMContentLoaded', function() {
    console.log('hogehoge')
    if (getVotedIds().includes(parseInt(document.getElementById('vote').getAttribute('talk_id')))) {
        toggleVoted();
    }
})