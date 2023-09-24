window.onload = () => {

    document.getElementsByClassName('copy_button').forEach((elm) => {
        elm.addEventListener('click', (e) => {
            navigator.clipboard.writeText(e.target.parentElement.parentElement.querySelector('.dest_url').textContent)
                .then(() => {
                    e.target.parentElement.textContent = "Copied"
                })
                .catch((error) => {
                    console.error("Failed to copy", error);
                });

        });
    })
}