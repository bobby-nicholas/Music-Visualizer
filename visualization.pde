public abstract class visualization{
  protected PApplet    app;
  protected GWindow    window;
  protected String     windowTitle;
  protected color[]    palette;
  protected int        curColor;
  protected final int  LEFT_CHAN = 0, RIGHT_CHAN = 1, MIX_CHAN = 2, 
                       WHITE = 0, TAN = 1, TEAL = 2, RED = 3, BLUE = 4, BACKGROUND = 80,
                       PADDING = 10, MARGIN = 25;

  visualization(PApplet a, String wt, int posX, int posY, int defWidth, int defHeight, boolean resize, int background){
    build(a, wt, posX, posY, defWidth, defHeight, resize, background);  
  }
  visualization(PApplet a, String wt, int posX, int posY, int defWidth, int defHeight, boolean resize){
    build(a, wt, posX, posY, defWidth, defHeight, resize, BACKGROUND);  
  }
  visualization(PApplet a, String wt, int defWidth, int defHeight){
    build(a, wt, 200, 200, defWidth, defHeight, true, BACKGROUND);
  }
  visualization(PApplet a, String wt){
    build(a, wt, 200, 200, 400, 200, true, BACKGROUND);
  }
  private void build(PApplet a, String wt, int posX, int posY, int defWidth, int defHeight, boolean resize, int background){
    app = a;
    //app.frame.setVisible(false);
    windowTitle = wt;
    window = new GWindow(app, windowTitle, posX, posY, defWidth, defHeight, false, JAVA2D);
    window.setActionOnClose(GWindow.CLOSE_WINDOW);
    window.setResizable(resize);
    window.setMinimumSize(new Dimension(200,200));
    window.setOnTop(false);
    window.setBackground(background);
    window.addDrawHandler(this, "drawHandle");
    window.addMouseHandler(this, "mouseHandle");
    window.addKeyHandler(this, "keyHandle");
    window.addOnCloseHandler(this, "closeHandle");
    palette = new color[5];
    palette[WHITE] = color(240);
    palette[TAN]   = color(200, 200, 100);
    palette[TEAL]  = color(150, 200, 150);
    palette[RED]   = color(200, 100, 100);
    palette[BLUE]  = color(100, 100, 200);
    curColor = 0;
    if     (this instanceof mediaPlayer)         globalActiveSource = TRACK_PLAYER;
    else if(this instanceof diatonicSynth)       globalActiveSource = SOUND_GEN;
    else if(this instanceof microphoneInterface) globalActiveSource = MICROPHONE;
  }
  protected void drawInstructionsBtn(GWinApplet a){
    a.ellipseMode(CENTER);
    int size = 20;
    int centerX = (a.width-5)-size/2, centerY = 5+size/2;
    if(overCircularBtn(a, centerX, centerY, size)) a.fill(palette[TEAL]);
    else a.fill(palette[RED]);
    a.strokeWeight(3);
    a.stroke(0);
    a.ellipse(centerX, centerY, size, size);
    a.textAlign(CENTER,CENTER);
    a.fill(0);
    a.textSize(20);
    a.textFont(font[QUERY_FONT], 20);
    a.text("?", centerX, centerY);
  }
  protected boolean overInstructionsBtn(GWinApplet a){
    int size = 20;
    int centerX = (a.width-5)-size/2, centerY = 5+size/2;
    return overCircularBtn(a, centerX, centerY, size);
  }
  //https://processing.org/examples/rollover.html
  protected boolean overCircularBtn(GWinApplet win, float x, float y, float diameter){
    float disX = x - win.mouseX;
    float disY = y - win.mouseY;
    return sqrt(sq(disX) + sq(disY)) < diameter/2 ? true : false; 
  }/****************/
  protected boolean overRectangleBtn(GWinApplet win, float x1, float y1, float x2, float y2){
    return win.mouseX > x1 && win.mouseX < x2 && win.mouseY > y1 && win.mouseY < y2 ? true : false;
  }
  protected int globalMouseX(){
    Point a = MouseInfo.getPointerInfo().getLocation();
    return a.x;
  }
  protected int globalMouseY(){
    Point a = MouseInfo.getPointerInfo().getLocation();
    return a.y;
  }
  abstract void drawHandle(GWinApplet a, GWinData d);
  abstract void mouseHandle(GWinApplet a, GWinData d, MouseEvent e);
  abstract void keyHandle(GWinApplet a, GWinData d, KeyEvent e);
  abstract void closeHandle(GWindow w);
}
