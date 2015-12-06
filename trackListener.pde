public class trackListener extends listener{
  private int TRACK_INDEX = -1;
  private trackPlayer player;
  trackListener(soundSource[] src){
    super(src);
    if(sources!=null){
      for(int i=0; i<sources.length; i++)
        if(sources[i] instanceof trackPlayer){
          TRACK_INDEX = i;
          activeSource = TRACK_PLAYER;
          break;
        }
    }
    player = TRACK_INDEX != -1 ? (trackPlayer)sources[TRACK_INDEX] : null;
  }
  boolean loadTrack() { 
    if(player==null) return false;
    globalVisible = true;
    player.load(G4P.selectInput("Select a track", "wav,mp3", "audio files")); 
    globalVisible = false;
    return true;
  } 
  boolean playTrack() { return player!=null ? player.control(trackControl.PLAY) : false; }
  boolean pauseTrack(){ return player!=null ? player.control(trackControl.PAUSE) : false; }
  boolean stopTrack() { return player!=null ? player.control(trackControl.STOP) : false; }
  boolean loopTrack() { return player!=null ? player.control(trackControl.LOOP) : false; }
  boolean volumeUp()  { return player!=null ? player.control(trackControl.GAIN_UP) : false; }
  boolean volumeDown(){ return player!=null ? player.control(trackControl.GAIN_DOWN) : false; }
  boolean isPlaying() { return player!=null ? player.playing() : false; }
  boolean isLooping() { return player!=null ? player.looping() : false; }
  void cueTrack(int ms)   { if(player!=null)  player.setPosition(ms); }
  void cueTrack(float pc) { if(pc>=0 && pc<=1) cueTrack(int(player.trackLength()*pc)); }
  float pComplete(){ return player!=null && player.trackLength()>0 && player.trackPosition()>=0 ? player.trackPosition()/float(player.trackLength()) : 0.0; }
  String elapsedTimeStr(){ return player!=null ? time(player.trackPosition()) : "0:00"; }
  String trackLengthStr(){ return player!=null ? time(player.trackLength()) : "0:00"; }
  String trackTitleStr() {
    if(player!=null){
      AudioMetaData meta = player.trackMetaData(); 
      return meta!=null ? meta.title() : ""; 
    }
    return "";
  }
  String trackInfoStr()  {
    if(player!=null){
      AudioMetaData meta = player.trackMetaData(); 
      return meta!=null ? meta.author() + " - " + meta.album() : "";
    }
    return "";
  }
  private int toSecs(int ms)  { return ms>=0 ? ms / 1000 % 60 : 0; } //seconds more than highest minute
  private int toMins(int ms)  { return ms>=0 ? ms / 1000 / 60 : 0; }
  private String time(int ms) { return toSecs(ms) > 9 ? toMins(ms) + ":" + toSecs(ms) : toMins(ms) + ":0" + toSecs(ms); }
}
