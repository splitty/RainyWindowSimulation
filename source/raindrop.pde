//Luke Labenski
//the following program creates a simulation of looking out the car window as a kid
//on a rainy drive through the country
//Creative programming 2 simulation/Final project
//rain noise from - https://www.youtube.com/watch?v=WpxJJFcWM8s

//regquires processing sound library
import processing.sound.*;

float resolution = 260; // how many points in the circle
float x = 1;
float y = 1;
//float prevX;
//float prevY;

//importing said sound file for rain
SoundFile file;
String audioname = "rain.wav";
String path;

float tChange = .02; // how quick time flies

float nVal; // noise value

int nb=2000; // number of drops
int maxBGDrops =2000;//max raindrops in background
int minBGDrops=600;//min raindrops in bg
int h, h1;//height of drops
BGDrop[] BGdrops=new BGDrop[maxBGDrops];//arraylist of all drops on screeen
//loading images for scene purposes
PImage img;
PImage back;
PImage rail;
PImage railFollow;
int railCount = 0;
int railCount2 = width;
//arraylist for holding drops on window
ArrayList<Drop> droplets = new ArrayList<Drop>();
//landscape background layers
Landscape[] layers = new Landscape[7];
//pgraphics window for displaying drops on window
PGraphics pg;
PGraphics railg;
//drop on window class
class Drop {
  //basically this just creates the droplet object
  float rad, nVal, nInt, nAmp, startH, startW, dropSpeed, dropSlide, t;
  Streak streak;
  Drop() {
    this.startH = -20;//starting Y axis
    this.startW = random(20, width+100);//starting X axxis
    //speed at which droplet descends
    this.dropSpeed = random(0.01, 0.5);
    this.dropSlide = random(-0.5, -0.05);
    //starting time
    this.t = 0;
    //radius of droplet, how big ya want it?
    this.rad = random(10, 20);
    //add the streak to follow droplet down
    this.streak = new Streak(startW, startH);
  }


  ///here's where we actually display the droplet on screen
  void display() {
    //we draw everything to a pgraphics window to display it infront of BG
    pg.beginDraw();
    pg.tint(255, 20);
    pg.pushMatrix();
    pg.translate(this.startW, this.startH);
    float nInt = 0.473; // noise intensity
    float nAmp = 0.19; // noise amplitude
    fill(160, 20);
    pg.beginShape();
    for (float a=0; a<=TWO_PI; a+=TWO_PI/resolution) {
      //a = random(0, TWO_PI);
      nVal = map(noise( cos(a)*nInt+1, sin(a)*nInt+1, t ), 0.0, 1.0, nAmp, 1.0); // map noise value to match the amplitude

      x = cos(a)*rad *nVal;
      y = sin(a)*rad *nVal;

      pg.vertex(x, y);
    }
    pg.endShape(CLOSE);


    pg.popMatrix();
    pg.endDraw();
    this.dropSpeed = random(0, 2);
    this.dropSlide = random(-1.4, 0); 
    println(dropSpeed);
    println(dropSlide);
    this.startH += this.dropSpeed;
    this.startW += this.dropSlide;

    this.streak.updateLine(this.dropSpeed, this.dropSlide);

    this.t += tChange;

    if (this.startW < -20) {
      this.startW = random(20, width);
      this.startH = -20;
      this.t = 0;
      //this.streak = new Streak(startW, startH);
    }
    if (this.startH > height+20) {
      this.startH = -10;
      this.startW = random(20, width);
      this.t = 0;
      //this.streak = new Streak(startW, startH);
    }
  }
}
//streak class for following the droplet on window
class Streak {
  int count;
  ArrayList<PVector> points = new ArrayList<PVector>();

  Streak(float x, float y) {
    points.add(new PVector(x, y));
    this.count = 0;
  }
  //created the trail behind the droplet
  void updateLine(float x, float y) {
    pg.beginDraw();
    pg.tint(255, 0);
    this.count++;
    points.add(new PVector(x, y));
    pg.fill(255, 10);
    pg.stroke(150, 0);
    pg.line(x, y, points.get(count).x, points.get(count).y);
    pg.endDraw();
  }
}
//original idea and concept from
//https://www.openprocessing.org/sketch/4138/
class BGDrop {
  int x, y, d, z, onde, d1, oldY;
  float acc;
  boolean s;
  //background raindroplet size and class objects
  BGDrop(int x, int y, int z, int d) {
    this.x=x;
    this.y=y;
    this.d=d;
    this.z=z;
    onde=0;
    d1=d;
    acc=0;
    oldY=y;
  }
  //forcing the droplet towards the ground
  void fall() {
    if (y>0)acc+=0.4;
    stroke(200, 200, 200, map(z, 0, height, 0, 255));
    strokeWeight(2);
    if (y<z) {
      y=int(y+8+acc);
      line(x, oldY, x, y);
      oldY=y;
    }
    //splash that bish when it hits the bottom of the screen
    else {
      noFill();
      stroke(175, 175, 175, 175-map(onde, 0, d, 0, 255));
      strokeWeight(map(onde, 0, d, 0, 4));
      d=d1+(y-height)*4;
      ellipse(x, y, onde/5, onde/20);
      onde=onde+7;
      if (onde>d) {
        onde=0;
        acc=0;
        x=int(random(width));
        y=-int(random(height*2));
        oldY=y;
        d=d1;
      }
    }
  }
}

