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
                                '<h5 class="modal-title"></h5>' +
                                '<button type="button" class="btn-close flex-shrink-0" data-dismiss-talk-modal aria-label="Close"></button>' +
                            '</div>' +
                            '<div class="modal-body japanese-modern-theme proposal-show">' +
                                '<div class="proposal-card-body">' + body.innerHTML + '</div>' +
                            '</div>' +
                            '<div class="modal-footer">' +
                                '<button type="button" class="btn btn-primary me-auto" data-talk-select style="display: none;"></button>' +
                                '<a href="' + url + '"><button type="button" class="btn btn-info">Permalinkを表示</button></a>' +
                                '<button type="button" class="btn btn-secondary" data-dismiss-talk-modal>Close</button>' +
                            '</div>' +
                        '</div>' +
                    '</div>';

                // タイトルは HTML として解釈させない
                modal.querySelector('.modal-title').textContent = link.textContent || '';

                // タイムテーブル上のチェックボックスと連動する参加ボタン
                var talkId = link.getAttribute('data-talk-id');
                var checkbox = talkId && document.querySelector('.talks_checkbox[talk_id="' + talkId + '"]');
                var selectButton = modal.querySelector('[data-talk-select]');
                if (checkbox) {
                    var renderSelectButton = function() {
                        if (checkbox.checked) {
                            selectButton.textContent = '✓ 参加予定（取り消す）';
                            selectButton.className = 'btn btn-outline-primary me-auto';
                        } else {
                            selectButton.textContent = checkbox.disabled ? '満席' : 'このセッションに参加する';
                            selectButton.className = 'btn btn-primary me-auto';
                        }
                        selectButton.disabled = checkbox.disabled;
                    };
                    selectButton.addEventListener('click', function() {
                        // click() で排他制御や件数表示のハンドラも動かす
                        checkbox.click();
                        renderSelectButton();
                    });
                    renderSelectButton();
                    selectButton.style.display = '';
                }

                // backdrop
                var backdrop = document.createElement('div');
                backdrop.className = 'modal-backdrop fade show';
                document.body.appendChild(backdrop);

                modal.style.display = 'block';
                modal.classList.add('show');
                document.body.classList.add('modal-open');

                var players = [];
                if (window.videojs) {
                    modal.querySelectorAll('video.video-js').forEach(function(el) {
                        if (!el.hasAttribute('data-vjs-player')) {
                            players.push(window.videojs(el));
                        }
                    });
                }

                function closeModal() {
                    players.forEach(function(player) {
                        if (!player || typeof player.dispose !== 'function') return;
                        if (typeof player.isDisposed === 'function' && player.isDisposed()) return;
                        try {
                            player.dispose();
                        } catch (error) {
                            console.error('Failed to dispose video player in talk modal.', error);
                        }
                    });
                    players = [];
                    document.removeEventListener('keydown', closeOnEscape);
                    modal.onclick = null;
                    modal.classList.remove('show');
                    modal.style.display = 'none';
                    document.body.classList.remove('modal-open');
                    if (backdrop.parentNode) backdrop.parentNode.removeChild(backdrop);
                }

                modal.querySelectorAll('[data-dismiss-talk-modal]').forEach(function(btn) {
                    btn.addEventListener('click', closeModal);
                });
                // .modal が画面全体を覆っていて backdrop にはクリックが届かないため、
                // ダイアログ本体の外側をクリックしたら閉じる
                modal.onclick = function(event) {
                    if (!event.target.closest('.modal-content')) closeModal();
                };
                function closeOnEscape(event) {
                    if (event.key === 'Escape') closeModal();
                }
                document.addEventListener('keydown', closeOnEscape);
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
                        const removedTitles = [];

                        checkboxes.forEach(function(other) {
                            if (other === element) return;
                            if (other.getAttribute('data-conference-day') !== myDay) return;

                            const otherStart = parseInt(other.getAttribute('data-start-time'));
                            const otherEnd = parseInt(other.getAttribute('data-end-time'));

                            // 時間重複判定: A.start < B.end && B.start < A.end
                            if (myStart < otherEnd && otherStart < myEnd) {
                                if (other.checked && other.hasAttribute('data-talk-title')) {
                                    removedTitles.push(other.getAttribute('data-talk-title'));
                                }
                                other.checked = false;
                            }
                        });
                        this.checked = true;

                        if (removedTitles.length > 0) {
                            showTimetableToast('時間が重なるため「' + removedTitles.join('」「') + '」の選択を外しました');
                        }
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

// 選択を外したことなどを画面下部に一時表示する
var timetableToastTimer = null;
function showTimetableToast(message) {
    var toast = document.getElementById('timetable-toast');
    if (!toast) return;
    toast.textContent = message;
    toast.classList.remove('tw-hidden');
    clearTimeout(timetableToastTimer);
    timetableToastTimer = setTimeout(function() {
        toast.classList.add('tw-hidden');
    }, 5000);
}

// 選択件数と、登録済みの内容から変わっているかを表示する
window.addEventListener('DOMContentLoaded', function() {
    var status = document.getElementById('timetable-selection-status');
    if (!status) return;

    var checkboxes = Array.from(document.getElementsByClassName('talks_checkbox'));
    var checkedIds = function() {
        return checkboxes.filter(function(c) { return c.checked; })
                         .map(function(c) { return c.getAttribute('talk_id'); })
                         .sort()
                         .join(',');
    };
    var saved = checkedIds();
    var count = status.querySelector('[data-selection-count]');
    var unsaved = status.querySelector('[data-selection-unsaved]');

    var render = function() {
        var current = checkedIds();
        count.textContent = current === '' ? 0 : current.split(',').length;
        unsaved.classList.toggle('tw-hidden', current === saved);
    };
    checkboxes.forEach(function(c) { c.addEventListener('change', render); });
    render();
});
