import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['pane']
  static values = { selectedPane: String }

  connect() {
    if (this.selectedPaneValue)
      this.show(`${this.selectedPaneValue}-pane`)
  }

  change(event) {
    this.hideAll()
    this.show(`${event.target.value}-pane`)
  }

  show(paneId) {
    this.paneTargets.forEach(pane => {
      if (pane.id === paneId)
        pane.classList.remove('hidden')
    })
  }

  hideAll() {
    this.paneTargets.forEach(pane => pane.classList.add('hidden'))
  }
}