final int TRACK_PLAYER = 0, SOUND_GEN = 1, MICROPHONE = 2, NO_SOURCE = -1;
/*****************************/
int globalActiveSource = NO_SOURCE;
/*****************************/
public class visualizationManager extends visualization{
  private Minim         min;
  private soundSource[] sourceList;
  private String[]      labels;
  private final int     BHEIGHT = 30;
  visualizationManager(PApplet a){
    //Create the window
    super(a, "Music Visualizer 11.9", 50, a.displayHeight/3, 650, 250, false);
    //Create a new Minim object
    min = new Minim(app);
    //Create the three sound sources and store then in an array
    sourceList = new soundSource[3];
    sourceList[TRACK_PLAYER] = new trackPlayer(min);
    sourceList[SOUND_GEN]    = new soundGen(min);
    sourceList[MICROPHONE]   = new microphone(min);
    labels = new String[3];
    a.textFont(font[MANAGER_FONT]);
    a.textAlign(CENTER,CENTER);
    //When this window closes, the application exits
    window.setActionOnClose(GWindow.EXIT_APP);
  }
  void drawHandle(GWinApplet a, GWinData d){
    a.fill(palette[WHITE]);
    a.textFont(font[MANAGER_FONT]);
    a.textAlign(CENTER,CENTER);
    a.textSize(30);
    a.fill(palette[RED]);
    a.text("Music Visualizer", a.width/2, MARGIN);
    int top    = MARGIN*3;
    int left   = MARGIN;
    int right  = left + (a.width-MARGIN*2)/3;
    int bWidth = right - left - PADDING*2;
    int bottom = top + BHEIGHT;
    int center = (left+right)/2;
    a.textSize(25);
    a.fill(palette[WHITE]);
    labels[0]  = "Sound Sources";
    labels[1]  = "Visualizations";
    labels[2]  = "Analysis";
    for(int i=0; i<3; i++){ // column headers
      a.text(labels[i],center,top);
      left   = right;
      right  = left+(a.width-MARGIN*2)/3;
      center = (left+right)/2;
    }
    a.textSize(15);
    labels[0] = "Media Player";
    labels[1] = "Diatonic Synthesizer";
    labels[2] = "Microphone";
    left   = MARGIN;
    right  = left+(a.width-MARGIN*2)/3;
    center = (left+right)/2;
    for(int i=0; i<3; i++){ // sound sources
      top    = bottom+PADDING;
      bottom = top+BHEIGHT;
      if(overRectangleBtn(a, left+PADDING, top, right-PADDING, bottom))a.fill(palette[BLUE]);
      else a.fill(palette[TAN]);
      a.rect(left+PADDING,top,bWidth,BHEIGHT,5);
      a.fill(0);
      a.text(labels[i], center, (top+bottom)/2);
    }
    labels[0] = "Waveform";
    labels[1] = "Spectrum";
    labels[2] = "Synesthesia";
    top    = MARGIN*3;
    bottom = top+BHEIGHT;
    left   = right;
    right  = left+(a.width-MARGIN*2)/3;
    center = (left+right)/2;
    for(int i=0; i<3; i++){ // sound sources
      top    = bottom+PADDING;
      bottom = top+BHEIGHT;
      if(overRectangleBtn(a, left+PADDING, top, right-PADDING, bottom))a.fill(palette[BLUE]);
      else a.fill(palette[TAN]);
      a.rect(left+PADDING,top,bWidth,BHEIGHT,5);
      a.fill(0);
      a.text(labels[i], center, (top+bottom)/2);
    }
    labels[0] = "Pitch Detection";
    labels[1] = "Beat Detection";
    top    = MARGIN*3;
    bottom = top+BHEIGHT;
    left   = right;
    right  = left+(a.width-MARGIN*2)/3;
    center = (left+right)/2;
    for(int i=0; i<2; i++){ // sound sources
      top    = bottom+PADDING;
      bottom = top+BHEIGHT;
      if(overRectangleBtn(a, left+PADDING, top, right-PADDING, bottom))a.fill(palette[BLUE]);
      else a.fill(palette[TAN]);
      a.rect(left+PADDING,top,bWidth,BHEIGHT,5);
      a.fill(0);
      a.text(labels[i], center, (top+bottom)/2);
    }
  }
  void mouseHandle(GWinApplet a, GWinData d, MouseEvent e){
    if(e.getAction() == MouseEvent.CLICK){
      int top    = MARGIN*3+BHEIGHT+PADDING,
          left   = MARGIN;
      int right  = left+(a.width-MARGIN*2)/3,
          bottom = top+BHEIGHT;
      if(overRectangleBtn(a, left+PADDING, top, right-PADDING, bottom)){ //over player
        launchMediaPlayer(); return;
      }
      top = bottom+PADDING;
      bottom = top+BHEIGHT;
      if(overRectangleBtn(a, left+PADDING, top, right-PADDING, bottom)){ //over synth
        launchDiatonicSynth(); return;
      }
      top = bottom+PADDING;
      bottom = top+BHEIGHT;
      if(overRectangleBtn(a, left+PADDING, top, right-PADDING, bottom)){ //over mic
        launchMicrophoneMonitor(); return;
      }
      top    = MARGIN*3+BHEIGHT+PADDING;
      bottom = top+BHEIGHT;
      left   = right;
      right  = left+(a.width-MARGIN*2)/3;
      if(overRectangleBtn(a, left+PADDING, top, right-PADDING, bottom)){ //over waveform
        launchWaveVisualizer(); return;
      }
      top = bottom+PADDING;
      bottom = top+BHEIGHT;
      if(overRectangleBtn(a, left+PADDING, top, right-PADDING, bottom)){ //over spectrum
        launchSpectrumVisualizer(); return;
      }
      top = bottom+PADDING;
      bottom = top+BHEIGHT;
      if(overRectangleBtn(a, left+PADDING, top, right-PADDING, bottom)){ //over animation
        launchSynesthesiaVisualizer(); return;
      }
      top    = MARGIN*3+BHEIGHT+PADDING;
      bottom = top+BHEIGHT;
      left   = right;
      right  = left+(a.width-MARGIN*2)/3;
      if(overRectangleBtn(a, left+PADDING, top, right-PADDING, bottom)){ //over pitch
        launchPitchVisualizer(); return;
      }
      top = bottom+PADDING;
      bottom = top+BHEIGHT;
      if(overRectangleBtn(a, left+PADDING, top, right-PADDING, bottom)){ //over beat
        launchBeatVisualizer(); return;
      }
    }
  }
  void keyHandle(GWinApplet a, GWinData d, KeyEvent e){
    
  }
  //Sound Source Interfaces....
  private void launchMediaPlayer(){
    soundSource[] sources = new soundSource[1];
    sources[0] = sourceList[TRACK_PLAYER];
    trackListener lis = new trackListener(sources);
    mediaPlayer mPlayer = new mediaPlayer(app, lis);
  }
  void launchDiatonicSynth(){
    soundSource[] sources = new soundSource[1];
    sources[0] = sourceList[SOUND_GEN];
    genListener lis = new genListener(sources);
    diatonicSynth dSynth = new diatonicSynth(app, lis);
  }
  void launchMicrophoneMonitor(){
    soundSource[] sources = new soundSource[1];
    sources[0] = sourceList[MICROPHONE];
    micListener lis = new micListener(sources);
    microphoneInterface mInterface = new microphoneInterface(app, lis);
  }
  //Visualizers...
  private void launchWaveVisualizer(){
    soundSource[] sources = new soundSource[3];
    sources[0] = sourceList[TRACK_PLAYER];
    sources[1] = sourceList[SOUND_GEN];
    sources[2] = sourceList[MICROPHONE];
    waveListener lis = new waveListener(sources);
    waveform wave = new waveform(app, lis);
  }
  private void launchSpectrumVisualizer(){
    soundSource[] sources = new soundSource[3];
    sources[0] = sourceList[TRACK_PLAYER];
    sources[1] = sourceList[SOUND_GEN];
    sources[2] = sourceList[MICROPHONE];
    spectrumListener lis = new spectrumListener(sources);
    spectrum spec = new spectrum(app, lis);
  }
  private void launchSynesthesiaVisualizer(){
    soundSource[] sources = new soundSource[3];
    sources[0] =  sourceList[TRACK_PLAYER];
    sources[1] =  sourceList[SOUND_GEN];
    sources[2] =  sourceList[MICROPHONE];
    waveListener  wLis = new waveListener(sources);
    pitchListener pLis = new pitchListener(sources);
    beatListener  bLis = new beatListener(sources);
    synesthesia   syn  = new synesthesia(app, wLis, pLis, bLis);
  }
  //Analysis....
  private void launchBeatVisualizer(){
    soundSource[] sources = new soundSource[3];
    sources[0] =  sourceList[TRACK_PLAYER];
    sources[1] =  sourceList[SOUND_GEN];
    sources[2] =  sourceList[MICROPHONE];
    beatListener  lis     = new beatListener(sources);
    beatDetection bDetect = new beatDetection(app, lis);
  }
  void launchPitchVisualizer(){
    soundSource[] sources = new soundSource[3];
    sources[0] = sourceList[TRACK_PLAYER];
    sources[1] = sourceList[SOUND_GEN];
    sources[2] = sourceList[MICROPHONE];
    pitchListener  lis     = new pitchListener(sources);
    pitchDetection pDetect = new pitchDetection(app, lis);
  }
  void closeHandle(GWindow a){
    min.stop();
  } 
}
