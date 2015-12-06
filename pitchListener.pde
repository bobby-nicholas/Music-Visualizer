public class pitchListener extends listener{
  private final int   LOCAL_MAXIMA = 0, HARMONIC_PROD = 1, AUTOCORRELATION = 2;
  private final int   MAX_DOWNSAMPLES = 8, MIN_PERIOD = 5, MAX_PERIOD = 800;
  private final float MIN_FREQ = 1.0, MAX_FREQ = 50000.0; 
  private int         activeMethod;
  private float       detectedPitch;
  private FFT         transform;
  private int         bufferSize;
  private float       sampleRate;
  private float       lowestFreq, highestFreq;
  private int         downSamples, smallestPeriod, largestPeriod;
  private color       r = color(250, 10, 10),
                      g = color(10, 250, 10),
                      b = color(10, 10, 250);
  
  pitchListener(soundSource[] src){
    super(src);
    detectedPitch = 0;
    activeMethod = HARMONIC_PROD;
    bufferSize = bufferSize();
    sampleRate = sampleRate();
    if(bufferSize!=0 && sampleRate!=0){
      transform = new FFT(bufferSize, sampleRate);
      transform.window(FFT.HAMMING);
    }
    lowestFreq     = MIN_FREQ;
    highestFreq    = MAX_FREQ;
    smallestPeriod = MIN_PERIOD;
    largestPeriod  = MAX_PERIOD;    
    downSamples    = 4;
  }
  private boolean refresh(){
    if(sources!=null && transform!=null && bufferSize == bufferSize() && sampleRate == sampleRate()) return true;
    else if(sources!=null && bufferSize()!=0 && sampleRate()!=0){
      bufferSize = bufferSize();
      sampleRate = sampleRate();
      transform = new FFT(bufferSize, sampleRate);
      if(transform==null) return false;
      transform.window(FFT.HAMMING);
      println("REFRESHED -- " + transform.timeSize());
      return true;
    }
    return false;
  }
  float lowestFreq() { return lowestFreq; }
  float highestFreq(){ return highestFreq; }
  int   downSamples(){ return downSamples; }
  void  lowestFreq(float f) { lowestFreq  = (f >= MIN_FREQ) ? (f < highestFreq) ? f : highestFreq/2 : MIN_FREQ; }
  void  highestFreq(float f){ highestFreq = (f > lowestFreq) ? (f <= MAX_FREQ) ? f : MAX_FREQ : lowestFreq*2; }
  void  downSamples(int d)  { downSamples = (d >= 0) ? (d <= MAX_DOWNSAMPLES) ? d : MAX_DOWNSAMPLES : 0; }
  void setDetectMethod(int method){ activeMethod = method; }
  String getDetectMethod(){
    switch(activeMethod){
      case LOCAL_MAXIMA:    return "Fundamental Frequency";
      case HARMONIC_PROD:   return "Harmonic Product Spectrum";
      case AUTOCORRELATION: return "Autocorrelation";
      default:              return "None";
    }
  }
  float detectPitchFreq(GWinApplet a){
    switch(activeMethod){
      case LOCAL_MAXIMA:
      detectedPitch = localMaxima(mix());   
      break;
      case HARMONIC_PROD:
      detectedPitch = harmonicProduct(mix());
      break;
      case AUTOCORRELATION:
      detectedPitch = autocorrelation(mix());
      break;
      default: detectedPitch = 0;
    }
    return detectedPitch;
  }
  String detectPitchClass(GWinApplet a){
    switch(activeMethod){
      case LOCAL_MAXIMA:
      detectedPitch = localMaxima(mix());   
      break;
      case HARMONIC_PROD:
      detectedPitch = harmonicProduct(mix());
      break;
      case AUTOCORRELATION:
      detectedPitch = autocorrelation(mix());
      break;
      default: detectedPitch = 0;
    }
    return pitchClass(detectedPitch);
  }
  float localMaxima(float[] sample){
    return spectrumIndexToFreq(indexOfMaximum(getBoundedSpectrum(sample)));
  }
  //code was influenced by http://dsp.stackexchange.com/questions/11432/how-does-one-know-how-many-times-to-downsample-in-harmonic-product-spectrum
  float harmonicProduct(float[] sample){
    return spectrumIndexToFreq(indexOfMaximum(getProductSpectrum(getHarmonicSpectrumMatrix(sample))));
  }
  //help from: https://gerrybeauregard.wordpress.com/2013/07/15/high-accuracy-monophonic-pitch-estimation-using-normalized-autocorrelation/
  float autocorrelation(float[] sample){
    return wavePeriodToFreq(getWavePeriod(getNormalizedAC(sample)));
  }
  float[] getBoundedSpectrum(float[] sample){
    if(refresh()){
      if(sample.length != transform.timeSize()) println("NOT EQUAL... sample = " + sample.length + " timeSize = " + transform.timeSize());
      transform.forward(sample);
      int   startIndex = transform.freqToIndex(lowestFreq);
      int   endIndex   = transform.freqToIndex(highestFreq);
      float[] spectrum = new float[transform.specSize()];
      for(int i = startIndex; i <= endIndex; i++){
        spectrum[i] = transform.getBand(i);
      }
      return spectrum;
    }
    return null;
  }
  float[][] getHarmonicSpectrumMatrix(float[] sample){
    if(sample == null) return null;
    if(downSamples < 0) return null;
    float[] fullSpec = getBoundedSpectrum(sample);
    if(fullSpec == null) return null;
    float[][] hps = new float[downSamples+1][];
    hps[0] = new float[fullSpec.length];
    for(int i = 1; i<downSamples+1; i++) hps[i] = new float[fullSpec.length/(i+1)];
    arrayCopy(fullSpec, hps[0]);
    //1 downsample = the product of the full spectrum and the spectrum downsampled by a factor of 2
    for(int i=1; i<downSamples+1; i++){
      for(int j=0; j<hps[i].length; j++){
        hps[i][j] = fullSpec[j * (i+1)];
      }
    }
    return hps;
  }
  float[] getProductSpectrum(float[][] matrix){
    float product[] = null;
    if(matrix!=null){
      product = new float[matrix[matrix.length-1].length];
      arrayCopy(matrix[matrix.length-1], product);
      for(int i=matrix.length-2; i>=0; i--){
        for(int j=0; j<product.length; j++){
          product[j] *= matrix[i][j];
        }
      }
    }
    return product;
  }
  int indexOfMaximum(float[] buf){
    if(buf == null) return -1;
    float maximum = 0;
    int   index   = -1;
    for(int i = 0; i<buf.length; i++){
      if(buf[i] > maximum){
        maximum = buf[i];
        index = i;
      }
    }
    return index;
  }
  float spectrumIndexToFreq(int index){ 
    return index >= 0 ? index/float(bufferSize) * sampleRate : 0.0;
  }
  float wavePeriodToFreq(float period){
    float freq = 0.0;
    if(period > 0) freq = sampleRate/period;
    return freq; 
  }
  float[] getNormalizedAC(float[] sample){
    if(!refresh()) return null; 
    if(sample.length/2 > smallestPeriod) largestPeriod = sample.length/2;
    float[] normalizedAC = new float[largestPeriod+1];
    for(int period = smallestPeriod-1; period < largestPeriod+1; period++){
      float standardAC = 0;
      float sumSqBeg = 0, sumSqEnd = 0;
      for(int i = 0; i < sample.length - period; i++){
        standardAC += sample[i] * sample[i+period];
        sumSqBeg += pow(sample[i], 2);
        sumSqEnd += pow(sample[i+period], 2);
      }
      normalizedAC[period] = standardAC / sqrt(sumSqBeg * sumSqEnd);
    }
    return normalizedAC;
  }
  float getWavePeriod(float[] normalizedAC){
    if(normalizedAC==null) return 0; 
    int bestPeriod = smallestPeriod;
    for(int period = smallestPeriod+1; period < largestPeriod+1; period++){
      if(normalizedAC[period] > normalizedAC[bestPeriod]) bestPeriod = period;
    }
    int correctedPeriod = periodOctaveCorrect(normalizedAC, bestPeriod);
    //increase precision with interpolation of neighboring vals
    float estimatedPeriod = correctedPeriod;
    if(correctedPeriod > 0 && correctedPeriod < normalizedAC.length-1){
      float mid   = normalizedAC[correctedPeriod];
      float left  = normalizedAC[correctedPeriod-1];
      float right = normalizedAC[correctedPeriod+1];
      float shift = 0.5 * (right-left) / (mid*2 - left - right);
      estimatedPeriod += shift;
    }
    return estimatedPeriod;
  }
  int periodOctaveCorrect(float[] normalizedAC, int period){
    //check if the found period has peaks at integer fractions of itself.
    float threshold = .90; // the strength of the period fraction must be >= 90% of the found period
    int     maxFrac = period/smallestPeriod;
    int   corPeriod = period;
    boolean found    = false;
    for(int i = maxFrac; i >= 1; i--){
      boolean flag = true; 
      for(int j = 1; j < i; j++){
        int subPeriod = j * period / i;
        if(normalizedAC[subPeriod] < normalizedAC[period] * threshold){
          flag = false;
        }
      }
      if(flag){
        found = true;
        corPeriod =  period / i;
        break;
      }
    }
    //if(corPeriod == period) println("SUB PERIOD NOT FOUND");
    return corPeriod;
  }
  String pitchClass(float pitch){
    /*finds the pitch class which 
      corresponds most closely to the pitch freq*/
    if(pitch > lowestFreq && pitch < highestFreq){
      //find the distance between 'A1' and the pitch freq.
      float disp = abs(hStepToFreq(0) - pitch);
      //set the class to 'A'
      String pClass = hStepToNote(0);
      /*search from A1 -> G8 for a better match
        i.e. smaller distance between the freq. and note*/
      for(int i=1; i<12*8; i++){
        if(abs(hStepToFreq(i) - pitch) < disp){
          disp = abs(hStepToFreq(i) - pitch);
          pClass = hStepToNote(i);  
        }
      }
      return pClass;
    }
    return "none";  
  }
  color pitchClassToColor(String colorScale){
    color c;
    String pClass = pitchClass(localMaxima(mix()));
    //LOUIS BERTRAND CASTEL (1734)
    if(colorScale.toUpperCase() == "CASTEL"){
           if(pClass =="C")     c = #1C0D82; //BLUE
      else if(pClass =="C#/Db") c = #1B9081; //BLUE-GREEN
      else if(pClass =="D")     c = #149033; //GREEN
      else if(pClass =="D#/Eb") c = #709226; //OLIVE-GREEN
      else if(pClass =="E")     c = #F5F43C; //YELLOW
      else if(pClass =="F")     c = #F5D23B; //YELLOW-ORANGE
      else if(pClass =="F#/Gb") c = #F88010; //ORANGE
      else if(pClass =="G")     c = #FA0B0C; //RED
      else if(pClass =="G#/Ab") c = #A00C09; //CRIMSON
      else if(pClass =="A")     c = #D71386; //VIOLET
      else if(pClass =="A#/Bb") c = #4B0E7D; //AGATE
      else if(pClass =="B")     c = #7F087C; //INDIGO
      else c = color(80);
    }
    //D.D. JAMESON (1844)
    else if(colorScale.toUpperCase() == "JAMESON"){
           if(pClass =="C")     c = #FA0B0C; 
      else if(pClass =="C#/Db") c = #F44712; 
      else if(pClass =="D")     c = #F88010; 
      else if(pClass =="D#/Eb") c = #F5D23B; 
      else if(pClass =="E")     c = #F5F43C; 
      else if(pClass =="F")     c = #149033; 
      else if(pClass =="F#/Gb") c = #1B9081; 
      else if(pClass =="G")     c = #1C0D82; 
      else if(pClass =="G#/Ab") c = #4B0E7D; 
      else if(pClass =="A")     c = #7F087C; 
      else if(pClass =="A#/Bb") c = #A61586; 
      else if(pClass =="B")     c = #D71386; 
      else c = color(80);
    }
    //H. VON HELMHOLTZ (1910)
    else if(colorScale.toUpperCase() == "HELMHOLTZ"){
           if(pClass =="C")     c = #F5F43C; 
      else if(pClass =="C#/Db") c = #149033; 
      else if(pClass =="D")     c = #1B9081; 
      else if(pClass =="D#/Eb") c = #1C5BA0; 
      else if(pClass =="E")     c = #7F087C; 
      else if(pClass =="F")     c = #D71386; 
      else if(pClass =="F#/Gb") c = #9D0E55; 
      else if(pClass =="G")     c = #FA0B0C; 
      else if(pClass =="G#/Ab") c = #D32C0A; 
      else if(pClass =="A")     c = #D02A08; 
      else if(pClass =="A#/Bb") c = #F62E0D; 
      else if(pClass =="B")     c = #F17A0F; 
      else c = color(80);
    }
    /*My Personal Mapping...
      Blue  fades to Green from C  to E
      Green fades to Red   from E  to G#
      Red   fades to Blue  from G# to C
    */
    else if(colorScale.toUpperCase() == "BOBBY"){
           if(pClass =="C")     c = lerpColor(b, g, 0/4.0);
      else if(pClass =="C#/Db") c = lerpColor(b, g, 1/4.0);
      else if(pClass =="D")     c = lerpColor(b, g, 2/4.0); 
      else if(pClass =="D#/Eb") c = lerpColor(b, g, 3/4.0);
      else if(pClass =="E")     c = lerpColor(g, r, 0/4.0); 
      else if(pClass =="F")     c = lerpColor(g, r, 1/4.0); 
      else if(pClass =="F#/Gb") c = lerpColor(g, r, 2/4.0);
      else if(pClass =="G")     c = lerpColor(g, r, 3/4.0);
      else if(pClass =="G#/Ab") c = lerpColor(r, b, 0/4.0); 
      else if(pClass =="A")     c = lerpColor(r, b, 1/4.0); 
      else if(pClass =="A#/Bb") c = lerpColor(r, b, 2/4.0); 
      else if(pClass =="B")     c = lerpColor(r, b, 3/4.0); 
      else c = color(80);
    }
    else c = color(80);
    return c;
  }
  
  float frequencyToWavelength(float freq){
    return freq > 0 ? sampleRate/freq : 0;  
  }

  float hStepToFreq(int steps){
    return pow(pow(2,(1/12.0)), steps) * 55.0; //A1  
  }
  String hStepToNote(int steps){
    int pClass = steps % 12;
    switch(pClass){
      case 0:  return "A";
      case 1:  return "A#/Bb";
      case 2:  return "B";
      case 3:  return "C";
      case 4:  return "C#/Db";
      case 5:  return "D";
      case 6:  return "D#/Eb";
      case 7:  return "E";
      case 8:  return "F";
      case 9:  return "F#/Gb";
      case 10: return "G";
      case 11: return "G#/Ab";
      default: return "";
    }  
  }
}
