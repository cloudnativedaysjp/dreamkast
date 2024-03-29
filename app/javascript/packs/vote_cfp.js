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
    function print_vote_alert () {
        alert("投票を受け付けられませんでした。\nしばらく時間をおいてから再度の投票をお願いします。");
    }
    const voteUrl = document.getElementById('vote').getAttribute('vote_url');

    const eventAbbr = document.getElementById('vote').getAttribute('event_name');
    const talkId = parseInt(document.getElementById('vote').getAttribute('talk_id'));
    const method = 'POST'
    const query = `mutation {
          vote(input: {
            confName: ${eventAbbr}
            talkId: ${talkId}
        })
    }`;
    const body = JSON.stringify({ query });
    const headers = { 'Content-Type': 'application/json' };

    try {
        fetch(voteUrl,{ method, headers, body})
            .then(r=> {
              if (!r.ok) {
                  throw new Error();
              }
              data = r.json();
              if (data.hasOwnProperty('errors')) {
                  throw new Error();
              } else {
                  setVotedId(talkId);
                  toggleVoted();
              }
            })
            .catch(e => {
                  print_vote_alert();
            })
    } catch(e) {
        print_vote_alert();
    }
    return false;
});

window.addEventListener('DOMContentLoaded', function() {
    if (getVotedIds().includes(parseInt(document.getElementById('vote').getAttribute('talk_id')))) {
        toggleVoted();
    }
})
