/*

   Sandstorm Pixel Sort by AKTracer
   based on ASDF Pixel Sort by Kim Asendorf
   Uses random start and end limits in each row wise or column wise traversal, craeting a sandstorm effect
   https://instagram.com/tay.glitch
   https://instagram.com/aktracer
   
 Instructions:
 * Put file name and file extension
 * run, click on image multiple times
 * each click separately saves a new file
 * press any key or close the window to exit
 
 
Tips:
 * Even if you don't change any settings, every new session will still produce unique results
 * Set direction to vertical or horizontal. 
 * set threshold value for mild or strong effect
 * Toggle reverseMode to true or false if you want the pixels to go in the opposite direction
 * set mode to 0,1 or 2 to target only the white/midtone/black pixels
 * If you want the pixels to go in more than 1 direction, feed the previous result as input, change the direction settings and apply, you can build up complex effects this way
 
 */

String imgFileName = "tay"; //If this doesnt work, try to rename your image in your OS
String fileType = "jpg"; //Case sensitive "JPG" and "jpg" are not the same, this tends to cause problems, please verify the case in your file explorer
PImage img; 

int direction = 1; //0 hori 1 vertical
boolean reverseMode = true; //reverse the direction of sort

int mode = 2; 
/* MODE
mode 1 moves inversely to set direction
0 ~ black sort - leaves black pixels alone and sorts the others
1 ~ brightness sort - sorts bright pixels and leaves alone darks, affected brightness depends on the threshold
2 ~ white sort - leaves alone white pixels and sorts the others
*/

int blackValue = -50000000; //mode 0 - pulls whites bigger the stronger
int brightnessValue = 170; //mode 1 - pulls mids, smaller the stronger
int whiteValue = -8000000; //mode 2 - pulls blacks, smaller the stronger

/****    THRESHOLD VALUES    ****

 if you are doing a black sort, only blackValue matters 
 for white sort only whitevalue matters, and so on

Subtler threshold values are often equally rewarding, stronger values give more variation
 
*  blackValue: 
default: -16000000, . 
sandstorm mode: -900 Million
retouch mode: -8 Million, -5 Million would be even milder than that

*  brightnessValue
default: 160
sandstorm mode: -1
retouch mode: 200

*  whiteValue
default:-13000000
sandstorm mode: -1
retouch mode: -13 Million

*/


/*---------------------------------------*/

int loops = 1;
int row = 0; // no need to touch, gets overrided
int column = 0; // no need to touch, gets overrided

boolean saved = false;

void setup() {
  img = loadImage(imgFileName+"."+fileType);
  getDirection();
  // use only numbers (not variables) for the size() command, Processing 3
  size(600, 600);
  
  // load image onto surface - scale to the available width,height for display
  image(img, 0, 0, img.width, img.height);
}

void getDirection(){
  if (direction == 0){
    column = img.width;
    row = 0;
  }
  if (direction == 1){
    row = img.height;
    column = 0;
  }
}

int countNum = Math.round(random(9000));
 
void draw() {
   if(reverseMode){
     img.pixels = reverse(img.pixels); 
   }
   
  // loop through columns
  while(column < img.width-1) {
    println("Sorting Column " + column);
    img.loadPixels(); 
    sortColumn();
    column++;
    img.updatePixels();
  }
  
  // loop through rows
  while(row < img.height-1) {
    println("Sorting Row " + column);
    img.loadPixels(); 
    sortRow();
    row++;
    img.updatePixels();
  }

  //reverse it again
   if(reverseMode){
     img.pixels = reverse(img.pixels); 
   }
   
/*  
  if(rotation){
    rotate(rotateBack);
  }
*/

  // load updated image onto surface and scale to fit the display width,height
    image(img, 0, 0, img.width, img.height);
  
  if(!saved && frameCount >= loops) {
    
  // save img
    img.save(imgFileName+"_"+countNum+"_"+"mode_"+mode+".png");
    countNum++;
  
    saved = true;
    println("Saved "+frameCount+" Frame(s)");
    
    // exiting here can interrupt file save, wait for user to trigger exit
    println("Hii! Click to sort and resave, press any key to exit...new save goes to a new file");
  }
}

void keyPressed() {
  if(saved)
  {
    System.exit(0);
  }
}




