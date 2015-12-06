public class micListener extends listener{
  private int        MIC_INDEX = -1;
  private microphone mic;
  private int        bufferSize;
  private float      sampleRate;
  micListener(soundSource[] src){
    super(src);
    if(sources!=null){
      for(int i=0; i<sources.length; i++)
        if(sources[i] instanceof microphone){
          MIC_INDEX    = i;
          activeSource = MIC_INDEX;
          break;
        }
    }
    mic = MIC_INDEX != -1 ? (microphone)sources[MIC_INDEX] : null;
    if(mic!=null){
      bufferSize = bufferSize();
      sampleRate = sampleRate();
    }
  }
  void on()      { if(mic!=null && mic.muted()) mic.unmute(); }
  void off()     { if(mic!=null && !mic.muted()) mic.mute();  }
  boolean isOn() { return mic!=null ? mic.muted() : false; }
  boolean micDetected() { return mic.lineInFound(); }
  void monitorOn(){
    if(mic!=null && !isMonitoring())
      mic.startMonitoring();
  }
  void monitorOff(){
    if(isMonitoring()) mic.stopMonitoring();
  }
  boolean isMonitoring(){
    if(mic!=null) return mic.monitoring();
    return false;
  }
  void toggleMonitoring(){
    if(mic==null)return;
    if(isOn()) mic.stopMonitoring();
    else mic.startMonitoring();
  }
  void changeBufferSize(int bSize){
    if(mic!=null && bSize>0 && bSize<=8192 && bSize!=bufferSize){
      bufferSize = bSize;
      mic.refresh(bufferSize, sampleRate);
    }  
  }
  void changeSampleRate(float sRate){
    if(mic!=null && sRate>=1000 && sRate<=192000 && sRate!=sampleRate){
      sampleRate = sRate;
      mic.refresh(bufferSize, sampleRate);
    }  
  }
  void toggleMute(){
    if(mic!=null){
      if(mic.muted()) mic.unmute();
      else mic.mute();
    }  
  }
  boolean isMuted(){
    if(mic!=null && mic.muted()) wipeSamples();
    return mic!=null ? mic.muted() : false;  
  }
}

