public class genTone{
  float      freq;
  soundGen   gen;
  Wavetable  waveform;
  Oscil    os;
  genTone(String n, float vol, soundGen g, Wavetable w){
    freq = Frequency.ofPitch(n).asHz();
    gen = g;
    waveform = w;
    os = gen.generateTone(Frequency.ofHertz(freq), vol, waveform);
  }
  genTone(float f, float vol, soundGen g, Wavetable w){
    freq = f;
    gen = g;
    waveform = w;
    os = gen.generateTone(Frequency.ofHertz(freq), vol, waveform);
  }
  void on(){
    gen.patchIn(os);
  }
  void off(){
    gen.unPatch(os);  
  }
}
