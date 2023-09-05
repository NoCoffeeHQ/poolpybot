import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {
  static values = { url: String }

  async connect() {
    this.pollId = setInterval(this.pollCallback.bind(this), 5000)
    this.pollCallback()
  }

  disconnect() {
    clearInterval(this.pollId)
  }

  async pollCallback() {
    console.log('called!')
    const response = await get(this.urlValue)

    if (response.ok) {
      const json = await response.json
    
      if (json.unread)
        this.element.classList.remove('hidden')
      else
        this.element.classList.add('hidden')
    }
  }
}