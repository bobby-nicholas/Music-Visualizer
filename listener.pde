public abstract class listener implements AudioListener{
  synchronized void samples(float[] sam){ left = sam; }
  synchronized void samples(float[] l, float[] r){ left = l; right = r; }
/*----------------AudioListener Implementation-----------------------------*/  
  
  protected soundSource[] sources;
  protected int activeSource;
  protected float[] left;
  protected float[] right;
  listener(){
    sources = null;
    activeSource = NO_SOURCE;
  }
  listener(soundSource[] src){
    sources = src;
    if(sources!=null){
      if(sources.length > 1)
        activeSource = globalActiveSource;
      else activeSource = 0;
      listen();
      //if(!sources[activeSource].attachListener(this)) println("failed to attach to listener " + activeSource);
    }
    else activeSource = NO_SOURCE;
  }
  void setActiveSource(int src){
    if(src == NO_SOURCE || src == TRACK_PLAYER || src == SOUND_GEN || src == MICROPHONE){
      activeSource = src;
    }
  }
  float[] left() {
    if(sources==null || activeSource==NO_SOURCE || sources[activeSource].muted() || left==null)
      return bufferSize() != 0 ? new float[bufferSize()] : new float[64];
    return left;
  }
  float[] right(){ 
    if(sources==null || activeSource==NO_SOURCE || sources[activeSource].muted() || right==null)
      return bufferSize() != 0 ? new float[bufferSize()] : new float[64];
    return right;
  }
  float[] mix(){
    if(sources==null || activeSource==NO_SOURCE || sources[activeSource].muted() || left==null)
      return bufferSize() != 0 ? new float[bufferSize()] : new float[64];
    if(right!=null){
      float[] mix = new float[left.length];
      for(int i=0; i<left.length; i++) mix[i] = (left[i]+right[i]) / 2.0;
      return mix;
    }
    return left;
  }
  float level(char chan){
    if(sources==null || activeSource==NO_SOURCE || sources[activeSource].muted())
      return 0;
    if((chan=='L'||chan=='l') && left!=null){
      return sources[activeSource].getLevel(chan);  
    }
    else if((chan=='R'||chan=='r') && right!=null){
      return sources[activeSource].getLevel(chan);
    }
    else if((chan=='M'||chan=='m') && left!=null){
      return (sources[activeSource].getLevel('L') + sources[activeSource].getLevel('R'))/2.0;
    }
    return 0;
  }
  void wipeSamples(){ left = null; right = left; }
  void nextSource(){
    if(sources!=null && activeSource>=0 && activeSource<sources.length){
      if(!sources[activeSource].detachListener(this)) println("failed to detach from listener " + activeSource);
      activeSource = (activeSource+1) % sources.length;
      if(!sources[activeSource].attachListener(this)) println("failed to attach to listener " + activeSource);
    }
  }
  int bufferSize() { 
    return sources!=null && activeSource != NO_SOURCE ? sources[activeSource].getBufferSize() : 0;
  }
  float sampleRate(){ 
    return sources!=null && activeSource != NO_SOURCE ? sources[activeSource].getSampleRate() : 0; 
  }
  void listen(){
    if(sources==null){
      println("sources array is null...");
      return;  
    }
    //is a special sound source listener. active source never changes
    if(sources.length==1) return;
    
    //From no source, to some source
    if(activeSource == NO_SOURCE && globalActiveSource != NO_SOURCE){
      setActiveSource(globalActiveSource);
      sources[activeSource].attachListener(this);
    }
    //From some source, to no source
    else if(activeSource != NO_SOURCE && globalActiveSource == NO_SOURCE){
      stopListening();
      setActiveSource(globalActiveSource);
    }
    //From some source, to some other source
    else if(activeSource != NO_SOURCE && globalActiveSource != NO_SOURCE && activeSource != globalActiveSource){
      stopListening();
      setActiveSource(globalActiveSource);
      sources[activeSource].attachListener(this);
    }
    //May or may not be listening to the active source, so try and attach listener
    else if(activeSource != NO_SOURCE){
      sources[activeSource].attachListener(this);
    }
  }
  void stopListening(){
    if(sources!=null && activeSource != NO_SOURCE){
      wipeSamples();
      sources[activeSource].detachListener(this);
    }    
  }
}
