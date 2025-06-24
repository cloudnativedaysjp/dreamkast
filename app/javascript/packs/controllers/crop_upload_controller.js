import { Controller } from "@hotwired/stimulus"
import Cropper from "cropperjs"
import { Uppy } from '@uppy/core'
import FileInput from '@uppy/file-input'
import Informer from '@uppy/informer'
import ProgressBar from '@uppy/progress-bar'
import ThumbnailGenerator from '@uppy/thumbnail-generator'
import XHRUpload from '@uppy/xhr-upload'

export default class extends Controller {
    static targets = [ "fileInput" ]

    connect() {
        this.fileInputTargets.forEach(fileInput => {
            console.log(fileInput)
            this.cropUpload(fileInput)
        })
    }

    cropUpload(fileInput) {
        console.log(fileInput)
        let formGroup = fileInput.parentNode
        console.log(formGroup)
        let hiddenInput = document.querySelector('.upload-data')
        console.log(hiddenInput)
        let imagePreview = document.querySelector('.image-preview img')
        console.log(imagePreview)

        formGroup.removeChild(fileInput)

        let uppy = new Uppy({
            autoProceed: true,
        })
            .use(FileInput, {
                target: formGroup,
                locale: { strings: { chooseFiles: 'Choose file' } },
            })
            .use(Informer, {
                target: formGroup,
            })
            .use(ProgressBar, {
                target: imagePreview.parentNode,
            })
            .use(ThumbnailGenerator, {
                thumbnailWidth: 600,
            })
            .use(XHRUpload, {
                endpoint: '/upload/avatar',
            })

        uppy.on('upload-success', function (file, response) {
            imagePreview.src = response.uploadURL

            hiddenInput.value = JSON.stringify(response.body['data'])

            let copper = new Cropper(imagePreview, {
                aspectRatio: 1,
                viewMode: 1,
                guides: false,
                autoCropArea: 1.0,
                background: false,
                checkCrossOrigin: false,
                crop: function (event) {
                    let data = JSON.parse(hiddenInput.value)
                    data['metadata']['crop'] = event.detail
                    hiddenInput.value = JSON.stringify(data)
                }
            })
        })
    }
}