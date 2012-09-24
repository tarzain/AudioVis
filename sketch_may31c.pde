import processing.opengl.*;

/**
 * AudioVis
 * by Zainul Shah.
 *  
 * This program analyzes the audio from a selected file and renders a 3D 
 * visualization corresponding to the resulting data.
 */
import javax.swing.JFileChooser;
import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioPlayer jingle;
FFT fft;
String windowName;
File fSong;
int z=0;
int px=0;
int py=0;
int pz=0;
float max=0.000001;
float overallMax=0.000001;
boolean chooserOpen=false;
//tile[][] tiles=new tile[102][102];
PImage bg;
PImage pmap;
PImage texmap;
PImage lightsMap;
PImage bluepic;
PImage greenpic;
PImage redpic;
int pixelSize=2;
PGraphics pg;
int sDetail = 35;  // Sphere detail setting
float rotationX = 0;
float rotationY = 0;
float velocityX = 0;
float velocityY = 0;
float globeRadius = 450;
float pushBack = 0;
float[] cx, cz, sphereX, sphereY, sphereZ;
float sinLUT[];
float cosLUT[];
float SINCOS_PRECISION = 0.5;
int SINCOS_LENGTH = int(360.0 / SINCOS_PRECISION);
int scaledNum;
int coolnessCt=0;
int total=0;
float avg=0;
int timerCtr=0;
boolean showStars=true;
boolean showText=true;
boolean showCoolness=false;
boolean showCoolnessSuper=true;
float totalFR=0;
float avgFR=0;


void setup()
{
  size(screen.width-5, screen.height-50,OPENGL);
//  setResizeable(true);
  minim = new Minim(this);
  lightsMap=loadImage("worldNightYellow.jpg");
  redpic=loadImage("world32kRED.jpg");
    redpic.filter(ERODE); 
    redpic.blend(lightsMap,0,0,1350,675,0,0,1350,675,ADD);
  bluepic=loadImage("world32kBLUE.jpg");
    bluepic.filter(ERODE); 
    bluepic.blend(lightsMap,0,0,1350,675,0,0,1350,675,ADD);
  greenpic=loadImage("world32kGREEN.jpg");
    greenpic.filter(ERODE); 
    greenpic.blend(lightsMap,0,0,1350,675,0,0,1350,675,ADD);
  texmap=loadImage("world32kGRAYER.jpg");
    texmap.filter(ERODE); 
    texmap.blend(lightsMap,0,0,1350,675,0,0,1350,675,ADD);
  pmap=texmap;
  
  initializeSphere(sDetail);
  pg = createGraphics(160, 90, P2D);
  colorMode(HSB);
  noSmooth();
  
  JFileChooser chooser = new JFileChooser();
  chooser.setFileFilter(chooser.getAcceptAllFileFilter());
  int returnVal = chooser.showOpenDialog(null);
  if (returnVal == JFileChooser.APPROVE_OPTION) {  
    println("You chose to open this file: " + chooser.getSelectedFile().getName());
    fSong=(chooser.getSelectedFile());
  }
  
  jingle = minim.loadFile(fSong+"", 2048);
  jingle.loop();
  // create an FFT object that has a time-domain buffer the same size as jingle's sample buffer
  // note that this needs to be a power of two and that it means the size of the spectrum
  // will be 512. see the online tutorial for more info.
  fft = new FFT(jingle.bufferSize(), jingle.sampleRate());
  textFont(createFont("SanSerif", 12));
//  textFont(createFont("AgencyFB-Bold",14));
  windowName = "None";
  z=0;
  
}

