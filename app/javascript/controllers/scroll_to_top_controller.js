import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "button" ]

  connect() {
    this.toggleVisibility = this.toggleVisibility.bind(this)
    window.addEventListener("scroll", this.toggleVisibility)
    this.toggleVisibility()
  }

  disconnect() {
    window.removeEventListener("scroll", this.toggleVisibility)
  }

  scrollToTop() {
    window.scrollTo({
      top: 0,
      behavior: "instant"
    })
  }

  toggleVisibility() {
    if (window.scrollY > 500) {
      this.buttonTarget.classList.remove("hidden")
    } else {
      this.buttonTarget.classList.add("hidden")
    }
  }
}
