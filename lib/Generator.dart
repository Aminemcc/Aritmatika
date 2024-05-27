import 'dart:math';
import 'Solver.dart';
import 'SolverInt.dart';
import 'SolverUtility.dart';

class Generator {

  //untuk mendapatkan fungsi calculate
  SolverUtility util = SolverUtility();
  Random random = Random();
  int countIteration = 0;
  List<String> operators = [];

  Generator(){
    operators = List.from(util.operators);
  }

  List<int> generateNumbersInt(int n, int mini, int maxi){
    List<int> numbers = [];
    for(int i = 0; i < n ; i++){
      numbers.add(random.nextInt(maxi - mini) + mini);
    }
    return numbers;
  }
  List<double> generateNumbersDouble(int n, int mini, int maxi){
    List<double> numbers = [];
    for(int i = 0; i < n ; i++){
      numbers.add((random.nextInt(maxi - mini) + mini).toDouble());
    }
    return numbers;
  }

  List<String> randomOperators(int n){
    if(n > util.n_operators){
      n = util.n_operators;
    } else if(n <= 1){
      n = 3;
    }
    operators.shuffle();
    return operators.take(n).toList();

  }

  Map<String, dynamic> generate(int n, int mini, int maxi, int target_mini, int target_maxi, List<String> operators, bool intergerOnlyMode){
    // would return List of n numbers, 1 target number, 1 solution
    // numbers : List of numbers (int)
    // target : target number
    // solution : String of 1 solution only
    countIteration = 0;
    if(intergerOnlyMode){
      return generateInt(n, mini, maxi, target_mini, target_maxi, operators);
    }
    else{
      return generateDouble(n, mini, maxi, target_mini, target_maxi, operators);
    }
    Map<String, dynamic> temp = {};
    return temp;
  }
  Map<String, dynamic> generateInt(int n, int mini, int maxi, int target_mini, int target_maxi, List<String> operators){
    bool foundTarget = false;
    List<int> originalNumbers = generateNumbersInt(n, mini, maxi);
    List<int> numbers = [];
    List<String> solutions = [];
    List<String> curOperators = [];
    String operator = '', solution1 = '', solution2 = '', curSolution = '';
    int index1 = 0, index2 = 0, num1 = 0, num2 = 0, result = 0;
    String operator1 = '0', operator2 = '0';
    while(!foundTarget) {
      numbers = List.from(originalNumbers);
      solutions = numbers.map<String>((int number) => number.toString()).toList();
      curOperators = List.generate(numbers.length, (index) => '0');
      while (numbers.length > 1) {
        countIteration++;
        if(countIteration > util.max_generate_iteration){
          foundTarget = true;
          break;
        }
        num1 = random.nextInt(numbers.length);
        num2 = random.nextInt(numbers.length);
        if (num1 == num2) {
          continue;
        }
        index1 = util.minimum(num1, num2);
        index2 = util.maximum(num1, num2);
        num1 = numbers[index1];
        num2 = numbers[index2];
        operator = operators[random.nextInt(operators.length)];
        result = util.calculateInt(num1, num2, operator);
        if (result == util.infinityInt) {
          continue;
        }
        num2 = numbers.removeAt(index2);
        num1 = numbers.removeAt(index1);
        solution2 = solutions.removeAt(index2);
        solution1 = solutions.removeAt(index1);
        operator2 = curOperators.removeAt(index2);
        operator1 = curOperators.removeAt(index1);
        curSolution = util.makeSolution(
            operator1, operator2, operator, solution1, solution2);

        numbers.add(result);
        solutions.add(curSolution);
        curOperators.add(operator);
      }
      if(countIteration > util.max_generate_iteration){
        Map<String, dynamic> ret = {'numbers': null, 'target': null, 'operators': null, 'solution': null};
        return ret;
      }
      if(target_mini <= numbers[0] && numbers[0] <= target_maxi){
        print(countIteration);
        foundTarget = true;
      }
    }
    Map<String, dynamic> ret = {'numbers': originalNumbers, 'target': numbers[0].toInt(), 'operators': operators, 'solution': solutions[0]};
    return ret;
  }
  Map<String, dynamic> generateDouble(int n, int mini, int maxi, int target_mini, int target_maxi, List<String> operators){
    bool foundTarget = false;
    List<int> originalNumbers = generateNumbersInt(n, mini, maxi);
    List<double> numbers = [];
    List<String> solutions = [];
    List<String> curOperators = [];
    String operator = '', solution1 = '', solution2 = '', curSolution = '';
    int index1 = 0, index2 = 0, temp1 = 0, temp2 = 0;
    double num1 = 0, num2 = 0, result = 0;
    String operator1 = '0', operator2 = '0';
    while(!foundTarget) {
      numbers = originalNumbers.map<double>((int number) => number.toDouble()).toList();
      solutions = originalNumbers.map<String>((int number) => number.toString()).toList();
      curOperators = List.generate(numbers.length, (index) => '0');
      while (numbers.length > 1) {
        countIteration++;
        if(countIteration > util.max_generate_iteration){
          foundTarget = true;
          break;
        }
        temp1 = random.nextInt(numbers.length);
        temp1 = random.nextInt(numbers.length);
        if (temp1 == temp2) {
          continue;
        }
        index1 = util.minimum(temp1, temp2);
        index2 = util.maximum(temp1, temp2);
        num1 = numbers[index1];
        num2 = numbers[index2];
        operator = operators[random.nextInt(operators.length)];
        result = util.calculateDouble(num1, num2, operator);
        if (result == util.infinityInt) {
          continue;
        }
        num2 = numbers.removeAt(index2);
        num1 = numbers.removeAt(index1);
        solution2 = solutions.removeAt(index2);
        solution1 = solutions.removeAt(index1);
        operator2 = curOperators.removeAt(index2);
        operator1 = curOperators.removeAt(index1);
        curSolution = util.makeSolution(
            operator1, operator2, operator, solution1, solution2);

        numbers.add(result);
        solutions.add(curSolution);
        curOperators.add(operator);
      }
      if(countIteration > util.max_generate_iteration){
        print("MAX ITERATION");
        Map<String, dynamic> ret = {'numbers': null, 'target': null, 'operators': null, 'solution': null};
        return ret;
      }
      if(target_mini <= numbers[0] && numbers[0] <= target_maxi && numbers[0] - numbers[0].toInt() == 0){
        foundTarget = true;
      }
    }
    Map<String, dynamic> ret = {'numbers': originalNumbers, 'target': numbers[0].toInt(), 'operators': operators, 'solution': solutions[0]};
    return ret;
  }

}