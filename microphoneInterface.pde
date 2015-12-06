public class microphoneInterface extends visualization{
  private micListener mListener;
  microphoneInterface(PApplet a, micListener mL){
    super(a, "Microphone", 300, 210, 250, 320, false);
    mListener = mL;
    //window.papplet.shapeMode(CENTER);
    window.papplet.textAlign(CENTER,CENTER);
    window.papplet.textFont(font[MANAGER_FONT]);
  }
  void drawMicrophoneBtn(GWinApplet a, int x, int y, int bWidth, int bHeight){
    a.textSize(25);
    a.fill(palette[WHITE]);
    if(mListener!=null && mListener.micDetected())
      a.text("Microphone", a.width/2, MARGIN);
    else{
      a.text("No Mic Detected", a.width/2, MARGIN);
      if(mListener!=null) mListener.off();
    }
    if(overRectangleBtn(a, x, y, x+bWidth, y+bHeight)
       || (!mListener.isMuted())) a.fill(palette[BLUE],255);
    else a.fill(palette[BLUE],80);
    a.rect(x, y, bWidth, bHeight, 10, 0, 0, 10);
    x = a.width/2;
    if(overRectangleBtn(a, x, y, x+bWidth, y+bHeight)
       || (mListener.isMuted())) a.fill(palette[RED],255);
    else a.fill(palette[RED],80);
    a.rect(x, y, bWidth, bHeight, 0, 10, 10, 0);
    a.textSize(15);
    a.fill(0);
    x = MARGIN*2;
    a.text("ON", x+(bWidth/2), y+(bHeight/2)+1);
    x = a.width/2;
    a.text("OFF", x+(bWidth/2), y+(bHeight/2)+1);
  }
  void drawSampleRateBtn(GWinApplet a, int x, int y, int bWidth, int bHeight){
    a.textSize(20);
    a.fill(palette[WHITE]);
    a.text("Sample Rate", a.width/2, y);
    y += MARGIN;
    if(overRectangleBtn(a, x, y, x+bWidth, y+bHeight)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN],200);
    a.rect(x,y,bWidth,bHeight, 10, 0, 0, 10);
    x = a.width-MARGIN-bWidth;
    if(overRectangleBtn(a, x, y, x+bWidth, y+bHeight)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN],200);
    a.rect(x,y,bWidth,bHeight,0,10,10,0);
    x = MARGIN+bWidth+PADDING;
    int bWidth2 = (a.width-MARGIN-bWidth-PADDING)-(MARGIN+bWidth+PADDING);
    a.fill(palette[WHITE],180);
    a.rect(x,y,bWidth2,bHeight);
    x = MARGIN+(bWidth/2);
    y += (bHeight/2);
    a.textSize(15);
    a.fill(0);
    a.text("-", x, y+1);
    x = (a.width-MARGIN-bWidth/2);
    a.text("+", x, y+1);
    x = a.width/2;
    a.fill(0);
    if(mListener!=null) a.text(str(mListener.sampleRate()/1000.0)+" kHz", x, y+1);
  }
  void drawBufferSizeBtn(GWinApplet a, int x, int y, int bWidth, int bHeight){
    a.textSize(20);
    a.fill(palette[WHITE]);
    a.text("Buffer Size", a.width/2, y);
    y += MARGIN;
    if(overRectangleBtn(a, x, y, x+bWidth, y+bHeight)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN],200);
    a.rect(x,y,bWidth,bHeight, 10, 0, 0, 10);
    x = a.width-MARGIN-bWidth;
    if(overRectangleBtn(a, x, y, x+bWidth, y+bHeight)) a.fill(palette[TAN],255);
    else a.fill(palette[TAN],200);
    a.rect(x,y,bWidth,bHeight,0,10,10,0);
    x = MARGIN+bWidth+PADDING;
    int bWidth2 = (a.width-MARGIN-bWidth-PADDING)-(MARGIN+bWidth+PADDING);
    a.fill(palette[WHITE],180);
    a.rect(x,y,bWidth2,bHeight);
    x = MARGIN+(bWidth/2);
    y += (bHeight/2);
    a.textSize(15);
    a.fill(0);
    a.text("-", x, y+1);
    x = (a.width-MARGIN-bWidth/2);
    a.text("+", x, y+1);
    x = a.width/2;
    a.fill(0);
    if(mListener!=null) a.text(str(mListener.bufferSize()), x, y+1);
  }
  void drawMonitoringBtn(GWinApplet a, int x, int y, int bWidth, int bHeight){
    a.textSize(20);
    a.fill(palette[WHITE]);
    a.text("Monitoring", a.width/2, y);
    y += MARGIN;
    if(overRectangleBtn(a, x, y, x+bWidth, y+bHeight) || mListener.isMonitoring())
      a.fill(palette[BLUE], 255);
    else a.fill(palette[BLUE], 80);
    a.rect(x, y, bWidth, bHeight, 10, 0, 0, 10);
    x = a.width/2;
    if(overRectangleBtn(a, x, y, x+bWidth, y+bHeight) || mListener.isMonitoring())
      a.fill(palette[RED], 255);
    else a.fill(palette[RED], 80);
    a.rect(x, y, bWidth, bHeight, 0, 10, 10, 0);
    a.textSize(15);
    a.fill(0);
    x = MARGIN*2;
    a.text("ON", x+(bWidth/2), y+(bHeight/2)+1);
    x = a.width/2;
    a.text("OFF", x+(bWidth/2), y+(bHeight/2)+1);
  }
  void drawHandle(GWinApplet a, GWinData d){
    //int x = MARGIN*2, y = MARGIN*2, bWidth = int(((a.width-MARGIN*4)/2)), bHeight = 25;
    a.strokeWeight(3);
    a.stroke(0);
    drawMicrophoneBtn(a, MARGIN*2, MARGIN*2, int(((a.width-MARGIN*4)/2)), 25);
    drawSampleRateBtn(a, MARGIN,   MARGIN*4, int(((a.width-MARGIN*4)/4)), 25);
    drawBufferSizeBtn(a, MARGIN,   MARGIN*7, int(((a.width-MARGIN*4)/4)), 25);
    drawMonitoringBtn(a, MARGIN*2, MARGIN*10,int(((a.width-MARGIN*4)/2)), 25);
  }
  void mouseHandle(GWinApplet a, GWinData d, MouseEvent e){
    if(e.getAction() == MouseEvent.CLICK){
      globalActiveSource = MICROPHONE;
      //ON button
      int x = MARGIN*2, y = MARGIN*2, bWidth = int(((a.width-MARGIN*4)/2)), bHeight = 25;
      if(overRectangleBtn(a, x, y, x+bWidth, y+bHeight)){
        if(mListener!=null) mListener.on();  
        return;
      }
      //OFF button
      x = a.width/2;
      if(overRectangleBtn(a, x, y, x+bWidth, y+bHeight)){
        if(mListener!=null) mListener.off();
        return;
      }
      //Sample Rate DOWN
      x      = MARGIN;
      y      = MARGIN*5;
      bWidth = int(((a.width-MARGIN*4)/4));
      if(overRectangleBtn(a, x, y, x+bWidth, y+bHeight)){
        if(mListener!=null) mListener.changeSampleRate(mListener.sampleRate() - 1000);
        return;
      }
      //Sample Rate UP
      x = a.width-MARGIN-bWidth;
      if(overRectangleBtn(a, x, y, x+bWidth, y+bHeight)){
        if(mListener!=null) mListener.changeSampleRate(mListener.sampleRate() + 1000);
        return;
      }
      //Buffer Size DOWN
      x = MARGIN;
      y = MARGIN*8;
      if(overRectangleBtn(a, x, y, x+bWidth, y+bHeight)){
        if(mListener!=null) mListener.changeBufferSize(mListener.bufferSize() / 2);
        return;
      }
      //Buffer Size UP
      x = a.width-MARGIN-bWidth;
      if(overRectangleBtn(a, x, y, x+bWidth, y+bHeight)){
        if(mListener!=null) mListener.changeBufferSize(mListener.bufferSize() * 2);
        return;
      }
    }
  }
  void keyHandle(GWinApplet a, GWinData d, KeyEvent e){
    globalActiveSource = MICROPHONE;
    if(e.getAction() == KeyEvent.RELEASE && a.keyCode == ' ' && mListener!=null){
      if(mListener!=null)mListener.toggleMute();
    }
  }
  void closeHandle(GWindow w){
    //mListener.stopListening();
    globalActiveSource = NO_SOURCE;
  }
}
