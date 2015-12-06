public abstract class soundSource{
  protected Minim               minim;
  protected ArrayList<listener> listeners;
  protected AudioSource         source;
  
  soundSource(){ 
    minim     = new Minim(this);
    listeners = new ArrayList<listener>();
  }
  soundSource(Minim min){
    minim     = min;
    listeners = new ArrayList<listener>();
  }
  boolean attachListener(listener lis){
    if(source != null && !listeners.contains(lis)){
      source.addListener(lis);
      listeners.add(lis);
      return true;
    }
    return false;
  }
  boolean detachListener(listener lis){
    if(source!=null && listeners.contains(lis)){
      source.removeListener(lis);
      listeners.remove(listeners.indexOf(lis));
      return true;
    }
    return false;
  }
  boolean purgeListeners(){
    boolean flag = true;
    while(!listeners.isEmpty()){
      if(!detachListener(listeners.get(0))) flag = false;
   }
   return flag; 
  }
  boolean isListening(listener a){ return source!=null && listeners.contains(a) ? true : false; } 
  
  boolean muted(){
    return source!=null ? source.isMuted() : false;
  }
  void mute(){
    if(source!=null) source.mute();
  }
  void unmute(){
    if(source!=null) source.unmute();
  }
  float getLevel(char chan){
    if(source==null) return 0;
    if(chan=='L' || chan=='l') return source.left.level();
    if(chan=='R' || chan=='r') return source.right.level();
    return 0;
  }
  int getBufferSize()  { return source!=null ? source.bufferSize() : 0; }
  float getSampleRate(){ return source!=null ? source.sampleRate() : 0.0; }
}
