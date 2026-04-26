import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "postalCode",      // 郵便番号入力
    "prefecture",      // 都道府県セレクト
    "city",           // 市区町村入力
    "addressLine1",   // 町名・番地入力
    "loading",        // ローディング表示
    "error"           // エラー表示
  ]

  static values = {
    debounceDelay: { type: Number, default: 500 }
  }

  connect() {
    this.debounceTimer = null
  }

  // 郵便番号入力時に呼ばれる
  search(event) {
    const postalCode = this.postalCodeTarget.value.replace(/[^0-9]/g, '')

    // 7桁未満ならクリア
    if (postalCode.length < 7) {
      this.clearError()
      return
    }

    // デバウンス処理
    clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(() => {
      this.fetchAddress(postalCode)
    }, this.debounceDelayValue)
  }

  async fetchAddress(postalCode) {
    try {
      this.showLoading()
      this.clearError()

      const response = await fetch(`https://zipcloud.ibsnet.co.jp/api/search?zipcode=${postalCode}`)

      if (!response.ok) {
        throw new Error('API error')
      }

      const data = await response.json()

      if (data.status !== 200) {
        throw new Error(data.message || 'API error')
      }

      if (!data.results || data.results.length === 0) {
        this.showError('該当する住所が見つかりませんでした。郵便番号を確認してください。')
        return
      }

      this.fillAddress(data.results[0])
    } catch (error) {
      console.error('Postal code lookup error:', error)
      this.showError('住所の取得に失敗しました。しばらくしてから再度お試しください。')
    } finally {
      this.hideLoading()
    }
  }

  fillAddress(result) {
    // 都道府県をセレクトボックスから選択
    const prefecture = result.address1 // "東京都"
    const prefectureSelect = this.prefectureTarget

    // セレクトボックスの選択肢から該当する都道府県を探す
    for (let i = 0; i < prefectureSelect.options.length; i++) {
      if (prefectureSelect.options[i].value === prefecture) {
        prefectureSelect.selectedIndex = i
        break
      }
    }

    // 市区町村を設定
    this.cityTarget.value = result.address2

    // 町域を設定（既存の値がない場合のみ）
    if (!this.addressLine1Target.value) {
      this.addressLine1Target.value = result.address3
    }

    // フォーカスを町名・番地フィールドに移動
    this.addressLine1Target.focus()
  }

  showLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove('d-none')
    }
  }

  hideLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add('d-none')
    }
  }

  showError(message) {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = message
      this.errorTarget.classList.remove('d-none')
    }
  }

  clearError() {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = ''
      this.errorTarget.classList.add('d-none')
    }
  }
}
