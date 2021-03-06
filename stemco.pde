XMLElement xml;
PVector minLatLon, maxLatLon;
HashMap hm;
Boolean DEBUG = false;
PFont fontA;
ArrayList highwaysToDraw;

void setup() {
  //Processing tradition seems to be to do size calls first, but 
  //I need to dynamically figure out what Y is going to be. 
  //(it's based on x, and minmax lat/lon)
  size(100, 100);
  //Set up font rendering so we can write some text.
  fontA = loadFont("Arial-BoldMT-10.vlw");
  textFont(fontA, 10);
  strokeWeight(2);
  drawMap("redmond_sm.osm");

}

void draw() {
  noStroke();
  fill(255);
  rect(0,0,125,30);
  fill(0);
  text(mouseX + "," + mouseY, 10, 10);
  PVector lonLat = getLonLat(new PVector(mouseX, mouseY));
  text(lonLat.x + "," + lonLat.y, 10, 20);
}

void drawMap(String filename) {
  xml = new XMLElement(this, filename);
  int numNodes = xml.getChildCount();
  //there will be more nodes here - getChildCount
  //obviously returns ways, relations, etc.
  //but default load factor on the hash is 0.75, so maybe it works.
  hm = new HashMap(numNodes);
  //get the first tag - it describes our bounds.
  XMLElement kid = xml.getChild(0);
  //Oh man I had these backwords. Lon is x, latitude is y.
  minLatLon = new PVector(kid.getFloatAttribute("minlon"), kid.getFloatAttribute("minlat"));
  maxLatLon = new PVector(kid.getFloatAttribute("maxlon"), kid.getFloatAttribute("maxlat"));
  //It does seem to ignore these - some of the nodes returned by the OSM file exceed these bounds. Many of them do.
  debugMsg("Min: " + minLatLon);
  debugMsg("Max: " + maxLatLon);  
  int xSize = 500;
  int ySize = int(xSize * (minLatLon.x - minLatLon.y) / (maxLatLon.x - maxLatLon.y) / cos(maxLatLon.y/360*PI*2));
  size(xSize, ySize);
  debugMsg("Size x: " + xSize + " thus Y: " + ySize);

  for (int i = 1; i < numNodes; i++) { 
    PVector vertexCoord = new PVector();
    kid = xml.getChild(i);
    String name = kid.getName();
    if(name.equals("node")) {
      String id = kid.getStringAttribute("id");
      float lat = kid.getFloatAttribute("lat");
      float lon = kid.getFloatAttribute("lon");
      debugMsg(id + " : " + name + " : " + lat + " : " + lon);   
      PVector latlon = new PVector(lon, lat);
      //PVector ellipseCoord = getScreenCoords(latlon);
      //noFill();
      //ellipse(ellipseCoord.x, ellipseCoord.y, 5, 5);
      hm.put(id, new OsmNode(int(id), lat, lon));
    } else if(name.equals("way")) {
        OsmWay way = new OsmWay(int(kid.getStringAttribute("id")));
        int numNodesInWay = kid.getChildCount();
        for(int j=0; j<numNodesInWay; j++) {
          XMLElement kid2 = kid.getChild(j);
          if(kid2.getName().equals("nd")) { 
            OsmNode noder = (OsmNode)hm.get(kid.getChild(j).getStringAttribute("ref"));
            way.addNode(noder);
          } else if(kid2.getName().equals("tag")){
              if(kid2.getStringAttribute("k").equals("name")) {
                way.name = kid2.getStringAttribute("v");
              }
              if(kid2.getStringAttribute("k").equals("highway")) {
                way.highwayType = kid2.getStringAttribute("v");
              }
          }
        }//end of for loop 
     
        if(way.willDraw()) {
          noFill();
          beginShape();
          stroke(random(255), random(255), random(255));
          for(int k=0; k<way.nodes.size(); k++) {
            OsmNode node = (OsmNode)way.nodes.get(k);
            PVector vert = getScreenCoords(node.lonlat);
            vertex(vert.x, vert.y);
            if(k == way.nodes.size() / 2 && way.name != null) {
              //draw name at middle node. offset in the x direction by length.
              fill(0);
              text(way.name, vert.x - (10 - random(20)), vert.y - (10 - random(20)));
              noFill();
            }
          }
          endShape();
        }
    }//end of for loop
  }
}

