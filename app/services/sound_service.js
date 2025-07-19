class SoundService {
  constructor() {
    this.audioContext = null;
    this.sounds = {};
    this.musicEnabled = true;
    this.sfxEnabled = true;
    this.volume = 0.7;
  }

  async initialize() {
    try {
      this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
      await this.loadSounds();
      return true;
    } catch (error) {
      console.warn('Audio initialization failed:', error);
      return false;
    }
  }

  async loadSounds() {
    const soundFiles = {
      battleStart: '/sounds/battle_start.mp3',
      unitMove: '/sounds/unit_move.mp3',
      unitAttack: '/sounds/unit_attack.mp3',
      unitDefend: '/sounds/unit_defend.mp3',
      victory: '/sounds/victory.mp3',
      defeat: '/sounds/defeat.mp3',
      ambient: '/sounds/ambient_battle.mp3'
    };

    for (const [key, path] of Object.entries(soundFiles)) {
      try {
        const response = await fetch(path);
        const arrayBuffer = await response.arrayBuffer();
        const audioBuffer = await this.audioContext.decodeAudioData(arrayBuffer);
        this.sounds[key] = audioBuffer;
      } catch (error) {
        console.warn(`Failed to load sound ${key}:`, error);
      }
    }
  }

  playSound(soundName, loop = false) {
    if (!this.sfxEnabled || !this.sounds[soundName]) return;

    const source = this.audioContext.createBufferSource();
    const gainNode = this.audioContext.createGain();
    
    source.buffer = this.sounds[soundName];
    source.loop = loop;
    gainNode.gain.value = this.volume;
    
    source.connect(gainNode);
    gainNode.connect(this.audioContext.destination);
    
    source.start();
    
    return source;
  }

  playBattleStart() {
    return this.playSound('battleStart');
  }

  playUnitMove() {
    return this.playSound('unitMove');
  }

  playUnitAttack() {
    return this.playSound('unitAttack');
  }

  playUnitDefend() {
    return this.playSound('unitDefend');
  }

  playVictory() {
    return this.playSound('victory');
  }

  playDefeat() {
    return this.playSound('defeat');
  }

  playAmbientBattle() {
    return this.playSound('ambient', true);
  }

  setVolume(volume) {
    this.volume = Math.max(0, Math.min(1, volume));
  }

  toggleMusic() {
    this.musicEnabled = !this.musicEnabled;
    return this.musicEnabled;
  }

  toggleSFX() {
    this.sfxEnabled = !this.sfxEnabled;
    return this.sfxEnabled;
  }

  stopAllSounds() {
    if (this.audioContext) {
      this.audioContext.close();
      this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
    }
  }
}

// Export for use in Rails asset pipeline
if (typeof module !== 'undefined' && module.exports) {
  module.exports = SoundService;
} else {
  window.SoundService = SoundService;
}