void mouseClicked() {
  getDirection();
  if(reverseMode){
    img.pixels = reverse(img.pixels);
  }
  if(direction==0){
    while(row < img.height-1) {
      println("Sorting Row " + column);
      img.loadPixels(); 
      sortRow();
      row++;
      img.updatePixels();
    }
  }

  //if direction ==1 sortColumn
  if(direction==1){
    while(column < img.width-1) {
      println("Sorting Column " + column);
      img.loadPixels(); 
      sortColumn();
      column++;
      img.updatePixels();
    }
  }
  
  if(reverseMode){ ///put it back
    img.pixels = reverse(img.pixels);
  }
  
  // save img
    img.save(imgFileName+"_"+countNum+"_"+"mode_"+mode+".png");

  
    println("Yass! Saved and secured! -  IMG ID:"+countNum);
        countNum++;
    // exiting here can interrupt file save, wait for user to trigger exit
    println("click to save more or press any key to exit...");
}


int offsetFromLeft(){
  return Math.round(random(img.width)); //<--scope for fine tuning
}
int offsetFromRight(){
  return Math.round(random(img.width)); //<--scope for fine tuning
}
int offsetFromTop(){
  return Math.round(random(img.height)); //<--scope for fine tuning
}
int offsetFromBottom(){
  return Math.round(random(img.height)); //<--scope for fine tuning
}
//if the end offset is smaller than start offset, that row will be left unsorted
//the program will move to the next row

void sortRow() {
  // current row
  int y = row;
  
  // where to start sorting
  int startX = offsetFromLeft();
  int x = startX; // need a copy?
  
  // where to stop sorting
  int xend = 0; // to set xend limit we alter the getNextBlack function, all the getNext functions
  
  while(xend < img.width-1) {
    switch(mode) {
      case 0:
        x = getFirstNotBlackX(x, y);
        xend = getNextBlackX(x, y);
        break;
      case 1:
        x = getFirstBrightX(x, y);
        xend = getNextDarkX(x, y);
        break;
      case 2:
        x = getFirstNotWhiteX(x, y);
        xend = getNextWhiteX(x, y);
        break;
      default:
        break;
    }
    
    if(x < 0) break;
    int sortLength = xend-x; //for each new xend pixel, establish a new sort length
    if(sortLength<0) sortLength=0;
    color[] unsorted = new color[sortLength]; //new (color)pixel array of length sortlength
    color[] sorted = new color[sortLength]; //another copy of pixel array
    
    for(int i=0; i<sortLength; i++) { //between x and xend
      unsorted[i] = img.pixels[x + i + y * img.width]; //copy the image pixels into unsorted pixel array
    }
    
    sorted = sort(unsorted); //sort the array of pixels[i], the color contents are just a numeric value
    
    //row[0,0,x,i,i,i,i,xend,0,0]
    //--------|<-sortlength>|----
    for(int i=0; i<sortLength; i++) { 
      img.pixels[x + i + y * img.width] = sorted[i]; //y*img.width gives us the start of that row, 
                                                      //we offset that with starting point x 
                                                      //and we traverse every i offset from x 
                                                      //until the entire sortlength 
                                                      //of that single row is covered
                                                      //...I had a lot of trouble understanding this, but i got it!
    }
    
    x = xend+1;
  }
}


void sortColumn() {
  // current column
  int x = column;
  
  int startY = offsetFromTop();
  
  // where to start sorting
  int y = startY;
  
  // where to stop sorting
  int yend = 0; 
  
  while(yend < img.height- 1) {
    switch(mode) {
      case 0:
        y = getFirstNotBlackY(x, y);
        yend = getNextBlackY(x, y); //yend is returned as a y value on graph
                                    //the actual index calculation using this y
                                   // happens at the bottom of this function
        break;
      case 1:
        y = getFirstBrightY(x, y);
        yend = getNextDarkY(x, y);
        break;
      case 2:
        y = getFirstNotWhiteY(x, y);
        yend = getNextWhiteY(x, y);
        break;
      default:
        break;
    }
    
    if(y < 0) break;
    
    int sortLength = yend-y;
    
    color[] unsorted = new color[sortLength];
    color[] sorted = new color[sortLength];
    
    for(int i=0; i<sortLength; i++) {
      unsorted[i] = img.pixels[x + (y+i) * img.width];
    }
    
    sorted = sort(unsorted); 
    
    for(int i=0; i<sortLength; i++) {
      img.pixels[x + (y+i) * img.width] = sorted[i]; // the writing swap happens here< check if the pixel is equal to sorted[i]. if it is, dont treat it, leave it be
      //if the sorted[i] replaces pixel here, then treat pixel[i] with a treat function. could be channel shift, color swap, alpha swap, multiply, add etc.
    }
    
    y = yend+1;
  }
}


