public class waveListener extends listener{
  waveListener(soundSource[] src){
    super(src);
  }
//  int averageIntensity(){
//    float intensity = map(level('M'), 0, .3, 0, 255);
//    //print(intensity + "    ");
//    return int(intensity);
//  }
//  float averageLeft(){
//    if(left!=null){
//      float av = 0;
//      for(int i=0; i<left.length; i++) av += abs(left[i]);
//      av /= left.length;
//      return av;
//    }
//    return 0.0;
//  }
//  float averageRight(){
//    if(right!=null){
//      float av = 0;
//      for(int i=0; i<right.length; i++) av += abs(right[i]);
//      av /= right.length;
//      return av;
//    }
//    return averageLeft();
//  }
//  float averageMix(){ return left!=null || right!=null ? (averageLeft() + averageRight())/2 : 0.0; }
}
