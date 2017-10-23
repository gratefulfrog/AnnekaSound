/**
 * Basic sketch to receive Serial messages from Arduino
 * and translates those to OSC-messages for Reaper
 * 
 * You will need to adapt the USER PARAMETERS
 * and you will need to install a Library: oscP5
 * 
 * made for werkcollege AV&IT
 * by annoo bob eddi
 * oct 2017
 *
 */

///////////////////// USER PARAMETERS /////////////////////////////

// make sure you use the same baud rate in your Arduino sketch
final int baudRate = 115200;

// Go and look for the IP-address in Reaper when using OSC
// This is the address Processing sends to and Reaper listens to.
// Put this string in remoteIP, here.

//final String remoteIP = "192.168.1.43"; //eg. "127.0.0.1";
final String remoteIP = "127.0.0.1";

// Take note of the sendPort and fill this in in Reaper.
// This is the port Processing sends to and Reaper listens to.

final int listenPort = 4242, 
          sendPort   = 4242;

// The listenPort here is to actively debug.

// the portNames are here to debug as well.
final String portName = "/dev/ttyACM0";

// final String portName = "COM6"; // "/dev/ttyUSB0";

///////////////////// END of USER PARAMETERS /////////////////////////////

import processing.serial.*;
import java.util.*;

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

Serial myPort;                  // The serial port
boolean firstContact = false,   // Whether we've heard from the microcontroller
        messageArrived = false; 

String incoming = "", 
       IncomingOSCMessage = "";

final char startChar = '*', 
           endChar   = '#';
           
final char contactCharacter = '|';

// To make sure we only send the parameters (values) that change
// these global variabls are delcared here but should
// not be initialized here!
HashMap<String, Float> oldParams,
                       newParams,
                       toSendParams;

// We need to split the message at every comma
void processIncoming () {
  String resVec[]  = incoming.split(",");
  // we get name + value pairs
  // so for every name (+2)...
  try{
    for (int i = 0; i< resVec.length; i+=2) { 
      float value = Float.parseFloat(resVec[i+1]);
      // put them in the new Hashtable
      newParams.put(resVec[i], value);
    }
  }
  // if an error occurs, let's catch it display and exit.
  catch(Exception ex){
    println("Exception Message: " + ex);
    printArray(resVec);
    exit();
  }
}

// To filter our messages
/* We make sure there is only an OSC-out message when 
 * the input message (Serial) changes
 * That is: if we turn/push the button and it changes value.
 * So we filter out the incoming values that actually change
 * note: we won't avoid jumping values
 * as come from eg accelerometers or distance sensors
 * you will need to smooth those yourself in Arduino 
 */
void filterParams () {
  toSendParams = new HashMap();
  for (String key : newParams.keySet()) {
    // if the key is already present
    if (oldParams.containsKey(key)) {
      // key present and value not the same, then update
      if (!oldParams.get(key).equals(newParams.get(key))) {    
        toSendParams.put(key, newParams.get(key));
      }
    }
    else{ // key is not present in old params, so put it!
        toSendParams.put(key, newParams.get(key));
    }
    oldParams.put(key, newParams.get(key));
  }
}

void makeOSC() {
  for (String key : toSendParams.keySet()) {
    OscMessage myMessage = new OscMessage("/"+ key);
    myMessage.add(toSendParams.get(key));
    /* send the message */
    oscP5.send(myMessage, myRemoteLocation);
  }
}

void translateMessage() {
  processIncoming();
  filterParams();
  makeOSC();
}
// When we want to print to the window
void ShowIncoming() {
  // to see incoming message, as set in the HashMap
  text("Incoming from Arduino", 20, 20);
  int y = 20;
  for (String key : newParams.keySet()) {
    y = y+20;
    text(key, 20, y);
    text(newParams.get(key), 300, y);
  }
}

void showOsc() {
  text(IncomingOSCMessage, 300, 200);
  IncomingOSCMessage ="";
}


void setup() {
  size(1000, 800);  // Stage size
  fill(255);
  background(0);
  oldParams = new HashMap();
  newParams = new HashMap();
  
  //printArray(Serial.list());
  myPort = new Serial(this, portName, baudRate);

  /* start oscP5, listening for incoming messages */
  oscP5 = new OscP5(this, listenPort);

  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress(remoteIP, sendPort);
}

void draw() {
  if (messageArrived) {
    background(0);
    translateMessage();
    ShowIncoming();
    messageArrived= false;
  }
  showOsc();
}

void serialEvent(Serial myPort) {
  // read a byte from the serial port:
  char inChar = myPort.readChar();
  //println(inChar);
  // if this is the first char received, and it's an @,
  // clear the serial buffer and note that you've
  // had first contact from the microcontroller.
  // Otherwise, process the incoming char
  if (!firstContact) {
    if (inChar == contactCharacter) {
      myPort.clear();          // clear the serial port buffer
      firstContact = true;     // you've had first contact from the microcontroller
      myPort.write(contactCharacter);       // ask for more
      println("started!");
    }
  } else {
    switch (inChar) {
    case contactCharacter:
      // This may happen at init
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
