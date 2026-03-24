import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { baseUrl: String }

  jump(event) {
    const value = event.target.value
    if (value) {
      window.location.href = `${this.baseUrlValue}/chapters/${value}`
    }
  }
}
