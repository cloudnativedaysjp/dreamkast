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
            document.getElementsByClassName('add-talk')[0].hidden = true;
        }
        addDeleteButtonListener(div.querySelector('.remove_talk_field'));
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
            ['required', 'max', 'min', 'maxlength', 'pattern'].forEach((attr) => {
                e.target.parentElement.querySelectorAll(selector).forEach((elm) => {
                    elm.removeAttribute(attr);
                })
            })
        })
        if (fieldLength() < 3) {
            document.getElementsByClassName('add-talk')[0].hidden = false;
        }
    }
}
