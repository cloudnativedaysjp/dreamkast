import Cropper from "cropperjs"

function cropUpload(fileInput) {
  let formGroup = fileInput.parentNode
  let hiddenInput = document.querySelector('.upload-data')
  let imagePreview = document.querySelector('.image-preview img')

  formGroup.removeChild(fileInput)

  let uppy = Uppy.Core({
      autoProceed: true,
    })
    .use(Uppy.FileInput, {
      target: formGroup,
      locale: { strings: { chooseFiles: 'Choose file' } },
    })
    .use(Uppy.Informer, {
      target: formGroup,
    })
    .use(Uppy.ProgressBar, {
      target: imagePreview.parentNode,
    })
    .use(Uppy.ThumbnailGenerator, {
      thumbnailWidth: 600,
    })
    .use(Uppy.XHRUpload, {
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

window.addEventListener('load', function () {
  document.querySelectorAll('#avatar_upload').forEach(function (fileInput) {
    cropUpload(fileInput)
  })
});