void draw()
{
  texmap=pmap;
  background(0);
  frameRate(60);
  stroke(255);
  
  //rotateY(map(mouseX, 0, width, 0, PI));
  //rotateZ(map(mouseY, 0, height, 0, -PI));
  // perform a forward FFT on the samples in jingle's left buffer
  // note that if jingle were a MONO file, this would be the same as using jingle.right or jingle.left
  fft.forward(jingle.mix);

  float fov = PI/3.0;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(fov, float(width)/float(height), 
  cameraZ/10.0, cameraZ*10.0);
  lights();
//  max=0;
  
  if(showCoolness&&showCoolnessSuper){ //begin showing coolness
    
   float  xc = 25;

  // Enable this to control the speed of animation regardless of CPU power
  // int timeDisplacement = millis()/30;

  // This runs plasma as fast as your computer can handle
  int timeDisplacement = frameCount;

  // No need to do this math for every pixel
  float calculation1 = sin( radians(timeDisplacement * 0.61655617));
  float calculation2 = sin( radians(timeDisplacement * -3.6352262));
  
  // Output into a buffered image for reuse
  pg.beginDraw();
  pg.loadPixels();

  // Plasma algorithm
  for (int x = 0; x < pg.width; x++, xc += pixelSize)
  {
    float  yc    = 25;
    float s1 = 128 + 128 * sin(radians(xc) * calculation1 );

    for (int y = 0; y < pg.height; y++, yc += pixelSize)
    {
      float s2 = 128 + 128 * sin(radians(yc) * calculation2 );
      float s3 = 128 + 128 * sin(radians((xc + yc + timeDisplacement * 5) / 2));  
      float s  = (s1+ s2 + s3) / 3;
      pg.pixels[x+y*pg.width] = color(s, 255 - s / 2.0, 255);
    }
  }   
  pg.updatePixels();
  pg.endDraw();

  // display the results
  image(pg,0,0,width,height); 
  coolnessCt++;
  if(coolnessCt>30)
    showCoolness=false;  
  }  //end of show coolness
  if(showStars){
    for(int i=fft.specSize(); i>0; i-=10){
        rect(i+1,(height-fft.getBand(i)*4)-height/2,1.5,1.5);
        fill(255);
    }  
    for(int i=0; i<fft.specSize(); i+=10){
        rect((width-i),(height-fft.getBand(i)*4)-height/2,1.5,1.5);
        fill(255);
    }
  }  
  for(int i=0; i<fft.specSize()-10; i+=10)
  {
        if(fft.getBand(i)>max){
           max=(int)fft.getBand(i); 
        }
        if(fft.getBand(i)>overallMax){
           overallMax=(int)fft.getBand(i); 
        }
        total+=(int)fft.getBand(i);  
//        velocityX+=(fft.getBand(i)*4)*0.00001;
//        velocityY-=(fft.getBand(i)*4)*0.00001;
        
	//line(i,height, i, height-fft.getBand(i)*4);    
  }  
//    System.out.println("x,y,z: "+i+" "+(height-fft.getBand(i)*4)+" "+z);
    // draw the line for frequency band i, scaling it by 4 so we can see it a bit better
    //line(i, height, i, height - fft.getBand(i)*4);
  
  
  
  
//  fill(255);
  // keep us informed about the window being used
//  text("The window being used is: " + windowName, 5, 20);
  avg=total/(fft.specSize()/10);
  totalFR+=frameRate;
  avgFR=totalFR/timerCtr;
  if(showText){
  text("The maximum frequency component amplitude is: "+max+" and the overall maximum is: "+overallMax, 5,40);
  text("The average frequency component amplitude is: "+avg, 5,20);
  text("The plasma background option is on: "+showCoolnessSuper, 5,60);
  text("The current time in the song is: "+floor((timerCtr*avgFR*2.13/1000)/60)+":"+(timerCtr*avgFR*2.28/1000)%60, 5,80);
  }  
  z-=0.5;
  velocityX+=(max)*(overallMax/100000);
  velocityY-=(max)*(overallMax/100000);
//  velocityX+=(max)*0.01;
//  velocityY-=(max)*0.01;
  if(((max/(overallMax+100))*100)<10){
    texmap=pmap;
  }
  else if(((max/(overallMax+100))*100)<20){
    texmap=bluepic;
  }
  else if(((max/(overallMax+100))*100)<30){
    texmap=greenpic;
  }
  else{
    texmap=redpic;
  }  
  if((avg>=4.5)){
    showCoolness=true;
    coolnessCt=0; 
  }  
  max=0.00001;
  total=0;
  renderGlobe();
  timerCtr++;
//  rotateY(map(mouseX, 0, width, 0, PI));
//  rotateX(map(mouseY, 0, height, 0, -PI));
   
}

void keyReleased()
{
  if ( key == 'w' ) 
  {
    // a Hamming window can be used to shape the sample buffer that is passed to the FFT
    // this can reduce the amount of noise in the spectrum
    fft.window(FFT.HAMMING);
    windowName = "Hamming";
  }
  
  if ( key == 'e' ) 
  {
    fft.window(FFT.NONE);
    windowName = "None";
  }
}

void stop()
{
  // always close Minim audio classes when you finish with them
  jingle.close();
  minim.stop();
  
  super.stop();
}

void renderGlobe() {
//    scaledNum=((1/(700/num))*100);
    pushMatrix();
    translate(width/2.0, height/2.0, pushBack);
    pushMatrix();
    noFill();
    stroke(255,200);
    strokeWeight(2);
    smooth();
    popMatrix();
    lights();    
    pushMatrix();
    rotateX( radians(-rotationX) );  
    rotateY( radians(270 - rotationY) );
    fill(200);
    noStroke();
    textureMode(IMAGE);
    colorMode(HSB);
//    //color c=color((float)(scaledNum*2.25),(float)(scaledNum*2.25),(float)(scaledNum*2.25));
////    tint(c);
    texturedSphere(globeRadius, texmap);
    popMatrix();  
    popMatrix();
    rotationX += velocityX;
    rotationY += velocityY;
    velocityX *= 0.95;
    velocityY *= 0.95;
    
  
  // Implements mouse control (interaction will be inverse when sphere is  upside down)
  if(mousePressed){
      showStars=!showStars;
//    velocityX += (mouseY-pmouseY) * 0.01;
//    velocityY -= (mouseX-pmouseX) * 0.01;
  } 
}

