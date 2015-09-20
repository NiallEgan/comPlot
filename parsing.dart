import 'dart:math';
import 'dart:collection';

class LinearExpression { // coef * sub + con
  ComplexNumber coef;
  ComplexNumber con;
  var sub;
  LinearExpression(this.coef, this.con, this.sub);
}

class Z {}

class QuotientExpression { // numerator / denominator
  LinearExpression numerator;
  LinearExpression denominator;
  LinearExpression(this.numerator, 
                   this.Denominator);
}

class AbsExpression { // |eqn|
    var eqn;
    AbsExpression(var eqn) {
      if(eqn is LinearExpression || eqn is QuotientExpression) {
        this.eqn = eqn;
      } else if(eqn is ComplexNumber) {
        this.eqn = new LinearExpression(0, eqn)
      } 
    }
}

class ArgExpression { // arg(eqn)
    var eqn;
    ArgExpression(var eqn) {
      if(eqn is LinearExpression) {
        this.eqn = eqn;
      } else if(eqn is ComplexNumber) {
        this.eqn = new LinearExpression(0, eqn);
      }
    }
}


class ComplexNumber { // re + im * i
  num re;
  num im;
  ComplexNumber(this.re, this.im);

  ComplexNumber operator +(x) {
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
        } else if(x is LinearExpression && y is LinearEquation && 
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
          return new LinearExpression(-y.coef, x - y.con, y.sub);
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
          return new LinearExpression(1 / y, 0, x);
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
      (eqn) => new ArgExpression(eqn, 1, 0));}
class Abs extends Operator {Abs(): super(2, 1, 'abs', 1,
      (eqn) => new AbsExpression(eqn, 1, 0));}
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
          output.addLast(n * 3.14159265);
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
          /*if(operators.isNotEmpty && 
            (operators.first is Arg || operators.first is Abs)) {
            output.addLast(operators.removeFirst());
          }*/
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
      output.addLast(3.14159625);
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

ComplexNumber graph(Queue lhs) {
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
          operands.addFirst(token.eval(firstOp,operands.removeFirst()));
        }
      }
    }
    if(operands.length != 1) {
      print("Error: Incorrect number of operands");
      return null;
    }
    return operands.removeFirst();
  }
  lhs = buildSide(lhs);
  return lhs;
  //rhs = buildSide(rhs);

  // Transform to graphable form
}

main() {
  print(graph(parse('(5 + 3i) / (1 - i)')[0]).re); 
  print("+" + 
        graph(parse('(5 + 3i) / (1 - i)')[0]).im.toString() + "i" );

  parse('23+5');
  parse('3 - 4 + 5');
  parse('5 + ((1 + 2) * 4) - 3');
  parse('arg(5) / 3 +10');
  parse('100 *(6 - abs(3 / 10))');
  parse('(4z + 5z) * 3');
  print(printOutput(parse('3 + 4 = 7')[0]));
  print(printOutput(parse('arg((5z + 3) / (2 - z)) = 10')[0]));
  print(printOutput(parse('arg((5z - 3i) / (2z + 1)) = pi / 4')[0]));
}

