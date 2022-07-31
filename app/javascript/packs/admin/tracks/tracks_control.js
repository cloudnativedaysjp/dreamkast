var elements = document.getElementsByClassName('start-offset');
var submit_button = document.getElementById('submit-offset');

elements.forEach(element => {
    element.addEventListener('change', function() {
        this.nextElementSibling.value = this.value;
        submit_button.classList.add('btn-danger');
    }, false);
});