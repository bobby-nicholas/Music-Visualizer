public class soundGen extends soundSource{
  private ArrayList<Oscil> activeOscils;
  private int              bufferSize;
  private float            sampleRate;

  soundGen(Minim m){
    super(m);
    bufferSize = 1024;
    sampleRate = 44100;
    source = minim.getLineOut(Minim.STEREO, bufferSize, sampleRate, 16);
    activeOscils = new ArrayList<Oscil>(); 
  }
  Oscil generateTone(Frequency freq, float amp, Waveform wav){
    return new Oscil(freq, amp, wav);
  }
  void patchIn(Oscil osc){
    if(!activeOscils.contains(osc)){
      osc.patch((AudioOutput)source);
      activeOscils.add(osc);
    }
  }
  void unPatch(Oscil osc){
    if(activeOscils.contains(osc)){
      osc.unpatch((AudioOutput)source);
      activeOscils.remove(activeOscils.indexOf(osc));
    }
  }
  void setSampleRate(float rate){
    if(source instanceof AudioOutput && rate > 5000 && rate < 50000){
      sampleRate = rate;
      if(purgeListeners()){
        source = minim.getLineOut(Minim.STEREO, bufferSize, sampleRate);
      }
      else print("Purge Failed");
    }
  }
  void setBufferSize(int size){
    if(source instanceof AudioOutput && size > 31 && size < 5121){
      float s = size;
      while(s % 2 == 0 && s > 1){
        s /= 2;  
      }
      if(s==1){
        bufferSize = size;
        if(purgeListeners()){
          source = minim.getLineOut(Minim.STEREO, bufferSize, sampleRate);
        }
        else print("Purge Failed");
      }
    }
  }
}
