public class beatListener extends listener{
  private BeatDetect soundDetect, freqDetect;
  private int bufferSize;
  private float sampleRate;
  beatListener(soundSource[] src){
    sources = src;
    activeSource = src!=null ? 0 : -1;
    if(sources!=null){
      soundDetect = new BeatDetect();
      bufferSize = bufferSize();
      sampleRate = sampleRate(); 
      if(bufferSize!=0 && sampleRate!=0) freqDetect = new BeatDetect(bufferSize(), sampleRate());
    }  
  }
  //the freq energy mode requires that the buffer size matches the value it was initialized with
  boolean refresh(){
    if(sources!=null && ( bufferSize!=bufferSize() || sampleRate!=sampleRate())){
      bufferSize = bufferSize();
      sampleRate = sampleRate();
      freqDetect = new BeatDetect(bufferSize, sampleRate);
      return true;
    }
    return false;
  }
  int beatSpectrumSize(){ return sources!=null && freqDetect!=null ? freqDetect.dectectSize() : 0; }
  boolean detectOnset(){
    if(soundDetect!=null){
      soundDetect.detect(mix());
      return soundDetect.isOnset();
    }
    else refresh();
    return false;
  }
  //returns a boolean array including the sound energy mode
  boolean[] listenForBeat(){
    boolean[] beat = null;
    if(soundDetect!=null && freqDetect!=null){
      soundDetect.detect(mix());
      freqDetect.detect(mix());
      if(beatSpectrumSize() > 0){
        beat = new boolean[beatSpectrumSize() + 1];
        if(soundDetect.isOnset()){
          beat[0] = true;
          for(int i = 1; i<beatSpectrumSize() + 1; i++) beat[i] = freqDetect.isOnset(i-1);
        }
        else{
          beat[0] = false;
          for(int i = 1; i<beatSpectrumSize() + 1; i++) beat[i] = freqDetect.isOnset(i-1);
        }
      }
    }
    else refresh();
    return beat;
  }
}