void setup() {
  //setting screen size to 1080p monitor
  size(1920, 1080);
  noiseDetail(8);
  smooth();
  //fullscreen();
  //adding our 8 droplets
  droplets.add(new Drop());
  droplets.add(new Drop());
  droplets.add(new Drop());
  droplets.add(new Drop());
  droplets.add(new Drop());
  droplets.add(new Drop());
  droplets.add(new Drop());
  //adding our background droplets
  h = abs(height/3);
  h1=h*2;
  for (int i = 0; i < maxBGDrops; i++) {
    BGdrops[i] = new BGDrop(int(random(width)), -int(random(height*2)), (int)map((h+int(random(h1))), height*.35, height, 0, height), 1280);
  }
  //adding our layers for parallax scrolling
  for (int i = 0; i < layers.length; i++) {

    int j = int(map(i, 0, layers.length, height/2.5, height));
    int k = int(map(i, 0, layers.length, 0, 100));
    int l = int(map(i, 0, layers.length, .5, 25));

    layers[i] = new Landscape(j, k, l);
  }
  for (int i = 0; i < 9999; i++) {
    for (int i2 = 0; i2 < layers.length; i2++) {

      float j = map(i2, 0, layers.length, .1, 10);

      layers[i2].update(j);
    }
  }
  //create pgraphics window  to put droplets into
  pg  = createGraphics(width, height);
  railg  = createGraphics(width, height);
  //create railings and load sound/window front
  rail = loadImage("railBack.png");
  railFollow = loadImage("railBack.png");
  img = loadImage("carwindow.png");
  //back = loadImage("back.jpg");
  //audio cues
  path = sketchPath(audioname);
  file = new SoundFile(this, path);
  file.play();
}

void draw() {
  //image(back,0,0);
  //draw the background behind everything
  //i put this into a pgraphics window so it wouldnt block any drops taht are continuing
  railg.beginDraw();
  railg.background(150);
  railg.endDraw();
  image(railg, 0, 0);
  //displaying layers in background
  for (int i = 0; i < layers.length; i++) {

    float j = map(i, 0, layers.length, .5, 10);

    layers[i].update(j);
    if (i != 0) {
      layers[i].display();
    }
  }

  strokeWeight(5);
  for (int i = 0; i < height; i+=5) {
    float j = map(i, 0, height, 0, 100);
    stroke(255, j);
    line(0, i, width, i);
  }
  fill(0, 140);
  rect(0, 0, width, height);

  for (int i=0; i<nb; i++) {
    BGdrops[i].fall();
  }

  //background(255,40);
  for (int i = 0; i < droplets.size(); i++) {
    //println(droplets.get(i).startW);
    droplets.get(i).display();
  }
  image(railFollow, railCount, 0);
  image(rail, railCount2, 0);
  pg.beginDraw(); 
  pg.endDraw();
  image(pg, 0, 0);
  if (railCount <=-width*2) {
    railCount = width;
  } else {
    railCount+=-90;
  }
  if (railCount2 <=-width*2) {
    railCount2 = width*2;
  } else {
    railCount2+=-90;
  }
  //filter(BLUR,1);
  image(img, 0, 0);
}





//infinite scrolling landscape adapted from
//https://www.openprocessing.org/sketch/194607/
class Horizon {
  float x;
  float y;
  float offsety, foffsety;  
  float storedoffset;
  Horizon(float tx, int ty, int n) {
    offsety= ty;
    storedoffset = offsety;
    x = tx;
    y = offsety + random(-5, 5);
    foffsety = offsety;
  }

  void update(float ypos, float speed, float rr) {
    offsety = storedoffset+ypos; 
    foffsety += (offsety - foffsety) * .01;
    x-=speed;
    if (x <= 0) {
      x = width;
      y = foffsety+random(-rr, rr);
    }
  }

  void display() {
    ellipse(x, y, 10, 10);
  }
}
class Landscape {
  Horizon[] points = new Horizon[1000];
  int left, right;
  int timer = 0;
  float yy;
  float shade;
  float res;
  Landscape(int b, float s, float r) {
    res = r;
    shade = s;
    for (int i = 0; i < points.length; i++) {
      float j = map(i, 0, points.length, 0, width);
      points[i] = new Horizon(j, b, i);
    }
  }

  void update(float speedx) {
    timer-=3;
    if (timer < 0) {
      yy = random(-75, 75);
      timer = int(random(25, 200));
    }
    for (int i = 0; i < points.length; i++) {
      points[i].update(yy, speedx, res); 
      // points[i].display();
    }
  }
  void display() {
    pushMatrix();
    scale(1.5, 1);
    translate((-width/points.length)*2, 0);
    noStroke();
    fill(75-shade, 165-shade, 70-shade);
    beginShape();
    for (int i = 0; i < points.length; i++) {  
      vertex(points[i].x, points[i].y); 
      if (points[i].x >= width-(width/points.length)-1) {
        vertex(width, height*2); 
        vertex(0, height*2);
      }
    }
    vertex(points[0].x, points[0].y);
    endShape();
    popMatrix();
  }
}
