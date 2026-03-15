window.addEventListener('DOMContentLoaded', function() {
    if (document.getElementById('is_offline') && document.getElementById('is_offline').value == 'true') {
        const checkboxes = Array.from(document.getElementsByClassName("talks_checkbox"));
        // data-start-time属性があれば時間重複ベースの排他制御を使用
        const useTimeOverlap = checkboxes.length > 0 && checkboxes[0].hasAttribute('data-start-time');

        checkboxes.forEach(function(element) {
            element.addEventListener("click", function() {
                if (useTimeOverlap) {
                    // 時間重複ベースの排他制御（CNK用）
                    if (this.checked) {
                        const myDay = this.getAttribute('data-conference-day');
                        const myStart = parseInt(this.getAttribute('data-start-time'));
                        const myEnd = parseInt(this.getAttribute('data-end-time'));

                        checkboxes.forEach(function(other) {
                            if (other === element) return;
                            if (other.getAttribute('data-conference-day') !== myDay) return;

                            const otherStart = parseInt(other.getAttribute('data-start-time'));
                            const otherEnd = parseInt(other.getAttribute('data-end-time'));

                            // 時間重複判定: A.start < B.end && B.start < A.end
                            if (myStart < otherEnd && otherStart < myEnd) {
                                other.checked = false;
                            }
                        });
                        this.checked = true;
                    }
                } else {
                    // 従来のslotベースの排他制御（既存テンプレート用）
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
                }
            })
        })
    }
})
