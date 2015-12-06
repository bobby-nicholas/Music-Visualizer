public class genListener extends listener{
  private int GEN_INDEX = -1;
  private soundGen gen;
  genListener(soundSource[] src){
    super(src);
    if(sources!=null){
      for(int i=0; i<sources.length; i++)
        if(sources[i] instanceof soundGen){
          GEN_INDEX = i; 
          break;
        }
    }
    gen = GEN_INDEX != -1 ? (soundGen)sources[GEN_INDEX] : null;      
    if(gen == null) println("warning");
  }
  void setBufferSize(int bSize){
    gen.setBufferSize(bSize);
  }
  void setSampleRate(float sRate){
    gen.setSampleRate(sRate);  
  }
  genTone triggerTone(String n, float vol, Wavetable wave){
    return new genTone(n, vol, gen, wave);
  }
  genTone triggerTone(float freq, float vol, Wavetable wave){
    return new genTone(freq, vol, gen, wave);
  }
  genTone triggerTone(String mKey, float oct, int hSteps, float vol, Wavetable wave){
    float freq = toFrequency(mKey, oct, hSteps);
    println(freq);
    return new genTone(freq, vol, gen, wave);
  }
  //THIS NEEDS FIXING
  float toFrequency(String mKey, float oct, int hSteps){
     float f = (pow(pow(2,(1/12.0)), hSteps)) * getKey(mKey);
     return f * oct;     
  }
  int majorScaleDegreeToHalfStep(int degree){
    if(degree == 1) return 0;
    if(degree == 2) return 2;
    if(degree == 3) return 4;
    if(degree == 4) return 5;
    if(degree == 5) return 7;
    if(degree == 6) return 9;
    if(degree == 7) return 11;
    else return -1;
  }
  float getKey(String k){
    int hSteps = -1;
    if     (k == "A"              ) hSteps = 0;
    else if(k == "A#" || k == "Bb") hSteps = 1;
    else if(k == "B"  || k == "Cb") hSteps = 2;
    else if(k == "C"  || k == "B#") hSteps = 3;
    else if(k == "C#" || k == "Db") hSteps = 4;
    else if(k == "D"              ) hSteps = 5;
    else if(k == "D#" || k == "Eb") hSteps = 6;
    else if(k == "E"  || k == "Fb") hSteps = 7;
    else if(k == "F"  || k == "E#") hSteps = 8;
    else if(k == "F#" || k == "Gb") hSteps = 9;
    else if(k == "G"              ) hSteps = 10;
    else if(k == "G#" || k == "Ab") hSteps = 11;
    return hSteps != -1 ? (pow(pow(2,(1/12.0)), hSteps) * 55) : 0;
  }
  String hStepToNote(int steps, String curKey){
    int pClass = steps % 12;
    switch(pClass){
      case 0:  return "A";
      case 1:  
          if(curKey == "F") 
               return "Bb";
          else return "A#"; 
      case 2:  return "B";
      case 3:  return "C";
      case 4:  return "C#";
      case 5:  return "D";
      case 6:  return "D#";
      case 7:  return "E";
      case 8:  return "F";
      case 9:  return "F#";
      case 10: return "G";
      case 11: return "G#";
      default: return "";
    }
  }
  int keyToHalfStep(String k){
    if(k == "A")     return 0;
    if(k == "A#/Bb") return 1;
    if(k == "B")     return 2;
    if(k == "C")     return 3;
    if(k == "C#/Db") return 4;
    if(k == "D")     return 5;
    if(k == "D#/Eb") return 6;
    if(k == "E")     return 7;
    if(k == "F")     return 8;
    if(k == "F#/Gb") return 9;
    if(k == "G")     return 10;
    if(k == "G#/Ab") return 11;
    else return -1;
  }
  int freqToOctave(float freq){
    if(freq < 31)    return 0;
    if(freq < 62)    return 1;
    if(freq < 124)   return 2;
    if(freq < 247)   return 3;
    if(freq < 494)   return 4;
    if(freq < 988)   return 5;
    if(freq < 1976)  return 6;
    if(freq < 3952)  return 7;
    if(freq < 7903)  return 8;
    if(freq < 12544) return 9;
    if(freq < 25088) return 10;
    else             return 11;
  }
}
