import { Controller } from "@hotwired/stimulus";
import Cropper from "cropperjs";
import { Uppy } from "@uppy/core";
// Import Uppy CSS
import "@uppy/core/css/style.min.css";
import "@uppy/progress-bar/dist/style.css";
import "@uppy/informer/dist/style.css";
import "@uppy/file-input/dist/style.css";
import FileInput from "@uppy/file-input";
import Informer from "@uppy/informer";
import ProgressBar from "@uppy/progress-bar";
import ThumbnailGenerator from "@uppy/thumbnail-generator";
import XHRUpload from "@uppy/xhr-upload";

export default class extends Controller {
  static targets = ["fileInput"];

  connect() {
    this.fileInputTargets.forEach((fileInput) => {
      console.log(fileInput);
      this.cropUpload(fileInput);
    });
  }

  cropUpload(fileInput) {
    console.log(fileInput);
    let formGroup = fileInput.parentNode;
    console.log(formGroup);
    let hiddenInput = document.querySelector(".upload-data");
    console.log(hiddenInput);
    let imagePreview = document.querySelector(".image-preview img");
    console.log(imagePreview);

    // Cropperインスタンスを保持する変数
    let currentCropper = null;

    // 既に画像がある場合はプレースホルダーを非表示にする
    const imagePreviewContainer = imagePreview.parentNode;
    const placeholder = imagePreviewContainer.querySelector(".image-placeholder");

    // srcが有効なURLの場合（空でなく、現在のページURLでもない）
    const hasValidSrc = imagePreview.getAttribute("src") && imagePreview.getAttribute("src") !== "";
    if (hasValidSrc && placeholder) {
      placeholder.style.setProperty("display", "none", "important");
      imagePreview.style.setProperty("display", "block", "important");
    }

    formGroup.removeChild(fileInput);

    let uppy = new Uppy({
      autoProceed: true,
    })
      .use(FileInput, {
        target: formGroup,
        locale: { strings: { chooseFiles: "Choose file" } },
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
        endpoint: "/upload/avatar",
      });

    uppy.on("upload-success", function (file, response) {
      // プレースホルダーを非表示
      const imagePreviewContainer = imagePreview.parentNode;
      const placeholder = imagePreviewContainer.querySelector(".image-placeholder");
      if (placeholder) {
        placeholder.style.setProperty("display", "none", "important");
      }

      hiddenInput.value = JSON.stringify(response.body["data"]);

      // 既存のCropperインスタンスがあれば画像を置き換え
      if (currentCropper) {
        currentCropper.replace(response.uploadURL);
      } else {
        // 初回アップロード時: 画像を設定してCropperを作成
        imagePreview.src = response.uploadURL;
        // Cropperが表示を管理するので、inline styleのdisplay:noneを削除
        imagePreview.style.removeProperty("display");

        currentCropper = new Cropper(imagePreview, {
          aspectRatio: 1,
          viewMode: 1,
          guides: false,
          autoCropArea: 1.0,
          background: false,
          checkCrossOrigin: false,
          crop: function (event) {
            let data = JSON.parse(hiddenInput.value);
            data["metadata"]["crop"] = event.detail;
            hiddenInput.value = JSON.stringify(data);
          },
        });
      }
    });
  }
}