PVector getLonLat(PVector screenCoords) {
  PVector ans = new PVector();
  ans.x = map(mouseX, 0, width, minLatLon.x, maxLatLon.x);
  ans.y = map(mouseY, height, 0, minLatLon.y, maxLatLon.y);
  return ans;
}
PVector getScreenCoords(PVector rawCoords) {
  PVector ans = new PVector();
  ans.x = map(rawCoords.x, minLatLon.x, maxLatLon.x, 0, width);
  ans.y = map(rawCoords.y, minLatLon.y, maxLatLon.y, height, 0);
  //screen coordinates, 0,0 is upper left, not lower left. this killed me for a good hour.
  debugMsg(rawCoords + " --> " + ans);
  return ans;
}

//Should draw some ellipses at various points. 
boolean testGetScreenCoords() {
   PVector ans = new PVector(0,height);
   PVector test = minLatLon;
   PVector testans = (getScreenCoords(test));
   if(testans.x != ans.x || testans.y != ans.y) {
     println("false");
     return false;
   } else {
     println("pass: 0, 700");
   }
   ellipse(testans.x, testans.y, 20, 20);
   test = new PVector(abs((abs(maxLatLon.x) - abs(minLatLon.x)))/2 + abs(minLatLon.x), (abs(abs(maxLatLon.y) - abs(minLatLon.y))/2 + abs(minLatLon.y)));
   //should return something like height/2, width/2
   testans = getScreenCoords(test);
   ellipse(testans.x, testans.y, 20, 20);
   test = new PVector(abs((abs(maxLatLon.x) - abs(minLatLon.x)))/4 + abs(minLatLon.x), (abs(abs(maxLatLon.y) - abs(minLatLon.y))/4 + abs(minLatLon.y)));
   //should print something like height/4, 3*width/4
   testans = getScreenCoords(test);
   ellipse(testans.x, testans.y, 20, 20);
   test = new PVector(abs((abs(maxLatLon.x) - abs(minLatLon.x)))/4 * 3 + abs(minLatLon.x), (abs(abs(maxLatLon.y) - abs(minLatLon.y))/4 + abs(minLatLon.y)));
   testans = getScreenCoords(test);
   ellipse(testans.x, testans.y, 20, 20);
   test = new PVector(abs((abs(maxLatLon.x) - abs(minLatLon.x)))/4 + abs(minLatLon.x), (abs(abs(maxLatLon.y) - abs(minLatLon.y))/4 * 3 + abs(minLatLon.y)));
   testans = getScreenCoords(test);
   ellipse(testans.x, testans.y, 20, 20);
   test = new PVector(abs((abs(maxLatLon.x) - abs(minLatLon.x)))/4 * 3 + abs(minLatLon.x), (abs(abs(maxLatLon.y) - abs(minLatLon.y))/4 * 3 + abs(minLatLon.y)));
   testans = getScreenCoords(test);
   ellipse(testans.x, testans. y, 20, 20);
   test = new PVector(maxLatLon.x, maxLatLon.y);
   testans = getScreenCoords(test);
   ellipse(testans.x, testans. y, 20, 20);
   test = new PVector(maxLatLon.x, minLatLon.y);
   testans = getScreenCoords(test);
   ellipse(testans.x, testans. y, 20, 20);
   
   return true;
}

void debugMsg(String msg) {
  if(DEBUG) {
    println(msg);
  }
}
/**@deprecated
float getScreenX(float lon) {
/*
  println("lon: " + lon);
  println("lon-minLon: " + abs(abs(lon)-abs(minLon)));
  println("max-min: "+ abs(abs(maxLon)-abs(minLon)));
  println("height: " + height);
  print("answer: " + abs(abs(lon)-abs(minLon)) / (abs(abs(minLon)-abs(maxLon))) * height);
 
  return (abs(abs(lon)-abs(minLon))) / (abs(abs(minLon)-abs(maxLon))) * width;
}
float getScreenY(float lat) {
  println("lat: " + lat);
  println("lat-minlat: " + abs(abs(lat)-abs(minLat)));
  println("max-min: "+ abs(abs(maxLat)-abs(minLat)));
  println("width: " + height);
  println("answer: " + abs(abs(lat)-abs(minLat)) / (abs(abs(minLat)-abs(maxLat))) * height);
  return (abs(abs(lat)-abs(minLat))) / abs((abs(maxLat)-abs(minLat))) * height;
}
*/
