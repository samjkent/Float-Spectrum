#include <Boards.h>

#define USE_HSV
#include <WS2812.h>

#define DATA_PIN    8
#define NUM_LEDS    300
#define NUM_TUBES   25

WS2812 LED(NUM_LEDS); 

byte byteBuffer[NUM_TUBES*3]; 
cRGB value;
cRGB z;
int i = 0;
int timer = 0;

int hsv_vals[NUM_TUBES][3] = {
  {240,180,255},
  {240,180,255},
  {240,180,255},
  {240,180,255},
  {240,180,255},
  
  {240,180,255},
  {60,255,255},
  {60,255,255},
  {60,255,255},
  {240,180,255},


  {240,180,255},
  {60,255,255},
  {0,255,255},
  {60,255,255},
  {240,180,255},

  {240,180,255},
  {60,255,255},
  {60,255,255},
  {60,255,255},
  {240,180,255},

  {240,180,255},
  {240,180,255},
  {240,180,255},
  {240,180,255},
  {240,180,255}
};

void setup() {
  
  LED.setOutput(DATA_PIN);  

  Serial.begin(115200);
     
    for(int j = 0; j < 25; j++){
          cRGB colour;
          colour.SetHSV(hsv_vals[j][0], hsv_vals[j][1], hsv_vals[j][2]);
          for(int k = 0; k < 12; k++){
            LED.set_crgb_at((12*j)+k, colour);
          }
     }

  LED.sync();
}

void requestData() {
  while (Serial.available() <= 0) {
    Serial.print('A');   // send a capital A
    delay(10);
  }
}


void loop()
{
        requestData();

      if(Serial.available() > 0){
            Serial.readBytes(byteBuffer, NUM_TUBES);
            for(int i = 0; i < NUM_TUBES; i++){
              unsigned int brightness = (unsigned int)byteBuffer[i];
              brightness = brightness * 2;
              if(brightness > 255) brightness = 255; 
              hsv_vals[i][2] = brightness; // Update brightness
            }            
          }
         

    for(int j = 0; j < NUM_TUBES; j++){
          cRGB colour;
          colour.SetHSV(hsv_vals[j][0], hsv_vals[j][1], hsv_vals[j][2]);
          for(int k = 0; k < 12; k++){
            LED.set_crgb_at((12*j)+k, colour);
          }
     }
    LED.sync();

}
