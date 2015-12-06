public class synesthesia extends visualization{
  private waveListener  wListener;
  private pitchListener pListener;
  private beatListener  bListener;
  private rainDrop[]    drops;
  private ArrayList     splashes;
  private color         bg;
  private float         gravity;
  private boolean       frameToggle, lightning;
  private int           curForm = 0, curMap = 0;
  private String[]      colorMaps = {"CASTEL", "JAMESON", "HELMHOLTZ", "BOBBY" };
  private final int     RAIN = 0, MOIRE = 1, SPINNER = 2, N_FORMS = 3, N_MAPS = 4;
  synesthesia(PApplet a, waveListener wL, pitchListener pL, beatListener bL){
    super(a, "Synesthesia Visualizer", displayWidth/4, displayHeight/4, 400, 400, true);
    wListener = wL;
    pListener = pL;
    bListener = bL;
    gravity   = 10;
    bg        = color(0);
    drops     = new rainDrop[400];
    splashes  = new ArrayList();
    lightning = true;
    for(int i=0; i<drops.length; i++) drops[i] = new rainDrop();
    window.setBackground(0);
  } 
  void drawHandle(GWinApplet a, GWinData d){
    if(wListener==null || pListener==null || bListener==null){
      return; 
    }
    wListener.listen();
    pListener.listen();
    bListener.listen();
    switch(curForm){
      case RAIN:    drawRain(a);    break;
      case MOIRE:   drawMoire(a);   break;
      case SPINNER: drawSpinner(a); break;
    }
  }
  void drawSpinner(GWinApplet a){
    window.setAutoClear(true);
    a.translate(a.width/2, a.height/2);
    for(float i=0; i<360; i+=0.5){
      a.pushMatrix();
      a.rotate(radians(i));
      a.translate(0, min(a.width, a.height)/3);
      a.rotate(radians(i * 3));
      a.scale(map(sin(radians(i * 6)), -1, 1, 0.5, 1),
              map(sin(radians(i * 3)), -1, 1, 0.5, 1));
      a.noFill();
      a.stroke(pListener.pitchClassToColor(colorMaps[curMap]));
      a.ellipse(0, 0, 5 + (wListener.level('L') * 240), 5 +( wListener.level('R') * 160));
      a.popMatrix();  
    }
  }
  void drawMoire(GWinApplet a){
    window.setAutoClear(true);
    a.noStroke();
    a.pushMatrix();
    a.translate(a.width/2, a.height/2);
    a.fill(pListener.pitchClassToColor(colorMaps[curMap]));
    for(int i=0; i<100; i++){
      float t0 = map(i, 0, 99, 0, TWO_PI);
      float t1 = t0 + (TWO_PI/200);
      a.arc(0, 0, a.width*100, a.height*100, t0, t1);
    } 
    a.popMatrix();
    a.pushMatrix();
    a.translate(a.width * wListener.level('M'), a.height * wListener.level('M'));
    a.rotate(TWO_PI * a.frameCount/800);
    a.translate(a.width/2, a.width/2);
    a.fill(pListener.pitchClassToColor(colorMaps[curMap]));
    for(int i=0; i<100; i++){
      float t0 = map(i, 0, 99, 0, TWO_PI);
      float t1 = t0 + (TWO_PI/200);
      a.arc(0, 0, a.width*100, a.height*100, t0, t1);
    }  
    a.popMatrix();
  }
  void drawRain(GWinApplet a){
    if(drops==null || splashes==null) return;
    window.setAutoClear(false);
    a.frameRate(30);
    //Get every other frame for drawing of splashes
    frameToggle = frameToggle ? false : true;
    //if beat detected, make a flash of lightning
    if(lightning && bListener.detectOnset()){
      bg += random(50, 100);
      if(bg>255) bg = 255;
    }
    else bg = (bg-80) > 0 ? bg-80 : 0;
    //streaking effect
    a.fill(bg, 90);
    a.noStroke();
    a.rect(0, 0, a.width, a.height);
    for(int i=0; i<drops.length; i++){
      //Set or reset the rain drop to the top of the screen
      if(!drops[i].initialized){ 
        drops[i] = new rainDrop();
        drops[i].X(random(1, a.width + 200));
        drops[i].Y(random(-100, 0));
        drops[i].endPoint(random(a.height - (a.height/3.5), a.height));
        //drops in the "foreground" fall faster than those in the background
        drops[i].wind(1 + map(drops[i].endY, (a.height - (a.height/3.5)), a.height, 0, 2),
                gravity + map(drops[i].endY, (a.height - (a.height/3.5)), a.height, 0, 15));
        drops[i].dropColor = pListener.pitchClassToColor(colorMaps[curMap]);
        drops[i].initialized = true;
      }
      //Draw the falling rain drops
      else{
        a.stroke(drops[i].dropColor);
        a.line(drops[i].x, drops[i].y, drops[i].tailX, drops[i].tailY);
        drops[i].X(drops[i].x - drops[i].windX);
        drops[i].Y(drops[i].y + drops[i].windY);
        //Has the rain drop hit the ground?
        if(drops[i].y > drops[i].endY){
          //reset the rain drop and create a splash in its landing place
          drops[i].initialized = false;  
          splashes.add(new splash(drops[i].x, drops[i].y, 1, 0.2, drops[i].dropColor));
        }
      }
    }
    if(frameToggle){
      int len = splashes.size();
      for(int i=0; i<len; i++){
        splash s = (splash)splashes.remove(0);
        a.noFill();
        a.stroke(s.splashColor);
        a.ellipse(s.x, s.y, s.sWidth, s.sHeight);
        if(s.sWidth < 60){
          splashes.add(new splash(s.x, s.y, s.sWidth * 2, s.sHeight * 2, s.splashColor));
        }
      }
    }
  }
  void mouseHandle(GWinApplet a, GWinData d, MouseEvent e){
    if(e.getAction() == MouseEvent.CLICK){
    
    }
  }
  void keyHandle(GWinApplet a, GWinData d, KeyEvent e){
    if(e.getAction() == KeyEvent.RELEASE){
      //Toggle lightning with L key
      if(a.keyCode == 'L'){ lightning = lightning ? false : true; return; }
      
      //Cycle animations with LEFT and RIGHT arrow keys
      if(a.keyCode == LEFT){  curForm = curForm > 0 ? curForm-1 : N_FORMS-1; return; }
      if(a.keyCode == RIGHT){ curForm = curForm+1 < N_FORMS ? curForm+1 : 0; return; }
      
      //Cycle through color mappings with C key
      if(a.keyCode == 'C'){ curMap = (curMap + 1) % N_MAPS; return; }
    }
  }
  void closeHandle(GWindow a){} 
}

public class rainDrop{
  boolean initialized = false;
  color   dropColor;
  float   x, y, tailX, tailY, endY, windX, windY;
  void X(float p){
    x     = p;
    tailX = x + windX;
  }
  void Y(float p){
    y     = p;
    tailY = y - windY;  
  }
  void wind(float wX, float wY){
    windX = wX;
    windY = wY;  
  }
  void endPoint(float p){
    endY = p;  
  }
}
public class splash{
  float x, y, sWidth, sHeight;
  color splashColor;
  splash(float x, float y, float w, float h, color c){
    this.x      = x;
    this.y      = y;
    sWidth      = w;
    sHeight     = h;
    splashColor = c;
  }
}
