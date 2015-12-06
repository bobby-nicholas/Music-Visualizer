public class waveform extends visualization{
  private waveListener wListener;
  private boolean[]    activeChannels;
  private int          bufferSize = 0, counter = 0;
  private int          nBuffers = 1;
  private boolean      scale = false, grid = true;
  private float        targetTime = 0;
  waveform(PApplet a, waveListener wL){
    super(a, "Waveform Visualizer", 280, 200, 650, 280, true);
    window.setAutoClear(false);
    window.setBackground(80);
    window.setMinimumSize(new Dimension(650,250));
    wListener = wL;
    activeChannels = new boolean[3];
    activeChannels[LEFT_CHAN]  = true;
    activeChannels[RIGHT_CHAN] = true;
    activeChannels[MIX_CHAN]   = false;
    curColor = 2;
  }
  void drawHandle(GWinApplet a, GWinData d){
    window.setAutoClear(false);
    if(wListener==null) return;
    wListener.listen();
    if(bufferSize != wListener.bufferSize()){
      bufferSize = wListener.bufferSize();
    }
    drawWave(a);
    //drawInstructionsBtn(a);
  }
  void drawVerticalRule(GWinApplet a, float topY, float bottomY, float minVal, float maxVal){
    a.stroke(palette[WHITE]);
    a.fill(palette[WHITE]);
    a.strokeWeight(1);
    a.textSize(10);
    a.textAlign(RIGHT,CENTER);
    int left = MARGIN*2-PADDING;
    a.line(left,   topY,    left,   bottomY);
    a.line(left-5, bottomY, left,   bottomY);
    a.line(left-5, topY,    left,   topY);
    a.text(nf(maxVal,1,1),  left-6, topY+2);
    a.text(nf(minVal,1,1),  left-6, bottomY-2);
  }
  void drawHorizontalRule(GWinApplet a, float start, float end){
    int left = MARGIN*2-PADDING, right = a.width-MARGIN, y = a.height-MARGIN*3;
    a.stroke(palette[WHITE]);
    a.fill(palette[WHITE]);
    a.strokeWeight(1);
    a.textSize(10);
    a.textAlign(CENTER,TOP);
    a.line(left,  y, right, y);
    a.line(left,  y, left,  y+5);
    a.line(right, y, right, y+5);
    a.text(nf(start,1,2), left, y+10);
    a.text(nf(end,1,2),   right, y+10);
    a.text('>', right+6, y-5);
    a.text("Seconds", (left+right)/2, y+10);
  }
  void drawButtons(GWinApplet a){
    int left = MARGIN, right = a.width-MARGIN,
        top  = a.height-MARGIN*2, bottom = a.height-PADDING*2;
    a.stroke(0);
    a.strokeWeight(2);
    a.fill(palette[WHITE]);
    a.textSize(12);
    a.textAlign(CENTER,TOP);
    int x = left, y = top;
    int bWidth = 50, bHeight = 20;
    a.text("Grid", x+bWidth, y);
    y += 15;
    if(grid || overRectangleBtn(a, x,y, x+bWidth,y+bHeight)) a.fill(palette[BLUE],255);
    else a.fill(palette[BLUE],80);
    a.rect(x, y, bWidth, bHeight, 5,0,0,5);
    if(!grid || overRectangleBtn(a, (x+bWidth),  y, (x+bWidth)+bWidth, y+bHeight)) a.fill(palette[RED],255);
    else a.fill(palette[RED],80); 
    a.rect(x+bWidth, y, bWidth, bHeight, 0,5,5,0);
    a.fill(0);
    a.text("On",  x+(bWidth/2.0), y+2);
    a.text("Off", x+(bWidth*1.5), y+2);
    y = top;
    x += .20*(right-left);
    a.fill(palette[WHITE]);
    a.text("Scale", x+(bWidth/2.0), y);
    y += 15;
    if(!scale || overRectangleBtn(a, x,y, x+bWidth,y+bHeight)) a.fill(palette[BLUE],255);
    else a.fill(palette[BLUE],80);
    a.rect(x, y, bWidth, bHeight, 5,0,0,5);
    if(scale || overRectangleBtn(a, x+bWidth,y, x+bWidth*2,y+bHeight)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN],80);
    a.rect(x+bWidth, y, bWidth, bHeight, 0,5,5,0);
    a.fill(0);
    a.text("Full", x+(bWidth/2.0), y+2);
    a.text("Fit", x+(bWidth*1.5), y+2);
    y = top;
    x += .20*(right-left);
    a.fill(palette[WHITE]);
    bWidth /= 2;
    a.text("Channels", x+(bWidth*1.5), y);
    y += 15;
    if(activeChannels[LEFT_CHAN] ||overRectangleBtn(a, x,  y, x+bWidth, y+bHeight)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN], 80);
    a.rect(x, y, bWidth, bHeight,3);
    if(activeChannels[RIGHT_CHAN] || overRectangleBtn(a, x+bWidth,  y, (x+bWidth)+bWidth, y+bHeight)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN],80);
    a.rect(x+bWidth, y, bWidth, bHeight,3);
    if(activeChannels[MIX_CHAN] ||overRectangleBtn(a, x+bWidth*2,  y, x+bWidth*2 + bWidth, y+bHeight)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN],80);
    a.rect(x+bWidth*2, y, bWidth, bHeight,3);
    a.fill(0);
    a.text("L", x+(bWidth/2.0), y+2);
    a.text("R", x+(bWidth*1.5), y+2);
    a.text("M", x+(bWidth*2.5), y+2);
    y = top;
    x += .20*(right-left);
    a.fill(palette[WHITE]);
    a.text("Color", x+(bWidth*2.0), y);
    y += 15;
    for(int i=1; i<palette.length; i++){
      if(curColor == i || overRectangleBtn(a, x+(bWidth * (i-1)),  y, x+(bWidth * (i-1))+bWidth, y+bHeight)) a.fill(palette[i],255);
      else a.fill(palette[i],80);
      a.rect(x+(bWidth * (i-1)), y, bWidth, bHeight, 5);  
    }
    y = top;
    x += .20*(right-left);
    a.fill(palette[WHITE]);
    a.text("Time", x + bWidth*2.0 + 5, y);
    y += 15;
    if(overRectangleBtn(a, x,  y, x+bWidth, y+bHeight)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN],80);
    a.rect(x, y, bWidth, bHeight, 5);
    a.fill(palette[WHITE]);
    a.rect(x+bWidth+5, y, bWidth*2, bHeight);
    if(overRectangleBtn(a, x+(bWidth+5)+(bWidth*2+5),  y, x+(bWidth+5)+(bWidth*2+5)+bWidth, y+bHeight)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN],80);
    a.rect(x+(bWidth+5)+(bWidth*2+5), y, bWidth, bHeight,5);
    a.fill(0);
    a.text("-", x+(bWidth/2.0), y+2);
    a.text(nf(targetTime, 1, 1), x + bWidth*2 + 5 , y+2);
    a.text("+", x + bWidth*3 + 10 + (bWidth/2.0), y+2);
  }
  void wipe(GWinApplet a){
    a.fill(BACKGROUND);
    a.noStroke();
    if(grid){
      a.rect(0,0, MARGIN*2, a.height);
      a.rect(MARGIN*2, a.height-MARGIN*3-1, a.width-MARGIN*2, MARGIN*3);
    }
    else{
      a.rect(0,0, MARGIN, a.height);
      a.rect(MARGIN, a.height-MARGIN*3-1, a.width-MARGIN*2, MARGIN*3);
    }
  }
  void wipe(GWinApplet a, float x1, float y1, float x2, float y2){
    a.fill(BACKGROUND);
    a.noStroke();
    a.rect(x1, y1, x2-x1, y2-y1);  
  }
  void drawWave(GWinApplet a){
    if(wListener==null) return;
    wipe(a);
    drawButtons(a);
    float left = MARGIN*2, right  = a.width-MARGIN,
          top  = MARGIN,   bottom = top+(a.height-MARGIN*3-top)/2-PADDING, minV, maxV;
    if(!grid) left = MARGIN;
    float time   = 1;
    int nSamples = nBuffers * wListener.bufferSize();
    if(activeChannels[LEFT_CHAN]){
      float[] leftSamples = wListener.left();
      if(scale){
        minV = min(leftSamples); maxV = max(leftSamples);
       if(minV == maxV){ minV -= .01; maxV += .01; } 
      }
      else{ minV = -1; maxV =  1; }
      for(int i=0; i<leftSamples.length-1; i++){
        float x1 = map(i+counter, 0, nSamples-1, left, right);
        float y1 = map(leftSamples[i], minV, maxV, top, bottom);
        float x2 = map(i+1+counter, 0, nSamples-1, left, right);
        float y2 = map(leftSamples[i+1], minV, maxV, top, bottom);
        a.stroke(palette[curColor]);
        a.strokeWeight(1);
        a.line(x1,y1,x2,y2);
      }
      if(grid) drawVerticalRule(a, top, bottom, minV, maxV);
    }
    if(activeChannels[RIGHT_CHAN]){
      float[] rightSamples = wListener.right();
      top    = bottom + PADDING;
      bottom = a.height-MARGIN*3-PADDING;
      if(scale){
        minV = min(rightSamples); maxV = max(rightSamples);
       if(minV == maxV){ minV -= .01; maxV += .01; } 
      }
      else{ minV = -1; maxV =  1; }
      for(int i=0; i<rightSamples.length-1; i++){
        float x1 = map(i+counter, 0, nSamples-1, left, right);
        float y1 = map(rightSamples[i], minV, maxV, top, bottom);
        float x2 = map(i+1+counter, 0, nSamples-1, left, right);
        float y2 = map(rightSamples[i+1], minV, maxV, top, bottom);
        a.stroke(palette[curColor]);
        a.strokeWeight(1);
        a.line(x1,y1,x2,y2);
      }
      if(grid) drawVerticalRule(a, top, bottom, minV, maxV);
    }
    if(activeChannels[MIX_CHAN]){
      float[] mixSamples = wListener.mix();
      top = MARGIN;
      bottom = a.height-MARGIN*3-PADDING;
      if(scale){
        minV = min(mixSamples); maxV = max(mixSamples);
       if(minV == maxV){ minV -= .01; maxV += .01; } 
      }
      else{ minV = -1; maxV =  1; }
      for(int i=0; i<mixSamples.length-1; i++){
        float x1 = map(i+counter, 0, nSamples-1, left, right);
        float y1 = map(mixSamples[i], minV, maxV, top, bottom);
        float x2 = map(i+1+counter, 0, nSamples-1, left, right);
        float y2 = map(mixSamples[i+1], minV, maxV, top, bottom);
        a.stroke(palette[curColor]);
        a.strokeWeight(1);
        a.line(x1,y1,x2,y2);
      }
      if(grid) drawVerticalRule(a, top, bottom, minV, maxV);
    }
    /*-counter keeps track of how many samples have been painted to the screen since the last screen refresh
      -nSamples is the total number of samples to be drawn to the screen before clearing
      -counter is reset to 0 when its next value would be greater than nSamples, and the screen refreshed*/
    counter = (counter + wListener.bufferSize() <= nSamples - wListener.bufferSize()) ? counter + wListener.bufferSize() : 0;
    //-t calculates the amount of time it takes to draw all the samples to the screen, given the current frame rate
    float t = nSamples/(a.frameRate*bufferSize);
    if(grid) drawHorizontalRule(a, 0, t);
    if(counter==0){
      //wipe the screen
      window.setBackground(BACKGROUND);
      /*if the number of buffers took a longer or shorter amount of time to visualize than the time selected by the user,
         adjust the number of buffers up or down accordingly*/ 
      if     (t > (targetTime+0.01) && nBuffers > 1)    nBuffers--;
      else if(t < (targetTime-0.01) && nBuffers < 1000) nBuffers++;
    }
  }
  void mouseHandle(GWinApplet a, GWinData d, MouseEvent e){
    if(e.getAction() == MouseEvent.CLICK){
      int left = MARGIN, right = a.width-MARGIN,
          top  = a.height-MARGIN*2, bottom = a.height-PADDING*2;
      int x = left, y = top, bWidth = 50, bHeight = 20;
      y += 15;
      if(overRectangleBtn(a, x,y, x+bWidth,y+bHeight)){ // graph on
        grid = true; return;
      }
      if(overRectangleBtn(a, (x+bWidth),  y, (x+bWidth)+bWidth, y+bHeight)){ //graph off
        grid = false; return;  
      }
      x += .20*(right-left);
      if(overRectangleBtn(a, x,y, x+bWidth,y+bHeight)){ //scale on
        scale = false; return;
      }
      if(overRectangleBtn(a, (x+bWidth),  y, (x+bWidth)+bWidth, y+bHeight)){ //scale off
        scale = true; return;
      }
      x += .20*(right-left);
      bWidth /= 2;
      if(overRectangleBtn(a, x,  y, x+bWidth, y+bHeight)){ //left channel toggle
        if(activeChannels[LEFT_CHAN]) activeChannels[LEFT_CHAN] = false;
        else if(!activeChannels[LEFT_CHAN]){
          activeChannels[LEFT_CHAN] = true;
          activeChannels[MIX_CHAN] = false;
        }
        return;  
      }
      int x2 = x+bWidth;
      if(overRectangleBtn(a, x2,  y, x2+bWidth, y+bHeight)){ //right channel toggle
        if(activeChannels[RIGHT_CHAN]) activeChannels[RIGHT_CHAN] = false;
        else if(!activeChannels[RIGHT_CHAN]){
          activeChannels[RIGHT_CHAN] = true;
          activeChannels[MIX_CHAN] = false;
        }
        return;
      }
      x2 += bWidth;
      if(overRectangleBtn(a, x2,  y, x2+bWidth, y+bHeight)){ //mix channel toggle
        if(activeChannels[MIX_CHAN]) activeChannels[MIX_CHAN] = false;
        else if(!activeChannels[MIX_CHAN]){
          activeChannels[LEFT_CHAN]  = false;
          activeChannels[RIGHT_CHAN] = false;
          activeChannels[MIX_CHAN]   = true;
        }
        return;
      }
      x += .20*(right-left);
      for(int i=1; i<palette.length; i++){
        if(overRectangleBtn(a, x+(bWidth * (i-1)),  y, x+(bWidth * (i-1))+bWidth, y+bHeight)){ //color buttons
          curColor = i; return;
        }
      }
      x += .20*(right-left);
      if(overRectangleBtn(a, x,  y, x+bWidth, y+bHeight)){ //decrease target time
        window.setBackground(BACKGROUND);
        counter = 0;
        if(targetTime >= 0.25){
          targetTime /= 2.0;
          nBuffers = (nBuffers/2) > 0 ? nBuffers/2 : 1;
        }
        else{
          targetTime = 0;
          nBuffers   = 1;
        }
        return;  
      }
      if(overRectangleBtn(a, x+(bWidth+5)+(bWidth*2+5),  y, x+(bWidth+5)+(bWidth*2+5)+bWidth, y+bHeight)){ //increase target time
        window.setBackground(BACKGROUND);
        counter = 0;
        if(targetTime > 30 && targetTime < 60){
          targetTime = 60;
          nBuffers  *= 2;
        }
        else if(targetTime == 0){
          targetTime = 0.25;
          nBuffers   = 2;
        }
        else{
          targetTime *= 2;
          nBuffers   *= 2;
        }
        return;
      }
    }
  }
  void keyHandle(GWinApplet a, GWinData d, KeyEvent e){
    if(e.getAction() == KeyEvent.RELEASE && a.keyCode == 'C') {
      curColor = (curColor+1) % palette.length;
    }
    else if(e.getAction() == KeyEvent.RELEASE && a.keyCode == 'L') {
      activeChannels[LEFT_CHAN] = activeChannels[LEFT_CHAN] ? false : true;
      activeChannels[MIX_CHAN] = false;
      window.setBackground(80);
    }
    else if(e.getAction() == KeyEvent.RELEASE && a.keyCode == 'R') {
      activeChannels[RIGHT_CHAN] = activeChannels[RIGHT_CHAN] ? false : true;
      activeChannels[MIX_CHAN] = false;
      window.setBackground(80);
    }
    else if(e.getAction() == KeyEvent.RELEASE && a.keyCode == 'M') {
      activeChannels[MIX_CHAN] = activeChannels[MIX_CHAN] ? false : true;
      activeChannels[LEFT_CHAN] = false;
      activeChannels[RIGHT_CHAN] = false;
      window.setBackground(80);
    }
  }
  void closeHandle(GWindow a){
    wListener.stopListening();
  }
}
