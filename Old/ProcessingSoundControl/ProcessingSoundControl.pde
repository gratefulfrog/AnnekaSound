
///////////////////// USER PARAMETERS /////////////////////////////

final String remoteIP = "127.0.0.1";

final int listenPort = 12000,
          sendPort   = 12000;

final String portName = "/dev/ttyACM0";

///////////////////// END of USER PARAMETERS /////////////////////////////

import processing.serial.*;

import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;

Serial myPort;                       // The serial port
boolean firstContact = false,        // Whether we've heard from the microcontroller
        messageArrived = false;
        
String incoming = "",
       IncomingOSCMessage = "";

final char startChar = '*',
           endChar   = '#',
           contactCharacter = '|';

void showIncoming(){ 
  String resVec[]  = incoming.split(",");
  try{
    for (int i = 0; i< resVec.length;i+=2){
      text(resVec[i],20,20+20*i);
      text(resVec[i+1],20 + resVec[i].length()*10, 20+20*i); 
      OscMessage myMessage = new OscMessage("/" + resVec[i]);
      float number = Float.parseFloat(resVec[i+1]);
      myMessage.add(number); /* add a number to the osc message */

      /* send the message */
      oscP5.send(myMessage, myRemoteLocation); 
    }
  }
  catch(Exception ex){
    println("Exception Message: " + ex);
    printArray(resVec);
    exit();
  }
  
}

void showOsc(){
  text(IncomingOSCMessage, 300,200);
  IncomingOSCMessage ="";
}
void setup() {
  size(1000, 800); 
  fill(255);
  background(0);
  //printArray(Serial.list());
  myPort = new Serial(this, portName, 115200);
  
  /* start oscP5, listening for incoming messages */
  oscP5 = new OscP5(this,listenPort);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress(remoteIP,sendPort);
}

void draw() {
  if(messageArrived){
    background(0);
    showIncoming();
    messageArrived= false;
  }
  showOsc();
}

void serialEvent(Serial myPort) {
  // read a byte from the serial port:
  char inChar = myPort.readChar();
  // if this is the first char received, and it's an contactCharacter,
  // clear the serial buffer and note that you've
  // had first contact from the microcontroller.
  // Otherwise, process the incoming char
  if (!firstContact) {
    if (inChar == contactCharacter) {
      println("First contact!");
      myPort.clear();          // clear the serial port buffer
      firstContact = true;     // you've had first contact from the microcontroller
      myPort.write(str(contactCharacter));       // ask for more
      println("started!");
    }
  }
  else {
    switch (inChar){
      case contactCharacter:
        println("got extra contactCharacter");
        firstContact = false;
        break;
      case startChar:
        incoming= "";
        break;
      case endChar:
        messageArrived = true;
        //println("end of msg");
        break;
      default:
        incoming += inChar;
        break;
    }
  }
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {  
  float value = theOscMessage.get(0).floatValue(); // get the 1st osc argument
  
  IncomingOSCMessage += "\n" + 
                        String.format("### received an osc message: " + 
                                      " addrpattern: " + 
                                      theOscMessage.addrPattern() + 
                                      " :  %f", 
                                      value);
  println(IncomingOSCMessage);
}