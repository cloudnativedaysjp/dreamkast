import { Controller } from "@hotwired/stimulus"

// ヘッダーのモバイルメニューとユーザーメニューを Bootstrap なしで開閉する
export default class extends Controller {
  static targets = ["menu", "dropdown"]

  toggleMenu(event) {
    event.preventDefault()
    if (!this.hasMenuTarget) return

    const expanded = this.menuTarget.classList.toggle("is-open")
    event.currentTarget.setAttribute("aria-expanded", expanded.toString())
  }

  toggleDropdown(event) {
    event.preventDefault()
    if (!this.hasDropdownTarget) return

    const expanded = this.dropdownTarget.classList.toggle("is-open")
    event.currentTarget.setAttribute("aria-expanded", expanded.toString())
  }

  hideDropdown(event) {
    if (!this.hasDropdownTarget) return
    if (this.element.contains(event.target)) return

    this.dropdownTarget.classList.remove("is-open")
    const toggle = this.element.querySelector('[data-action*="navbar#toggleDropdown"]')
    toggle?.setAttribute("aria-expanded", "false")
  }
}
