class tile{
int x;
int y;
public int z;

  tile(int x, int y, int z){
    this.x=x;
    this.y=y;
    this.z=z;
    beginShape();
     vertex(x,y,z);
     vertex(x+1,y,z);
     vertex(x+1,y,z-1);
     vertex(x,y,z-1);
    endShape();
  }
  void move(int x, int y, int z){
    
    translate(x,y,z);
    
  }
  
  void display(){
    beginShape();
     vertex(x,y,z);
     vertex(x+1,y,z);
     vertex(x+1,y,z-1);
     vertex(x,y,z-1);
    endShape();
//   System.out.println(x+" "+y+" "+z); 
  }

    
  
  
}
