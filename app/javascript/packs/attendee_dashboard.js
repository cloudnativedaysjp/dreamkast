$(document).on('click', '#twitter_share', function(event) {
    const content = document.getElementById("tweet_content")
    window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(content.value)}`);
});
