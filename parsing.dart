import 'dart:math';
import 'dart:collection';

class LinearExpression { // coef * sub + con
  ComplexNumber coef;
  ComplexNumber con;
  var sub;
  LinearExpression(var coef, var con, var sub) {
    if(coef is int || coef is double) {
      this.coef = new ComplexNumber(coef, 0);
    } else if(coef is ComplexNumber) {
      this.coef = coef;
    } else {
      print('Error: Coef must be a compelx number or int');
    }
    if(con is int || con is double) {
      this.con = new ComplexNumber(con, 0);
    } else if(con is ComplexNumber) {
      this.con = con;
    } else {
      print('Error: Con must be a complex number of int');
    }
    this.sub = sub;
  }
}

class Z {}

class QuotientExpression { // numerator / denominator
  LinearExpression numerator;
  LinearExpression denominator;
  QuotientExpression(this.numerator, 
                   this.denominator);
}

class AbsExpression { // |eqn|
    var eqn;
    AbsExpression(this.eqn);
}

class ArgExpression { // arg(eqn)
    var eqn;
    ArgExpression(this.eqn);
}


class ComplexNumber { // re + im * i
  num re;
  num im;
  ComplexNumber(this.re, this.im);

  ComplexNumber operator +(x) {
    if(!(x is ComplexNumber)) {
      return new ComplexNumber(re + x, im);
    }
    return new ComplexNumber(re + x.re, im + x.im);
   
  }
  ComplexNumber operator -(x) {
    return new ComplexNumber(re - x.re, im - x.im);
  }
  ComplexNumber operator /(x) {
    return new ComplexNumber((re * x.re + im * x.im) /
                            (x.re * x.re + x.im * x.im), 
                            (im * x.re - re * x.im) / 
                            (x.re * x.re + x.im * x.im));
  }
  ComplexNumber operator *(x) {
    return new ComplexNumber(re * x.re - im * x.im,
                             re * x.im + im * x.re);
  }
}

class Operator {
  int precedence;
  String repr;
  int assoc;
  int operands;
  var eval;
  Operator(this.precedence, this.assoc, this.repr, this.operands, this.eval);
}

class Plus extends Operator {Plus(): super(0, 1, '+', 2,
      (x, y) {
        if(x is ComplexNumber && y is ComplexNumber) {
          return x + y;
        } else if(x is ComplexNumber && y is LinearExpression) {
          return new LinearExpression(y.coef, x + y.con, y.sub);
        } else if(x is LinearExpression && y is ComplexNumber) {
          return new LinearExpression(x.coef, y + x.con, x.sub);
        } else if(x is LinearExpression && y is LinearExpression && 
                  x.sub is Z && y.sub is Z) {
          return new LinearExpression(x.coef + y.coef, x.con + y.con, 
                                    x.sub);
        } else if((x is AbsExpression || x is ArgExpression) 
                   && y is ComplexNumber) {
          return new LinearExpression(1, y, x);
        } else if(x is ComplexNumber && 
                 (y is AbsExpression || y is ArgExpression)) {
          return new LinearExpression(1, x, y); 
        } else {
          print("Error:Plus Incorrect operand types");
          return null;
        }});}

class Minus extends Operator {Minus(): super(0, 1, '-', 2,
        (x, y) {
        if(x is ComplexNumber && y is ComplexNumber) {
          return x - y;
        } else if(x is LinearExpression && y is ComplexNumber) {
          return new LinearExpression(x.coef, x.con - y, x.sub);
        } else if(x is ComplexNumber && y is LinearExpression) {
          return new LinearExpression(new ComplexNumber(0, 0) -y.coef, 
                                      x - y.con, y.sub);
        } else if(x is LinearExpression && y is LinearEquation &&
                  x.sub is Z && y.sub is Z) {
          return new LinearExpression(x.coef - y.coef, x.con - y.con, 
                     x.sub);
        } else if((x is ArgExpression || x is AbsExpression) && y is
                  ComplexNumber) {
          return new LinearExpression(1, -y, x);
        } else if(x is ComplexNumber && (y is ArgExpression || 
                  y is AbsExpression)) {
          return new LinearExpression(-1, x, y); 
        } else if(x is ArgExpression && y is ArgEquation) {
          return new ArgExpression(new QuotientExpression(x, y));
        } else {
          print("Error:Minus Incorrect operand types");
          return null;
        }});}

class Divide extends Operator {Divide(): super(1, 1, '/', 2,
      (x, y) {
        if(x is ComplexNumber && y is ComplexNumber) {
          return x / y;
        } else if(x is LinearExpression && y is ComplexNumber) {
          return new LinearExpression(x.coef / y, x.con / y, x.sub);
        } else if(x is ComplexNumber && y is LinearExpression) {
          return new 
          QuotientExpression(new LinearExpression(0, x, y.sub), y);
        } else if(x is LinearExpression && y is LinearExpression) {
          return new QuotientExpression(x, y);
        } else if((x is ArgExpression || x is AbsExpression) && y is
                  ComplexNumber) {
          return new LinearExpression(new ComplexNumber(1, 0) / y, 
                                      0, x);
        } else {
          print("Error: Divide Incorrect operand types");
          return null;
        }});}

