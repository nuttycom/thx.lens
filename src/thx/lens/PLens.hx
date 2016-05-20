package thx.lens;

using thx.Functions;

class PLens<S, T, A, B> {
  public var get(default, null): S -> A;
  public var set(default, null): B -> (S -> T);

  public function new(get: S -> A, set: B -> (S -> T)) {
    this.get = get;
    this.set = set;
  }

  function modify(f: A -> B): S -> T {
    return function(s: S) {
      return this.set(f(this.get(s)))(s);
    };
  }
}

class PLenses {
  public static function pLens<S, T, A, B>(get: S -> A, set: B -> (S -> T)): PLens<S, T, A, B> {
    return new PLens(get, set);
  }
}

class PLensExtensions {
  public static function modifyFunctionF<S, T, A, B, C>(l: PLens<S, T, A, B>, f: A -> (C -> B)): S -> (C -> T) {
    return function(s: S) {
      function set(b: B): T return l.set(b)(s);
      var get: C -> B = f(l.get(s));
      return set.compose(get);
    };
  }

  public static function compose<S, T, A, B, C, D>(stab: PLens<S, T, A, B>, abcd: PLens<A, B, C, D>) {
    return new ComposePLens(stab, abcd);
  }

  public static function view<S, T, A, B>(s: S, la: PLens<S, T, A, B>): A {
    return la.get(s);
  }

  public static function update<S, T, A, B>(s: S, la: PLens<S, T, A, B>, b: B): T {
    return la.set(b)(s);
  }
}

class ComposePLens<S, T, A, B, C, D> extends PLens<S, T, C, D> {
  public function new(stab: PLens<S, T, A, B>, abcd: PLens<A, B, C, D>) {
    super(
      function(s: S): C return abcd.get(stab.get(s)),
      function(d: D): S -> T return stab.modify(abcd.set(d))
    );
  }
}



