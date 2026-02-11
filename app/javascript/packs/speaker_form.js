const fieldLength = () => {
    let sum = 0;
    Object.keys(document.getElementsByClassName('talk-field')).forEach((key) => {
        if(document.getElementsByClassName('talk-field')[key].hidden == false){
            sum += 1;
        }
    })
    return sum;
}

// セッション追加ボタンのクリックハンドラー（重複登録を防ぐため名前付き関数として定義）
const handleAddTalkClick = (e) => {
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
    // 動的に追加されたフィールドにも文字数カウンター、カンファレンス選択機能、スタイル変更を適用
    setTimeout(() => {
        initializeCharCounter();
        initializeConferenceFieldToggle();
        initializeInputCardStyles();
    }, 100);
    return false;
};

const initializeAddTalkButton = () => {
    const fields = Array.from(document.getElementsByClassName('add_talk_fields'))
    if (fields.length === 0) {
        return;
    }
    // 既存のイベントリスナーを削除してから新しいリスナーを追加（重複登録を防ぐ）
    fields[0].removeEventListener('click', handleAddTalkClick);
    fields[0].addEventListener('click', handleAddTalkClick);
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
        // ボタン内のSVGやテキストがクリックされた場合も考慮して、closest()で削除ボタンを取得
        const deleteButton = e.target.closest('.remove_talk_field');
        const talkField = deleteButton.closest('.talk-field');

        // destroy_flag_fieldを設定
        const destroyFlag = talkField.querySelector('.destroy_flag_field');
        if (destroyFlag) {
            destroyFlag.value = 1;
        }

        // フィールドを非表示
        talkField.hidden = true;

        // バリデーション属性を削除
        ['input', 'textarea', 'select'].forEach((selector) => {
            talkField.querySelectorAll(selector).forEach((elm) => {
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

// 文字数制限を適用（タイトル: 60文字、概要: 500文字）
const MAX_TITLE_CHARS = 60;
const MAX_ABSTRACT_CHARS = 500;

// 文字数をカウント（全角・半角・絵文字関係なく、絵文字は1文字としてカウント）
const countChars = (str) => {
    if (!str) return 0;
    // Intl.Segmenterを使って絵文字を正しく1文字としてカウント
    try {
        const segmenter = new Intl.Segmenter('ja', { granularity: 'grapheme' });
        return [...segmenter.segment(str)].length;
    } catch (e) {
        // フォールバック: スプレッド演算子を使用（古いブラウザ対応）
        return [...str].length;
    }
}

// テスト用にエクスポート（Node.js環境の場合のみ）
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { 
        countChars, 
        MAX_TITLE_CHARS, 
        MAX_ABSTRACT_CHARS,
        // テスト用に他の関数もエクスポート可能にする場合はここに追加
    };
}

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
                // 制限を超えた場合、絵文字を考慮して正しく切り詰める
                let truncated = '';
                try {
                    const segmenter = new Intl.Segmenter('ja', { granularity: 'grapheme' });
                    const segments = [...segmenter.segment(text)];
                    truncated = segments.slice(0, maxChars).map(seg => seg.segment).join('');
                } catch (err) {
                    // フォールバック: スプレッド演算子を使用
                    const chars = [...text];
                    truncated = chars.slice(0, maxChars).join('');
                }
                e.target.value = truncated;
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

// ===== 3カンファレンス選択機能 =====

/**
 * カンファレンス選択に応じてカテゴリ・受講者フィールドを表示/非表示
 */
const toggleConferenceFields = (formIndex) => {
    // HTMLで生成される実際のID（parameterize.underscoreの結果）に合わせる
    const cndCheckbox = document.getElementById(`target_conference_cloud_native_${formIndex}`);
    const pekCheckbox = document.getElementById(`target_conference_platform_engineering_${formIndex}`);
    const srekCheckbox = document.getElementById(`target_conference_sre_${formIndex}`);

    if (!cndCheckbox) return; // conference_id: 15 以外は何もしない

    // CloudNative Days フィールド
    const cndFields = document.querySelectorAll(`.cnd-fields[data-form-index="${formIndex}"]`);
    cndFields.forEach(field => {
        if (cndCheckbox.checked) {
            field.style.display = 'block';
            // required 属性を追加（selectタグ）
            field.querySelectorAll('.cnd-category-select').forEach(select => {
                select.setAttribute('required', 'required');
            });
        } else {
            field.style.display = 'none';
            // required 属性を削除し、選択をクリア（selectタグ）
            field.querySelectorAll('.cnd-category-select').forEach(select => {
                select.removeAttribute('required');
                select.selectedIndex = 0; // 最初のオプション（「選択してください」）に戻す
            });
            field.querySelectorAll('.cnd-visitor-checkbox').forEach(checkbox => {
                checkbox.checked = false;
            });
        }
    });

    // Platform Engineering フィールド
    const pekFields = document.querySelectorAll(`.pek-fields[data-form-index="${formIndex}"]`);
    pekFields.forEach(field => {
        if (pekCheckbox.checked) {
            field.style.display = 'block';
            // required 属性を追加（selectタグ）
            field.querySelectorAll('.pek-category-select').forEach(select => {
                select.setAttribute('required', 'required');
            });
        } else {
            field.style.display = 'none';
            // required 属性を削除し、選択をクリア（selectタグ）
            field.querySelectorAll('.pek-category-select').forEach(select => {
                select.removeAttribute('required');
                select.selectedIndex = 0; // 最初のオプション（「選択してください」）に戻す
            });
            field.querySelectorAll('.pek-visitor-checkbox').forEach(checkbox => {
                checkbox.checked = false;
            });
        }
    });

    // SRE フィールド
    const srekFields = document.querySelectorAll(`.srek-fields[data-form-index="${formIndex}"]`);
    srekFields.forEach(field => {
        if (srekCheckbox.checked) {
            field.style.display = 'block';
            // required 属性を追加（selectタグ）
            field.querySelectorAll('.srek-category-select').forEach(select => {
                select.setAttribute('required', 'required');
            });
        } else {
            field.style.display = 'none';
            // required 属性を削除し、選択をクリア（selectタグ）
            field.querySelectorAll('.srek-category-select').forEach(select => {
                select.removeAttribute('required');
                select.selectedIndex = 0; // 最初のオプション（「選択してください」）に戻す
            });
            field.querySelectorAll('.srek-visitor-checkbox').forEach(checkbox => {
                checkbox.checked = false;
            });
        }
    });
};

/**
 * カンファレンス選択チェックボックスにイベントリスナーを設定
 */
const initializeConferenceFieldToggle = () => {
    document.querySelectorAll('.target-conference-checkbox').forEach(checkbox => {
        const formIndex = checkbox.dataset.formIndex;

        // 初期表示制御
        toggleConferenceFields(formIndex);

        // 既にイベントリスナーが登録されている場合はスキップ（重複登録を防ぐ）
        if (!checkbox.dataset.listenerInitialized) {
            checkbox.dataset.listenerInitialized = 'true';
            // 変更イベント
            checkbox.addEventListener('change', () => {
                toggleConferenceFields(formIndex);
            });
        }
    });
};

// ===== ラジオボタン・チェックボックスの選択状態スタイル =====

/**
 * ラジオボタンの選択状態に応じてカードスタイルを更新
 */
const updateRadioCardStyles = (radioInput) => {
    const name = radioInput.name;
    // 同じname属性を持つすべてのラジオボタンを取得
    const allRadios = document.querySelectorAll(`input[type="radio"][name="${name}"]`);

    allRadios.forEach(radio => {
        const card = radio.closest('.cfp-radio-card');
        if (card) {
            if (radio.checked) {
                card.classList.add('border-primary', 'bg-primary', 'bg-opacity-10');
            } else {
                card.classList.remove('border-primary', 'bg-primary', 'bg-opacity-10');
            }
        }
    });
};

/**
 * チェックボックスの選択状態に応じてカードスタイルを更新
 */
const updateCheckboxCardStyles = (checkboxInput) => {
    const card = checkboxInput.closest('.cfp-checkbox-card, .cfp-conference-card');
    if (card) {
        if (checkboxInput.checked) {
            card.classList.add('border-primary', 'bg-primary', 'bg-opacity-10');
        } else {
            card.classList.remove('border-primary', 'bg-primary', 'bg-opacity-10');
        }
    }
};

/**
 * ラジオボタンとチェックボックスのスタイル変更イベントを初期化
 */
const initializeInputCardStyles = () => {
    // ラジオボタンの変更イベント
    document.querySelectorAll('.cfp-radio-card input[type="radio"]').forEach(radio => {
        if (!radio.dataset.styleListenerInitialized) {
            radio.dataset.styleListenerInitialized = 'true';
            radio.addEventListener('change', () => {
                updateRadioCardStyles(radio);
            });
        }
    });

    // チェックボックスの変更イベント
    document.querySelectorAll('.cfp-checkbox-card input[type="checkbox"], .cfp-conference-card input[type="checkbox"]').forEach(checkbox => {
        if (!checkbox.dataset.styleListenerInitialized) {
            checkbox.dataset.styleListenerInitialized = 'true';
            checkbox.addEventListener('change', () => {
                updateCheckboxCardStyles(checkbox);
            });
        }
    });

    // カード全体をクリックでラジオボタン/チェックボックスを選択
    document.querySelectorAll('.cfp-radio-card, .cfp-checkbox-card').forEach(card => {
        if (!card.dataset.cardClickInitialized) {
            card.dataset.cardClickInitialized = 'true';
            card.addEventListener('click', (e) => {
                // すでにinputやlabelをクリックした場合は何もしない
                if (e.target.tagName === 'INPUT' || e.target.tagName === 'LABEL') {
                    return;
                }
                const input = card.querySelector('input[type="radio"], input[type="checkbox"]');
                if (input && !input.disabled) {
                    if (input.type === 'radio') {
                        input.checked = true;
                        input.dispatchEvent(new Event('change', { bubbles: true }));
                    } else {
                        input.checked = !input.checked;
                        input.dispatchEvent(new Event('change', { bubbles: true }));
                    }
                }
            });
        }
    });
};

// 既存の初期化処理に追加
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        initializeAddTalkButton();
        initializeRemoveTalkButton();
        initializeCharCounters();
        initializeConferenceFieldToggle();
        initializeInputCardStyles(); // 追加
    })
} else {
    initializeAddTalkButton();
    initializeRemoveTalkButton();
    initializeCharCounters();
    initializeConferenceFieldToggle();
    initializeInputCardStyles(); // 追加
}

// Turbo Frame 内でフォームが差し替えられた場合にも再初期化
document.addEventListener('turbo:frame-load', () => {
    initializeCharCounters();
    initializeConferenceFieldToggle();
    initializeInputCardStyles();
});
