class OsmNode {
    int id;
    PVector lonlat;
    
    public OsmNode(int idArg, float lat, float lon) {
      this.id = idArg;
      this.lonlat = new PVector();
      lonlat.x = lon;
      lonlat.y = lat;
    }
    
}
