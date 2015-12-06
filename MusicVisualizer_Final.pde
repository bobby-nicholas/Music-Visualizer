/*
Main Entry point of the program.
Do all imports in this tab, for clarity sake
*/


import java.awt.Font;
import java.awt.*;
import java.awt.Dimension;
import java.util.regex.*;
//------------
import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
//import ddf.minim.effects.*;
//------------
import g4p_controls.*;
//------------
import fisica.*;
//------------

PFont[] font;
final int  DATA_FONT = 0, MANAGER_FONT = 1, PLAYER_FONT = 2, QUERY_FONT = 3;

/*This is a part of hack to make song loading work.... 
  the issue may be tied to the hiding of the default processing window 
  which is not part of the program.  Exposing the window to view while
  the open file dialogue box is open solves the problem for some
  but others not at all. globalVisible is toggled byset true by the trackListener  
*/ 
boolean globalVisible = false;
void setup(){
  font = new PFont[5];
  font[DATA_FONT]    = loadFont("Monospaced-20.vlw");
  font[MANAGER_FONT] = loadFont("GillSans-Bold-20.vlw");
  font[QUERY_FONT]   = loadFont("AvenirNextCondensed-DemiBoldItalic-20.vlw");
  font[PLAYER_FONT]  = loadFont("TrajanPro-Regular-38.vlw");
  
  visualizationManager vm = new visualizationManager(this);
}
void draw(){
   this.frame.setVisible(globalVisible);
}
