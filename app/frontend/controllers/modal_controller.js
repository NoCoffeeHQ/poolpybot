import { Controller } from "@hotwired/stimulus"
import { useClickOutside } from 'stimulus-use'
import { get } from "@rails/request.js"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ['panel']
  
  connect() {
    this.show()
  }

  clickOutside(event) {
    if (event && this.panelTarget.contains(event.target)) {
      return
    }
    this.close()
  }

  show() {
    this.element.classList.remove('hidden')
    setTimeout(() => {
      this.panelTarget.classList.remove('hidden')  
    }, 200)
    
  }

  close() {
    this.panelTarget.classList.add('hidden')
    setTimeout(() => {
      this.element.classList.add('hidden')
    }, 200)
  }

  closeWithKeyboard(event) {
    if (event.code == 'Escape') {
      this.close()
    }
  }
}