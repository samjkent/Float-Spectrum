import processing.sound.*;
import processing.serial.*;
import controlP5.*;

ControlP5 cp5;
Knob gain;

FFT fft;
AudioIn in;
int bands = 512;
float[] spectrum = new float[bands];
float globalGain = 1000;
int globalModulate = 0;       // 0 - use tube property, 1 - amplitude, 2 - brightness
color lowTubeColour;
color midTubeColour;
color highTubeColour;
int r = 11;
int g = 143;
int b = 213;

float[] tubeValues = new float[25];

int colour = 0xFF0000;

Serial myPort;
byte[] tubeVals = new byte[25]; 

float updateTube(int n, int fLB, int fUB, color colour, float gain){
  
  if(fUB < fLB){
    print("Error: fUB is smaller than fLB");
    return 0.0;
  }
  
  // Convert f to bins
  float fPerBin = 20000/bands;
  int fLBBin = ceil(fLB/fPerBin);
  int fUBBin = ceil(fUB/fPerBin);
  
  float binAvg = 0;
  
  // Get average of bins
  for(int i = fLBBin; i <= fUBBin; i++){
    binAvg = binAvg + spectrum[i];
  }
  
  float binMag = (binAvg/(fUBBin-fLBBin+1));
  binMag = binMag * globalGain * gain;
  
  // avg out
  float alpha = 0.595;
  binMag = (1-alpha) * tubeValues[n] + alpha * binMag;

  if (mousePressed == true) {
    if(mouseX < 625 && mouseX > 525 && mouseY > 200 && mouseY < 230) {
      binMag = 0;
    }
    
    if(mouseX < 625 && mouseX > 525 && mouseY > 250 && mouseY < 280) {
      binMag = 255;
    }
    
  }

  // Draw rectangles
  fill(colour, binMag);
  rect(30+(100*(n%5)), 100*(floor(n/5)+1), 50, 50);
  fill(colour);
  text("ID: " + n, 30+(100*(n%5)), 100*(floor(n/5)+1)-30);
  text(fLB + "-", 30+(100*(n%5)), 100*(floor(n/5)+1)-20);
  text(fUB + "hz", 30+(100*(n%5)), 100*(floor(n/5)+1)-10);
  text("Gain:" + gain, 30+(100*(n%5)), 100*(floor(n/5)+1));
  text("Out:" + binMag, 30+(100*(n%5)), 100*(floor(n/5)+1)+10);

  //float red    = ((colour & 0x00FF0000) >> 16);
  //float green  = ((colour & 0x0000FF00) >> 8);
  //float blue   = ((colour & 0x000000FF) >> 0);
  
  //byte red_byte, green_byte, blue_byte;
  
  //if(binMag <= 255){
  //    red_byte    = byte(red   * (binMag/255));
  //    green_byte  = byte(green * (binMag/255));
  //    blue_byte   = byte(blue  * (binMag/255));
  //} else {
  //    red_byte    = byte(red);
  //    green_byte  = byte(green);
  //    blue_byte   = byte(blue);
  //}
      
  //myPort.write(red_byte);
  //myPort.write(green_byte);
  //myPort.write(blue_byte);
  
  float binMult = binMag/255.0;
  if(binMult > 1) binMult = 1;
  byte binMag_byte = (byte)floor(0xFF * binMult);
  
  if(binMag_byte == 0xFF) binMag_byte = (byte)0xFE;
  tubeVals[n] = binMag_byte;
  return binMag;
}

void setup() {
  
  frameRate(200);
  printArray(Serial.list());
  //myPort = new Serial(this, Serial.list()[3], 115200);

  size(660, 600);
  background(0);
  
    
  // Create an Input stream which is routed into the Amplitude analyzer
  fft = new FFT(this, bands);
  in = new AudioIn(this, 0);
  
  // start the Audio Input
  in.start();
  
  // patch the AudioIn
  fft.input(in);
  
  cp5 = new ControlP5(this);
   gain = cp5.addKnob("gain")
               .setRange(0,200)
               .setValue(100)
               .setPosition(525,70)
               .setRadius(50)
               .setDragDirection(Knob.VERTICAL)
               ;
               
  cp5.addBang("Dark")
     .setValue(0)
     .setPosition(525,200)
     .setSize(100,30)
     ;
  
  cp5.addBang("Bright")
     .setValue(0)
     .setPosition(525,250)
     .setSize(100,30)
     ;
}      

void draw() { 
  background(0);
  fft.analyze(spectrum);
  
  in.amp(gain.getValue() / 100.0);
  
  lowTubeColour = color(255,0,0);
  midTubeColour = color(255,0,125);
  highTubeColour = color(125,100,255);

  //updateTube(int n, int fLB, int fUB, color colour, float gain)
   //row 1
  float subMag = updateTube(0, 1500, 4000, highTubeColour, 30);
  updateTube(1, 3400, 6000, highTubeColour, 32);
  float redMag = updateTube(2, 6000, 7000, highTubeColour, 32);
  float midMag = updateTube(3, 6500, 7200, highTubeColour, 34);
  float yellowMag = updateTube(4, 7000, 9500, highTubeColour, 30);
  
  // 2
  float highMag = updateTube(5, 2000, 10000, highTubeColour, 36);
  updateTube(6, 600, 1000, midTubeColour, 6);
  updateTube(7, 200, 250, midTubeColour, 4);
  updateTube(8, 100, 200, midTubeColour, 4);
  updateTube(9, 4900, 6200, highTubeColour, 26);
  
  // 3
  updateTube(10, 2000, 3300, highTubeColour, 34);
  updateTube(11, 110, 220, midTubeColour, 4);
  updateTube(12, 30, 60, lowTubeColour, 2);
  updateTube(13, 140, 180, midTubeColour, 4);
  updateTube(14, 3500, 4000, highTubeColour, 32);
  
  //// 4
  updateTube(15, 2500, 3000, highTubeColour, 25);
  updateTube(16, 200, 450, midTubeColour, 4);
  updateTube(17, 160, 320, midTubeColour, 4);
  updateTube(18, 300, 600, midTubeColour, 4);
  updateTube(19, 2100, 2700, highTubeColour, 28);
  
  //// 5
  updateTube(20, 7000, 10000, highTubeColour, 32);
  updateTube(21, 4000, 4500, highTubeColour, 31);
  updateTube(22, 6000, 6500, highTubeColour, 34);
  updateTube(23, 6500, 7500, highTubeColour, 31);
  updateTube(24, 3000, 15000, highTubeColour, 30);
  ////updateTube(25, 600, 1000, highTubeColour, 5);
  ////updateTube(26, 750, 1200, highTubeColour, 7);
  ////updateTube(27, 600, 700, highTubeColour, 8);
  ////updateTube(28, 700, 1150, highTubeColour, 5);
  ////updateTube(29, 1500, 5500, highTubeColour, 10);
  
  for(int i = 0; i < bands; i++){
  // The result of the FFT is normalized
  // draw the line for frequency band i scaling it up by 5 to get more amplitude.
  stroke(150);
  line( i, height, i, height - spectrum[i]*height*5 );
  }
  
}

void serialEvent(Serial myPort) {
  myPort.write(tubeVals);  
}