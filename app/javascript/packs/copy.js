window.onload = () => {
    document.getElementsByClassName('copy_button').forEach((elm) => {
        elm.addEventListener('click', (e) => {
            const url = e.target.parentElement.parentElement.querySelector('.dest_url').textContent
            const parent = e.target.parentElement
            const icon = e.target

            navigator.clipboard.writeText(url)
                .then(() => {
                    console.log("Copied to clipboard successfully!")
                    e.target.parentElement.textContent = "Copied"
                    setTimeout(() => {
                        parent.textContent = ""
                        parent.appendChild(icon)
                    }, 5000)
                })
                .catch((error) => {
                    console.error("Failed to copy", error);
                });

        });
    })
}