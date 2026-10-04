// セッション詳細モーダル表示
// #talk-modal（各ビューに置いた空の div）をオーバーレイとして使い、中身を組み立てて表示する。
// Tailwind の important セレクタ（#wrapper）の内側に置く必要があるため、body 直下には要素を足さない。
var TALK_MODAL_OVERLAY_CLASS = 'tw-fixed tw-inset-0 tw-z-[1050] tw-flex tw-items-start tw-justify-center tw-overflow-y-auto tw-bg-gray-900/50 tw-p-4 sm:tw-py-10';
var TALK_MODAL_BUTTON_BASE = 'tw-inline-flex tw-items-center tw-justify-center tw-rounded-md tw-border tw-border-solid tw-px-4 tw-py-2 tw-text-sm tw-font-semibold tw-no-underline tw-shadow-sm tw-transition hover:tw-no-underline focus-visible:tw-outline focus-visible:tw-outline-2 focus-visible:tw-outline-offset-2 focus-visible:tw-outline-blue-500 disabled:tw-cursor-not-allowed disabled:tw-opacity-50';
var TALK_MODAL_BUTTON_PRIMARY = TALK_MODAL_BUTTON_BASE + ' tw-cursor-pointer tw-border-cndt-navy tw-bg-cndt-navy tw-text-white hover:tw-opacity-90';
var TALK_MODAL_BUTTON_OUTLINE = TALK_MODAL_BUTTON_BASE + ' tw-cursor-pointer tw-border-cndt-navy tw-bg-white tw-text-cndt-navy hover:tw-bg-sky-50';
var TALK_MODAL_BUTTON_SECONDARY = TALK_MODAL_BUTTON_BASE + ' tw-cursor-pointer tw-border-gray-300 tw-bg-white tw-text-gray-700 hover:tw-bg-gray-50 hover:tw-text-gray-900';

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
                    '<div class="tw-relative tw-my-auto tw-w-full tw-max-w-3xl tw-overflow-hidden tw-rounded-lg tw-bg-white tw-shadow-xl"' +
                         ' data-talk-modal-dialog role="dialog" aria-modal="true" aria-labelledby="talk-modal-title" tabindex="-1" style="outline: none;">' +
                        '<div class="tw-flex tw-items-start tw-gap-4 tw-border-0 tw-border-b tw-border-solid tw-border-gray-200 tw-px-5 tw-py-4">' +
                            '<h2 id="talk-modal-title" class="tw-m-0 tw-flex-1 tw-break-words tw-text-lg tw-font-bold tw-leading-snug tw-text-gray-900"></h2>' +
                            '<button type="button" data-dismiss-talk-modal aria-label="閉じる"' +
                                   ' class="-tw-mr-2 -tw-mt-1 tw-flex tw-h-9 tw-w-9 tw-shrink-0 tw-cursor-pointer tw-items-center tw-justify-center tw-rounded-full tw-border-0 tw-bg-transparent tw-p-0 tw-text-gray-500 tw-transition hover:tw-bg-gray-100 hover:tw-text-gray-900 focus-visible:tw-outline focus-visible:tw-outline-2 focus-visible:tw-outline-blue-500">' +
                                '<svg class="tw-h-5 tw-w-5" viewBox="0 0 20 20" fill="none" aria-hidden="true">' +
                                    '<path d="M5 5l10 10M15 5L5 15" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>' +
                                '</svg>' +
                            '</button>' +
                        '</div>' +
                        // 中身は talks#show の .proposal-card-body をそのまま使うため、そのスタイルの親クラスを付ける
                        '<div class="japanese-modern-theme proposal-show tw-px-5 tw-py-4">' +
                            '<div class="proposal-card-body">' + body.innerHTML + '</div>' +
                        '</div>' +
                        '<div class="tw-flex tw-flex-wrap tw-items-center tw-gap-2 tw-border-0 tw-border-t tw-border-solid tw-border-gray-200 tw-bg-gray-50 tw-px-5 tw-py-3">' +
                            '<button type="button" data-talk-select class="tw-hidden"></button>' +
                            '<div class="tw-ml-auto tw-flex tw-gap-2">' +
                                '<a data-talk-permalink class="' + TALK_MODAL_BUTTON_SECONDARY + '">Permalinkを表示</a>' +
                                '<button type="button" data-dismiss-talk-modal class="' + TALK_MODAL_BUTTON_SECONDARY + '">閉じる</button>' +
                            '</div>' +
                        '</div>' +
                    '</div>';

                // タイトルは HTML として解釈させない
                modal.querySelector('#talk-modal-title').textContent = link.textContent || '';
                modal.querySelector('[data-talk-permalink]').setAttribute('href', url);

                // タイムテーブル上のチェックボックスと連動する参加ボタン
                var talkId = link.getAttribute('data-talk-id');
                var checkbox = talkId && document.querySelector('.talks_checkbox[talk_id="' + talkId + '"]');
                var selectButton = modal.querySelector('[data-talk-select]');
                if (checkbox) {
                    var renderSelectButton = function() {
                        if (checkbox.checked) {
                            selectButton.textContent = '✓ 参加予定（取り消す）';
                            selectButton.className = TALK_MODAL_BUTTON_OUTLINE;
                        } else {
                            selectButton.textContent = checkbox.disabled ? '満席' : 'このセッションに参加する';
                            selectButton.className = TALK_MODAL_BUTTON_PRIMARY;
                        }
                        selectButton.disabled = checkbox.disabled;
                    };
                    selectButton.addEventListener('click', function() {
                        // click() で排他制御や件数表示のハンドラも動かす
                        checkbox.click();
                        renderSelectButton();
                    });
                    renderSelectButton();
                }

                modal.className = TALK_MODAL_OVERLAY_CLASS;
                document.body.style.overflow = 'hidden';
                // キーボード操作をダイアログ内から始められるようにする（× にフォーカスリングを出さない）
                modal.querySelector('[data-talk-modal-dialog]').focus({ preventScroll: true });

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
                    modal.className = 'tw-hidden';
                    modal.innerHTML = '';
                    document.body.style.overflow = '';
                    link.focus();
                }

                modal.querySelectorAll('[data-dismiss-talk-modal]').forEach(function(btn) {
                    btn.addEventListener('click', closeModal);
                });
                // ダイアログ本体の外側（オーバーレイ）をクリックしたら閉じる
                modal.onclick = function(event) {
                    if (!event.target.closest('[data-talk-modal-dialog]')) closeModal();
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
