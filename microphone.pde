public class microphone extends soundSource{
  private boolean detected;
  private int     bufferSize;
  private float   sampleRate; 
  microphone(Minim m){
    super(m); 
    detected   = true;
    bufferSize = 1024;
    sampleRate = 44100;
    try{ source = minim.getLineIn(Minim.STEREO, bufferSize, sampleRate); }
    catch(Exception c){ detected = false; }
  }
  void startMonitoring(){
    if(source instanceof AudioInput){
      ((AudioInput)source).enableMonitoring();
    }
  }
  void stopMonitoring(){
    if(source instanceof AudioInput){
      ((AudioInput)source).disableMonitoring();
    }
  }
  boolean lineInFound(){ return detected; } 
  boolean monitoring(){
    return source instanceof AudioInput ? ((AudioInput)source).isMonitoring() : false;
  }
  void refresh(int bSize, float sRate){
    bufferSize = bSize;
    sampleRate = sRate;
    source = minim.getLineIn(Minim.STEREO, bufferSize, sampleRate);  
  }  
  void disconnect(){
    AudioInput in  = (AudioInput)source;
    in.mute();
  }
}

