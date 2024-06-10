import 'dart:math';

class SolverUtility{
  final max_iteration = 1000000;
  final max_generate_iteration = 1000000;
  final max_count_solution = 20;
  final n_operators = 12; // sesuaikan dengan operator di level
  final List<String> operators = ['+', '-', '*', '/', '**', '//', '%', '<<', '>>', '&', '|', '^'];
  final Map<String, int> level = {"0": 0, "|": 1, "^": 2, "&": 3, "<<": 4, ">>": 4, "+": 5, "-": 5, "*": 6, "/": 6, "//": 6, "%": 6, "**": 7};
  final nonKomutatif = ["-", "/", ">>", "//", "%", "**"];
  final double infinityDouble = double.infinity;
  final int infinityInt = (1 << 31) - 1;
  final int infinity = (1 << 31) - 1;

  int minimum(int a, int b) => a < b ? a : b;

  int maximum(int a, int b) => a > b ? a : b;

  bool validDouble(double num){
    return -infinityInt < num && num < infinityInt;
  }

  String makeSolution(String operator1, String operator2, String operator, String solution1, String solution2){
    String solution = '';
    bool flag1 = operator1 == '0', flag2 = operator2 == '0';
    if(flag1 && flag2){
      return '$solution1 $operator $solution2';
    }
    if(flag1){
      operator1 = operator;
    }
    if(flag2){
      operator2 = operator;
    }
    int level1 = level[operator1]!;
    int level2 = level[operator2]!;
    int curLevel = level[operator]!;
    if(level1 >= curLevel){
      solution = '$solution1 ';
    } else{
      solution = '($solution1) ';
    }
    solution += '$operator ';
    if(level2 < curLevel){
      solution += '($solution2)';
    } else if(level2 == curLevel){
      if(!flag2 && nonKomutatif.contains(operator2)){
        solution += '($solution2)';
      } else{
        solution += solution2;
      }
    } else{
      solution += solution2;
    }
    return solution;
  }

  double calculateDouble(double a, double b, String operator) {
    double result = 0;
    try {
      switch (operator) {
        case '+':
          result = a + b;
          return validDouble(result) ? result : double.infinity;
        case '-':
          result = a - b;
          return validDouble(result) ? result : double.infinity;
        case '*':
          result = a * b;
          return validDouble(result) ? result : double.infinity;
        case '/':
          return b != 0 ? a / b : double.infinity;
        case '**':
          if(b < 0){return double.infinity;}
          if(b == 0){return 1;}
          if(a == 0){return 0;}
          result = pow(a, b).toDouble();
          return (validDouble(result)) ? result : double.infinity;
        case '//':
          return (a ~/ b).toDouble();
        case '%':
          return (a - a.toInt() == 0 && b - b.toInt() == 0 && b != 0) ? (a.toInt() % b.toInt()).toDouble() : double.infinity;
        case '<<':
          if(a - a.toInt() == 0 && b - b.toInt() == 0){
            int temp = (a.toInt() << b.toInt());
            return (temp != 0 || a == 0) ? temp.toDouble() : double.infinity;
          }
          return double.infinity;
        case '>>':
          return (a - a.toInt() == 0 && b - b.toInt() == 0) ? (a.toInt() >> b.toInt()).toDouble() : double.infinity;
        case '&':
          return (a - a.toInt() == 0 && b - b.toInt() == 0) ? (a.toInt() & b.toInt()).toDouble() : double.infinity;
        case '|':
          return (a - a.toInt() == 0 && b - b.toInt() == 0) ? (a.toInt() | b.toInt()).toDouble() : double.infinity;
        case '^':
          return (a - a.toInt() == 0 && b - b.toInt() == 0) ? (a.toInt() ^ b.toInt()).toDouble() : double.infinity;
        default:
          return double.infinity; // Handle invalid operator
      }
    } catch(e) {
      return double.infinity;
    }
  }

  int calculateInt(int a, int b, String operator) {
    int result = -1;
    try {
      switch (operator) {
        case '+':
          result = a + b;
          return ((-infinity > result && result > infinity) || (result == 0 && a != -b)) ? infinity : result;
        case '-':
          result = a - b;
          return ((-infinity > result && result > infinity) || (result == 0 && a != b)) ? infinity : result;
        case '*':
          result = a * b;
          return ((-infinity > result && result > infinity) || (result == 0 && a != 9 && b != 0)) ? infinity : result;
        case '/':
          if(b == 0){
            return infinity;
          }
          return a % b == 0? a ~/ b : infinity;
        case '**':
          if(b < 0){return infinity;}
          if(b == 0){return 1;}
          if(a == 0){return 0;}
          result = pow(a, b).toInt();
          return ((-infinity > result && result > infinity) || (result == 0)) ? infinity : result;
        case '//':
          return a ~/ b;
        case '%':
          return (b != 0) ? a % b : infinity;
        case '<<':
          return (a << b != 0 || a == 0) ? a << b : infinity;
        case '>>':
          return a >> b;
        case '&':
          return a & b;
        case '|':
          return a | b;
        case '^':
          return a ^ b;
        default:
          return infinity; // Handle invalid operator
      }
    } catch(e) {
      return infinity;
    }
  }

}