
class SFXManager {
  constructor() {
    this.interval = 0;
    this.timeout = null;    
    this.ctx = new AudioContext();
    
    this.beep = this.beep.bind(this);
  }
  
  getFrequency(numSemitones) {
    return 440 * Math.pow(Math.pow(2, 1/12), numSemitones);
  };
  
  beep() {
    const t0 = this.ctx.currentTime;
    const t1 = t0 + 0.075;
    const t2 = t0 + 1.5;
    const oscL = this.ctx.createOscillator();
    const oscR = this.ctx.createOscillator();
    const merger = this.ctx.createChannelMerger(2);
    const amp = this.ctx.createGain();
    
    oscL.type = 'square';
    oscR.type = 'square';
    amp.gain.value = 0;
    oscL.start(t0);
    oscR.start(t0);
    oscL.detune.value =  3.5;
    oscR.detune.value = -3.5;
    oscL.connect(merger, 0, 0);
    oscR.connect(merger, 0, 1);
    merger.connect(amp);
    amp.connect(this.ctx.destination);
    
    oscL.frequency.cancelScheduledValues(t0);
    oscR.frequency.cancelScheduledValues(t0);
    amp.gain.cancelScheduledValues(t0);

    oscL.frequency.setValueAtTime(this.getFrequency(0 + this.interval), t0);
    oscR.frequency.setValueAtTime(this.getFrequency(0 + this.interval), t0);
    oscL.frequency.setValueAtTime(this.getFrequency(12 + this.interval), t1);
    oscR.frequency.setValueAtTime(this.getFrequency(12 + this.interval), t1);

    amp.gain.setValueAtTime(0.175, t0);
    amp.gain.exponentialRampToValueAtTime(1e-6, t2);
    oscL.stop(t2);
    oscR.stop(t2);
    
    this.interval = this.interval + 2;
    window.clearTimeout(this.timeout);
    this.timeout = window.setTimeout(()=>{this.interval = 0}, 1250);
    
  }
}

export let sfxManager = new SFXManager()