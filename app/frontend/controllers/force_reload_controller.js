import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { doIt: Boolean }

  connect() {
    if (this.doItValue) {
      window.location.href = window.location.href
    }
  }
}