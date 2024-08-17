import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["button", "url"]

    copy(event) {
        console.log("AAAAAAAAAAAAAAAAAAAAAA")
        event.preventDefault();
        const url = this.urlTarget.textContent;
        const parent = event.target.parentElement;
        const icon = event.target;

        navigator.clipboard.writeText(url)
            .then(() => {
                console.log("Copied to clipboard successfully!");
                parent.textContent = "Copied";
                setTimeout(() => {
                    parent.textContent = "";
                    parent.appendChild(icon);
                }, 5000);
            })
            .catch((error) => {
                console.error("Failed to copy", error);
            });
    }
}
