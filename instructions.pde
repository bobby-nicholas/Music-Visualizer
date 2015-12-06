public class instructions{  
  PApplet app;
  String  instructions;
  String  heading;
  PImage  image;
  int     textSize, imageWidth, imageHeight;
  final int PADDING = 10, MARGIN = 25;
  GWindow window;
  
  instructions(PApplet a, Object obj, int locX, int locY){
    app = a;
    instructions = "";
    if(obj instanceof mediaPlayer){
      textSize = 12;
      imageWidth = 300;
      imageHeight = 150;
      build("Media Player Help", locX, locY, 350, 450, "media_player.txt", "media_player.png");
    }
    else if(obj instanceof diatonicSynth){
      textSize = 12;
      imageWidth = 905/2;
      imageHeight = 291/2;
      build("Synthesizer Help", locX, locY, 455, 400, "synth.txt", "synth.png");
    }
    else if(obj instanceof beatDetection){
    }
    else if(obj instanceof microphoneInterface){
    }
    else if(obj instanceof spectrum){ 
    }
    else if(obj instanceof waveform){
    }
    else{
    }
  }
  void build(String windowTitle, int x, int y, int iWidth, int iHeight, String instructionsPath, String imagePath){
    if(loadData(instructionsPath, imagePath)){
      window = new GWindow(app, windowTitle, x, y, iWidth, iHeight, false, JAVA2D);
      window.setBackground(80);
      window.setResizable(false);
      window.setActionOnClose(GWindow.CLOSE_WINDOW);
      window.addDrawHandler(this, "drawHandle");
    }
  }
  boolean loadData(String textPath, String imPath){
    String text[] = app.loadStrings(textPath);
    if(text!=null && text.length > 1){
      heading = text[0];
      for(int i=1; i<text.length; i++) instructions += (text[i] + "\n");
      image = app.loadImage(imPath);
      return image!=null ? true : false;
    }
    return false;
  }
  void drawHandle(GWinApplet a, GWinData d){
    a.fill(240);
    a.textAlign(CENTER);
    a.textSize(textSize * 2);
    a.text(heading, PADDING, PADDING, a.width-(PADDING*2), PADDING + textSize * 2);
    a.image(image, PADDING, PADDING + textSize*2 + PADDING, imageWidth, imageHeight);
    a.textSize(textSize);
    a.textAlign(LEFT);
    a.text(instructions, PADDING, (PADDING*2 + textSize*2) + imageHeight + PADDING, a.width-(PADDING*2), (a.height-PADDING) - ((PADDING*2 + textSize*2) + imageHeight + PADDING));
  }
}
