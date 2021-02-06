const Uppy = require('@uppy/core')
const Dashboard = require('@uppy/dashboard')
const AwsS3Multipart = require('@uppy/aws-s3-multipart')

require('@uppy/core/dist/style.css')
require('@uppy/dashboard/dist/style.css')

const uppyTriggerElement = document.querySelector('.upload-data')

const startUppy = () => {
    const hiddenInput = document.querySelector('.upload-data')
    const uppy = Uppy({
        restrictions: {maxNumberOfFiles: 1}
    })
        .use(Dashboard, {
            height: 250,
            inline: true,
            target: '#drag-drop-area',
        })
        .use(AwsS3Multipart, {companionUrl: '/'})

    uppy.on('upload-success', (file, response) => {
        const uploadedFileData = {
            id: response.uploadURL.match(/\/video_file\/([^\?]+)/)[1],
            storage: 'video_file',
            metadata: {
                size: file.size,
                filename: file.name,
                mime_type: file.type,
            }
        }
        hiddenInput.value = JSON.stringify(uploadedFileData)
    })
}

if (uppyTriggerElement) {
    startUppy()
}
