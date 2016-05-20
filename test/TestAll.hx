import utest.Runner;
import utest.ui.Report;
import utest.Assert;

import thx.lens.*;

class TestAll {
  public static function main() {
    var runner = new Runner();
    runner.addCase(new TestPLens());
    Report.create(runner);
    runner.run();
  }
}
