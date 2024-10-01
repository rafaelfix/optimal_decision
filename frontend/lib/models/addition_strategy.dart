/*
tiokompisar: x + y > 10
Ex: 7 + 4 ==> 10 + 1
raknaUpp: x + y <= 10
Ex: 2 + 4 ==> 0 + 6
dubblar: x + x
Ex: 4 + 4 ==> 6 + 2
nastanDubblar1: x + (x+1)
Ex: 7 + 8 ==> 14 + 1
nastanDubblar2: x + (x+2)
Ex: 7 + 9 ==> 8 + 8
sandBox: free play
*/

enum AdditionStrategy {
  tiokompisar,
  raknaUpp,
  dubblar,
  nastanDubblar1,
  nastanDubblar2,
  okand,
  sandbox,
}

/// Calculates strategy given [x] and [y].
/// Order:
/// - [AdditionStrategy.dubblar]/[AdditionStrategy.nastanDubblar1]
///   /[AdditionStrategy.nastanDubblar2] (mutually exclusive)
/// - [AdditionStrategy.tiokompisar]
/// - [AdditionStrategy.raknaUpp]
///
/// If any of [x] or [y] is zero sandbox mode is chosen,
/// since there are no meaningful strategies to choose from.
/// 1+1 is excluded from [AdditionStrategy.dubblar] and is run
/// with [AdditionStrategy.raknaUpp].
AdditionStrategy calcStrategy(int x, int y) {
  //Guard.
  if (x == 0 || y == 0) {
    return AdditionStrategy.raknaUpp;
  } else if (x == y && x != 1) {
    // x != 1 to exclude 1+1
    return AdditionStrategy.dubblar;
  } else if ((x - y).abs() == 1) {
    return AdditionStrategy.nastanDubblar1;
  } else if ((x - y).abs() == 2) {
    return AdditionStrategy.nastanDubblar2;
  } else if (x + y > 10) {
    return AdditionStrategy.tiokompisar;
  } else {
    return AdditionStrategy.raknaUpp;
  }
}
