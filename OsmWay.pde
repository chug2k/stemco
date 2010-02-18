class OsmWay {
  int id;
  ArrayList nodes;
  String name;
  String highwayType;

  public OsmWay(int id) {
    this.id = id;
    nodes = new ArrayList();
  }
  public void addNode(OsmNode node) {
    nodes.add(node);
  }
  public boolean willDraw() {
    if(this.highwayType == null) {
      return false;
    }
    return (
      this.highwayType.equals("residential") ||
      this.highwayType.equals("secondary") ||
      this.highwayType.equals("service")
      );
  }
}
//  willDrawTypes = new ArrayList();
//  willDrawTypes.add("motorway");
//  willDrawTypes.add("motorway_link");
//  willDrawTypes.add("trunk");
//  willDrawTypes.add("trunk_link");
//  willDrawTypes.add("primary");
//  willDrawTypes.add("primary_link");
//  willDrawTypes.add("secondary");
//  willDrawTypes.add("secondary_link");
//  willDrawTypes.add("tertiary");
//  willDrawTypes.add("unclassified");
//  willDrawTypes.add("road");
//  willDrawTypes.add("residential");
//  willDrawTypes.add("living_street");
//  willDrawTypes.add("service");

