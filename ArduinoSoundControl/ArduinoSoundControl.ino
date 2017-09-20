// time to wait in ms between polls to the pins
const int loopPauseTime =  20; // milli seconds


// start and end values for the message sent on Serial
const String startString =  "*",
             endString = "#";

const char contactCharacter = '@';

// pin id's
const int dPin0 = 2,
          aPin0 = A0,
          aPin1 = A1,
          aPin2 = A2,
          aPin3 = A3;

// pin mapping endpoints
const float dp0Low =   0,
            dp0Hi  =   10.0,
            ap0Low =  -100.0,
            ap0Hi  =   100.0,
            ap1Low =  -200.0,
            ap1Hi  =   200.0,
            ap2Low =  -300.0,
            ap2Hi  =   300.0,
            ap3Low =  -400.0,
            ap3Hi  =   400.0;


void establishContact() {
  while (Serial.available() <= 0) {
    Serial.print(contactCharacter);   // send a char and wait for a response...
    delay(300);
  }
  Serial.read();
}

void setup() {
  // set the pinModes for all the pins
  pinMode(dPin0,INPUT);  
  pinMode(aPin0,INPUT);
  pinMode(aPin1,INPUT);
  pinMode(aPin2,INPUT);
  pinMode(aPin3,INPUT);
  
  analogReference(EXTERNAL);

  // initialize Serial comms
  Serial.begin(115200);
  while(!Serial);
  
  // wait for handshake
  establishContact();
}

void loop() {
  // poll all the pins and map the reading to the appropriate range
  float v0 = map(digitalRead(dPin0),0,1,dp0Low,dp0Hi),
        v1 = map(analogRead(aPin0), 0,1023,ap0Low,ap0Hi),
        v2 = map(analogRead(aPin1), 0,1023,ap1Low,ap1Hi),
        v3 = map(analogRead(aPin2), 0,1023,ap2Low,ap3Hi),
        v4 = map(analogRead(aPin3), 0,1023,ap3Low,ap3Hi);

  // write start of message
  Serial.print(startString);  // start a message sequence

  // wirte all the name,value pairs, separated by commas
  Serial.print("v0,");
  Serial.print(v0);
  Serial.print(",v1,");
  Serial.print(v1);
  Serial.print(",v2,");
  Serial.print(v2);
  Serial.print(",v3,");
  Serial.print(v3);
  Serial.print(",v4,");
  Serial.print(v4);

  // write the end of message
  Serial.print(endString);

  // wait for a while..
  delay(loopPauseTime);
}


