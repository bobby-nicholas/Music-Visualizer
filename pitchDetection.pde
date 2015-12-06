public class pitchDetection extends visualization {
  private pitchListener pListener;
  private float[]       plot;
  private int           pIndex;
  private final int     ALGORITHM = 0, PLOT = 1;
  private int           curAlgo, nAlgos, mode;
  
  pitchDetection(PApplet a, pitchListener pL) {
    super(a, "Pitch Detector", 800, 550);
    pListener = pL;
    window.papplet.textAlign(CENTER, CENTER);
    window.papplet.stroke(palette[WHITE]);
    window.setMinimumSize(new Dimension(500,600));
    curAlgo = pListener.LOCAL_MAXIMA;
    nAlgos = 3;
    mode = ALGORITHM;
    pIndex = 0;
    plot = new float[200];
  }
  void drawHandle(GWinApplet a, GWinData d) {
    drawButtons(a);
    if (pListener==null) return;
    pListener.listen();
    if(!pListener.refresh())  return;
    if(mode == ALGORITHM){
      if(curAlgo == pListener.LOCAL_MAXIMA) 
        drawFundamentalFreqAlgo(a);
      else if(curAlgo == pListener.HARMONIC_PROD)
        drawHPSAlgo(a);
      else if(curAlgo == pListener.AUTOCORRELATION)
        drawAutocorrelationAlgo(a);
    }
    else if(mode == PLOT){
      drawPlot(a);  
    }
  }
  void drawPlot(GWinApplet a){
    if(pListener==null) return;
    a.fill(palette[WHITE]);
    a.stroke(palette[WHITE]);
    a.strokeWeight(1);
    a.textSize(30);
    if(curAlgo == pListener.LOCAL_MAXIMA){
      a.text("Fundamental Frequency", a.width/2, MARGIN);
      plot[pIndex] = pListener.localMaxima(pListener.mix());
    }
    else if(curAlgo == pListener.HARMONIC_PROD){
      a.text("Harmonic Product Spectrum", a.width/2, MARGIN);
      plot[pIndex] = pListener.harmonicProduct(pListener.mix());
    }
    else if(curAlgo == pListener.AUTOCORRELATION){
      a.text("Autocorrelation", a.width/2, MARGIN);
      plot[pIndex] = pListener.autocorrelation(pListener.mix());
    }
    a.textSize(25);
    a.text(nf(plot[pIndex],1,1) + "\n" + pListener.pitchClass(plot[pIndex]), a.width/2, a.height-40);
    float subHeight = a.height/1.5;
    float subWidth  = a.width-MARGIN*3;
    float top    = MARGIN*2;
    float bottom = top+subHeight; 
    float left   = MARGIN*2;
    float right  = left+subWidth;
    a.line(left, top, left, bottom);
    a.line(left, bottom, right, bottom);
    a.textSize(12);
    for(int i = 28; i<12544; i *= 2){
        float y = map(log(i)/log(2), log(27.50)/log(2), log(12543.855)/log(2), bottom, top);
        a.line(left, y, left-5, y);
        a.text(str(i), MARGIN, y);
    }
    a.stroke(palette[TEAL]);
    a.strokeWeight(4);
    for(int i=0; i<pIndex; i++){
      if     (plot[i] > 12543.855) plot[i] = 12543.855;
      else if(plot[i] < 27.50    ) plot[i] = 27.50;
      float x1 = map(i, 0, plot.length-1, left, right);
      float x2 = map(i+1, 0, plot.length-1, left, right);
      float y1 = map(log(plot[i])/log(2), log(27.50)/log(2), log(12543.855)/log(2), bottom, top);
      float y2 = map(log(plot[i+1])/log(2), log(27.50)/log(2), log(12543.855)/log(2), bottom, top);
      a.line(x1, y1, x2, y2);
    }
    pIndex = (pIndex+1) % plot.length;
  }
  void drawButtons(GWinApplet a) {
    int bWidth = 140, bHeight = 50;
    int locX = a.width-MARGIN-bWidth, locY = a.height-PADDING-bHeight;
    if (overRectangleBtn(a, locX, locY, locX+bWidth, locY+bHeight)) a.fill(palette[TEAL]);
    else a.fill(palette[TAN]);
    a.stroke(0);
    a.strokeWeight(2);
    a.rect(locX, locY, bWidth, bHeight, 5);
    a.fill(0);
    a.textSize(15);
    a.text("Change Detection\nMethod", (locX+locX+bWidth)/2, (locY+locY+bHeight)/2);
    locX = MARGIN; bWidth = 130; bHeight = 20;
    for(int i=0; i<2; i++){
      if(i == mode) a.fill(palette[RED]);
      else if (overRectangleBtn(a, locX, locY, locX+bWidth, locY+bHeight)) a.fill(palette[TEAL]);
      else a.fill(palette[TAN]);
      a.rect(locX, locY, bWidth, bHeight, 5);
      a.fill(0);
      String text;
      if(i==0) text = "Algorith"; else text = "Plot";
      a.text(text, (locX+locX+bWidth)/2, (locY+locY+bHeight)/2);
      locY += bHeight+PADDING;  
    }
  }
  void drawAutocorrelationAlgo(GWinApplet a) {
    window.setAutoClear(true);
    float[] sample   = pListener.mix();
    float[] normalAC = pListener.getNormalizedAC(sample);
    float   period   = pListener.getWavePeriod(normalAC);
    float   pitch    = pListener.wavePeriodToFreq(period);
    String  pClass   = pListener.pitchClass(pitch);

    float subHeight = a.height/1.5;
    float subWidth  = a.width-MARGIN*3;
    float minVal    = min(sample);
    float maxVal    = max(sample);
    a.fill(palette[WHITE]);
    a.stroke(palette[WHITE]);
    a.strokeWeight(1);
    a.textSize(30);
    a.text("Autocorrelation", a.width/2, MARGIN);
    a.textSize(25);
    a.text(nf(pitch,1,1) + "\n" + pClass, a.width/2, a.height-40); 
    float top    = MARGIN*2;
    float bottom = top+subHeight;
    float center = (top+bottom)/2; 
    float left   = MARGIN*2;
    float right  = left+subWidth;
    a.line(left, top, left, bottom);
    a.line(left-5, center, right, center);
    if (sample==null) return;
    a.textSize(15);
    a.text("0", left-PADDING, center);
    a.text("1", left-PADDING, top);
    a.text("-1", left-PADDING, bottom);
    a.text(str(sample.length), right+2, center+5);
    int mIndex = 0;
    for (int i=0; i<sample.length-period; i++) {
      if (sample[i] == maxVal) {
        mIndex = i; 
        break;
      }
    }
    for (int i=0; i<sample.length-1; i++) {
      if (i >= mIndex && i <= mIndex+period) a.stroke(palette[RED]);
      else a.stroke(palette[TEAL]);
      float x1 = map(i, 0, sample.length-1, left, right);
      float y1 = map(sample[i], -1, 1, bottom, top);
      float x2 = map(i+1, 0, sample.length-1, left, right);
      float y2 = map(sample[i+1], -1, 1, bottom, top);
      a.line(x1, y1, x2, y2);
    }
  }
  void drawFundamentalFreqAlgo(GWinApplet a) {
    window.setAutoClear(true);
    float[] spectrum = pListener.getBoundedSpectrum(pListener.mix());
    int     index    = pListener.indexOfMaximum(spectrum);
    float   pitch    = pListener.spectrumIndexToFreq(index);
    String  pClass   = pListener.pitchClass(pitch);

    float subHeight = a.height/1.5;
    float subWidth  = a.width-MARGIN*3;
    a.fill(palette[WHITE]);
    a.stroke(palette[WHITE]);
    a.strokeWeight(1);
    a.textSize(30);
    a.text("Fundamental Frequency", a.width/2, MARGIN);
    float top    = MARGIN*2;
    float bottom = top+subHeight; 
    float left   = MARGIN*2;
    float right  = left+subWidth;
    a.line(left, top, left, bottom);
    a.line(left, bottom, right, bottom);
    if (spectrum!=null) {
      a.textSize(15);
      a.text("0", left-PADDING*2, bottom);
      a.text(str(int(max(spectrum))), left-PADDING*2, top);
      a.line(left-5, bottom, left, bottom);
      a.line(left-5, top, left, top);
      int labelScale;
      float bFactor = 1024.0 / pListener.bufferSize();
      if      (subWidth < 500) labelScale = int(256 / bFactor);
      else if (subWidth < 1000)labelScale = int(128 / bFactor);
      else if (subWidth < 1800)labelScale = int(64  / bFactor);
      else                     labelScale = int(32  / bFactor);
      for (int i=0; i<spectrum.length; i+=labelScale) {
        float freq = pListener.spectrumIndexToFreq(i);
        float x = map(i, 0, spectrum.length-1, left, right);
        a.line(x, bottom, x, bottom+5);
        a.text(str(int(freq)), x, bottom+PADDING);
      }

      for (int i=0; i<spectrum.length; i++) {
        float x = map(i, 0, spectrum.length-1, left, right);
        float y = map(spectrum[i], 0, max(spectrum), 0, subHeight);
        if (i == index) { 
          a.stroke(palette[RED]); 
          a.strokeWeight(3);
        } else {
          a.stroke(palette[TEAL]); 
          a.strokeWeight(1);
        }
        a.line(x, bottom, x, bottom-y);
      }
    }

    a.stroke(palette[WHITE]);
    a.textSize(25);
    a.text(nf(pitch,1,1) + "\n" + pClass, a.width/2, a.height-40);
  }
  void drawHPSAlgo(GWinApplet a) {
    window.setAutoClear(true);
    float[][] hMatrix = pListener.getHarmonicSpectrumMatrix(pListener.mix());
    float[]   product = pListener.getProductSpectrum(hMatrix);
    int       index   = pListener.indexOfMaximum(product);
    float     pitch   = pListener.spectrumIndexToFreq(index);
    String    pClass  = pListener.pitchClass(pitch);

    float subHeight = hMatrix!=null ? (a.height-MARGIN*2)/(hMatrix.length+3) : (a.height-MARGIN*2)/(pListener.downSamples()+4);
    float subWidth  = a.width-MARGIN*3;
    int clip = 100;
    a.fill(palette[WHITE]);
    a.stroke(palette[WHITE]);
    a.strokeWeight(1);
    a.textSize(30);
    a.text("Harmonic Product Spectrum", a.width/2, MARGIN);
    float top = MARGIN*2;
    float bottom = top+subHeight;
    a.textSize(15);
    a.text("1", MARGIN+PADDING, (top+bottom)/2);
    for (int i = 0; i < pListener.downSamples ()+2; i++) {
      bottom = top + subHeight;
      float right = (i == pListener.downSamples()+1) ? (MARGIN*2+subWidth)/(pListener.downSamples()+1) : (MARGIN*2+subWidth)/(i+1);
      if (i==pListener.downSamples()+1) a.stroke(palette[TAN]); 
      else a.stroke(palette[WHITE]);
      a.line(MARGIN*2, top, MARGIN*2, bottom);
      a.line(MARGIN*2, bottom, right, bottom);
      if (i>0 && i<pListener.downSamples()+1) a.text("1/" + str(i+1), MARGIN+PADDING, (top+bottom)/2);
      else if (i==pListener.downSamples()+1) {
        a.stroke(palette[WHITE]);
        a.text("HPS", MARGIN+PADDING, (top+bottom)/2);
      }
      top = bottom + PADDING;
    }
    if (hMatrix!=null) {
      top = MARGIN*2;
      for (int i = 0; i < hMatrix.length; i++) {
        bottom = top + subHeight;
        for (int j = 0; j < hMatrix[i].length-1; j++) {
          if (j == index || j+1 == index) { 
            a.stroke(palette[RED]); 
            a.strokeWeight(2);
          } else { 
            a.stroke(palette[TEAL]); 
            a.strokeWeight(1);
          }
          float x1 = map(j, 0, hMatrix[0].length, MARGIN*2, MARGIN+subWidth);
          float x2 = map(j+1, 0, hMatrix[0].length, MARGIN*2, MARGIN+subWidth);
          float val = hMatrix[i][j] < clip ? hMatrix[i][j] : clip;
          float y1 = map(hMatrix[i][j], 0, max(hMatrix[i]), 0, subHeight);
          val = hMatrix[i][j+1] < clip ? hMatrix[i][j] : clip;
          float y2 = map(hMatrix[i][j+1], 0, max(hMatrix[i]), 0, subHeight);
          a.line(x1, bottom-y1, x2, bottom-y2);
        }
        top = bottom + PADDING;
      }
      for (int i = 0; i < product.length-1; i++) {
        bottom = top + subHeight;
        if (i == index || i+1 == index) { 
          a.stroke(palette[RED]); 
          a.strokeWeight(2);
        } else { 
          a.stroke(palette[TAN]); 
          a.strokeWeight(1);
        }
        float x1 = map(i, 0, hMatrix[0].length, MARGIN*2, MARGIN+subWidth);
        float x2 = map(i+1, 0, hMatrix[0].length, MARGIN*2, MARGIN+subWidth);
        float y1 = map(product[i], 0, max(product), 0, subHeight); 
        float y2 = map(product[i+1], 0, max(product), 0, subHeight);
        a.line(x1, bottom-y1, x2, bottom-y2);
      }
    }
    a.stroke(palette[WHITE]);
    a.textSize(25);
    a.text(nf(pitch,1,1) + "\n" + pClass, a.width/2, a.height-40);
  }
  void mouseHandle(GWinApplet a, GWinData d, MouseEvent e) {
    if(e.getAction() == MouseEvent.CLICK){
      //Detection Method Button
      int bWidth = 140, bHeight = 50;
      int locX = a.width-MARGIN-bWidth, locY = a.height-PADDING-bHeight;
      if(overRectangleBtn(a, locX, locY, locX+bWidth, locY+bHeight)){
        curAlgo = (curAlgo+1) % nAlgos;
        window.setBackground(80); return;
      }
      //Algorithm Mode Button
      locX = MARGIN; bWidth = 130; bHeight = 20;
      if(overRectangleBtn(a, locX, locY, locX+bWidth, locY+bHeight)){
        mode = ALGORITHM; return;
      }
      locY += bHeight+PADDING;
      if(overRectangleBtn(a, locX, locY, locX+bWidth, locY+bHeight)){
        mode = PLOT; return;
      }  
    }
  }
  void keyHandle(GWinApplet a, GWinData d, KeyEvent e) {
  }
  void closeHandle(GWindow w) {
  }
}

