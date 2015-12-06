public class mediaPlayer extends visualization{
  private trackListener tListener;
  mediaPlayer(PApplet a, trackListener l){
    super(a, "Media Player", displayWidth/3, displayHeight/3, 600, 300, false);
    tListener = l;
    window.papplet.ellipseMode(CENTER);
  }
  void drawHandle(GWinApplet a, GWinData d){
    if(tListener!=null) tListener.listen();
    drawPlayBtn(a, 60, 190, 100);
    drawLoadTrackBtn(a, 30, 270, 40);
    drawStopBtn(a, 85, 270, 40);
    drawLoopBtn(a, 140, 270, 40);
    drawProgressLine(a, 130, 190);
    drawText(a);
    //drawInstructionsBtn(a);
  }
  void drawPlayBtn(GWinApplet a, int centerX, int centerY, int diam){
    a.strokeWeight(2);
    a.stroke(0);
    if(overCircularBtn(a, centerX, centerY, diam)) a.fill(palette[TEAL]);
    else a.fill(palette[TAN]);
    a.ellipse(centerX, centerY, diam, diam);
    if(overCircularBtn(a, centerX, centerY, diam)) a.fill(palette[TAN]);
    else a.fill(palette[WHITE]);
    //Play button
    if(!tListener.isPlaying()) a.triangle(centerX-20, centerY-30, centerX-20, centerY+30, centerX+35, centerY);   
    else{//Pause button
      a.rect(centerX-22, centerY-30, 15, 60);
      a.rect(centerX+8, centerY-30, 15, 60);
    }
  }
  void drawLoadTrackBtn(GWinApplet a, int centerX, int centerY, int diam){
    a.strokeWeight(2);
    a.stroke(0);
    if(overCircularBtn(a, centerX, centerY, diam)) a.fill(palette[TEAL]);
    else a.fill(palette[TAN]);
    a.ellipse(centerX, centerY, diam, diam);
    if(overCircularBtn(a, centerX, centerY, diam)) a.fill(palette[TAN]);
    else a.fill(palette[WHITE]);
    a.rect(centerX-10,centerY+4,20,8);
    a.triangle(centerX-10, centerY, centerX, centerY-16, centerX+10, centerY); 
  }
  void drawStopBtn(GWinApplet a, int centerX, int centerY, int diam){
    a.strokeWeight(2);
    a.stroke(0);
    if(overCircularBtn(a, centerX, centerY, diam)) a.fill(palette[TEAL]);
    else a.fill(palette[TAN]);
    a.ellipse(centerX, centerY, diam, diam);
    if(overCircularBtn(a, centerX, centerY, diam)) a.fill(palette[TAN]);
    else a.fill(palette[WHITE]);
    a.rect(centerX-10,centerY-10,20,20);
  }
  void drawLoopBtn(GWinApplet a, int centerX, int centerY, int diam){
    a.strokeWeight(2);
    a.stroke(0);
    if(tListener.isLooping()) a.fill(palette[RED]);
    else if(overCircularBtn(a, centerX, centerY, diam)) a.fill(palette[TEAL]);
    else a.fill(palette[TAN]);
    a.ellipse(centerX, centerY, diam, diam);
    if(overCircularBtn(a, centerX, centerY, diam)) a.fill(palette[TAN]);
    else a.fill(palette[WHITE]);
    a.arc(centerX,centerY,diam/2,diam/2,radians(0),radians(360));
    a.line(centerX-diam/4-1, centerY-1, centerX-diam/4-4, centerY+3);
    a.line(centerX-diam/4+2, centerY-1, centerX-diam/4+5, centerY+3);
    a.line(centerX+diam/4-2, centerY+1, centerX+diam/4-5, centerY-3);
    a.line(centerX+diam/4+1, centerY+1, centerX+diam/4+4, centerY-3);
  }
  void drawProgressLine(GWinApplet a, int x, int y){
    a.strokeWeight(3);
    a.stroke(palette[TAN]);
    a.line(x, y, a.width-MARGIN, y);
    if(tListener!=null){
      a.stroke(palette[TEAL]);
      a.strokeWeight(12);
      float locX = map(tListener.pComplete(), 0, 1, x, a.width-MARGIN);
      a.line(x, y, locX, y);
    }
  }
  void drawText(GWinApplet a){
    if(tListener!=null){
      a.textFont(font[PLAYER_FONT],35);
      a.textAlign(LEFT,TOP);
      a.fill(255);
      a.text(tListener.trackTitleStr(), PADDING, MARGIN, a.width, 50);  //track title
      a.textSize(18);
      a.text(tListener.trackInfoStr(), PADDING, 70, a.width-PADDING*2, 80);//track information
      a.textFont(font[DATA_FONT],14);
      a.text(tListener.elapsedTimeStr(), 130, 200, 80, 30);        //elapsed time
      a.textAlign(RIGHT,TOP);
      a.text(tListener.trackLengthStr(), a.width-90, 200, 70, 30); //track time
    }    
  }
  void mouseHandle(GWinApplet a, GWinData d, MouseEvent e){
    if(e.getAction() == MouseEvent.CLICK){
      globalActiveSource = TRACK_PLAYER;
      if(tListener==null) return;
      if(overCircularBtn(a, 60, 190, 100)){ //over play button
        if(!tListener.isPlaying()) tListener.playTrack();
        else tListener.pauseTrack();
      }
      else if(overCircularBtn(a, 30, 270, 40))  tListener.loadTrack(); //over load button 
      else if(overCircularBtn(a, 85, 270, 40))  tListener.stopTrack(); //over stop button
      else if(overCircularBtn(a, 140, 270, 40)) tListener.loopTrack(); //over loop button
      else if(overRectangleBtn(a, 130-(3), 190-(3), a.width-MARGIN+(3), 190+(3))){    //over progress bar
        float per = map(a.mouseX, 130, a.width-MARGIN, 0, 1);
        tListener.cueTrack(per);  
      }
      /*You can access a protype instructions popup if you uncomment the next line
        make sure to uncomment the drawInstructionsBtn() in the main draw handle.
      */
      //else if(overInstructionsBtn(a)) { instructions in = new instructions(app, this, globalMouseX(), globalMouseY()); }
    }
  }
  void keyHandle(GWinApplet a, GWinData d, KeyEvent e){
    if(e.getAction() == KeyEvent.RELEASE && a.keyCode == ' '){
      globalActiveSource = TRACK_PLAYER;
      if(tListener!=null){
        if(!tListener.isPlaying()) tListener.playTrack();
        else tListener.pauseTrack();  
      }
    }
  }
  void closeHandle(GWindow a){
    if(tListener!=null && tListener.isPlaying()) tListener.stopTrack();
    globalActiveSource = NO_SOURCE;
  } 
}
