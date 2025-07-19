import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    enabled: Boolean,
    volume: { type: Number, default: 0.7 }
  }

  connect() {
    this.audioContext = null
    this.sounds = {}
    this.ambientSound = null
    
    if (this.enabledValue) {
      this.initializeAudio()
    }
  }

  disconnect() {
    this.stopAllSounds()
  }

  initializeAudio() {
    try {
      this.audioContext = new (window.AudioContext || window.webkitAudioContext)()
    } catch (error) {
      console.warn('Web Audio API not supported')
    }
  }

  playSound(soundName) {
    if (!this.enabledValue || !this.audioContext) return

    // Create audio element for the sound
    const audio = new Audio(`/sounds/${soundName}`)
    audio.volume = this.volumeValue
    audio.play().catch(error => {
      console.warn(`Could not play sound: ${soundName}`, error)
    })
  }

  playAmbient(soundName) {
    if (!this.enabledValue) return

    // Stop current ambient sound
    this.stopAmbient()

    // Create new ambient sound
    this.ambientSound = new Audio(`/sounds/${soundName}`)
    this.ambientSound.volume = this.volumeValue * 0.3 // Lower volume for ambient
    this.ambientSound.loop = true
    this.ambientSound.play().catch(error => {
      console.warn(`Could not play ambient sound: ${soundName}`, error)
    })
  }

  stopAmbient() {
    if (this.ambientSound) {
      this.ambientSound.pause()
      this.ambientSound = null
    }
  }

  stopAllSounds() {
    this.stopAmbient()
    // Stop any other playing sounds
    Object.values(this.sounds).forEach(sound => {
      if (sound && !sound.paused) {
        sound.pause()
      }
    })
  }

  setVolume(volume) {
    this.volumeValue = Math.max(0, Math.min(1, volume))
    
    // Update all playing sounds
    if (this.ambientSound) {
      this.ambientSound.volume = this.volumeValue * 0.3
    }
  }

  toggleMute() {
    this.enabledValue = !this.enabledValue
    
    if (!this.enabledValue) {
      this.stopAllSounds()
    }
  }

  // Battle-specific sound methods
  playBattleStart() {
    this.playSound('battle_start.mp3')
  }

  playUnitMove() {
    this.playSound('unit_move.mp3')
  }

  playUnitAttack() {
    this.playSound('unit_attack.mp3')
  }

  playUnitDefend() {
    this.playSound('unit_defend.mp3')
  }

  playUnitDeath() {
    this.playSound('unit_death.mp3')
  }

  playVictory() {
    this.playSound('victory.mp3')
  }

  playDefeat() {
    this.playSound('defeat.mp3')
  }

  // Ambient sounds based on terrain and weather
  playBattleAmbient() {
    this.playAmbient('ambient_battle.mp3')
  }

  playColdAmbient() {
    this.playAmbient('ambient_cold.mp3')
  }

  playHotAmbient() {
    this.playAmbient('ambient_hot.mp3')
  }

  playRain() {
    this.playAmbient('rain.mp3')
  }

  playSnow() {
    this.playAmbient('snow.mp3')
  }

  playWind() {
    this.playAmbient('wind.mp3')
  }
}