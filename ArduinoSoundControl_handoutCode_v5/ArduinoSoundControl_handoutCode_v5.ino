/*  This code is a basic sketch to communicate with Processing through Serial.

     It is a blueprint in which you can put your own code
     specified for your own buttons, potentiometers or sensors.

     It has a handshake to make sure we have contact
     and the format in which we are communicating is decided

     It is important to construct the message this same way,
     so that Processing knows how to deconstruct it
     and send correct OSC-messages to our DAW

     made for werkcollege AV&IT
     oct 2017

*/

// baud rate
const long baudRate = 115200;

// time to wait in ms between polls to the pins
const int loopPauseTime =  200; // milli seconds

// start and end values for the message sent on Serial
const String startString = "*",
             endString   = "#";

const char contactCharacter = '|'; //<-- PROBLEM FIXED !

// pin id's
// Delete this line and put your variables indicating pin numbers here

// other global variables
// Delete this line and put your other variables here if needed

// We need this function to establish contact with the Processing sketch
// Keep it here
void establishContact() {
  while (Serial.available() <= 0) {
    Serial.print(contactCharacter);   // send a char and wait for a response...
    delay(300);
  }
  Serial.read();
}

void setup() {
  // set the pinModes for all the pins
  
  // uncomment if you use sensors that work on 3V instead of 5V
  // you will have to wire the 'ext' pin to 3.3V as well
  // analogReference(EXTERNAL);

  // initialize Serial comms
  Serial.begin(baudRate);
  while (!Serial);
  
  // wait for handshake
  establishContact();
}

void loop() {
  // STEP 1: READ BUTTONS
  // poll all the pins and map the reading to the appropriate range
  int bpmSlider = analogRead(A5);

  float v0 = map(bpmSlider,0,1023,60,250);
  float v1 = digitalRead(7);
  
  // examples:
  // float v0 = map(bpm, 0, 1023, 60, 250);
  // if you want to use a normalized float (eg. for volume)
  // float v1 = map(analogRead(pin2), fromMin, fromMax, 0, 100) / 100.0;

  // STEP 2: WRITE MESSAGE
  // write start of message
  Serial.print(startString);  // start a message sequence

  // wirte all the name,value pairs, separated by commas

  // example of sending a midi note
  Serial.print("/vkb_midi/@/note/20");
  Serial.print(",");
  Serial.print(v1); // requires an integer 0 or 1
  Serial.print(",");

  // example of changing the tempo
  Serial.print("/tempo/raw,");
  Serial.print(v0);

  // write the end of message
  Serial.print(endString);

  // wait for a while..
  delay(loopPauseTime);
}
