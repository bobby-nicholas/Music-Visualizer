public class diatonicSynth extends visualization {
  private genListener gListener;
  private genTone[]   tones;
  private String      curKey;
  private int         lowestOctave, bDiam, rDiam, curForm, nForms;
  private Wavetable   waveform;
  private final int   KEYBOARD_FORM = 0, SCALE_FORM = 1, TRIAD_FORM = 2;
  private int         bufSize;
  private float       samRate;
  private String[][]  keyboardLayout = {{ "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P" },
                      { "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "\'" },
                      { "SHIFT", "Z", "X", "C", "V", "B", "N", "M", ",", ".", "/" }};    
  diatonicSynth(PApplet a, genListener g) {
    super(a, "Diatonic Synthesizer", 500, 600, 800, 350, false);  
    gListener = g;
    if (gListener == null) println("Warning");
    tones = new genTone[32]; 
    curKey = "C";
    lowestOctave = 0;
    bDiam = 50;
    rDiam = 60;
    curForm = KEYBOARD_FORM;
    nForms = 3;
    waveform = Waves.SINE;
    //window.papplet.ellipseMode(CENTER);
    window.papplet.textAlign(CENTER,CENTER);
    //window.papplet.rectMode(CENTER);
    window.papplet.strokeWeight(3);
    globalActiveSource = SOUND_GEN;
    bufSize = gListener.bufferSize();
    samRate = gListener.sampleRate();
  }
  void drawHandle(GWinApplet a, GWinData d) {
    if(gListener!=null){
      gListener.listen();
      bufSize = gListener.bufferSize();
      samRate = gListener.sampleRate(); 
    }
    a.textFont(font[MANAGER_FONT]);
    float top = MARGIN, left = MARGIN;
    float right = drawOctaveButtons(a, left, top);
    left = right + PADDING;
    right = drawKeyButtons(a, left, top);
    left = right + PADDING;
    drawWaveButtons(a, left, top);
    left  = MARGIN * 2;
    top   = a.height - MARGIN*3; 
    right = drawNoteFormButtons(a, left, top);
    left  = right + PADDING;
    right = drawBufferSizeButtons(a, left, top);
    left  = right + PADDING;
    drawSampleRateButtons(a, left, top);
    left  = MARGIN*1.6;
    right = a.width - MARGIN*2;
    float bottom = top - PADDING;
    top   = MARGIN * 4; 
    drawNotes(a, left, top, right, bottom);
  }
  float drawOctaveButtons(GWinApplet a, float left, float top) {
    float bWidth = 50, bHeight = 30;
    a.textAlign(CENTER,CENTER);
    a.textSize(25);
    a.fill(palette[WHITE]);
    a.text("Octaves", left + bWidth * 1.5, top);
    a.textSize(12);
    a.fill(color(0));
    top += MARGIN;
    for (int i=0; i<3; i++) {
      String label = i == 0 ? "LOW" : i == 1 ? "MED" : "HIGH";
      if (i==lowestOctave) a.fill(palette[RED]);
      else if(overRectangleBtn(a, left + (bWidth*i), top, left + (bWidth*i) + bWidth, top + bHeight))
        a.fill(palette[TAN], 255);
      else a.fill(palette[TAN], 100);
      if     (i == 0) a.rect(left + (bWidth*i), top, bWidth, bHeight, 5,0,0,5);
      else if(i == 2) a.rect(left + (bWidth*i), top, bWidth, bHeight, 0,5,5,0);
      else            a.rect(left + (bWidth*i), top, bWidth, bHeight); 
      a.fill(0);
      a.text(label, left + (bWidth*i) + bWidth/2.0, top + bHeight/2.0);
    }
    //return right boundary
    return left + bWidth * 3;
  }
  float drawKeyButtons(GWinApplet a, float left, float top) {
    float    bWidth = 40, bHeight = 30;
    String[] keys = { "A", "B", "C", "D", "E", "F", "G" };
    a.textAlign(CENTER,CENTER);
    a.textSize(25);
    a.fill(palette[WHITE]);
    a.text("Major Keys", left + (bWidth * keys.length)/2.0, top);
    a.textSize(20);
    top += MARGIN;
    for(int i=0; i<keys.length; i++) {
      if(curKey == keys[i]) a.fill(palette[RED]);
      else if(overRectangleBtn(a, left + (bWidth*i), top, left + (bWidth*i) + bWidth, top + bHeight))
           a.fill(palette[TAN], 255);
      else a.fill(palette[TAN], 100);
      if(i == 0)                  a.rect(left + (bWidth*i), top, bWidth, bHeight, 5,0,0,5);
      else if(i == keys.length-1) a.rect(left + (bWidth*i), top, bWidth, bHeight, 0,5,5,0);
      else                        a.rect(left + (bWidth*i), top, bWidth, bHeight);
      a.fill(0);
      a.text(keys[i], left + (bWidth*i) + bWidth/2.0, top + bHeight/2.0);
    }
    //return right boundary
    return left + bWidth * keys.length;
  }
  float drawWaveButtons(GWinApplet a, float left, float top) {
    float       bWidth = 75, bHeight = 30;
    String[]    labels = { "SINE", "SQUARE", "SAW", "TRIANGLE" };
    Wavetable[] waves  = { Waves.SINE, Waves.SQUARE, Waves.SAW, Waves.TRIANGLE };
    a.textAlign(CENTER,CENTER);
    a.textSize(25);
    a.fill(palette[WHITE]);
    a.text("Waveforms", left + (labels.length * bWidth)/2.0, top);
    a.textSize(12);
    top += MARGIN;
    for (int i=0; i<labels.length; i++) {
      if(waveform == waves[i]) a.fill(palette[RED]);
      else if(overRectangleBtn(a, left + (bWidth*i), top, left + (bWidth*i) + bWidth, top + bHeight))
           a.fill(palette[TAN], 255);            
      else a.fill(palette[TAN], 100);
      if(i == 0)                    a.rect(left + (bWidth*i), top, bWidth, bHeight, 5,0,0,5);
      else if(i == labels.length-1) a.rect(left + (bWidth*i), top, bWidth, bHeight, 0,5,5,0);
      else                          a.rect(left + (bWidth*i), top, bWidth, bHeight);
      a.fill(0);
      a.text(labels[i], left + (bWidth*i) + bWidth/2.0, top + bHeight/2.0);
    }
    //return right boundary
    return left + bWidth * labels.length;
  }
  float drawNoteFormButtons(GWinApplet a, float left, float top){
    float bWidth = 120, bHeight = 30;
    String labels[] = { "KEYBOARD", "SCALE DEGREE", "DIATONIC TRIADS" };
    a.textSize(20);
    a.fill(palette[WHITE]);
    a.text("Note Representation", left + (labels.length * bWidth)/2.0, top);
    a.textSize(10);
    top += MARGIN;
    for(int i=0; i<labels.length; i++){
      if(curForm == i) a.fill(palette[RED]);
      else if(overRectangleBtn(a, left + (bWidth*i), top, left + (bWidth*i) + bWidth, top + bHeight))
           a.fill(palette[TAN],255);
      else a.fill(palette[TAN],100);
      if(i == 0)                    a.rect(left + (bWidth*i), top, bWidth, bHeight, 5,0,0,5);
      else if(i == labels.length-1) a.rect(left + (bWidth*i), top, bWidth, bHeight, 0,5,5,0);
      else                          a.rect(left + (bWidth*i), top, bWidth, bHeight);
      a.fill(0);
      a.text(labels[i], left + (bWidth*i) + bWidth/2.0, top + bHeight/2.0);
    }
    //return right boundary
    return left + bWidth * labels.length;
  }
  float drawBufferSizeButtons(GWinApplet a, float left, float top){
    float bWidth = 30, bHeight = 30;
    a.textSize(20);
    a.fill(palette[WHITE]);
    a.text("Buffer Size", left + (bWidth * 4 + PADDING * 2)/2.0, top);
    a.textSize(10);
    top += MARGIN;
    if(overRectangleBtn(a, left, top, left + bWidth, top + bHeight)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN],100);
    a.rect(left, top, bWidth, bHeight, 10,0,0,10);
    a.fill(0);
    a.text("-", left + (bWidth/2.0), top + (bHeight/2.0));
    left += bWidth + PADDING;
    a.fill(palette[WHITE]);
    a.rect(left, top, bWidth*2, bHeight);
    a.fill(0);
    a.text(bufSize, left + bWidth, top + (bHeight/2.0));
    left += bWidth * 2 + PADDING;
    if(overRectangleBtn(a, left, top, left + bWidth, top + bHeight)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN],100);
    a.rect(left, top, bWidth, bHeight, 0,10,10,0);
    a.fill(0);
    a.text("+", left + (bWidth/2.0), top + (bHeight/2.0));
    //return right boundary
    return left + bWidth;
  }
  float drawSampleRateButtons(GWinApplet a, float left, float top){
    float bWidth = 30, bHeight = 30;
    a.textSize(20);
    a.fill(palette[WHITE]);
    a.text("Sample Rate", left + (bWidth * 4 + PADDING * 2)/2.0, top);
    a.textSize(10);
    top += MARGIN;
    if(overRectangleBtn(a, left, top, left + bWidth, top + bHeight)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN],100);
    a.rect(left, top, bWidth, bHeight, 10,0,0,10);
    a.fill(0);
    a.text("-", left + (bWidth/2.0), top + (bHeight/2.0));
    left += bWidth + PADDING;
    a.fill(palette[WHITE]);
    a.rect(left, top, bWidth*2, bHeight);
    a.fill(0);
    a.text(nf(samRate/1000.0, 1, 1) + " kHz", left + bWidth, top + (bHeight/2.0));
    left += bWidth * 2 + PADDING;
    if(overRectangleBtn(a, left, top, left + bWidth, top + bHeight)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN],100);
    a.rect(left, top, bWidth, bHeight, 0,10,10,0);
    a.fill(0);
    a.text("+", left + (bWidth/2.0), top + (bHeight/2.0));
    //return right boundary
    return left + bWidth;
  }
  void drawNotes(GWinApplet a, float left, float top, float right, float bottom){
    float nWidth = right - left, nHeight = bottom - top;
    if(curForm == KEYBOARD_FORM){
      //map to the arrangement of notes to the computer keyboard
      a.stroke(0);
      a.strokeWeight(2);
      a.textSize(8);
      float bWidth  = nWidth / 13;
      float bHeight = nHeight / 4;
      int OFFSET = 0, noteNum = 0;
      float x = left + PADDING, y = top;
      for(int i = 0; i < keyboardLayout.length; i++){
        for(int j = 0; j < keyboardLayout[i].length; j++){
          if(tones[noteNum] != null) a.fill(palette[BLUE], 255);
          else a.fill(palette[BLUE], 100);
          a.rect(x + OFFSET, y, bWidth, bHeight, 3);
          a.fill(palette[WHITE]);
          a.text(keyboardLayout[i][j], x + OFFSET + (bWidth/2.0), y + (bHeight/2.0));
          noteNum++;
          x += bWidth + (PADDING/2.0);
        }
        x  = left + PADDING;
        y += bHeight + (PADDING/2.0);
        if(i==0)      OFFSET = PADDING;
        else if(i==1) OFFSET = -PADDING;
      }
    }
    else if(curForm == SCALE_FORM){
      //notes grouped by scale-degree, octaves going low to high vertically
      String[] scaleDegrees = {"TONIC", "SUBTONIC", "MEDIANT", "SUBDOMINANT", "DOMINANT", "SUBMEDIANT", "LEADING TONE"};
      float bWidth  = "LEADING TONE".length() * 8.5;
      float bHeight;
      float x = left, y = top;
      a.stroke(0);
      a.strokeWeight(2);
      a.fill(palette[WHITE]);
      a.textSize(12);
      for(int i = 0; i < scaleDegrees.length; i++){
        a.text(scaleDegrees[i], x + (bWidth/2.0), y);
        x += bWidth;
      }
      x = left;
      y =  top + PADDING;
      bHeight = (bottom - y)/6.5;
      int    noteIndex = 0, noteNum = 0;
      String note = "";
      int degree, octOffset = lowestOctave + 1;
      boolean flag;
      for(int i = 1; i <= 42; i++){
        if(i >= 7 && i <= 38){
          if(noteIndex == 0) degree = 7;
          else{
            degree = noteIndex % 7;
            if(noteIndex % 7 == 0) octOffset++;
          }
          if(tones[noteIndex] != null){
            noteNum = gListener.freqToOctave(gListener.toFrequency(curKey, pow(2, octOffset), gListener.majorScaleDegreeToHalfStep(degree)));
            note = gListener.hStepToNote(gListener.majorScaleDegreeToHalfStep(degree) + gListener.keyToHalfStep(curKey), curKey);  
            if(note == "") note = "G#";
            a.fill(palette[TAN], 200);
            flag = true;
          }
          else{ a.fill(palette[BLUE], 100); flag = false; }
          noteIndex++;
        }
        else{ a.fill(palette[BLUE], 50); flag = false; }
        a.rect(x, y, bWidth, bHeight, 2);
        if(flag){
          a.fill(0);
          if(i == 7){
            if(curKey == "A" || curKey == "B" || curKey == "C")
              a.text(note + (octOffset + 1), x+(bWidth/2.0), y+(bHeight/2.0));
            else a.text(note + (octOffset + 2), x+(bWidth/2.0), y+(bHeight/2.0));
          }
          else a.text(note + noteNum, x+(bWidth/2.0), y+(bHeight/2.0));
        }
        if(i % 7 == 0){ x = left; y += bHeight; }
        else x += bWidth;
      }
    }
    else if(curForm == TRIAD_FORM){
      //notes grouped as triads, corresponding to the natural chords of a major scale
      float bWidth  = 80;
      float x = left, y = top;
      a.stroke(0);
      a.strokeWeight(2);
      a.textSize(15);
      //I----------------------------------------------
      float centerX = map(1, 1, 7, left + (bWidth/2.0), right - (bWidth/2.0));
      float centerY = top + MARGIN * 3;
      a.fill(palette[WHITE]); 
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey), curKey) + " Major", centerX, top + PADDING);
      a.fill(palette[TEAL], 100);
      for(int i = 0; i < 5; i ++) if(tones[1+(7*i)] != null) { a.fill(palette[TEAL], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (17*PI/6), (7*PI/2) , PIE); // tonic
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey), curKey), centerX - (bWidth/4.0), centerY - 10);
      a.fill(palette[TEAL], 100);
      for(int i = 0; i < 5; i ++) if(tones[3+(7*i)] != null) { a.fill(palette[TEAL], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (3*PI/2), (13*PI/6), PIE); // mediant
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 4, curKey), centerX + (bWidth/4.0), centerY - 10);
      a.fill(palette[TEAL], 100);
      for(int i = 0; i < 4; i ++) if(tones[5+(7*i)] != null) { a.fill(palette[TEAL], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (13*PI/6), (17*PI/6), PIE); // dominant
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 7, curKey), centerX, centerY + (bWidth/4.0) + 2);
      //ii---------------------------------------------
      centerX = map(2, 1, 7, left + (bWidth/2.0), right - (bWidth/2.0));
      a.fill(palette[WHITE]);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 2, curKey) + " Minor", centerX, top + PADDING);
      a.fill(palette[BLUE], 100);  
      for(int i = 0; i < 5; i ++) if(tones[2+(7*i)] != null) { a.fill(palette[BLUE], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (17*PI/6), (7*PI/2) , PIE); // supertonic
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 2, curKey), centerX - (bWidth/4.0), centerY - 10);
      a.fill(palette[BLUE], 100);
      for(int i = 0; i < 4; i ++) if(tones[4+(7*i)] != null) { a.fill(palette[BLUE], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (3*PI/2), (13*PI/6), PIE); // subdominant
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 5, curKey), centerX + (bWidth/4.0), centerY - 10);
      a.fill(palette[BLUE], 100);
      for(int i = 0; i < 4; i ++) if(tones[6+(7*i)] != null) { a.fill(palette[BLUE], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (13*PI/6), (17*PI/6), PIE); // submediant
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 9, curKey), centerX, centerY + (bWidth/4.0) + 2);
      //iii--------------------------------------------
      centerX = map(3, 1, 7, left + (bWidth/2.0), right - (bWidth/2.0));
      a.fill(palette[WHITE]);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 4, curKey) + " Minor", centerX, top + PADDING);
      a.fill(palette[BLUE], 100);
      for(int i = 0; i < 5; i ++) if(tones[3+(7*i)] != null) { a.fill(palette[BLUE], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (17*PI/6), (7*PI/2) , PIE); // mediant
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 4, curKey), centerX - (bWidth/4.0), centerY - 10);
      a.fill(palette[BLUE], 100);
      for(int i = 0; i < 4; i ++) if(tones[5+(7*i)] != null) { a.fill(palette[BLUE], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (3*PI/2), (13*PI/6), PIE); // dominant
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 7, curKey), centerX + (bWidth/4.0), centerY - 10);
      a.fill(palette[BLUE], 100);
      if(tones[0] != null) a.fill(palette[BLUE], 255);
      for(int i = 0; i < 4; i ++) if(tones[7+(7*i)] != null) { a.fill(palette[BLUE], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (13*PI/6), (17*PI/6), PIE); // leading tone
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 11, curKey), centerX, centerY + (bWidth/4.0) + 2);
      //IV---------------------------------------------
      centerX = map(4, 1, 7, left + (bWidth/2.0), right - (bWidth/2.0));
      a.fill(palette[WHITE]);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 5, curKey) + " Major", centerX, top + PADDING);
      a.fill(palette[TEAL], 100);
      for(int i = 0; i < 4; i ++) if(tones[4+(7*i)] != null) { a.fill(palette[TEAL], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (17*PI/6), (7*PI/2) , PIE); // subdominant
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 5, curKey), centerX - (bWidth/4.0), centerY - 10);
      a.fill(palette[TEAL], 100);
      for(int i = 0; i < 4; i ++) if(tones[6+(7*i)] != null) { a.fill(palette[TEAL], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (3*PI/2), (13*PI/6), PIE); // submediant
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 9, curKey), centerX + (bWidth/4.0), centerY - 10);
      a.fill(palette[TEAL], 100);
      for(int i = 0; i < 5; i ++) if(tones[1+(7*i)] != null) { a.fill(palette[TEAL], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (13*PI/6), (17*PI/6), PIE); // tonic
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey), curKey), centerX, centerY + (bWidth/4.0) + 2);
      //V----------------------------------------------
      centerX = map(5, 1, 7, left + (bWidth/2.0), right - (bWidth/2.0));
      a.fill(palette[WHITE]);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 7, curKey) + " Major", centerX, top + PADDING);
      a.fill(palette[TEAL], 100);
      for(int i = 0; i < 4; i ++) if(tones[5+(7*i)] != null) { a.fill(palette[TEAL], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (17*PI/6), (7*PI/2) , PIE); // dominant
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 7, curKey), centerX - (bWidth/4.0), centerY - 10);
      a.fill(palette[TEAL], 100);
      if(tones[0] != null) a.fill(palette[TEAL], 255);
      for(int i = 0; i < 4; i ++) if(tones[7+(7*i)] != null) { a.fill(palette[TEAL], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (3*PI/2), (13*PI/6), PIE); // leading tone
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 11, curKey), centerX + (bWidth/4.0), centerY - 10);
      a.fill(palette[TEAL], 100);
      for(int i = 0; i < 5; i ++) if(tones[2+(7*i)] != null) { a.fill(palette[TEAL], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (13*PI/6), (17*PI/6), PIE); // supertonic
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 2, curKey), centerX, centerY + (bWidth/4.0) + 2);
      //vi--------------------------------------------
      centerX = map(6, 1, 7, left + (bWidth/2.0), right - (bWidth/2.0));
      a.fill(palette[WHITE]);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 9, curKey) + " Minor", centerX, top + PADDING);
      a.fill(palette[BLUE], 100);
      for(int i = 0; i < 4; i ++) if(tones[6+(7*i)] != null) { a.fill(palette[BLUE], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (17*PI/6), (7*PI/2) , PIE); // submediant
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 9, curKey), centerX - (bWidth/4.0), centerY - 10);
      a.fill(palette[BLUE], 100);
      for(int i = 0; i < 5; i ++) if(tones[1+(7*i)] != null) { a.fill(palette[BLUE], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (3*PI/2), (13*PI/6), PIE); // tonic
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey), curKey), centerX + (bWidth/4.0), centerY - 10);
      a.fill(palette[BLUE], 100);
      for(int i = 0; i < 5; i ++) if(tones[3+(7*i)] != null) { a.fill(palette[BLUE], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (13*PI/6), (17*PI/6), PIE); // mediant
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 4, curKey), centerX, centerY + (bWidth/4.0) + 2);
      //vii--------------------------------------------
      centerX = map(7, 1, 7, left + (bWidth/2.0), right - (bWidth/2.0));
      a.fill(palette[WHITE]);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 11, curKey) + " Diminished", centerX, top + PADDING);
      a.fill(palette[TAN], 100);
      if(tones[0] != null) a.fill(palette[TAN], 255);
      for(int i = 0; i < 4; i ++) if(tones[7+(7*i)] != null) { a.fill(palette[TAN], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (17*PI/6), (7*PI/2) , PIE); // leading tone
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 11, curKey), centerX - (bWidth/4.0), centerY - 10);
      a.fill(palette[TAN], 100);
      for(int i = 0; i < 5; i ++) if(tones[2+(7*i)] != null) { a.fill(palette[TAN], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (3*PI/2), (13*PI/6), PIE); // supertonic
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 2, curKey), centerX + (bWidth/4.0), centerY - 10);
      a.fill(palette[TAN], 100);
      for(int i = 0; i < 4; i ++) if(tones[4+(7*i)] != null) { a.fill(palette[TAN], 255); break; }
      a.arc(centerX, centerY, bWidth, bWidth, (13*PI/6), (17*PI/6), PIE); // subdominant
      a.fill(0);
      a.text(gListener.hStepToNote(gListener.keyToHalfStep(curKey) + 5, curKey), centerX, centerY + (bWidth/4.0) + 2);
    }
  }
  void mouseHandle(GWinApplet a, GWinData d, MouseEvent e) {   
    if(e.getAction() == MouseEvent.CLICK){
      globalActiveSource = SOUND_GEN;
      float left = MARGIN, top = MARGIN*2;
      float bWidth = 50, bHeight = 30;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ lowestOctave = 0; return; } // Low octave button
      left += bWidth;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ lowestOctave = 1; return; } // Med octave button
      left += bWidth;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ lowestOctave = 2; return; } // High octave button
      left  += bWidth + PADDING;
      bWidth = 40;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ curKey = "A"; return; } // A key button
      left += bWidth;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ curKey = "B"; return; } // B key button
      left += bWidth;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ curKey = "C"; return; } // C key button
      left += bWidth;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ curKey = "D"; return; } // D key button
      left += bWidth;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ curKey = "E"; return; } // E key button
      left += bWidth;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ curKey = "F"; return; } // F key button
      left += bWidth;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ curKey = "G"; return; } // G key button
      left  += bWidth + PADDING;
      bWidth = 75;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ waveform = Waves.SINE; return; } // Sine wave button
      left += bWidth;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ waveform = Waves.SQUARE; return; } // Square wave button
      left += bWidth;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ waveform = Waves.SAW; return; } // Saw wave button
      left += bWidth;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ waveform = Waves.TRIANGLE; return; } // Triangle wave button
      left = MARGIN * 2;
      top  = a.height - MARGIN*2;
      bWidth = 120;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ curForm = KEYBOARD_FORM; return; } // Keyboard form button
      left += bWidth;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ curForm = SCALE_FORM; return; } // Scale degree form button
      left += bWidth;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ curForm = TRIAD_FORM; return; } // Triad form button
      left += bWidth + PADDING;
      bWidth = 30;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ gListener.setBufferSize(bufSize/2); return; } // Decrease Buffer Size
      left += PADDING * 2 + bWidth * 3;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ gListener.setBufferSize(bufSize*2); return; } // Increase Buffer Size
      left += bWidth + PADDING;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ gListener.setSampleRate(samRate - 1000); return; } // Decrease Sample Rate
      left += PADDING * 2 + bWidth * 3;
      if(overRectangleBtn(a, left, top, left+bWidth, top+bHeight)){ gListener.setSampleRate(samRate + 1000); return; } // Increase Sample Rate
    }
  }
  void keyHandle(GWinApplet a, GWinData d, KeyEvent e) {
    globalActiveSource = SOUND_GEN;
    if(e.getAction() == KeyEvent.RELEASE && (a.keyCode == LEFT || a.keyCode == UP))    curForm = (curForm-1) < 0 ? nForms-1 : curForm-1;
    if(e.getAction() == KeyEvent.RELEASE && (a.keyCode == RIGHT || a.keyCode == DOWN)) curForm = (curForm+1) % nForms;
    
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'Q' && tones[0] == null) {
      tones[0] = gListener.triggerTone(curKey, pow(2, lowestOctave), 11, .2, waveform);
      tones[0].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'W' && tones[1] == null) {
      tones[1] = gListener.triggerTone(curKey, pow(2, lowestOctave+1), 0, .2, waveform);
      tones[1].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'E' && tones[2] == null) {
      tones[2] = gListener.triggerTone(curKey, pow(2, lowestOctave+1), 2, .2, waveform);
      tones[2].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'R' && tones[3] == null) {
      tones[3] = gListener.triggerTone(curKey, pow(2, lowestOctave+1), 4, .2, waveform);
      tones[3].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'T' && tones[4] == null) {
      tones[4] = gListener.triggerTone(curKey, pow(2, lowestOctave+1), 5, .2, waveform);
      tones[4].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'Y' && tones[5] == null) {
      tones[5] = gListener.triggerTone(curKey, pow(2, lowestOctave+1), 7, .2, waveform);
      tones[5].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'U' && tones[6] == null) {
      tones[6] = gListener.triggerTone(curKey, pow(2, lowestOctave+1), 9, .2, waveform);
      tones[6].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'I' && tones[7] == null) {
      tones[7] = gListener.triggerTone(curKey, pow(2, lowestOctave+1), 11, .2, waveform);
      tones[7].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'O' && tones[8] == null) {
      tones[8] = gListener.triggerTone(curKey, pow(2, lowestOctave+2), 0, .2, waveform);
      tones[8].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'P' && tones[9] == null) {
      tones[9] = gListener.triggerTone(curKey, pow(2, lowestOctave+2), 2, .2, waveform);
      tones[9].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'A' && tones[10] == null) {
      tones[10] = gListener.triggerTone(curKey, pow(2, lowestOctave+2), 4, .2, waveform);
      tones[10].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'S' && tones[11] == null) {
      tones[11] = gListener.triggerTone(curKey, pow(2, lowestOctave+2), 5, .2, waveform);
      tones[11].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'D' && tones[12] == null) {
      tones[12] = gListener.triggerTone(curKey, pow(2, lowestOctave+2), 7, .2, waveform);
      tones[12].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'F' && tones[13] == null) {
      tones[13] = gListener.triggerTone(curKey, pow(2, lowestOctave+2), 9, .2, waveform);
      tones[13].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'G' && tones[14] == null) {
      tones[14] = gListener.triggerTone(curKey, pow(2, lowestOctave+2), 11, .2, waveform);
      tones[14].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'H' && tones[15] == null) {
      tones[15] = gListener.triggerTone(curKey, pow(2, lowestOctave+3), 0, .2, waveform);
      tones[15].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'J' && tones[16] == null) {
      tones[16] = gListener.triggerTone(curKey, pow(2, lowestOctave+3), 2, .2, waveform);
      tones[16].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'K' && tones[17] == null) {
      tones[17] = gListener.triggerTone(curKey, pow(2, lowestOctave+3), 4, .2, waveform);
      tones[17].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'L' && tones[18] == null) {
      tones[18] = gListener.triggerTone(curKey, pow(2, lowestOctave+3), 5, .2, waveform);
      tones[18].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == ';' && tones[19] == null) {
      tones[19] = gListener.triggerTone(curKey, pow(2, lowestOctave+3), 7, .2, waveform);
      tones[19].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.key == '\'' && tones[20] == null) {
      tones[20] = gListener.triggerTone(curKey, pow(2, lowestOctave+3), 9, .2, waveform);
      tones[20].on();
    }
    if (e.getAction() == KeyEvent.PRESS && (a.keyCode == '\\' || a.keyCode == SHIFT) && tones[21] == null) {
      tones[21] = gListener.triggerTone(curKey, pow(2, lowestOctave+3), 11, .2, waveform);
      tones[21].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'Z' && tones[22] == null) {
      tones[22] = gListener.triggerTone(curKey, pow(2, lowestOctave+4), 0, .2, waveform);
      tones[22].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'X' && tones[23] == null) {
      tones[23] = gListener.triggerTone(curKey, pow(2, lowestOctave+4), 2, .2, waveform);
      tones[23].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'C' && tones[24] == null) {
      tones[24] = gListener.triggerTone(curKey, pow(2, lowestOctave+4), 4, .2, waveform);
      tones[24].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'V' && tones[25] == null) {
      tones[25] = gListener.triggerTone(curKey, pow(2, lowestOctave+4), 5, .2, waveform);
      tones[25].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'B' && tones[26] == null) {
      tones[26] = gListener.triggerTone(curKey, pow(2, lowestOctave+4), 7, .2, waveform);
      tones[26].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'N' && tones[27] == null) {
      tones[27] = gListener.triggerTone(curKey, pow(2, lowestOctave+4), 9, .2, waveform);
      tones[27].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == 'M' && tones[28] == null) {
      tones[28] = gListener.triggerTone(curKey, pow(2, lowestOctave+4), 11, .2, waveform);
      tones[28].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == ',' && tones[29] == null) {
      tones[29] = gListener.triggerTone(curKey, pow(2, lowestOctave+5), 0, .2, waveform);
      tones[29].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == '.' && tones[30] == null) {
      tones[30] = gListener.triggerTone(curKey, pow(2, lowestOctave+5), 2, .2, waveform);
      tones[30].on();
    }
    if (e.getAction() == KeyEvent.PRESS && a.keyCode == '/' && tones[31] == null) {
      tones[31] = gListener.triggerTone(curKey, pow(2, lowestOctave+5), 4, .2, waveform);
      tones[31].on();
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'Q') {
      tones[0].off();
      tones[0] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'W') {
      tones[1].off();
      tones[1] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'E') {
      tones[2].off();
      tones[2] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'R') {
      tones[3].off();
      tones[3] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'T') {
      tones[4].off();
      tones[4] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'Y') {
      tones[5].off();
      tones[5] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'U') {
      tones[6].off();
      tones[6] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'I') {
      tones[7].off();
      tones[7] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'O') {
      tones[8].off();
      tones[8] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'P') {
      tones[9].off();
      tones[9] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'A') {
      tones[10].off();
      tones[10] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'S') {
      tones[11].off();
      tones[11] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'D') {
      tones[12].off();
      tones[12] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'F') {
      tones[13].off();
      tones[13] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'G') {
      tones[14].off();
      tones[14] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'H') {
      tones[15].off();
      tones[15] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'J') {
      tones[16].off();
      tones[16] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'K') {
      tones[17].off();
      tones[17] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'L') {
      tones[18].off();
      tones[18] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == ';') {
      tones[19].off();
      tones[19] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.key == '\'') {
      tones[20].off();
      tones[20] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && (a.keyCode == '\\' || a.keyCode == SHIFT)) {
      tones[21].off();
      tones[21] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'Z') {
      tones[22].off();
      tones[22] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'X') {
      tones[23].off();
      tones[23] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'C') {
      tones[24].off();
      tones[24] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'V') {
      tones[25].off();
      tones[25] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'B') {
      tones[26].off();
      tones[26] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'N') {
      tones[27].off();
      tones[27] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == 'M') {
      tones[28].off();
      tones[28] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == ',') {
      tones[29].off();
      tones[29] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == '.') {
      tones[30].off();
      tones[30] = null;
    }
    if (e.getAction() == KeyEvent.RELEASE && a.keyCode == '/') {
      tones[31].off();
      tones[31] = null;
    }
  }
  void closeHandle(GWindow w) {
    if(tones!=null){
      for(int i=0; i<tones.length; i++)
        if(tones[i]!=null) tones[i].off();
    }
    globalActiveSource = NO_SOURCE;
  }
}

