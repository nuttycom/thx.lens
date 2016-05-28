package thx.lens;

import haxe.ds.Option;

import thx.Either;
import thx.fp.Functions.const;
using thx.Eithers;
using thx.Functions;

class PPrism<S, T, A, B> {
  public var getOrModify(default, null): S -> Either<T, A>;
  public var reverseGet(default, null): B -> T;

  public function new(getOrModify: S -> Either<T, A>, reverseGet: B -> T) {
    this.getOrModify = getOrModify;
    this.reverseGet = reverseGet;
  }

  public function getOption(s: S): Option<A> {
    return getOrModify(s).cata(const(None), Some);
  }

  public function modify(f: A -> B): S -> T {
    return function(s: S) {
      return this.getOrModify(s).cata(Functions.identity, function(a: A) return reverseGet(f(a)));
    };
  }

  public function set(b: B): S -> T {
    return modify(const(b));
  }
}

class PPrisms {
  public static function pPrism<S, T, A, B>(getOrModify: S -> Either<T, A>, reverseGet: B -> T): PPrism<S, T, A, B> {
    return new PPrism(getOrModify, reverseGet);
  }
}

class PPrismExtensions {
  public static function compose<S, T, A, B, C, D>(stab: PPrism<S, T, A, B>, abcd: PPrism<A, B, C, D>) {
    return new ComposePPrism(stab, abcd);
  }

  public static function view<S, T, A, B>(s: S, la: PPrism<S, T, A, B>): A {
    return la.get(s);
  }

  public static function update<S, T, A, B>(s: S, la: PPrism<S, T, A, B>, b: B): T {
    return la.set(b)(s);
  }
}

class ComposePPrism<S, T, A, B, C, D> extends PPrism<S, T, C, D> {
  public function new(stab: PPrism<S, T, A, B>, abcd: PPrism<A, B, C, D>) {
    super(
      function(s: S): Either<T, C> {
        return stab.getOrModify(s).flatMap(
          function(a: A) return abcd.getOrModify(a).leftMap(
            function(b: B) return stab.set(b)(s)
          )
        );
      },
      function(d: D): T return stab.reverseGet(abcd.reverseGet(d))
    );
  }
}




