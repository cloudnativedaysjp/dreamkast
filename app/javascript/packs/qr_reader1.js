document.addEventListener("DOMContentLoaded", function() {
  const video = document.getElementById('video');
  const canvas = document.getElementById('canvas');
  const snapBtn = document.getElementById('snap');

  navigator.mediaDevices.getUserMedia({ video: true })
    .then(function(stream) {
      video.srcObject = stream;
      video.play();
    })
    .catch(function(err) {
      console.log("カメラの起動に失敗しました: " + err);
    });

  snapBtn.addEventListener('click', function() {
    const context = canvas.getContext('2d');
    context.drawImage(video, 0, 0, canvas.width, canvas.height);

    // キャプチャした画像をデータURLとして取得
    const imageData = canvas.toDataURL('image/jpeg');
    console.log(imageData);

    // ここで取得したデータURLをサーバーに送信するなどの処理を行う
  });
});
