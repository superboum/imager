/* ~~~~~~ CONFIG ~~~~~~~ */
String PICTURE_FOLDER = "/home/qdufour/sketchbook/imager/img";
int MIN_PIC_PER_PAGE = 3;
int MAX_PIC_PER_PAGE = 6;
int TRIES = 200; // How many tries to replace a picture overlapping another one
int MIN_PIC_WIDTH = 295; // multiple de grid_size
int MAX_PIC_WIDTH = 1180; // multiple de grid_size

int GRID_SIZE = 59; // 59 --- en pixel
// configurer la size en dessous dans size();
/* ~~~ END OF CONFIG ~~~ */

int x = 0;
ArrayList<String> pics;

void setup() {
  size(2125, 2600);
  //size(510,623);
  pics = getPictureList(PICTURE_FOLDER);
}

void draw() {
  if (pics.size() > MAX_PIC_PER_PAGE) {
    println("=== frame "+x+" ===");
    displayPics();
    x++;
  } else {
    exit();
  }
  
  // Saves each frame as screen-0001.tif, screen-0002.tif, etc.
  saveFrame("line-######.png"); 
}

ArrayList<String> getPictureList(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    ArrayList<String> res = new ArrayList<String>();
    for (String n : names) {
      res.add(dir + "/" + n);
    }
    return res;
  } else {
    return null;
  }
}

ArrayList<PImage> pickPictures(ArrayList<String> list, int minSelectedPics, int maxSelectedPics, int minWidthPic, int maxWidthPic) {
  ArrayList<PImage> res = new ArrayList<PImage>();
  int number_to_pick = int(random(minSelectedPics,maxSelectedPics+1));
  
  for (int i = 0; i < number_to_pick; i++) {
    int pos = int(random(list.size()));
    String selected = list.get(pos);
    list.remove(selected);

    PImage img = loadImage(selected);
    int newWidth = int(random(minWidthPic / GRID_SIZE, maxWidthPic / GRID_SIZE)) * GRID_SIZE;
    img.resize(newWidth,0);
    res.add(img);
  }
  
  return res;
}

public class Occupation {
  boolean[][] data;
  
  public Occupation(int w, int h) {
    data = new boolean[h][w];
    for (int j = 0; j < h; j++) {
      for (int i = 0; i < w; i++) {
        data[j][i] = false;
      }
    }
  }
  
  public void addOccupation(int x1, int y1, int x2, int y2) {
    for (int b = y1; b < y2; b++) {
      for (int a = x1; a < x2; a++) {
        data[b][a] = true;
      }
    }
  }
  
  public boolean isOccupied(int x1, int y1, int x2, int y2) {
    for (int b = y1; b < y2; b++) {
      for (int a = x1; a < x2; a++) {
        if (data[b][a]) return true;
      }
    }
    return false;
  }
}

void displayPics() {
  ArrayList<PImage> lpics = pickPictures(pics, MIN_PIC_PER_PAGE, MAX_PIC_PER_PAGE, MIN_PIC_WIDTH, MAX_PIC_WIDTH);
  println(lpics.size() + " pics selected");
  boolean ok = true;
  int mega_counter = 0;

  do {
    ok = true;
    background(255);
    Occupation o = new Occupation(width, height);
    
    for (PImage pic : lpics) {
      int posx, posy, counter = 0;
      do {
        counter++;
        posx = int(random(0, (width - pic.width) / GRID_SIZE)) * GRID_SIZE;
        posy = int(random(0, (height - pic.height) / GRID_SIZE)) * GRID_SIZE;
        
        //println(posx, posy, posx+pic.width+GRID_SIZE, posy+pic.height+GRID_SIZE);
        if (counter == TRIES-1) { 
          println("Failed to find a correct position for this picture, sorry...");
          ok = false;
        }
      } while(o.isOccupied(posx, posy, posx+pic.width+GRID_SIZE, posy+pic.height+GRID_SIZE) && counter < TRIES && ok);
      if (!ok) break;
      
      o.addOccupation(posx, posy, posx+pic.width+GRID_SIZE, posy+pic.height+GRID_SIZE);          
      image(pic,posx,posy); 
    }
  } while(!ok && mega_counter++ < TRIES);
}