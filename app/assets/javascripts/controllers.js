import { Application } from "@hotwired/stimulus"

import BattleController from "./controllers/battle_controller.js"

const application = Application.start()

application.register("battle", BattleController)