import { Controller } from "@hotwired/stimulus"
import { useClickOutside } from 'stimulus-use'
import { get } from "@rails/request.js"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ['modal']
  static values = { url: String }

  connect() {
    useClickOutside(this)
  }

  toggle() {
    if (this.urlValue && !this.isOpen())
      this.loadAndOpen() 
    else
      this.modalTarget.classList.toggle('hidden')
  }

  clickOutside(event) {
    this.hide()
  }

  show() {
    this.modalTarget.classList.remove('hidden')
  }

  hide() {
    this.modalTarget.classList.add('hidden')
  }

  isOpen() {
    return !this.modalTarget.classList.contains('hidden')
  }

  async loadAndOpen() {
    const response = await get(this.urlValue, {
      headers: {
        'Accept': 'text/vnd.turbo-stream.html, text/html, application/xhtml+xml'
      }
    })
    if (response.ok) this.show()
  }
}
