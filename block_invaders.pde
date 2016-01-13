import java.util.ArrayList;
import java.util.Iterator;
import java.io.*;
import processing.sound.*;

Ship myShip1;
Fleet enemyFleet1;
SoundFile sample;

void setup() {
  size (400, 600);
  myShip1 = new Ship(color(255,0,0),200,580);
  enemyFleet1 = new Fleet(27);
  playSound("space1.mp3");
}

void playSound(String filename) {
  sample = new SoundFile(this, filename);
  sample.play();
}

void draw() {
  background(0);
  if (myShip1.destroyed == false) {
    myShip1.display();
    if (myShip1.hasMissile()) {
     myShip1.missile.display();
     if (enemyFleet1.checkInvadersHit(myShip1.missile.xpos, myShip1.missile.ypos)) {
       myShip1.missile.finish();
     }
    }
    if (enemyFleet1.hasInvaders()) {
     enemyFleet1.display();
     if (enemyFleet1.checkShipHit(myShip1.xpos, myShip1.ypos) || enemyFleet1.hasTouchedDown()) {
       myShip1.destroyed = true;
       playSound("laser3.wav");
     }
    }
    else {
      textSize(24);
      fill(255); // Fill color white
      text("You win!", 140, 250);
    }
  }
  else {
    textSize(24);
    fill(255); // Fill color white
    text("GAME OVER", 140, 250);
  }
}

class Ship { 
  color c;
  int xpos;
  int ypos;
  boolean destroyed;
  Projectile missile;

  Ship(color tempC, int tempXpos, int tempYpos) { 
    c = tempC;
    destroyed = false;
    xpos = tempXpos;
    ypos = tempYpos;
  }
  
  boolean hasMissile() {
    if (missile instanceof Projectile && missile.finished == false) {
      return true;
    }
    return false;
  }
  
  void display() {
    stroke(0);
    fill(c);
    rectMode(CENTER);
    xpos = mouseX;
    if (xpos < 20) xpos = 20;
    if (xpos > 380) xpos = 380;
    rect(xpos,ypos,14,20);
    if (mousePressed) {
      // ellipse(mouseX, mouseY, 8, 8); // laser sight
      if (!hasMissile()) {
        missile = new Projectile(color(0,0,255),mouseX,570);
      }
    }
  }

}

class Projectile { 
  color c;
  int xpos;
  int ypos;
  boolean finished;

  Projectile(color tempC, int tempXpos, int tempYpos) { 
    c = tempC;
    xpos = tempXpos;
    ypos = tempYpos;
    finished = false;
    playSound("laser1.wav");
  }
  
  void finish() {
    ypos = -50;
    finished = true;
  }
  
  void display() {
    stroke(0);
    fill(c);
    rectMode(CENTER);
    ypos = ypos - 20;
    if (finished == false && ypos > 0) {
      rect(xpos,ypos,5,5);
    }
    else {
      finished = true;
    }
  }

}

class InvaderProjectile { 
  color c;
  int xpos;
  int ypos;
  boolean finished;

  InvaderProjectile(color tempC, int tempXpos, int tempYpos) { 
    c = tempC;
    xpos = tempXpos;
    ypos = tempYpos;
    finished = false;
    playSound("laser2.wav");
  }
  
  void finish() {
    ypos = 900;
    finished = true;
  }
  
  boolean hit_check(int shipX, int shipY) {
    boolean xMatch = false;
    if (Math.abs(xpos-shipX) < 15) {
      xMatch = true;
    }
    boolean yMatch = false;
    if (Math.abs(ypos-shipY) < 15) {
      yMatch = true;
    }
    return (yMatch == true && xMatch == true);
  }
  
  void display() {
    stroke(0);
    fill(c);
    rectMode(CENTER);
    ypos = ypos + 15;
    if (finished == false && ypos < 600) {
      rect(xpos,ypos,5,5);
    }
    else {
      finished = true;
    }
  }

}

