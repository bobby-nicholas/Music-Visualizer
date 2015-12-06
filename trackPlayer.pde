public class trackPlayer extends soundSource{
  private Pattern pat;
  private Matcher match;
  trackPlayer(Minim m){
    super(m);
    pat = Pattern.compile("^.*((\\.mp3)|(\\.wav))$");
  }
  trackPlayer(Minim m, String path){
    super(m);
    pat = Pattern.compile("^.*((\\.mp3)|(\\.wav))$");
    load(path);
  }
  boolean load(String track){
    match = pat.matcher(track);
    if(match.matches()){
      if(source!=null){
        source.close();
        source = null;
        listeners.clear();
      }
      source = minim.loadFile(track);
      return true;
    }
    return false;
  }
  boolean playing(){ return source instanceof AudioPlayer ? ((AudioPlayer)source).isPlaying() : false; }
  boolean looping(){ return source instanceof AudioPlayer ? ((AudioPlayer)source).isLooping() : false; }
  AudioMetaData trackMetaData(){ return source instanceof AudioPlayer ? ((AudioPlayer)source).getMetaData() : null; }
  int trackLength()  { return source instanceof AudioPlayer ? ((AudioPlayer)source).length() : 0; }
  int trackPosition(){ return source instanceof AudioPlayer ? ((AudioPlayer)source).position() : -1; }
  void setPosition(int ms){ if(source instanceof AudioPlayer) ((AudioPlayer)source).cue(ms); }
  boolean control(trackControl action){
    if(source instanceof AudioPlayer){
      switch(action){
        case PLAY:
        if(!((AudioPlayer)source).isPlaying()) ((AudioPlayer)source).play();
        break;
        case PAUSE:
        if(((AudioPlayer)source).isPlaying()) ((AudioPlayer)source).pause();
        break;
        case STOP:
        source.close(); 
        source = null;
        listeners.clear();
        break;
        case LOOP: // the normal loop functionality is giving me problems....
        if(!((AudioPlayer)source).isLooping()){
          int pos = ((AudioPlayer)source).position();
          ((AudioPlayer)source).loop();
          ((AudioPlayer)source).cue(pos);
        }
        else if(((AudioPlayer)source).isLooping()){
          int pos = ((AudioPlayer)source).position();
          ((AudioPlayer)source).loop(0);
          ((AudioPlayer)source).pause();
          ((AudioPlayer)source).cue(pos);
          ((AudioPlayer)source).play();
        }
        break;
        case GAIN_UP:
        break;
        case GAIN_DOWN:
        break;
        default:  
      }
      return true;
    }
    return false;
  }
}
