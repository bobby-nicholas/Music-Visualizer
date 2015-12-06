public class spectrum extends visualization{
  private spectrumListener  sListener;
  private boolean[]         activeChannels;
  private boolean           averages = true, logarithmic = true, 
                            grid = true, vGrid = true, hGrid = true;
  private int               barsPerOctave = 3, nAverages = 30, nBuffers = 1, curForm, counter;
  private float             minOctaveWidth = 110, maxStrength = 100, tSeconds;
  private final int         VERTICAL_LINES = 0, LINE_GRAPH = 1, BAR_GRAPH = 2, TIME = 3, MIN_STRENGTH = 10;
  
  spectrum(PApplet a, spectrumListener sL){
    super(a, "Spectrum Visualizerer", 300, 300, 600, 250, true);
    sListener = sL;
    window.setMinimumSize(new Dimension(600,250));
    activeChannels = new boolean[3];
    activeChannels[LEFT_CHAN] = false;
    activeChannels[RIGHT_CHAN] = false;
    activeChannels[MIX_CHAN] = true;
    curColor = TEAL;
    curForm  = BAR_GRAPH;
    tSeconds = 0;
    counter  = 0;
  }
  void drawHandle(GWinApplet a, GWinData d){
    if(sListener!=null){
      sListener.listen();
      sListener.refresh();  
    }
    if(curForm == TIME) window.setAutoClear(false);
    else window.setAutoClear(true);
    drawSpectrum(a);
  }
  //depricated
  void drawVerticalLines(GWinApplet a, float[] spec, float left, float top, float right, float bottom){
    a.stroke(palette[curColor]);
    a.strokeWeight(2);
    if(spec==null)return;
    float mVal = max(spec) > MIN_STRENGTH ? max(spec) : MIN_STRENGTH;
    for(int i=0; i<spec.length; i++){
      float x = map(i, 0, spec.length-1, left, right);
      float y = map(spec[i], 0, mVal, 0, bottom-top);
      a.line(x, bottom, x, bottom-y);
    }
  }
  void drawLineGraph(GWinApplet a, float[] spec, float left, float top, float right, float bottom){
    a.stroke(palette[curColor]);
    a.strokeWeight(2);
    if(spec==null)return;
    float mVal = max(spec) > MIN_STRENGTH ? max(spec) : MIN_STRENGTH;
    for(int i=0; i<spec.length-1; i++){
      float x1 = map(i, 0, spec.length-1, left, right);
      float x2 = map(i+1, 0, spec.length-1, left, right);
      float y1 = map(spec[i], 0, mVal, 0, bottom-top);
      float y2 = map(spec[i+1], 0, mVal, 0, bottom-top);
      a.line(x1, bottom-y1, x2, bottom-y2);
    }
  }
  void drawVerticalBars(GWinApplet a, float[] spec, float left, float top, float right, float bottom){
    a.noStroke();
    a.fill(palette[curColor]);
    float mVal = max(spec) > MIN_STRENGTH ? max(spec) : MIN_STRENGTH;
    float barWidth = (right-left)/spec.length;
    float y;
    for(int i=0; i<spec.length; i++){
      y = map(spec[i], 0, mVal, 0, bottom-top);
      a.rect(left+(i*barWidth), bottom, barWidth, y*-1);
    }
  }
  void drawSpectrumIntensity(GWinApplet a, float[] spec, float left, float top, float right, float bottom){
    a.noStroke();
    float mVal = max(spec) > MIN_STRENGTH ? max(spec) : MIN_STRENGTH;
    float barWidth  = right-left;
    if(left + barWidth > right) return;
    float barHeight = (bottom-top)/spec.length;
    float x = left, y = top, intensity;
    //println("x = " + x + " y = " + y + " width = " + barWidth + " height = " + barHeight);
    for(int i = spec.length-1; i >= 0; i--){
      intensity = map(spec[i], 0, mVal, 0, 255);
      a.fill(palette[curColor], intensity);
      a.rect(x, y, barWidth, barHeight);
      y += barHeight;
    }
  }
  void drawVerticalScale(GWinApplet a, float right, float top, float bottom, float maxVal){
    a.stroke(palette[WHITE]);
    a.fill(palette[WHITE]);
    a.strokeWeight(1);
    a.textSize(12);
    a.textAlign(RIGHT,CENTER);
    if(curForm == TIME){
      a.textSize(10);
      a.text("Freq (Hz)", right-1, (top+bottom)/2.0);
    }
    else a.text("Density", right-2, (top+bottom)/2.0);
    a.textSize(12);
    a.line(right, top, right, bottom);
    a.line(right-5, top, right, top);
    a.line(right-5, bottom, right, bottom);
    a.text(int(maxVal), right-7, top);
    a.text("0", right-7, bottom);
  }
  void drawHorizontalScale(GWinApplet a, float top, float left, float right){
    a.stroke(palette[WHITE]);
    a.fill(palette[WHITE]);
    a.strokeWeight(1);
    a.textSize(12);
    a.textAlign(CENTER,TOP);
    float subWidth = (left + right)/2;
    a.line(left, top, right, top);
    if(curForm==TIME){
      if(sListener==null) return;
      a.text("Time (Seconds)",subWidth, top+PADDING);
      a.line(left, top, left, top+5);
      a.text(nf(0.0,1,1), left, top+7);
      a.line(right, top, right, top+5);
      a.text(nf(((nBuffers * sListener.bufferSize())/a.frameRate)/1000.0,1,1), right, top+7);
    }
    else{
      a.text("Frequency (Hz)",subWidth, top+MARGIN);
      int labelScale, specLength;
      float bFactor = 1024.0 / sListener.bufferSize();
      if      (subWidth < 300)labelScale = int(256 / bFactor);
      else if (subWidth < 600)labelScale = int(128 / bFactor);
      else if (subWidth < 800)labelScale = int(64  / bFactor);
      else                    labelScale = int(32  / bFactor); 
      if(logarithmic){
        specLength = sListener.spectrumAvgSize();
        if(labelScale > specLength/2) labelScale = specLength/4;
        for(int i=0; i<specLength; i+=labelScale){
          float freq = sListener.indexToFrequency(i, true);
          float x = map(i, 0, specLength-1, left, right);
          a.line(x, top, x, top+5);
          a.text(int(freq), x, top+7);
        }
        float freq = sListener.indexToFrequency(specLength-1, true);
        float x = map(specLength-1, 9, specLength-1, left, right);
        a.line(x, top, x, top+5);
        a.text(int(freq), x, top+7);
      }
      else{ 
        specLength = sListener.spectrumSize();
        for (int i=0; i<specLength; i+=labelScale) {
          float freq = sListener.indexToFrequency(i, false);
          float x = map(i, 0, specLength-1, left, right);
          a.line(x, top, x, top+5);
          a.text(int(freq), x, top+7);
        }
      }
    }
  }
  void wipe(GWinApplet a, float right, float bottom){
    a.fill(BACKGROUND);
    a.noStroke();
    a.rect(0,0,right, a.height-1);
    a.rect(0, bottom, a.width-1, a.height-bottom-1);
  }
  void drawButtons(GWinApplet a, float top, float left, float right){
    final int TEXT_SIZE = 12;
    a.textAlign(CENTER,TOP);
    a.textSize(TEXT_SIZE);
    a.stroke(0);
    a.strokeWeight(2);
    
    //Grid Toggle Buttons
    float x = left, y = top, bHeight = 20, bWidth;
    bWidth = "Off".length()*TEXT_SIZE;
    a.fill(palette[WHITE]);
    a.text("Grid", x + (bWidth/2.0), y);
    y += PADDING * 2;
    if(grid || overRectangleBtn(a, x, y, x+bWidth, y+bHeight)) a.fill(palette[BLUE],255);
    else a.fill(palette[BLUE], 80);
    a.rect(x, y, bWidth, bHeight,5,5,0,0);
    if(!grid || overRectangleBtn(a, x, y+bHeight, x+bWidth, y+bHeight*2)) a.fill(palette[RED],255);
    else a.fill(palette[RED], 80);
    a.rect(x, y + bHeight, bWidth, bHeight,0,0,5,5);
    a.fill(0);
    a.text("On",  x + (bWidth/2.0), y + 2);
    a.text("Off", x + (bWidth/2.0), (y + bHeight) + 2);

    //Graph Type Buttons
    x += bWidth + PADDING;
    y =  top;
    bWidth = "Line".length()*TEXT_SIZE;
    a.fill(palette[WHITE]);
    a.text("Graph", x + bWidth, y);
    y += PADDING*2;
    if(curForm == BAR_GRAPH || overRectangleBtn(a, x, y, x+bWidth, y+bHeight)) a.fill(palette[TEAL],255);
    else a.fill(palette[TEAL],80);
    a.rect(x, y, bWidth, bHeight, 5,0,0,5);
    if(curForm == LINE_GRAPH || overRectangleBtn(a, x+bWidth, y, x+bWidth*2, y+bHeight)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN],80);
    a.rect(x+bWidth, y, bWidth, bHeight, 0,5,5,0);
    if(curForm == TIME || overRectangleBtn(a, x, y+bHeight, x+bWidth*2, y+bHeight*2)) a.fill(palette[BLUE],255);
    else a.fill(palette[BLUE],80);
    a.rect(x, y+bHeight, bWidth*2, bHeight, 0,0,5,5);
    a.fill(0);
    a.text("Bar", x + (bWidth/2.0), y + 2);
    a.text("Line", x + bWidth + (bWidth/2.0), y + 2);
    a.text("Spectrogram", x + bWidth, y + bHeight + 2);
    //Linear-Logarithmic Toggle Buttons
    x += bWidth*2 + PADDING;
    y =  top;
    bWidth = "Logarithmic".length()*TEXT_SIZE-MARGIN*2;
    a.fill(palette[WHITE]);
    a.text("Frequecy Scale", x + bWidth/2.0, y);
    y += PADDING*2;
    if(!logarithmic || overRectangleBtn(a, x, y, x+bWidth,y+bHeight)) a.fill(palette[TEAL],255);
    else a.fill(palette[TEAL],80);
    a.rect(x, y, bWidth, bHeight,5,5,0,0);
    if(logarithmic || overRectangleBtn(a, x, y+bHeight, x+bWidth, y+bHeight*2)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN],80);
    a.rect(x, y+bHeight, bWidth, bHeight,0,0,5,5);
    a.fill(0);
    a.text("Linear", x + (bWidth/2.0), y + 2);
    a.text("Logarithmic", x + (bWidth/2.0), (y + bHeight) + 2);
    
    //Averages Toggle Buttons
    x += bWidth + PADDING;
    y =  top;
    bWidth = "Off".length()*TEXT_SIZE+MARGIN;
    a.fill(palette[WHITE]);
    a.text("Averages", x+bWidth, y);
    y += PADDING*2;
    if(averages || overRectangleBtn(a, x, y, x+bWidth, y+bHeight)) a.fill(palette[BLUE],255);
    else a.fill(palette[BLUE],80);
    a.rect(x,y,bWidth, bHeight, 10,0,0,10);
    if(!averages || overRectangleBtn(a, x+bWidth, y, x + bWidth*2, y + bHeight)) a.fill(palette[RED],255);
    else a.fill(palette[RED],80);
    a.rect(x+bWidth, y, bWidth, bHeight, 0,10,10,0);
    if(averages && overRectangleBtn(a, x, y+bHeight, x + bWidth/2.0, y + bHeight*2)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN],80);
    a.rect(x, y+bHeight, bWidth/2.0, bHeight, 10,0,0,10);
    if(averages) a.fill(palette[WHITE],255);
    else a.fill(palette[WHITE],80);
    a.rect(x + (bWidth/2.0), y+bHeight, bWidth, bHeight);
    if(averages && overRectangleBtn(a, x + bWidth*1.5, y+bHeight, x + bWidth*2, y + bHeight*2)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN],80);
    a.rect(x + bWidth*1.5, y + bHeight, bWidth/2.0, bHeight, 0,10,10,0);
    a.fill(0);
    a.text("On",  x + (bWidth/2.0), y + 2);
    a.text("Off", x + (bWidth*1.5), y + 2);
    a.text("-",   x + (bWidth/4.0), y + bHeight + 2);
    if(averages && sListener!=null) a.text(sListener.spectrumAvgSize(), x + bWidth, y + bHeight + 2);
    else a.text(". . .", x + bWidth, y + bHeight + 2);
    a.text("+", x + bWidth*2 - (bWidth/4.0), y + bHeight + 2);
    
    //Time Toggle Buttons
    x += bWidth*2 + PADDING;
    y =  top;
    bWidth = "Off".length()*TEXT_SIZE+MARGIN;
    a.fill(palette[WHITE]);
    a.text("Time (Sec)", x+bWidth, y);
    y += bHeight/2.0;
    if(curForm == TIME && overRectangleBtn(a, x, y+bHeight, x + bWidth/2.0, y + bHeight*2)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN],80);
    a.rect(x, y+bHeight, bWidth/2.0, bHeight, 10,0,0,10);
    if(curForm == TIME) a.fill(palette[WHITE],255);
    else a.fill(palette[WHITE],80);
    a.rect(x + (bWidth/2.0), y+bHeight, bWidth, bHeight);
    if(curForm == TIME && overRectangleBtn(a, x + bWidth*1.5, y+bHeight, x + bWidth*2, y + bHeight*2)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN],80);
    a.rect(x + bWidth*1.5, y + bHeight, bWidth/2.0, bHeight, 0,10,10,0);
    a.fill(0);
    a.text("-",   x + (bWidth/4.0), y + bHeight + 2);
    if(curForm == TIME) a.text(nf(tSeconds,1,1), x + bWidth, y + bHeight + 2);
    else a.text(". . .", x + bWidth, y + bHeight + 2);
    a.text("+", x + bWidth*2 - (bWidth/4.0), y + bHeight + 2);
    
    //Color Selection Buttons
    x += bWidth*2 + PADDING;
    y =  top;
    bWidth = bHeight;
    a.fill(palette[WHITE]);
    a.text("Color", x+bWidth, y);
    y += PADDING*2;
    int c = 1;
    for(int i=0; i<2; i++){
      for(int j=0; j<2; j++){
        if(curColor == c || overRectangleBtn(a, x + (bWidth * i),  y + (bHeight * j), x + (bWidth * i) + bWidth, y + (bHeight * j) + bHeight)) a.fill(palette[c],255);
        else a.fill(palette[c],80);
        a.rect(x + (bWidth*i), y + (bHeight*j), bWidth, bHeight, 5);
        c++;
      } 
    }
  }
  void drawSpectrum(GWinApplet a){
    //spectrum view area
    float left   = vGrid ? MARGIN*2+PADDING : MARGIN;
    float right  = a.width-MARGIN, top = MARGIN;
    float bottom = a.height - MARGIN*5-PADDING;
    char chan = activeChannels[LEFT_CHAN] ? 'L' : activeChannels[RIGHT_CHAN] ? 'R' : activeChannels[MIX_CHAN] ? 'M' : '-';
    float[] spec = null;
    if(averages){
      if(logarithmic) spec =  sListener.spectrumLogAvgs(chan, minOctaveWidth, barsPerOctave);
      else            spec =  sListener.spectrumLinAvgs(chan, nAverages);
    }
    else{
      if(logarithmic){
        int bands = sListener.spectrumSize();
        float max = sListener.sampleRate()/2;
        int octs  = 0;
        while(max > minOctaveWidth){ max /= 2; octs++; }
        int bandsPerOctave = int( bands / float(octs) );
        if(bandsPerOctave < 1) spec = sListener.spectrumLogAvgs(chan, minOctaveWidth, 12);
        else                   spec = sListener.spectrumLogAvgs(chan, minOctaveWidth, bandsPerOctave);
      }
      else spec = sListener.spectrumBands(chan);  
    }
    if(spec==null) return;
    float mValue = max(spec) > MIN_STRENGTH ? max(spec) : MIN_STRENGTH;
    if     (curForm == VERTICAL_LINES) drawVerticalLines(a, spec, left, top, right, bottom);
    else if(curForm == LINE_GRAPH)     drawLineGraph(a, spec, left, top, right, bottom);
    else if(curForm == BAR_GRAPH)      drawVerticalBars(a, spec, left, top, right, bottom);
    else if(curForm == TIME){
      wipe(a, left-1, bottom+1);
      float w = (right - left)/nBuffers;
      drawSpectrumIntensity(a, spec, left + (counter * w), top, left + (counter * w) + w, bottom);
      counter = (counter + 1 < nBuffers) ? counter + 1 : 0;
      if(counter == 0){
        window.setBackground(BACKGROUND);
        if     ((nBuffers * sListener.bufferSize())/a.frameRate/1000.0 > tSeconds) nBuffers = nBuffers > 1 ? nBuffers - 1 : 1;
        else if((nBuffers * sListener.bufferSize())/a.frameRate/1000.0 < tSeconds) nBuffers = nBuffers < 1000 ? nBuffers + 1 : 1000;
      }
    }
    if(vGrid){
      if(curForm==TIME) drawVerticalScale(a, left-PADDING, top, bottom, sListener.indexToFrequency(spec.length-1, logarithmic));
      else              drawVerticalScale(a, left-PADDING, top, bottom, mValue);
    }
    if(hGrid) drawHorizontalScale(a, bottom+PADDING, left, right);
    bottom += MARGIN*2+PADDING;
    left    = MARGIN;
    drawButtons(a, bottom, left, right);
  }
  void drawSpectrogram(GWinApplet a){
    
  }
  void mouseHandle(GWinApplet a, GWinData d, MouseEvent e){
    if(e.getAction() == MouseEvent.CLICK){
      float top = a.height - MARGIN*3 + PADDING*2, 
            left = MARGIN, bHeight = 20, bWidth;
      int TEXT_SIZE = 12;
      
      float x = left, y = top;
      bWidth = "Off".length()*TEXT_SIZE;
      //Grid 'On' Button
      if(overRectangleBtn(a, x, y, x+bWidth, y+bHeight)){
        hGrid = true; vGrid = true; 
        window.setBackground(BACKGROUND); 
        counter = 0;
        return;
      }
      //Grid 'Off' Button
      if(overRectangleBtn(a, x, y+bHeight, x+bWidth, y+bHeight*2)){
        hGrid = false; vGrid = false; 
        window.setBackground(BACKGROUND);
        counter = 0; 
        return;  
      }
      
      x += bWidth + PADDING;
      bWidth = "Line".length()*TEXT_SIZE;
      //'Bar' Graph Button
      if(overRectangleBtn(a, x, y, x+bWidth, y+bHeight)){
        curForm = BAR_GRAPH; return;
      }
      //'Line' Graph Button
      if(overRectangleBtn(a, x+bWidth, y, x+bWidth*2, y+bHeight)){
        curForm = LINE_GRAPH; return;
      }
      //'Time' Spectrogram Button
      if(overRectangleBtn(a, x, y+bHeight, x+bWidth*2, y+bHeight*2)){
        curForm = TIME; 
        counter = 0; 
        return;
      }
      
      x += bWidth*2 + PADDING;
      bWidth = "Logarithmic".length()*TEXT_SIZE-MARGIN*2;
      //'Linear' Plot Button
      if(overRectangleBtn(a, x, y, x+bWidth, y+bHeight)){
        logarithmic = false; return;
      }
      //'Logarithmic' Plot Button
      if(overRectangleBtn(a, x, y+bHeight, x+bWidth, y+bHeight*2)){
        logarithmic = true; return;
      }
      
      x += bWidth + PADDING;
      bWidth = "Off".length()*TEXT_SIZE+MARGIN;
      //Averages 'On' Button
      if(overRectangleBtn(a, x, y, x+bWidth, y+bHeight)){
        averages = true; return;
      }
      //Averages 'Off' Button
      if(overRectangleBtn(a, x+bWidth, y, x+bWidth*2, y+bHeight)){
        averages = false; return;
      }
      
      //# of Bars '-' Button
      if(averages && overRectangleBtn(a, x, y+bHeight, x + bWidth/2.0, y + bHeight*2)){
        if     ( logarithmic && barsPerOctave > 1) barsPerOctave--; 
        else if(!logarithmic && nAverages     > 1) nAverages--;
        return;
      }
      //# of Bars '+' Button
      if(averages && overRectangleBtn(a, x + bWidth*1.5, y+bHeight, x + bWidth*2, y + bHeight*2)){
        if     ( logarithmic && barsPerOctave < 11) barsPerOctave++;
        else if(!logarithmic && nAverages     < 88) nAverages++;
        return;
      }
      
      //Time Adjust Buttons
      x += bWidth*2 + PADDING;
      //# of Seconds '-' Button
      if(curForm == TIME && overRectangleBtn(a, x, y + (bHeight/2.0), x + bWidth/2.0, y + bHeight*1.5)){
        if(tSeconds > 0.25){
          tSeconds /= 2; 
          nBuffers = nBuffers/2 > 1 ? nBuffers/2 : 1;
        } 
        else{
          tSeconds = 0; 
          nBuffers = 1;
        }
        window.setBackground(BACKGROUND);
        counter = 0;
        return; 
      }
      //# of Seconds '+' Button
      if(curForm == TIME && overRectangleBtn(a, x + bWidth*1.5, y + (bHeight/2.0), x + bWidth*2, y + bHeight*1.5)){
        if(tSeconds >  30 && tSeconds < 60){
          tSeconds  = 60;
          nBuffers *= 2;
        }
        else if(tSeconds == 0 ){
          tSeconds  = 0.25;
          nBuffers  = 5;
        }
        else if(tSeconds <60){
          tSeconds *= 2;
          nBuffers *= 2;
        }
        window.setBackground(BACKGROUND);
        counter = 0;
        return; 
      }
      
      x += bWidth*2 + PADDING;
      bWidth = bHeight;
      int c = 1;
      //Color Select Buttons
      for(int i=0; i<2; i++){
        for(int j=0; j<2; j++){
          if(overRectangleBtn(a, x + (bWidth * i),  y + (bHeight * j), x + (bWidth * i) + bWidth, y + (bHeight * j) + bHeight))
            curColor = c;
          c++;
        } 
      }
    }
  }
  void keyHandle(GWinApplet a, GWinData d, KeyEvent e){
    if(e.getAction() == KeyEvent.RELEASE && a.keyCode == 'C') {
      curColor = (curColor+1) % palette.length;
    }
    else if(e.getAction() == KeyEvent.RELEASE && a.keyCode == 'L') {
      activeChannels[LEFT_CHAN] = activeChannels[LEFT_CHAN] ? false : true;
      activeChannels[RIGHT_CHAN] = false;
      activeChannels[MIX_CHAN] = false;
    }
    else if(e.getAction() == KeyEvent.RELEASE && a.keyCode == 'R') {
      activeChannels[RIGHT_CHAN] = activeChannels[RIGHT_CHAN] ? false : true;
      activeChannels[LEFT_CHAN] = false;
      activeChannels[MIX_CHAN] = false;
    }
    else if(e.getAction() == KeyEvent.RELEASE && a.keyCode == 'M') {
      activeChannels[MIX_CHAN] = activeChannels[MIX_CHAN] ? false : true;
      activeChannels[LEFT_CHAN] = false;
      activeChannels[RIGHT_CHAN] = false;
    }
    //adapted from http://code.compartmental.net/minim/windowfunction_class_windowfunction.html
    else if (e.getAction() == KeyEvent.RELEASE && a.keyCode == '0'){ sListener.setWinFunction(FFT.NONE); }
    else if (e.getAction() == KeyEvent.RELEASE && a.keyCode == '1'){ sListener.setWinFunction(FFT.BARTLETT); }
    else if (e.getAction() == KeyEvent.RELEASE && a.keyCode == '2'){ sListener.setWinFunction(FFT.BARTLETTHANN); }
    else if (e.getAction() == KeyEvent.RELEASE && a.keyCode == '3'){ sListener.setWinFunction(FFT.BLACKMAN); }
    else if (e.getAction() == KeyEvent.RELEASE && a.keyCode == '4'){ sListener.setWinFunction(FFT.COSINE); }
    else if (e.getAction() == KeyEvent.RELEASE && a.keyCode == '5'){ sListener.setWinFunction(FFT.GAUSS); }
    else if (e.getAction() == KeyEvent.RELEASE && a.keyCode == '6'){ sListener.setWinFunction(FFT.HAMMING); }
    else if (e.getAction() == KeyEvent.RELEASE && a.keyCode == '7'){ sListener.setWinFunction(FFT.HANN); }
    else if (e.getAction() == KeyEvent.RELEASE && a.keyCode == '8'){ sListener.setWinFunction(FFT.LANCZOS); }
    else if (e.getAction() == KeyEvent.RELEASE && a.keyCode == '9'){ sListener.setWinFunction(FFT.TRIANGULAR); }
    
  }
  void closeHandle(GWindow w){
    sListener.stopListening();
  }
}
