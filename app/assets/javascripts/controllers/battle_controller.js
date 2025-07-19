import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["unit", "battlefield", "status", "log"]

  connect() {
    console.log("Battle controller connected")
    this.setupEventListeners()
  }

  setupEventListeners() {
    this.element.addEventListener("battle:unit-selected", this.handleUnitSelected.bind(this))
    this.element.addEventListener("battle:action-performed", this.handleActionPerformed.bind(this))
  }

  handleUnitSelected(event) {
    const unitId = event.detail.unitId
    const unitElement = this.unitTargets.find(target => target.dataset.unitId === unitId)
    
    if (unitElement) {
      this.highlightUnit(unitElement)
      this.showUnitDetails(unitId)
    }
  }

  handleActionPerformed(event) {
    const { action, unitId, targetId } = event.detail
    
    this.updateBattlefield()
    this.updateUnitStatus(unitId)
    if (targetId) {
      this.updateUnitStatus(targetId)
    }
    this.addToBattleLog(action, unitId, targetId)
  }

  highlightUnit(unitElement) {
    this.unitTargets.forEach(target => target.classList.remove("selected"))
    unitElement.classList.add("selected")
  }

  showUnitDetails(unitId) {
    fetch(`/units/${unitId}.json`)
      .then(response => response.json())
      .then(data => {
        const detailsPanel = document.getElementById("unit-details")
        if (detailsPanel) {
          detailsPanel.innerHTML = this.renderUnitDetails(data)
        }
      })
  }

  renderUnitDetails(unit) {
    return `
      <h3>${unit.name}</h3>
      <p>Type: ${unit.unit_type}</p>
      <p>Health: ${unit.health || unit.max_health}/${unit.max_health}</p>
      <p>Morale: ${unit.morale || 100}/100</p>
      <p>Attack: ${unit.attack}</p>
      <p>Defense: ${unit.defense}</p>
      ${unit.special_abilities ? `<p>Special: ${unit.special_abilities.join(", ")}</p>` : ''}
    `
  }

  updateBattlefield() {
    // Refresh the battlefield view
    const battlefield = this.battlefieldTarget
    if (battlefield) {
      battlefield.dispatchEvent(new CustomEvent("battlefield:refresh"))
    }
  }

  updateUnitStatus(unitId) {
    const unitElement = this.unitTargets.find(target => target.dataset.unitId === unitId)
    if (unitElement) {
      fetch(`/battle_units/${unitId}.json`)
        .then(response => response.json())
        .then(data => {
          this.updateUnitDisplay(unitElement, data)
        })
    }
  }

  updateUnitDisplay(element, unitData) {
    const healthBar = element.querySelector(".health-bar")
    const moraleBar = element.querySelector(".morale-bar")
    
    if (healthBar) {
      healthBar.style.width = `${(unitData.current_health / unitData.max_health) * 100}%`
    }
    
    if (moraleBar) {
      moraleBar.style.width = `${(unitData.current_morale / 100) * 100}%`
    }
  }

  addToBattleLog(action, unitId, targetId) {
    const log = this.logTarget
    if (log) {
      const entry = document.createElement("div")
      entry.className = "battle-log-entry"
      entry.textContent = `${action} - Unit ${unitId}${targetId ? ` targeting ${targetId}` : ''}`
      log.appendChild(entry)
      log.scrollTop = log.scrollHeight
    }
  }

  // Battle action methods
  attack(event) {
    const unitId = event.currentTarget.dataset.unitId
    const targetId = event.currentTarget.dataset.targetId
    
    this.performAction("attack", unitId, targetId)
  }

  defend(event) {
    const unitId = event.currentTarget.dataset.unitId
    
    this.performAction("defend", unitId)
  }

  retreat(event) {
    const unitId = event.currentTarget.dataset.unitId
    
    this.performAction("retreat", unitId)
  }

  performAction(action, unitId, targetId = null) {
    fetch(`/battles/${this.element.dataset.battleId}/perform_action`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({
        action: action,
        unit_id: unitId,
        target_id: targetId
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.element.dispatchEvent(new CustomEvent("battle:action-performed", {
          detail: { action, unitId, targetId, result: data }
        }))
      }
    })
  }
}