// セッション詳細モーダル表示
window.addEventListener('DOMContentLoaded', function() {
    document.addEventListener('click', function(e) {
        var link = e.target.closest('a[data-talk-modal]');
        if (!link) return;
        e.preventDefault();
        e.stopPropagation();

        var url = link.getAttribute('href');
        fetch(url, { headers: { 'Accept': 'text/html' } })
            .then(function(response) { return response.text(); })
            .then(function(html) {
                var parser = new DOMParser();
                var doc = parser.parseFromString(html, 'text/html');
                var body = doc.querySelector('.proposal-card-body');
                if (!body) return;

                var modal = document.getElementById('talk-modal');
                if (!modal) return;

                modal.innerHTML =
                    '<div class="modal-dialog modal-lg" role="document">' +
                        '<div class="modal-content">' +
                            '<div class="modal-header">' +
                                '<h5 class="modal-title">' + (link.textContent || '') + '</h5>' +
                                '<button type="button" class="close" data-dismiss-talk-modal aria-label="Close">' +
                                    '<span aria-hidden="true">&times;</span>' +
                                '</button>' +
                            '</div>' +
                            '<div class="modal-body japanese-modern-theme proposal-show">' +
                                '<div class="proposal-card-body">' + body.innerHTML + '</div>' +
                            '</div>' +
                            '<div class="modal-footer">' +
                                '<a href="' + url + '"><button type="button" class="btn btn-info">Permalinkを表示</button></a>' +
                                '<button type="button" class="btn btn-secondary" data-dismiss-talk-modal>Close</button>' +
                            '</div>' +
                        '</div>' +
                    '</div>';

                // backdrop
                var backdrop = document.createElement('div');
                backdrop.className = 'modal-backdrop fade show';
                document.body.appendChild(backdrop);

                modal.style.display = 'block';
                modal.classList.add('show');
                document.body.classList.add('modal-open');

                function closeModal() {
                    modal.classList.remove('show');
                    modal.style.display = 'none';
                    document.body.classList.remove('modal-open');
                    if (backdrop.parentNode) backdrop.parentNode.removeChild(backdrop);
                }

                modal.querySelectorAll('[data-dismiss-talk-modal]').forEach(function(btn) {
                    btn.addEventListener('click', closeModal);
                });
                backdrop.addEventListener('click', closeModal);
            });
    });
});

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
