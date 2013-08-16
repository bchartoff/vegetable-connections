float step = .003;    // Size of each step along the path
float pct = 2.0;      // Percentage traveled (0.0 to 1.0)
float exponent; //determines curve of connecting lines
int w = 1200; //width of frame
int h = 700; //height of frame
float[] vegColor = {35,55,255}; //base color for vegetable dots in rgb
float[] connectColor = {255,0,0}; //base color for connecting lines in rgb
int numConnects = 6; //number of connection lines, note: if changed to more than 6 csv file must be expanded
int numVeg = 106; //total number of vegetables
int numRows = 7; //number of rows of vegetables
int numColumns = 15; // number of columns of vegetables, note: rows x columns >= numVeg in order to display all veg
float vegRad = 30; // radius of vegetable dots
float trans;
String[] nameList = new String[numVeg];
Vegetable[] vegList = new Vegetable[numVeg];
int index = -1;

//String[][] testcsv = {{"A", "5", "2", "C", "3", "B"},{"B","2","5","A","1","C"},{"C","10","2","A","4","B"}};
String csv[][] = new String[numVeg][(numConnects*2)+2];

void setup() {
    frameRate(78);

String lines[] = loadStrings("connections.csv");
//print(lines[0]);
//parse values into 2d array
for (int i=0; i < numVeg; i++) {
  String [] temp = new String [(numConnects*2)+2];
  temp= split(lines[i], ',');
  for (int j=0; j < (numConnects*2)+2; j++){
   csv[i][j]=temp[j];
  }
}
  size(w,h);
  noStroke();


  //generate list of veg names
  int i = 0;
  for (String[] row : csv){
    nameList[i] = row[0];
    i++;
  }
  
  //construct list of Vegetables
    int j = 0;
  for (String[] row : csv){
    String name = row[0];
    float transparency = float(row[1])/3;
    float xpos = indexToXCoord(j);
    float ypos = indexToYCoord(j);
    //construct list of connections within each vegetable
    Connect[] carray = new Connect[numConnects];
    float[] ccolarray = new float[numConnects];
    for(int m = 2 ; m <= (numConnects*2); m= m + 2){
      ccolarray[(m-2)/2] = float(row[m]);
    }
    ConnectColor[] adjustedcolors = colorAdjust(ccolarray);
    float startx,starty,endx,endy,th,tr;
    for(int n = 3 ; n <= (numConnects*2)+1; n= n + 2){
      for (int k = 0; k<numVeg; k++){
        if(row[n].equals("0")){
          startx = xpos;
          starty = ypos;
          endx = xpos;
          endy = ypos;
          th = 0;
          tr = 0;
          carray[(n-3)/2] = new Connect(startx, starty, endx, endy, th, tr);
        }
        if(row[n].equals(nameList[k])){
          startx = xpos;
          starty = ypos;
          endx = indexToXCoord(k);
          endy = indexToYCoord(k);
          th = adjustedcolors[(n-3)/2].getThickness();
          tr = adjustedcolors[(n-3)/2].getTransparency();
          carray[(n-3)/2] = new Connect(startx, starty, endx, endy, th, tr);
          break;
        }
      }
    }
    vegList[j] = new Vegetable(transparency, xpos, ypos, name, carray);
    j++;
  }
}

void draw() {
    pct += step;
      if (pct<1.0) {
//        print(index);
        exponent = 1.3;
        for(int i = 0; i< numConnects; i++){
          Connect connect = vegList[index].getConnectArray()[i];
          connect.movedot();
          connect.printdot();
         /* trans = 1;
          for(float step = .1; step <= .9; step = step+.1){
            if (pct > step && pct < step +.1){
              fill(255,255,255,trans);
              noStroke();
             // ellipse(connect.getx(),connect.gety(), rad, rad);
              ellipse(vegList[index].getx(),vegList[index].gety(), vegList[index].gettransparency(), vegList[index].gettransparency());
            }
            trans = trans+2;
          }
          if (pct >.95){
            fill(255,0,0,connect.getth()+5);
            noStroke();
           // ellipse(connect.getx(),connect.gety(), rad, rad);
           // ellipse(vegList[index].getx(),vegList[index].gety(), rad, rad);
          }
          */
          exponent = exponent + .2;
        }
      }
}

