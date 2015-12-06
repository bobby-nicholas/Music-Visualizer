public class beatDetection extends visualization{
  /*
  Uses a physics engine to represent beat spectrum 
  */
  private beatListener     bListener;
  private FWorld           world;
  private ArrayList<FBody> freqBodies;
  private int[]            bodyBrightness;
  private int              repulsiveForce, attractiveForce;
  private final int        S_DIAM = 10, L_DIAM = 100, PLANET = 0;
  beatDetection(PApplet a, beatListener bL){
    super(a, "Beat Detection", displayWidth/3, displayHeight/3, 400, 400, true);
    bListener = bL;
    Fisica.init(window.papplet);
    Fisica.setScale(1);
    world = new FWorld();
    world.setGravity(0, 0);
    freqBodies = new ArrayList<FBody>();
    repulsiveForce  = 4000;
    attractiveForce = 500;
  }
  void drawButtons(GWinApplet a){
    float x = MARGIN, y = a.height - MARGIN*2, bWidth, bHeight;
    a.strokeWeight(2);
    a.stroke(0);
    a.fill(palette[WHITE]);
    a.textSize(12);
    a.textFont(font[MANAGER_FONT]);
    a.textAlign(CENTER,CENTER);
    String str = "Attractive Force";
    bWidth  = str.length() * 10;
    bHeight = 20;
    a.text(str, x + bWidth/2.0, y);
    y += PADDING * 2;
    if(overRectangleBtn(a, x, y, x + (bWidth/4.0), y + bHeight)) // minus btn 
          a.fill(palette[TAN],200);
    else  a.fill(palette[TAN], 80);
    a.rect(x, y, bWidth/4.0, bHeight, 5,0,0,5);
    a.fill(0);
    a.text("-", x + (bWidth/8.0), y + (bHeight/2.0));
    a.fill(palette[WHITE]);
    a.rect(x + (bWidth/4.0), y, bWidth/2.0, bHeight);
    if(overRectangleBtn(a, x + bWidth * 0.75, y, x + bWidth, y + bHeight)) // plus btn 
          a.fill(palette[TAN],200);
    else  a.fill(palette[TAN], 80);
    a.rect(x + bWidth * 0.75, y, bWidth/4.0, bHeight, 0,5,5,0);
    a.fill(0);
    a.text("+", x + bWidth - (bWidth/8.0), y + (bHeight/2.0));
    a.text(attractiveForce / 10, x + (bWidth/2.0), y + bHeight/2.0);
    
    x  = x + bWidth + PADDING * 2;
    y -= PADDING * 2;
    str = "Repulsive Force";
    a.fill(palette[WHITE]);
    a.text(str, x + bWidth/2.0, y);
    y += PADDING * 2;
    if(overRectangleBtn(a, x, y, x + (bWidth/4.0), y + bHeight)) // minus btn 
          a.fill(palette[TAN],200);
    else  a.fill(palette[TAN], 80);
    a.rect(x, y, bWidth/4.0, bHeight, 5,0,0,5);
    a.fill(0);
    a.text("-", x + (bWidth/8.0), y + (bHeight/2.0));
    a.fill(palette[WHITE]);
    a.rect(x + (bWidth/4.0), y, bWidth/2.0, bHeight);
    if(overRectangleBtn(a, x + bWidth * 0.75, y, x + bWidth, y + bHeight)) // plus btn 
          a.fill(palette[TAN],200);
    else  a.fill(palette[TAN], 80);
    a.rect(x + bWidth * 0.75, y, bWidth/4.0, bHeight, 0,5,5,0);
    a.fill(0);
    a.text("+", x + bWidth - (bWidth/8.0), y + (bHeight/2.0));
    a.text(repulsiveForce / 10, x + (bWidth/2.0), y + bHeight/2.0);
  }
  void drawHandle(GWinApplet a, GWinData d){
    if(bListener==null || world==null) return;
    bListener.listen();
    world.draw(window.papplet);
    world.step();
    drawButtons(a);
    boolean[] beatFreqs = bListener.listenForBeat();
    if(beatFreqs == null || freqBodies == null) return;
    if(freqBodies.size() < beatFreqs.length) initializeBodies(a, beatFreqs);
    else{
      for(int i=0; i<freqBodies.size(); i++){
        if(beatFreqs[i]){
          bodyBrightness[i] = 255;
          if(i == PLANET)                 freqBodies.get(PLANET).setFillColor(color(palette[TEAL], bodyBrightness[i]));
          else if(i < beatFreqs.length/2) freqBodies.get(i).setFillColor(color(palette[TEAL], bodyBrightness[i]));
          else                            freqBodies.get(i).setFillColor(color(palette[TEAL], bodyBrightness[i]));
          float xDist = freqBodies.get(i).getX() - freqBodies.get(PLANET).getX(),
                yDist = freqBodies.get(i).getY() - freqBodies.get(PLANET).getY();
          PVector vector = new PVector(xDist, yDist);
          vector.normalize();
          freqBodies.get(i).addImpulse(vector.x * repulsiveForce, vector.y * repulsiveForce); 
        }
        else{
          bodyBrightness[i] = bodyBrightness[i] > 50 ? bodyBrightness[i] - 2 : 50;
          if(i == PLANET)                 freqBodies.get(PLANET).setFillColor(color(palette[BLUE], bodyBrightness[i]));
          else if(i < beatFreqs.length/2) freqBodies.get(i).setFillColor(color(palette[TAN], bodyBrightness[i]));
          else                            freqBodies.get(i).setFillColor(color(palette[RED], bodyBrightness[i]));
          float xDist = freqBodies.get(PLANET).getX() - freqBodies.get(i).getX(),
                yDist = freqBodies.get(PLANET).getY() - freqBodies.get(i).getY();
          PVector vector = new PVector(xDist, yDist);
          vector.normalize();                       
          freqBodies.get(i).addImpulse(vector.x * attractiveForce, vector.y * attractiveForce);
        }
      }
    }  
  }
  void initializeBodies(GWinApplet a, boolean[] beatFreqs){
    println("bodies size: " + freqBodies.size() + " Beat Freq Size: " + beatFreqs.length);
    bodyBrightness = new int[beatFreqs.length];
    for(int i=0; i<bodyBrightness.length; i++) bodyBrightness[i] = 80;
    world.clear();
    freqBodies.clear();
    FCircle onSet = new FCircle(L_DIAM);
    onSet.setPosition(a.width/2, a.height/2);
    onSet.setRestitution(0.5);
    onSet.setFriction(0.5);
    onSet.setFillColor(color(palette[RED], bodyBrightness[0]));
    onSet.setStatic(true);
    world.add(onSet);
    freqBodies.add(onSet);
    float y;
    for(int i = 1; i < beatFreqs.length/2; i++){
      y = map(i, 1, beatFreqs.length/2-1, MARGIN, a.height-MARGIN);
      FCircle freq = new FCircle(S_DIAM);
      freq.setPosition(MARGIN, y);
      freq.setRestitution(0.5);
      freq.setFriction(0.5);
      freq.setFillColor(color(palette[BLUE], bodyBrightness[i]));
      world.add(freq);
      freqBodies.add(freq);
    }
    for(int i = beatFreqs.length/2; i < beatFreqs.length; i++){
      y = map(i, beatFreqs.length/2, beatFreqs.length-1, MARGIN, a.height-MARGIN);
      FCircle freq = new FCircle(S_DIAM);
      freq.setPosition(a.width-MARGIN, y);
      freq.setRestitution(0.5);
      freq.setFriction(0.5);
      freq.setFillColor(color(palette[TAN], bodyBrightness[i]));
      world.add(freq);
      freqBodies.add(freq);
    }
  }
  void mouseHandle(GWinApplet a, GWinData d, MouseEvent e){
    if(e.getAction() == MouseEvent.CLICK){
      float bWidth  = "Attractive Force".length() * 10,
            bHeight = 20,
            x       = MARGIN,
            y       = a.height - MARGIN*2 + (PADDING * 2);
      if(overRectangleBtn(a, x, y, x + (bWidth/4.0), y + bHeight)){ // attract minus btn
        attractiveForce = attractiveForce > 50 ? attractiveForce - 50 : 50;
      }
      if(overRectangleBtn(a, x + bWidth * 0.75, y, x + bWidth, y + bHeight)){ // attract plus btn
        attractiveForce = attractiveForce < 2000 ? attractiveForce + 50 : 2000;
      }
      x += bWidth + PADDING * 2;
      if(overRectangleBtn(a, x, y, x + (bWidth/4.0), y + bHeight)){ // repulse minus btn
        repulsiveForce = repulsiveForce > 100 ? repulsiveForce - 100 : 100;
      }
      if(overRectangleBtn(a, x + bWidth * 0.75, y, x + bWidth, y + bHeight)){ // repulse plus btn
        repulsiveForce = attractiveForce < 10000 ? repulsiveForce + 100 : 10000;
      }
    }
  }
  void keyHandle(GWinApplet a, GWinData d, KeyEvent e){  }
  void closeHandle(GWindow w){}
}