class Fleet { 
  color c;
  float ypos;
  ArrayList<Invader> invaders;
  int ticks;
  int moves;

  Fleet(int invader_count) { 
    ticks = 0;
    moves = 0;
    invaders = new ArrayList<Invader>();
    int xpos = 60;
    int ypos = 20;
    int i2 = 0;
    for (int i = 0; i < invader_count; i++) {
     i2++;
     invaders.add(new Invader(xpos, ypos));
     if (xpos < 360) xpos = xpos + 40;
     else xpos = 60;
     if (i2 > 8) {
      i2 = 0;
      ypos += 40;
     }
    }
  }
  
  boolean hasInvaders() {
    return (invaders.size() > 0);
  }
  
  void killInvader(int index) {
    invaders.remove(index);
    invaders.trimToSize();
  }
  
  boolean checkInvadersHit(int hitX, int hitY) {
    int index = 0;
    int hit_index = 0;
    Iterator<Invader> itr = invaders.iterator();
    while (itr.hasNext()) {
     Invader invader = itr.next();
     if (invader.hit_check(hitX, hitY)) {
       hit_index = index+1;
     }
     index++;
    }
    if (hit_index > 0) {
      killInvader(hit_index-1);
      return true;
    }
    return false;
  }
  
  boolean checkShipHit(int shipX, int shipY) {
    Iterator<Invader> itr = invaders.iterator();
    while (itr.hasNext()) {
     Invader invader = itr.next();
     if (invader.hasMissile() && invader.missile.hit_check(shipX, shipY)) {
       return true;
     }
    }
    return false;
  }
  
  boolean hasTouchedDown() {
    Iterator<Invader> itr = invaders.iterator();
    while (itr.hasNext()) {
     Invader invader = itr.next();
     if (invader.ypos >= 580) {
       return true;
     }
    }
    return false;
  }
  
  void display() {
    if (ticks == 0 || ticks % 50 > 0) {
      Iterator<Invader> itr = invaders.iterator();
      while (itr.hasNext()) {
       Invader invader = itr.next();
       invader.display();
       if (ticks % 40 == 0 && Math.random() > 0.99) {
         invader.fire();
       }
      }
    }
    else {
      Iterator<Invader> itr = invaders.iterator();
      while (itr.hasNext()) {
        int modX = 0;
        int modY = 0;
        if (moves < 2) {
          modX = -20;
        }
        else if (moves == 2 || moves == 5) {
          modY = 20;
        }
        else if (moves < 6) {
          modX = 20;
        }

       Invader invader = itr.next();
       invader.move(modX, modY);
      }
      moves++;
      if (moves > 6) moves = 0;
    }
    
    ticks++;
  }

}

class Invader {
  color c;
  int xpos;
  int ypos;
  InvaderProjectile missile;

  Invader(int tempX, int tempY) { 
    xpos = tempX;
    ypos = tempY;
  }
  
  boolean hasMissile() {
    if (missile instanceof InvaderProjectile && missile.finished == false) {
      return true;
    }
    return false;
  }
  
  
  void move(int moveX, int moveY) {
    xpos = xpos + moveX;
    ypos = ypos + moveY;
    display();
  }
  
  void fire() {
    if (!hasMissile()) {
      missile = new InvaderProjectile(color(0,255,255),xpos,ypos);
    }
    
  }
  
  boolean hit_check(int hitX, int hitY) {
    boolean xMatch = false;
    if (Math.abs(xpos-hitX) < 16) {
      xMatch = true;
    }
    boolean yMatch = false;
    if (Math.abs(ypos-hitY) < 16) {
      yMatch = true;
    }
    return (yMatch == true && xMatch == true);
  }
  
  void display() {
    stroke(0);
    fill(color(0,255,0));
    rectMode(CENTER);
    rect(xpos,ypos,20,15);
    if (hasMissile()) {
       missile.display();
    }
  }
}