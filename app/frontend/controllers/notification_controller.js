import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]
  
  connect() {
    if (this.containerTarget) {
      this.containerTarget.classList.remove('hidden')

      setTimeout(() => { this.close() }, 10000)
    }
  }

  close() {
    this.containerTarget.classList.add('hidden')
  }
}
