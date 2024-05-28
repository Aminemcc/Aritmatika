import 'dart:math';

import 'package:aritmatika/utils/SolverUtility.dart';


class SolverInt {
  // Constant / Original
  final SolverUtility util = SolverUtility();
  int max_iteration = 0;
  int max_count_solution = 0;
  int infinity = 0;
  Map<String, int> level = {};
  List<String> nonKomutatif = [];
  late Function minimum, maximum, calculate, makeSolution;

  SolverInt(){
    max_iteration = util.max_iteration;
    max_count_solution = util.max_count_solution;
    infinity = util.infinityInt;
    level = util.level;
    nonKomutatif = util.nonKomutatif;

    minimum = util.minimum;
    maximum = util.maximum;
    calculate = util.calculateInt;
    makeSolution = util.makeSolution;
  }

  int target = 24;
  List<int> numbers = [4,5,6,7];
  List<String> operators = ["+","-","*","/"];
//   final List<String> operators = ["/"];

  // Temp
  int iMin = 0;
  int iMax = 0;

  // States
  List<int> bitState = [];

  Map<String, int> dp = {};
  Set<String> solutions = {};
  int cur_iteration = 0;
  int countSolution = 0;


  List<String> solve(List<int> new_numbers, int new_target, List<String> selectedOperators) {
    SolverInt();
    target = new_target;
    operators = selectedOperators;
    numbers.clear();
    cur_iteration = 0;
    numbers = List.from(new_numbers);
    // numbers = new_numbers;
    dp.clear();
    solutions.clear();
    countSolution = 0;
    bitState =  List.generate(this.numbers.length, (index) => 0);
    List<String> stringList =
    new_numbers.map<String>((int number) => number.toString()).toList();
    List<String> operatorList = List.generate(numbers.length, (index) => '0');
    _solve(stringList, List<int>.from(numbers), operatorList, 0);
    return solutions.toList();
  }

  void _solve(List<String> curSolution, List<int> curNumbers,
      List<String> curOperators, int depth) {
    cur_iteration++;
    if (depth == this.numbers.length - 1 || cur_iteration > max_iteration) {
      if (curNumbers[0] == this.target) {
        solutions.add(curSolution[0]);
        countSolution++;
//         print(curSolution[0]);
      } else if (cur_iteration == max_iteration){
        solutions.add("Max Iteration Reached");
      }
      return;
    }
    if(countSolution > max_count_solution){
      return;
    }
    String tempState = "";
    int temp = 0;
    int prev1 = 0;
    int prev2 = 0;
    for (int i = 0; i < numbers.length; i++) {
      if (curNumbers[i] == infinity) {
        continue;
      }
      for (int j = 0; j < numbers.length; j++) {
        if (i == j || curNumbers[j] == infinity) {
          continue;
        }
        for (int k = 0; k < operators.length; k++) {
          temp = calculate(curNumbers[i], curNumbers[j], operators[k]);
          if (temp == infinity || temp.isNaN) {
            continue;
          }
          prev1 = bitState[i];
          prev2 = bitState[j];
          bitState[i] = 1;
          bitState[j] = 1;
          tempState = bitState.join("") + '$temp';
          if (dp[tempState] == null) {
//             dp[tempState] = 1;
            List<int> tempNumbers = List.from(curNumbers);
            List<String> tempSolution = List.from(curSolution);
            List<String> tempOperators = List.from(curOperators);
            iMin = minimum(i, j);
            iMax = maximum(i, j);
            tempSolution[iMin] = makeSolution(curOperators[i], curOperators[j], operators[k], curSolution[i], curSolution[j]);
            tempSolution[iMax] = "";
            tempNumbers[iMin] = temp;
            tempNumbers[iMax] = infinity;
            tempOperators[iMin] = operators[k];
            tempOperators[iMax] = '0';
            _solve(tempSolution, tempNumbers, tempOperators, depth + 1);
          }
          bitState[i] = prev1;
          bitState[j] = prev2;
        }
      }
    }
  }
}
