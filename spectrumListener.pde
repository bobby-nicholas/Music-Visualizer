public class spectrumListener extends listener implements AudioListener{
  private FFT transform;
  private WindowFunction winFunction = FFT.NONE;
  private int bufferSize;
  private float sampleRate;
  spectrumListener(soundSource[] src){
    super(src);
    if(sources!=null && bufferSize()!=0 && sampleRate()!=0){
      bufferSize = bufferSize();
      sampleRate = sampleRate();
      transform = new FFT(bufferSize, sampleRate);
    }
  }
  boolean refresh(){
    if(sources!=null && transform!=null && bufferSize == bufferSize() && sampleRate == sampleRate()) return true;
    else if(sources!=null && bufferSize()!=0 && sampleRate()!=0){
      bufferSize = bufferSize();
      sampleRate = sampleRate();
      transform = new FFT(bufferSize, sampleRate);
      transform.window(winFunction);
      return true;
    }
    return false;
  }
  int spectrumSize()   { return transform!=null ? transform.specSize() : 0; }
  int spectrumAvgSize(){ return transform!=null ? transform.avgSize()  : 0; }
  float indexToFrequency(int index, boolean avg){
    if(avg) return transform!=null ? transform.getAverageCenterFrequency(index) : 0.0;
    else    return transform!=null ? transform.indexToFreq(index) : 0.0; 
  } 
  float[] spectrumBands(char chan){
    if(refresh()){
      transform.window(winFunction);
      transform.noAverages();
           if(chan=='l' || chan=='L') transform.forward(left());
      else if(chan=='r' || chan=='R') transform.forward(right());
      else if(chan=='m' || chan=='M') transform.forward(mix());
      else return null;
      float[] spec = new float[spectrumSize()];
      for(int i=0; i<spectrumSize(); i++) spec[i] = transform.getBand(i);
      return spec;
    }
    return null;
  }
  float[] spectrumRealPart(char chan){
    if(refresh()){
      transform.window(winFunction);
      transform.noAverages();
           if(chan=='l' || chan=='L') transform.forward(left());
      else if(chan=='r' || chan=='R') transform.forward(right());
      else if(chan=='m' || chan=='M') transform.forward(mix());
      else return null;
      float[] spec = transform.getSpectrumReal();
      return spec;
    }
    return null;
  }
  float[] spectrumFreqs(char chan){
    if(refresh()){
      transform.window(winFunction);
      transform.noAverages();
           if(chan=='l' || chan=='L') transform.forward(left());
      else if(chan=='r' || chan=='R') transform.forward(right());
      else if(chan=='m' || chan=='M') transform.forward(mix());
      else return null;
      float[] spec = new float[spectrumSize()];
      for(int i=0; i<spectrumSize(); i++) spec[i] = transform.getFreq(i);
      return spec;
    }
    return null;
  }
  float[] spectrumLogAvgs(char chan, float minOctWidth, int nAvgs){
    if(refresh()){
      transform.window(winFunction);
      transform.logAverages(int(minOctWidth), nAvgs);
           if(chan=='l' || chan=='L') transform.forward(left());
      else if(chan=='r' || chan=='R') transform.forward(right());
      else if(chan=='m' || chan=='M') transform.forward(mix());
      else return null;
      float[] spec = new float[spectrumAvgSize()];
      for(int i=0; i<spec.length; i++) spec[i] = transform.getAvg(i);
      return spec;
    }
    return null;
  }
  float[] spectrumLinAvgs(char chan, int nAvgs){
    if(refresh()){
      transform.window(winFunction);
      transform.linAverages(nAvgs);
           if(chan=='l' || chan=='L') transform.forward(left());
      else if(chan=='r' || chan=='R') transform.forward(right());
      else if(chan=='m' || chan=='M') transform.forward(mix());
      else return null;
      float[] spec = new float[spectrumAvgSize()];
      for(int i=0; i<spec.length; i++) spec[i] = transform.getAvg(i);
      return spec;
    }
    return null;
  }
  void setWinFunction(WindowFunction win){
    winFunction = win;  
  }
}
