import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "tweet_content" ]

    windowOpen() {
        const value = this.tweet_contentTarget.value
        window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(value)}`);
    }
}
