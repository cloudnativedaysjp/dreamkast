const fieldLength = () => {
    let sum = 0;
    Object.keys(document.getElementsByClassName('talk-field')).forEach((key) => {
        if(document.getElementsByClassName('talk-field')[key].hidden == false){
            sum += 1;
        }
    })
    return sum;
}

const initializeAddTalkButton = () => {
    const fields = Array.from(document.getElementsByClassName('add_talk_fields'))
    if (fields.length === 0) {
        return;
    }
    fields[0].addEventListener('click', (e) => {
        e.preventDefault();
        const time = new Date().getTime();
        const regexp = new RegExp(e.target.dataset.id, 'g');
        let div = document.createElement('div');
        div.innerHTML = e.target.dataset.fields.replace(regexp, time);
        document.getElementsByClassName('talk-fields')[0].append(div);
        if (fieldLength() >= 3) {
            document.getElementsByClassName('add-talk')[0].hidden = false;
        }
        addDeleteButtonListener(div.querySelector('.remove_talk_field'));
        // 動的に追加されたフィールドにも文字数カウンターを適用
        setTimeout(() => {
            initializeCharCounter();
        }, 100);
        return false;
    });
}

const initializeRemoveTalkButton = () => {
    Array.from(document.getElementsByClassName('remove_talk_field')).forEach((obj) => {addDeleteButtonListener(obj)});
}

if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        initializeAddTalkButton();
        initializeRemoveTalkButton()
    })
} else {
    initializeAddTalkButton();
    initializeRemoveTalkButton()
}


document.addEventListener('change', (e) => {
    if (e.target.classList.contains('talk-categories')) {
        const radio20min = e.target.parentElement.parentElement.querySelector('._20min');
        const radio40min = e.target.parentElement.parentElement.querySelector('._40min');
        if (e.target.selectedOptions[0].innerHTML == 'Keynote') {
            radio20min.disabled = false;
            radio40min.disabled = true;
            radio20min.checked = true;
        } else {
            radio20min.checked = false;
            radio20min.disabled = true;
            radio40min.disabled = false;
            radio40min.checked = true;
        }
    }
    return false;
});

const addDeleteButtonListener = (obj) => {
    obj.removeEventListener('click', buttonListener);
    obj.addEventListener('click', buttonListener);
}

const buttonListener = (e) => {
    e.preventDefault();
    if (confirm("このセッションを削除しますか？")) {
        e.target.parentElement.querySelector('.destroy_flag_field').value = 1;
        e.target.closest('.talk-field').hidden = true;
        ['input', 'textarea', 'select'].forEach((selector) => {
            e.target.parentElement.querySelectorAll(selector).forEach((elm) => {
                ['required', 'max', 'min', 'maxlength', 'pattern'].forEach((attr) => {
                    elm.removeAttribute(attr);
                })
            })
        })
        if (fieldLength() < 3) {
            document.getElementsByClassName('add-talk')[0].hidden = false;
        }
    }
}

// 文字数をカウント（全角・半角関係なく）
const countChars = (str) => {
    if (!str) return 0;
    return str.length;
}

// 文字数制限を適用（タイトル: 60文字、概要: 500文字）
const MAX_TITLE_CHARS = 60;
const MAX_ABSTRACT_CHARS = 500;

const initializeCharCounter = () => {
    // タイトルと概要欄の入力フィールドを取得
    const titleInputs = document.querySelectorAll('input[name*="[title]"]');
    const abstractInputs = document.querySelectorAll('textarea[name*="[abstract]"]');
    
    const setupCharCounter = (input, counterId, maxChars) => {
        // カウンター要素が既に存在する場合はスキップ
        if (document.getElementById(counterId)) {
            return;
        }
        
        // カウンター要素を作成
        const counter = document.createElement('span');
        counter.id = counterId;
        counter.className = 'char-counter';
        counter.style.fontSize = '0.7em';
        counter.style.color = '#666';
        counter.style.marginLeft = '5px';
        
        // 入力フィールドの親要素にカウンターを追加
        const fieldDiv = input.closest('.field');
        if (fieldDiv) {
            const label = fieldDiv.querySelector('label');
            if (label) {
                label.appendChild(counter);
            }
        }
        
        // 文字数カウントと表示を更新
        const updateCounter = () => {
            const text = input.value || '';
            const charCount = countChars(text);
            counter.textContent = `(${charCount}/${maxChars}文字)`;
            
            if (charCount > maxChars) {
                counter.style.color = '#dc3545';
                input.style.borderColor = '#dc3545';
            } else {
                counter.style.color = '#666';
                input.style.borderColor = '';
            }
        };
        
        // 入力時に文字数をチェックし、制限を超えた場合は入力を制限
        input.addEventListener('input', (e) => {
            const text = e.target.value || '';
            const charCount = countChars(text);
            
            if (charCount > maxChars) {
                // 制限を超えた場合、最後の文字を削除
                e.target.value = text.slice(0, maxChars);
            }
            
            updateCounter();
        });
        
        // 初期表示
        updateCounter();
    };
    
    // タイトル欄にカウンターを設定（60文字制限）
    titleInputs.forEach((input, index) => {
        const formIndex = input.name.match(/\[(\d+)\]/)?.[1] || index;
        setupCharCounter(input, `title-counter-${formIndex}`, MAX_TITLE_CHARS);
    });
    
    // 概要欄にカウンターを設定（500文字制限）
    abstractInputs.forEach((input, index) => {
        const formIndex = input.name.match(/\[(\d+)\]/)?.[1] || index;
        setupCharCounter(input, `abstract-counter-${formIndex}`, MAX_ABSTRACT_CHARS);
    });
}

// ページ読み込み時と動的に追加されたフィールドにも適用
const initializeCharCounters = () => {
    initializeCharCounter();
    
    // 動的に追加されたフィールドにも適用するため、MutationObserverを使用
    const observer = new MutationObserver(() => {
        initializeCharCounter();
    });
    
    const talkFieldsContainer = document.querySelector('.talk-fields');
    if (talkFieldsContainer) {
        observer.observe(talkFieldsContainer, {
            childList: true,
            subtree: true
        });
    }
}

// 既存の初期化処理に追加
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        initializeAddTalkButton();
        initializeRemoveTalkButton();
        initializeCharCounters();
    })
} else {
    initializeAddTalkButton();
    initializeRemoveTalkButton();
    initializeCharCounters();
}
