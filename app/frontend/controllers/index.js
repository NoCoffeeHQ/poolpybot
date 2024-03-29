// // Import and register all your controllers from the importmap under controllers/*

// import { application } from "controllers/application"

// // Eager load all controllers defined in the import map under controllers/**/*_controller
// import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
// eagerLoadControllersFrom("controllers", application)

// // Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// // import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// // lazyLoadControllersFrom("controllers", application)

import { Application } from '@hotwired/stimulus'
import { registerControllers } from 'stimulus-vite-helpers'
import StimulusTransition from "stimulus-transition"

const application = Application.start()
application.register('transition', StimulusTransition)

const controllers = import.meta.globEager('./**/*_controller.js')
registerControllers(application, controllers)