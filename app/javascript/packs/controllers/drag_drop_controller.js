import { Controller } from "@hotwired/stimulus";
import { Sortable } from "sortablejs";

export default class extends Controller {
    connect() {
        this.sortable = new Sortable(this.element, {
            animation: 150,
            onEnd: this.end.bind(this),
        });
    }

    async end(event) {
        console.log("event: ", event);
        console.log("event.item: ", event.item);
        console.log("event.item.dataset: ", event.item.dataset);
        const id = event.item.dataset.id;
        const conferenceAbbr = event.item.dataset.conferenceAbbr;
        const newPosition = event.newIndex;
        console.log("event.newIndex: ", event.newIndex);

        try {
            const response = await fetch(`/${conferenceAbbr}/admin/stamp_rally_check_points/${id}/reorder`, {
                method: "PATCH",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": document.querySelector("[name=csrf-token]").content,
                },
                body: JSON.stringify({ position: newPosition }),
            });

            if (!response.ok) throw new Error("Failed to reorder");
        } catch (error) {
            console.error("Reordering failed", error);
        }
    }
}