void mousePressed() {
  fill(255, 300);
  
  rect(0, 0, w, h);
  setup();
  index = mousePosToIndex(mouseX, mouseY);
  if(index >= 0){
    pct = 0.0;
  }
  else{
    pct = 10;
  }
}

class Vegetable{
   float transparency;
   float xpos;
   float ypos;
   String name;
   Connect[] connections = new Connect[numConnects];
   
   Vegetable(){
   }
   
   Vegetable(float tr, float xp, float yp, String n, Connect[] carray){
      xpos = xp;
      ypos = yp;
      name = n;
      fill(vegColor[0], vegColor[1], vegColor[2],tr);
      stroke(vegColor[0],vegColor[1], vegColor[2],100);
      ellipse(xpos, ypos,3+tr/20, 3+tr/20);
      fill(0,255);
      if(3+tr/20 > 60 ){
        text(name,xp-name.length()*2.6, yp-48);
      }
      else if(50 < 3+tr/20){
        text(name,xp-name.length()*2.6, yp-38);
      }
      else{
      text(name,xp-name.length()*2.6, yp-23);
      }
      connections = carray;
   }
   
   Connect[] getConnectArray(){
     return connections;
   }
   
   float gettransparency(){
     return transparency;
   }
   float getx(){
      return xpos;
   }
   
   float gety(){
     return ypos;
   }
   
   String getname(){
     return name;
   }     
}
   
class Connect{
  float endX, endY, rad;
  float re, gr, bl, tr, th;
  float x1;
  float y1;
  float x2;
  float y2;
  float beginX;
  float beginY;
  float distX;
  float distY;
  float trans;
  float thick;

  
  Connect(){
  }
  
  Connect(float bx, float by, float ex, float ey, float th, float tr){
    beginX = bx;
    beginY = by;
    x1 = beginX;
    y1 = beginY;
    endX = ex;
    endY = ey;
    trans = tr;
    thick = th;
    distX = endX-beginX;
    distY = endY-beginY;
  }
  
  void movedot(){
    x2 = x1+pct*distX;
    y2 = y1+(pow(pct, exponent) * distY);
  }
  
  void printdot(){
    smooth();
    fill(connectColor[0], connectColor[1], connectColor[2],trans*8);
    stroke(connectColor[0],connectColor[1], connectColor[2],trans*8);
    ellipse(x2, y2, thick, thick);
  }
  float getx(){
    return endX;
  }
  float gety(){
    return endY;
  }
  float getth(){
    return thick;
  }
  
}

class ConnectColor{
  float thickness;
  float transparency;
  
  ConnectColor(){
  }
  
  ConnectColor(float th, float tr){
    thickness = th;
    transparency = tr;
  }
  
  float getThickness(){
    return this.thickness;
  }
  
  float getTransparency(){
    return this.transparency;
  }
}
  

float indexToXCoord(int index){
  return ((index%numColumns)*(w/numColumns)+(w/numColumns)*.5);
}

float indexToYCoord(int index){
  int adjust =0;
  if(index%2==0){
    adjust = 0;
  }
  if(index%2==1){
    adjust = -10;
  }
  return(ceil(index/numColumns)*(h/numRows)+(h/numRows)*.6)+adjust;
}

int mousePosToIndex(float x, float y){
  int i = 0;
  for(Vegetable v: vegList){
    if(dist(x,y,v.getx(),v.gety()) <= vegRad){
      break;
    }
    else{
      i++;
    }
  }
  if(i < 106){
    return i;
  }
  else{
    return -1;
  }
    
}
ConnectColor[] colorAdjust(float[] values){
  float sum = 0;
  for(float v : values){
    sum = sum + v;
  }
  
  ConnectColor[] ccarray = new ConnectColor[numConnects];
  
  int i = 0;
  float tr, th;
  //float[] svalues = reverse(values));
  float thickness = numConnects+1;
  for(float v : values){
    if(v == 0){
      tr = 0;
      th = 0;
    }
    else{
      tr = 20*v/sum;
      th = thickness;
      ConnectColor cc = new ConnectColor(th,tr);
      ccarray[i] = cc;
      thickness--;
      i++;
    }
  }
  return ccarray;
}

