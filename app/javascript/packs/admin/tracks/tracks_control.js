var elements = document.getElementsByClassName('start-offset');
elements.forEach(element => {
    element.addEventListener('change', function() {
        this.nextElementSibling.value = this.value;
    }, false);
});