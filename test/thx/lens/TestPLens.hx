package thx.lens;

import thx.lens.PLens;
import thx.lens.PLens.*;
using thx.lens.PLens.PLensExtensions;

import utest.Assert;

typedef BS = {
  b: Bool,
  s: String
};

typedef FBS = {
  f: Float,
  bs: BS
};

class TestPLens {
  public function new() {}

  static var _b: PLens<BS, BS, Bool, Bool> = PLenses.pLens(
    function(x: BS): Bool return x.b,
    function(b: Bool): BS -> BS {
      return function(x: BS) return {
        b: b,
        s: x.s
      };
    }
  );

  static var _bs: PLens<FBS, FBS, BS, BS> = PLenses.pLens(
    function(x: FBS): BS return x.bs,
    function(bs: BS): FBS -> FBS {
      return function(x: FBS) return {
        f: x.f,
        bs: bs
      };
    }
  );

  public function testComposeLenses() {
    var composed = _bs.compose(_b);
    var test: FBS = {
      f: 0.0,
      bs: {
        b: true,
        s: "BinA"
      }
    };

    Assert.isTrue(test.view(composed));
    Assert.isFalse(test.update(composed, false).view(composed));
  }
}
