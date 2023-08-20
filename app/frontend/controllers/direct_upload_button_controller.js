import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['icon', 'text']
  static values = { inProgressLabel: String }

  connect() {
    this.element.addEventListener('change', () => {
      this.element.requestSubmit()
    })
  }

  startUploading(event) {
    this.textTarget.innerHTML = this.inProgressLabelValue
    this.iconTarget.classList.add('animate-bounce')
  }
}