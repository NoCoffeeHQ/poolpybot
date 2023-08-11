import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String }
  static targets = ['copy', 'copied']

  connect() {
    this.element.addEventListener('click', (event) => this.copyToClipboard())
  }

  copyToClipboard() {
    this.copyTargets.forEach(el => el.classList.add('hidden'))
    this.copiedTargets.forEach(el => el.classList.remove('hidden'))
    navigator.clipboard.writeText(this.textValue)
    setTimeout(() => {
      this.copiedTargets.forEach(el => el.classList.add('hidden'))
      this.copyTargets.forEach(el => el.classList.remove('hidden'))
    }, 3000)
  }
}