class Multiply extends Operator {Multiply(): super(1, 1, '*', 2, 
      (x, y) {
        if(x is ComplexNumber && y is ComplexNumber) {
          return x * y;
        } else if(x is LinearExpression && y is ComplexNumber) {
          return new LinearExpression(x.coef * y, x.con * y, x.sub);
        } else if(x is ComplexNumber && y is LinearExpression) {
          return new LinearExpression(y.coef * x, y.con * x, y.sub);
        } else if((x is ArgExpression || x is AbsExpression) && y is 
                   ComplexNumber) {
          return new LinearExpression(y, 0, x);
        } else if((y is ArgExpression || y is AbsExpression) && x is
                  ComplexNumber) {
          return new LinearExpression(x, 0, y);
        } else if(x is LinearExpression && y is LinearExpression) {
          print("Error: Polynomials are not supported");
        } else {
          print("Error:Times Incorrect operand types");
          return null;
        }});}

class Arg extends Operator {Arg(): super(2, 1, 'arg', 1, 
      (eqn) => new ArgExpression(eqn));}
class Abs extends Operator {Abs(): super(2, 1, 'abs', 1,
      (eqn) => new AbsExpression(eqn));}
class LParen extends Operator {LParen(): super(-1, 1, '(', 0, 0);}

String printOutput(Queue out) {
  String str = '';
  while(out.isNotEmpty) {
    var token = out.removeFirst();
    if(token is num) {
      str += ' ' + token.toString();
    } else if(token is LinearExpression) {
      str += ' (${token.coef}z + ${token.con})';
    } else if(token is ComplexNumber) {
      if(token.re != 0) str += ' ${token.re} + ${token.im}i';
      else if(token.im == 0) str += ' ${token.re}';
      else str += ' ${token.im}i';
    } else {
      str += ' ' + token.repr;
    }
  } 
  return str;
}

List <Queue> parse(String eqn) {
  eqn = eqn.replaceAll(new RegExp(' '), '');
  final Map <String, int> dig = {'0':0, '1':1, '2':2, '3':3, '4':4, 
                                 '5':5, '6':6, '7':7, '8':8, '9':9};
  final String stdError = 'Error in parsing equation. Read the help section for more information';
  Queue output = new Queue();
  Queue <Operator> operators = new Queue();
  Queue lhs;
  Map ops = {'+':() => new Plus(), '-':() => new Minus(), 
             '/':() => new Divide(), '*':() => new Multiply() };

  bool ra(String op) => ops[op]().assoc == 0;
  bool la(String op) => ops[op]().assoc == 1;
  bool lparenfound = false;
  int side = 0;
  bool isDig(String x) { 
    List <String> digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8',                            '9'];
    digits.retainWhere((n) => n == x);
    return digits.isNotEmpty;
  }

  int readNumber(String eqn, int start) {
    int n = 0;
    for(int i = start; i < eqn.length; i++) {
      if(!isDig(eqn[i])) break;
      n = n * 10 + dig[eqn[i]];
    }
    return n;
  }
  int isPowOfTen(int n) {
    int i = 0;
    while(n % 10 == 0) {
      n /= 10;
      i++;
      if(n == 1) return i;
    }
    return -1;
  }

  // Shunting yard algorithm
  for(int i = 0; i < eqn.length; i++) {
    var token = eqn[i];
    if(isDig(token)) {
      int n = readNumber(eqn, i);
      int numLen;
      if(n == 0 || n == 1) numLen = 1;
      else if(isPowOfTen(n) > 0) numLen = isPowOfTen(n) + 1;
      else numLen = (log(n) / log(10)).ceil();
      if(i + numLen < eqn.length && eqn[i + numLen] == 'z') {
        output.addLast(new LinearExpression(n, 0, new Z()));
        i += numLen;
      } else if(i + numLen < eqn.length && eqn[i + numLen] == 'i') {
        output.addLast(new ComplexNumber(0, n));
        i += numLen;
      } else if(i + numLen + 1 < eqn.length && eqn.substring(i, i+1) ==
                'pi') {
          output.addLast(new ComplexNumber(n * 3.14159265, 0));
          i += numLen + 1;
      } else {
        output.addLast(new ComplexNumber(n, 0));
        i += numLen - 1;
      }
    } else if(i+3 < eqn.length && eqn.substring(i, i+3) == 'arg') {
      operators.addLast(new Arg());
      i += 2;
    } else if(i+3 < eqn.length && eqn.substring(i, i+3) == 'abs') {
      operators.addLast(new Abs());
      i += 2;
    } else if(token == '+' || token == '-' || token == '*' ||
              token == '/') {
      while(operators.isNotEmpty) {
        if(  
          ((la(token) && operators.last.precedence >= 
            ops[token]().precedence) || (ra(token) && 
            operators.last.precedence < ops[token]().precedence))) {
            output.addLast(operators.removeLast());
        } else {
          break;
        }
      }
      operators.addLast(ops[token]());
    } else if(token == '(') {
      operators.addLast(new LParen());
    } else if(token == ')') {
      while(!lparenfound) {
        if(operators.isEmpty) {
          print("Error: Mismatched parentheses");
          return;
        }
        Operator op = operators.removeLast();
        if(op is LParen) {
          lparenfound = true;
        }
      if(!lparenfound) output.addLast(op);
      }
      lparenfound = false;
    } else if(token == 'z') {
      output.addLast(new LinearExpression(1, 0, new Z()));
    } else if(token == '=') {
      if(side == 0) {
        while(operators.isNotEmpty) {
          Operator op = operators.removeLast();
          if(op is LParen) {
            print("Error: Mistmatched parentheses");
            return;
          } 
          output.addLast(op);
        }
        side = 1;
        operators.clear();
        lhs = new Queue.from(output);
        output.clear();
      } else {
        print('Error: too many equal signs');
        return;
      }
    } else if(i + 1 < eqn.length && token == 'p'&& eqn[i+1] == 'i') {
      output.addLast(new ComplexNumber(3.14159625, 0));
      i++;
    } else if(token == 'i') {
      output.addLast(new ComplexNumber(0, 1));
    } else {
      print('Error: Unrecognised character: ${token}');
      return;
    }
  }
  while(operators.isNotEmpty) {
    Operator op = operators.removeLast();
    if(op is LParen) {
      print("Error: Mistmatched parentheses");
      return;
    } 
    output.addLast(op);
  }
  if(side != 1) {
    print("Error: No equation to plot");
    return [output];
  }
  return [lhs, output];
}

