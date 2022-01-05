pragma circom 2.0.0;
include "../node_modules/circomlib/circuits/mimcsponge.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

template Main() {
    signal input x;
    signal input y;
    signal input r;

    signal output h;

    signal xSq;
    signal ySq;
    signal rSq;

    r === 64;

    xSq <== x * x;
    ySq <== y * y;
    rSq <== r * r;

    /* check x^2 + y^2 > 32 */
    component comp0 = GreaterThan(64);
    xSq + ySq ==> comp0.in[0];
    32 ==> comp0.in[1];
    comp0.out === 1;
    log(1111111);
    /* check x^2 + y^2 < r^2 */
    component comp1 = LessEqThan(64);
    xSq + ySq ==> comp1.in[0];
    rSq ==> comp1.in[1];
    comp1.out === 1;

    /* check MiMCSponge(x,y) = pub */
    component mimc = MiMCSponge(2, 220, 1);

    mimc.ins[0] <== x;
    mimc.ins[1] <== y;
    mimc.k <== 0;

    mimc.outs[0] ==> h;

    log(33333333);
    var x_gcd = x;
    var y_gcd = y;

    log(x_gcd);
    log(y_gcd);

    // Euclidean gcd
    while (y_gcd > 0) {
      x_gcd %= y_gcd;
      // XOR swap
      x_gcd ^= y_gcd;
      y_gcd ^= x_gcd;
      x_gcd ^= y_gcd;
    }

    // Now either x_gcd or y_gcd should be 0 and the other the gcd, 
    // we sum them and check that's it's not a prime 
    var gcd = x_gcd;
    log(gcd);

    // make sure gcd is greater than 1.
    component comp2 = GreaterThan(64);
    comp2.in[0] <-- gcd;
    comp2.in[1] <== 1;
    comp2.out === 1;
    log(6666);

    // primes less than 64
    // gcd(a, b) <= a, b and we have constraint numbers to be at most 64 e.g (0, 64) or (64, 0)
    var primes[18] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61];
    component eq[18];
    var sum = 0;

    for (var i = 0; i < 18; i++) {
      eq[i] = IsEqual();
      // assignment instead of constraint, xor and % break quadratic constraint
      gcd --> eq[i].in[0];
      primes[i] ==> eq[i].in[1];
      sum += eq[i].out;

      // debugging
      if (eq[i].out == 1) {
        log(primes[i]);
      }
    }
    log(sum);

    // We want that sum is zero, i.e gcd isn't equal to any prime.
    component isz = IsZero();
    sum ==> isz.in;
    isz.out === 1;
    // Success code 
    log(200);
}
component main {public [r]} = Main();