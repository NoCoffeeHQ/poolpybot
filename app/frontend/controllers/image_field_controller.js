import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['image', 'uploader', 'emptyUploader', 'input']

  change(event) {
    this.imageTarget.src = URL.createObjectURL(event.target.files[0])
    this.imageTarget.classList.remove('hidden')
    this.uploaderTarget.classList.remove('hidden')
    this.emptyUploaderTarget.classList.add('hidden')
  }

  openDialog(event) {
    event.stopPropagation() & event.preventDefault()
    this.inputTarget.click()
  }
}