bool compareComplex(ComplexNumber x, ComplexNumber y) 
     => x.im == y.im && x.re == y.re;

graph(List <Queue> s) {
  Queue lhs = s[0];
  Queue rhs = s[1];
  // Build the syntax tree
   buildSide(Queue eqn) {
    Queue operands = new Queue();
    while(eqn.isNotEmpty) {
      var token = eqn.removeFirst();
      if(token is ComplexNumber || token is LinearExpression || 
         token is QuotientExpression || token is ArgExpression ||
         token is AbsExpression) {
        operands.addFirst(token);
      } else { // Token is an operator
        if(operands.length < token.operands) {
          print("Error: Incorrect number of operands");
          return "";
        } 
        if(token.operands == 1) {
          operands.addFirst(token.eval(operands.removeFirst()));
        } else if(token.operands == 2) {
          var firstOp = operands.removeFirst(); // Ensure correct order
          operands.addFirst(token.eval
                   (operands.removeFirst(), firstOp));
        }
      }
    }
    if(operands.length != 1) {
      print("Error: Incorrect number of operands");
      return null;
    }
    return operands.removeFirst();
  }
  makeModModCircle(LinearExpression f1, LinearExpression f2) {
    if(f1.coef.re * f2.coef.re <= 0) {
      print("Error: Mismathcing mod coefficients");
    } else if(compareComplex(f1.con, f2.con)) {
      print("Error: Mismatching constants");
    }
    AbsEquation abs1 = f1.sub;
    AbsEquation abs2 = f2.sub;
    double lambda = f2.coef.re / f1.coef.re;
    double lsq = lambda * lambda;
    double a = abs1.eqn.con.re;
    double b = abs1.eqn.con.im;
    double u = abs2.eqn.con.re;
    double v = abs2.eqn.con.re;
    
    double x = -pow((a - u * lsq) / (1 - lsq), 2);
    double y = -pow((b - v * lsq) / (1 - lsq), 2);
    double r = (-(a * a) - (b * b) - (lsq * lsq) * (u * u + v * v) + a 
                + b) / (1 - lsq);
    print("Circle centre ($x, $y) radius $r");
  }

  makeHalfLine(var f, ComplexNumber theta) {
    if(theta.im != 0) {
      print("Error: can't have an imaginary angle");
    }
    if(f is LinearExpression) {
      theta -= LinearExpression.con;
      theta /= LinearExpression.coef;
      f = f.sub.eqn;
    } else {
      f = f.eqn;
    }
    if(!(f.sub is Z)) {
      print("Error: Non-linear in z");
    }
    double m = tan(theta.re);
    double x = -f.con.re;
    double y = -f.con.im;
    print('Half line starting at ($x, $y) with gradient $m');
  }


  makeLine(AbsExpression mod1, AbsExpression mod2) {
    LinearExpression f1 = mod1.eqn;
    LinearExpression f2 = mod2.eqn;
    if(f1.coef.re != 1 && f2.coef.re != 1 && f1.coef.im != 0 &&
       f2.coef.im != 0) {
      print("Error: Incorrect z coefficient");
      return;
    }
    if(!(f1.sub is Z) && !(f2.sub is Z)) {
      print("Error: mod not linear in z");
      return;
    }
    if(f1.con.im == f2.con.im) {
      print(
      "Vertical line x-intercept ${0.5 * (-f1.con.re - f2.con.re)}");
      return;
    }
    double u = f1.con.re;
    double v = f1.con.im;
    double a = f2.con.re;
    double b = f2.con.im;
    double m = (u - a) / (b - v);
    double c = 0.5 * ((u * u + v * v - a * a - b * b) / (b - v));
    print("Line gradient $m, y-intercept $c, x-intercept ${-c/m}");
  }

  makeCircle(var expr, ComplexNumber r) {
    LinearExpression f;
    if(expr is LinearExpression) {
      f = expr.sub.eqn;
      r -= expr.con;
      r /= expr.coef; 
    } else {
      f = expr.eqn;
    }
    if(r.im != 0) {
      print("Error: can't have an imaginary radius");
      return;
    } else if(r.re <= 0) {
      print("Error: non-positive radius");
      return;
    }
    if(!(f is LinearExpression) && !(f.sub is Z)) {
      print("Error: non-linear in z when plotting circle");
      return;
    }
    if((f.coef.re != 1  || f.coef.re != -1) && f.coef.im != 0) {
      print("Error: non-unity coefficient on z");
    }
    else print("Circle centre (${-f.coef.re * f.con.re}, ${-f.coef.re * f.con.im}) radius : ${r.re}");
  } 
  makeArc(ArgExpression x, ComplexNumber theta) {
    if(!(x.eqn.denominator.sub is Z) || !(x.eqn.numerator.sub is Z)) {
      print("Error: Quotient not linear in Z");
      return;
    }
    if(theta.im != 0) {
      print("Error: can't have an imaginary angle");
    }
    LinearExpression n = x.eqn.denominator;
    LinearExpression d = x.eqn.numerator;
    print("Arc from (${-d.con.re}, ${-d.con.im}) to (${-n.con.re}. ${-n.con.im}) subtending an angle of ${theta.re} radians");

  }
  lhs = buildSide(lhs);
  rhs = buildSide(rhs);
  List sides = [lhs, rhs];
  // Transform to graphable form
  // Form of f(|g(z|) = x, x e Re
  for(int i = 0; i < 2; i++) {
    if(((sides[i] is LinearExpression && sides[i].sub is AbsExpression) 
       || (sides[i] is AbsExpression)) && 
       sides[1 - i] is ComplexNumber) {
        makeCircle(sides[i], sides[1- i]);
        return;
    // Form of |f(z)| = |g(z)|
    } else if(sides[i] is AbsExpression && 
              sides[1 - i] is AbsExpression) {
          makeLine(sides[i], sides[1 - i]);
          return;
    // Form of k|f(z)| = t|g(z)|
    } else if(sides[i] is LinearExpression && 
              sides[i].sub is AbsExpression && 
              sides[1 - i] is LinearExpression &&
              sides[1 - i].sub is AbsExpression) {
          makeModModCircle(sides[i], sides[1 - i]);
          return;
    } else if(sides[i] is AbsExpression && sides[1 - i] is 
              LinearExpression && sides[1 - i].sub is 
              AbsExpression) {
            makeModModCircle(new LinearExpression(1, 0, sides[i]), 
                             sides[1 - i]);
            return;
    // Form of n * arg(f(z)) + c = k
    } else if(((sides[i] is LinearExpression && sides[i].sub is
              ArgExpression && sides[i].sub.eqn is LinearExpression)
              || (sides[i] is ArgExpression && sides[i].eqn is 
                  LinearExpression)) && sides[1-i] is ComplexNumber) {
          makeHalfLine(sides[i], sides[1 - i]);
          return;
    // Form of arg(f(z) / g(z)) = k
    } else if(sides[i] is ArgExpression && 
              sides[i].eqn is QuotientExpression && 
              sides[1 - i] is ComplexNumber) {
          makeArc(sides[i], sides[1 - i]);
          return;
    } else {
      print("Error: I don't know how to plot that");
    }
  }
}

void printComplex(ComplexNumber x) {
  print("${x.re} + ${x.im}i");
}

main() {
  graph(parse("arg((z - 4i) / (z+4)) = pi / 2"));
} 

