import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["sponsorField", "type"];

    connect() {
        this.toggleSponsorField();
    }

    toggleSponsorField() {
        console.log(this.typeTarget.value)
        if (this.typeTarget.value === 'StampRallyCheckPointBooth') {
            this.sponsorFieldTarget.style.display = '';
        } else {
            this.sponsorFieldTarget.style.display = 'none';
        }
    }

    handleTypeChange() {
        this.toggleSponsorField();
    }
}
