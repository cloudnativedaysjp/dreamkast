window.addEventListener('DOMContentLoaded', function() {
    if (document.getElementById('is_offline') && document.getElementById('is_offline').value == 'true') {
        Array.from(document.getElementsByClassName("talks_checkbox")).forEach(function(element) {
            element.addEventListener("click", function() {
                if (this.checked) {
                    Array.from(document.getElementsByClassName(`slot_${element.getAttribute('day_slot')}`)).forEach(function(currentSelectedTalks) {
                        currentSelectedTalks.checked = false;
                    })
                    Array.from(document.getElementsByClassName(`${element.getAttribute('talk_number')}`)).forEach(function(selectedTalks) {
                        selectedTalks.checked = true;
                    })
                } else {
                    Array.from(document.getElementsByClassName(`${element.getAttribute('talk_number')}`)).forEach(function(selectedTalks) {
                        selectedTalks.checked = false;
                    })
                }

            })
        })
    }
})
