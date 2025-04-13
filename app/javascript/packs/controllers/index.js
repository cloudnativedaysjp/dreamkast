// Import and register all your controllers from the importmap under controllers/*

import { application } from "./application.js"

// Eager load all controllers defined in the import map under controllers/**/*_controller
// import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
// eagerLoadControllersFrom("controllers", application)

// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application)

import ShareRegistrationController from "./share_registration_controller.js"
application.register("share-registration", ShareRegistrationController)

import RemoveLinkFieldController from "./remove_link_field_controller.js"
application.register("remove-link-field", RemoveLinkFieldController)

import CopyController from "./copy_controller.js"
application.register("copy", CopyController)

import CropUploadController from "./crop_upload_controller.js"
application.register("crop-upload", CropUploadController)

import ModalController from "./modal_controller";
application.register("modal", ModalController);

import ToastController from "./toast_controller.js"
application.register("toast", ToastController)

import SponsorController from "./sponsor_controller.js"
application.register("sponsor", SponsorController)

import DragDropController from "./drag_drop_controller.js"
application.register("drag-drop", DragDropController)

import TalkLoggerController from "./talk_logger_controller.js"
application.register("talk-logger", TalkLoggerController)
