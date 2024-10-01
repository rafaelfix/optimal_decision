/// A [Node] is a representation of an imagenary challange for the user
/// it simply states when a challange should be unlocked and for how long it
/// should stay unlocked
///
/// * [operator] determines what operator the node represents
/// * [lockLevelMap] determines what level the profile needs to be in [operator] to unlock the node
/// * [screenSlot] determines where Horizontal the [Node] should be placed
/// note that [screenSlot] should be a value between 0 and totalSlots -1 in [PracticeModePage]
///
///
class Node {
  const Node({
    required this.lockLevelMap,
    required this.operator,
    required this.maxLevel,
    this.screenSlot = 2,
  });

  /// [lockLevelMap] determines what level the profile needs to be in [operator] to unlock the node
  final Map<String, int> lockLevelMap;

  /// [maxLevel] Decides at what level the node locks up because it hits its "max"
  final int maxLevel;

  /// [screenSlot] Decides at what "slot" the node shall be placed in
  final int screenSlot;

  /// [operator] is simply the operator of the node
  final String operator;

  /// These are the hard coded "max" values in the algorithm. A user can theoretically reach further but the limits are now unsure
  static const int maxAdd = 44;
  static const int maxAddy = 20;
  static const int maxSub = 20;

  static const int maxMul = 31;
  static const int maxMuly = 31;
  static const int maxDiv = 31;

  Node.add(int lock, int slot, int max)
      : this(lockLevelMap: {
          "+": lock,
          "p": 0,
          "-": 0,
          "*": 0,
          "m": 0,
          "/": 0,
        }, operator: "+", maxLevel: max, screenSlot: slot);

  Node.addy(int lock, int slot, int max)
      : this(lockLevelMap: {
          "+": maxAdd,
          "p": lock,
          "-": 0,
          "*": 0,
          "m": 0,
          "/": 0,
        }, operator: "p", maxLevel: max, screenSlot: slot);

  Node.sub(int lock, int slot, int max)
      : this(lockLevelMap: {
          "+": maxAdd,
          "p": maxAddy,
          "-": lock,
          "*": 0,
          "m": 0,
          "/": 0,
        }, operator: "-", maxLevel: max, screenSlot: slot);

  Node.mult(int lock, int slot, int max)
      : this(lockLevelMap: {
          "+": maxAdd,
          "p": maxAddy,
          "-": maxSub,
          "*": lock,
          "m": 0,
          "/": 0,
        }, operator: "*", maxLevel: max, screenSlot: slot);

  Node.multy(int lock, int slot, int max)
      : this(lockLevelMap: {
          "+": maxAdd,
          "p": maxAddy,
          "-": maxSub,
          "*": maxMul,
          "m": lock,
          "/": 0,
        }, operator: "m", maxLevel: max, screenSlot: slot);

  Node.div(int lock, int slot, int max)
      : this(lockLevelMap: {
          "+": maxAdd,
          "p": maxAddy,
          "-": maxSub,
          "*": maxMul,
          "m": maxMuly,
          "/": lock,
        }, operator: "/", maxLevel: max, screenSlot: slot);
}

/// The [NodeHandler] is meant do be a static handler of [Node]'s.
/// Its only use is to query all pre-designed levels
class NodeHandler {
  NodeHandler();

  // static Random rand = Random(4);

  // static const int nodeAmount = 4;

  // static final _nodes = List.generate(nodeAmount, _generateAdd) +
  //     List.generate(nodeAmount, _generateAdd);

  static final _nodes = [
    Node.add(0, 2, 10),
    Node.add(10, 0, 20),
    Node.add(20, 3, 30),
    Node.add(30, 1, Node.maxAdd),
    Node.addy(0, 0, 5),
    Node.addy(5, 3, 10),
    Node.addy(10, 1, 15),
    Node.addy(15, 2, Node.maxAddy),
    Node.sub(0, 4, 5),
    Node.sub(5, 2, 10),
    Node.sub(10, 0, 15),
    Node.sub(15, 3, Node.maxSub),
    Node.mult(0, 1, 8),
    Node.mult(8, 3, 16),
    Node.mult(16, 2, 24),
    Node.mult(24, 4, Node.maxMul),
    Node.multy(0, 2, 8),
    Node.multy(8, 0, 16),
    Node.multy(16, 2, 24),
    Node.multy(24, 4, Node.maxMuly),
    Node.div(0, 1, 8),
    Node.div(8, 3, 16),
    Node.div(16, 0, 24),
    Node.div(24, 2, Node.maxDiv),
  ];

  List<Node> get nodes => _nodes;
  int get length => _nodes.length;
}