void initializeSphere(int res)
{
  sinLUT = new float[SINCOS_LENGTH];
  cosLUT = new float[SINCOS_LENGTH];

  for (int i = 0; i < SINCOS_LENGTH; i++) {
    sinLUT[i] = (float) Math.sin(i * DEG_TO_RAD * SINCOS_PRECISION);
    cosLUT[i] = (float) Math.cos(i * DEG_TO_RAD * SINCOS_PRECISION);
  }

  float delta = (float)SINCOS_LENGTH/res;
  float[] cx = new float[res];
  float[] cz = new float[res];
  
  // Calc unit circle in XZ plane
  for (int i = 0; i < res; i++) {
    cx[i] = -cosLUT[(int) (i*delta) % SINCOS_LENGTH];
    cz[i] = sinLUT[(int) (i*delta) % SINCOS_LENGTH];
  }
  
  // Computing vertexlist vertexlist starts at south pole
  int vertCount = res * (res-1) + 2;
  int currVert = 0;
  
  // Re-init arrays to store vertices
  sphereX = new float[vertCount];
  sphereY = new float[vertCount];
  sphereZ = new float[vertCount];
  float angle_step = (SINCOS_LENGTH*0.5f)/res;
  float angle = angle_step;
  
  // Step along Y axis
  for (int i = 1; i < res; i++) {
    float curradius = sinLUT[(int) angle % SINCOS_LENGTH];
    float currY = -cosLUT[(int) angle % SINCOS_LENGTH];
    for (int j = 0; j < res; j++) {
      sphereX[currVert] = cx[j] * curradius;
      sphereY[currVert] = currY;
      sphereZ[currVert++] = cz[j] * curradius;
    }
    angle += angle_step;
  }
  sDetail = res;
}

// Generic routine to draw textured sphere
void texturedSphere(float r, PImage t) 
{
  int v1,v11,v2;
  r = (r + 240 ) * 0.33;
  beginShape(TRIANGLE_STRIP);
  texture(t);
  float iu=(float)(t.width-1)/(sDetail);
  float iv=(float)(t.height-1)/(sDetail);
  float u=0,v=iv;
  for (int i = 0; i < sDetail; i++) {
    vertex(0, -r, 0,u,0);
    vertex(sphereX[i]*r, sphereY[i]*r, sphereZ[i]*r, u, v);
    u+=iu;
  }
  vertex(0, -r, 0,u,0);
  vertex(sphereX[0]*r, sphereY[0]*r, sphereZ[0]*r, u, v);
  endShape();   
  
  // Middle rings
  int voff = 0;
  for(int i = 2; i < sDetail; i++) {
    v1=v11=voff;
    voff += sDetail;
    v2=voff;
    u=0;
    beginShape(TRIANGLE_STRIP);
    texture(t);
    for (int j = 0; j < sDetail; j++) {
      vertex(sphereX[v1]*r, sphereY[v1]*r, sphereZ[v1++]*r, u, v);
      vertex(sphereX[v2]*r, sphereY[v2]*r, sphereZ[v2++]*r, u, v+iv);
      u+=iu;
    }
  
    // Close each ring
    v1=v11;
    v2=voff;
    vertex(sphereX[v1]*r, sphereY[v1]*r, sphereZ[v1]*r, u, v);
    vertex(sphereX[v2]*r, sphereY[v2]*r, sphereZ[v2]*r, u, v+iv);
    endShape();
    v+=iv;
  }
  u=0;
  
  // Add the northern cap
  beginShape(TRIANGLE_STRIP);
  texture(t);
  for (int i = 0; i < sDetail; i++) {
    v2 = voff + i;
    vertex(sphereX[v2]*r, sphereY[v2]*r, sphereZ[v2]*r, u, v);
    vertex(0, r, 0,u,v+iv);    
    u+=iu;
  }
  vertex(sphereX[voff]*r, sphereY[voff]*r, sphereZ[voff]*r, u, v);
  endShape();
  
}

void changeGlobeColor(float col){
	col=abs(col);
        colorMode(HSB);
	color c=color(col,col,col);
//	texmap.tint(color(col,col,col));
}
void keyPressed(){
if(key=='s')
  showStars=!showStars;
if(key=='d')
  showText=!showText;
if(key=='c')
  showCoolnessSuper=!showCoolnessSuper;
}  
