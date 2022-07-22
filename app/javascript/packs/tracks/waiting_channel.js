import "./track_control.js"
import consumer from "./consumer"

consumer.subscriptions.create("WaitingChannel", {
    connected() {
        console.log("waiting connected");
    },

    disconnected() {},

    received(data) {
        console.log("received");
        var countdownNumberEl = document.getElementById('countdown-number');
        var min = 3;
        var max = 10
        var countdown = Math.floor(Math.random() * (max + 1 - min)) + min;

        countdownNumberEl.textContent = countdown;

        document.getElementById('countdown').classList.remove('hidden');
        document.getElementById('countdown-circle').style.animation = `countdown ${countdown}s linear infinite forwards`;

        setInterval(function() {
            countdown = --countdown;
            countdownNumberEl.textContent = countdown;
            if (countdown == 0) {
                window.location.href = data["redirectTo"];
            }
        }, 1000);
    },

    update: function(message) {
        return this.perform('update');
    }
});