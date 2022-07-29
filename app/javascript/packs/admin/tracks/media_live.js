import consumer from "./consumer"

consumer.subscriptions.create({ channel: "OnAirChannel", eventAbbr: "cnsec2022" }, {
    connected() {
        console.log("onair connected");
    },

    disconnected() {},

    received(data) {
        console.log("Received");
        window.location.reload();
    },

    update: function(message) {
        return this.perform('update');
    }
});