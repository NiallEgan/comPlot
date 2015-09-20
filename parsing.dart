import 'dart:math';
import 'dart:collection';

class LinearExpression { // coef * z + con
  ComplexNumber coef;
  ComplexNumber con;
  LinearExpression(this.coef, this.con); 
}

class QuotientExpression { // numerator / denominator
  LinearExpression numerator;
  LinearExpression denominator;
  LinearExpression(this.numerator, 
                   this.Denominator);
}

class AbsExpression { // |eqn| 
    var eqn;
    AbsExpression(var eqn) {
      if(eqn is LinearExpression) {
        this.eqn = eqn;
      } else if(eqn is ComplexNumber) {
        this.eqn = new LinearExpression(0, eqn)
      }
}

class ArgExpression { // arg(coef)
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
        } else if(x is ComplexNumber && y is LinearEquation) {
          return new LinearEquation(y.coef, x + y.con);
        } else if(x is LinearEquation && y is ComplexNumber) {
          return new LinearEquation(x.coef, y + x.con);
        } else if( x is LinearEquation && y is LinearEquation) {
          return new LinearEquation(x.coef + y.coef, x.con + y.con);
        } else {
          print("Error: Incorrect operand types");
          return null;
        }});}

class Minus extends Operator {Minus(): super(0, 1, '-', 2,
        (x, y) {
        if(x is ComplexNumber && y is ComplexNumber) {
          return x - y;
        } else if(x is LinearEquation && y is ComplexNumber) {
          return new LinearEquation(x.coef, x.con - y);
        } else if(x is ComplexNumber && y is LinearEquation) {
          return new LinearEquation(-y.coef, x - y.con);
        } else if(x is LinearEquation && y is LinearEquation) {
          return new LinearEquation(x.coef - y.coef, x.con - y.con);
        } else {
          print("Error: Incorrect operand types");
          return null;
        }});}

class Divide extends Operator {Divide(): super(1, 1, '/', 2,
      (x, y) {
        if(x is ComplexNumber && y is ComplexNumber) {
          return x / y;
        } else if(x is LinearEquation && y is ComplexNumber) {
          return new LinearEquation(x.coef / y, x.con / y);
        } else if(x is ComplexNumber && y is LinearEquation) {
          return new QuotientEquation(new LinearEquation(0, x), y);
        } else if(x is LinearEquation && y is LinearEquation) {
          return new QuotientEquation(x, y);
        } else {
          print("Error: Incorrect operand types");
          return null;
        }});}

class Multiply extends Operator {Multiply(): super(1, 1, '*', 2, 
      (x, y) {
        if(x is ComplexNumber && y is ComplexNumber) {
          return x * y;
        } else if(x is LinearEquation && y is ComplexNUmber) {
          return new LinearEquation(x.coef * y, x.con * y);
        } else if(x is ComplexNumber && y is LinearEquation) {
          return new LinearEquation(y.coef * x, y.con * x);
        } else if(x is LinearEquation && y is LinearEquation) {
          print("Error: Polynomials are not supported");
        } else {
          print("Error: Incorrect operand types");
          return null;
        }});}

class Arg extends Operator {Arg(): super(2, 1, 'arg', 1, 
      (eqn) => new ArgExpression(eqn));}
class Abs extends Operator {Abs(): super(2, 1, 'abs', 1,
      (eqn) => new AbsExpressionn(eqn));}
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
        output.addLast(new LinearExpression(n, 0));
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
      output.addLast(new LinearExpression(1, 0));
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
  if(side != 1) print("Error: No equation to plot");
  return [lhs, output];
}

String graph(Queue lhs, Queue rhs) {
  // Build the syntax tree
  Queue buildSide(Queue eqn) {
    Queue operands = new Queue();
    while(eqn.isNotEmpty) {
      var token = eqn.removeFirst();
      if(token is ComplexNumber || token is LinearEquation || 
         token is QuotientEquation || token is ArgExpression ||
         token is ModEquation) {
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
    // Can't check for errors until we see whats on the other side
    return operands;
  }
  lhs = buildSide(lhs);
  rhs = buildSide(rhs);

  // Transform to graphable form
}

main() {
  parse('3 + 4');
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

