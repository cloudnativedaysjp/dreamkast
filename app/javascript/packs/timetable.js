window.addEventListener('DOMContentLoaded', function() {
    document.getElementsByClassName("talks_checkbox").forEach(function(element) {
        element.addEventListener("click", function() {
            document.getElementsByClassName(`slot_${element.getAttribute('day_slot')}`).forEach(function(currentSelectedTalks) {
                currentSelectedTalks.checked = false;
            })
            document.getElementsByClassName(`${element.getAttribute('talk_number')}`).forEach(function(selectedTalks) {
                selectedTalks.checked = true;
            })
        })
    })
})