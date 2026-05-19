import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["button", "url"]

    copy(event) {
        event.preventDefault();
        const url = this.urlTarget.textContent;
        const button = this.buttonTarget;
        const originalHTML = button.innerHTML;

        navigator.clipboard.writeText(url)
            .then(() => {
                button.textContent = "Copied";
                setTimeout(() => {
                    button.innerHTML = originalHTML;
                }, 5000);
            })
            .catch((error) => {
                console.error("Failed to copy", error);
            });
    }
}
