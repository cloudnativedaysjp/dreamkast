const fieldLength = () => {
    let sum = 0;
    Object.keys(document.getElementsByClassName('talk-field')).forEach((key) => {
        if(document.getElementsByClassName('talk-field')[key].hidden == false){
            sum += 1;
        }
    })
    return sum;
}


window.onload = () => {
    document.getElementsByClassName('add_talk_fields')[0].addEventListener('click', (e) => {
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
    document.getElementsByClassName('remove_talk_field').forEach((obj) => {addDeleteButtonListener(obj)});
}

document.addEventListener('change', (e) => {
    if (e.target.classList.contains('talk-categories')) {
        const radio20min = e.target.parentElement.parentElement.querySelector('._20min');
        if (e.target.selectedOptions[0].innerHTML == 'Keynote') {
            radio20min.disabled = false;
            radio20min.checked = true;
        } else {
            radio20min.checked = false;
            radio20min.disabled = true;
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
        e.target.parentElement.querySelector('input').removeAttribute('required max min maxlength pattern');
        e.target.parentElement.querySelector('textarea').removeAttribute('required max min maxlength pattern');
        e.target.parentElement.querySelector('select').removeAttribute('required max min maxlength pattern');
        if (fieldLength() < 3) {
            document.getElementsByClassName('add-talk')[0].hidden = false;
        }
    }
}