// black x
int getFirstNotBlackX(int x, int y) {
  while(img.pixels[x + y * img.width] < blackValue) {
    x++;
    if(x >= img.width) 
      return -1;
  }
  
  return x;
}

int getNextBlackX(int x, int y) {
  x++;

  int xLimit = img.width - offsetFromRight();
  while(x<xLimit && img.pixels[x + y * img.width] > blackValue) {
    x++;
    if(x >= img.width) 
      return img.width-1;
  }
  
  return x-1;//this gets saved in xend. (y*width)+i between x and xend lets us traverse row wise
  //because while loop negates and advances the counter to an extra 1 place ahead
}

// brightness x
int getFirstBrightX(int x, int y) {
  
  while(brightness(img.pixels[x + y * img.width]) < brightnessValue) {
    x++;
    if(x >= img.width)
      return -1;
  }
  
  return x;
}


int getNextDarkX(int _x, int _y) {
  int x = _x+1;
  int y = _y;
  
  int xLimit = img.width - offsetFromRight();
  while(x<xLimit && brightness(img.pixels[x + y * img.width]) > brightnessValue) {
    x++;
    if(x >= img.width) return img.width-1;
  }
  return x-1;
}

// white x
int getFirstNotWhiteX(int x, int y) {

  while(img.pixels[x + y * img.width] > whiteValue) {
    x++;
    if(x >= img.width) 
      return -1;
  }
  return x;
}

int getNextWhiteX(int x, int y) {
  x++;


  int xLimit = img.width - offsetFromRight();
  while(x<xLimit && img.pixels[x + y * img.width] < whiteValue) {
    x++;
    if(x >= img.width) 
      return img.width-1;
  }
  return x-1;
}


// black y
int getFirstNotBlackY(int x, int y) {

  if(y < img.height) {
    while(img.pixels[x + y * img.width] < blackValue) {
      y++;
      if(y >= img.height)
        return -1;
    }
  }
  
  return y;
}


//W<-------orking on it here <<
//x remains constant offset
//y increases and (y*width) gives us next row
//each row is advanced and an offset x is applied
//this is columnwise traversal
int getNextBlackY(int x, int y) {
  y++;
  int yLimit = img.height - offsetFromBottom();
  if(y < img.height) {
    while(y<yLimit && img.pixels[x + y * img.width] > blackValue) {
      y++;
      if(y >= img.height)
        return img.height-1;
    }
  }
  return y-1; //this gets saved into yend. 
  //(y+i)*width+x lets us traverse column wise as i increases
}

// brightness y
int getFirstBrightY(int x, int y) {

  if(y < img.height) {
    while(brightness(img.pixels[x + y * img.width]) < brightnessValue) {
      y++;
      if(y >= img.height)
        return -1;
    }
  }
  
  return y;
}

int getNextDarkY(int x, int y) {
  y++;
  int yLimit = offsetFromBottom();
  if(y < img.height) {
    while(y<yLimit && brightness(img.pixels[x + y * img.width]) > brightnessValue) {
      y++;
      if(y >= img.height)
        return img.height-1;
    }
  }
  return y-1;
}

// white y
int getFirstNotWhiteY(int x, int y) {

  if(y < img.height) {
    while(img.pixels[x + y * img.width] > whiteValue) {
      y++;
      if(y >= img.height)
        return -1;
    }
  }
  
  return y;
}

int getNextWhiteY(int x, int y) {
  y++;
  int yLimit = offsetFromBottom();
  if(y < img.height) {
    while(y<yLimit && img.pixels[x + y * img.width] < whiteValue) {
      y++;
      if(y >= img.height) 
        return img.height-1;
    }
  }
  
  return y-1;
}

/*
ideas:
reverse mode: ACCOMPLISHED
sort towards the left and bottom instead of up and right
rotate image 180 before sort then put it back
had to reverse the pixels of image before sorting, then reverse it back before save

learned reverse function
img.pixels = reverse(img.pixels); //don't need a PImage function for this array based function 
                                  //the ".pixels" itself is the array

two way sort:
pulls the image apart both ways
all even rows pull to right - one pass
all odd rows pull to left - second pass

currently not working - rotation
boolean rotation = false; 
float rotationAngle = PI/2; //angle in radians. "PI/2" =1.571 is 90 TWO_PI is 360
float rotateBack = TWO_PI-rotationAngle;

*/
