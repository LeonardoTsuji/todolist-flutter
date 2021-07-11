import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolist/app/models/todo_model.dart';
import 'package:collection/collection.dart';
import 'package:todolist/app/repositories/todos_repository.dart';

class HomeController extends ChangeNotifier {
  final TodosRepository repository;
  int selectedTab = 1;
  DateTime daySelected;
  DateTime startFilter;
  DateTime endFilter;
  Map<String, List<TodoModel>> listTodos;
  var dateFormat = DateFormat('dd/MM/yyyy');
  bool saved = false;
  bool loading = false;
  String error;

  HomeController({@required this.repository}) {
    findAllForWeek();
  }

  Future<void> changeSelectedTab(BuildContext context, int index) async {
    selectedTab = index;
    switch (index) {
      case 0:
        filterDone();
        break;
      case 1:
        findAllForWeek();
        break;
      case 2:
        var day = await showDatePicker(
            context: context,
            initialDate: daySelected,
            firstDate: DateTime.now().subtract(Duration(days: 365 * 3)),
            lastDate: DateTime.now().add(Duration(days: 365 * 10)));
        if (day != null) {
          daySelected = day;
          findTodosBySelectedDay();
        }
        break;
    }
    notifyListeners();
  }

  Future<void> findAllForWeek() async {
    daySelected = DateTime.now();

    startFilter = DateTime.now();

    if (startFilter.weekday != DateTime.monday) {
      startFilter =
          startFilter.subtract(Duration(days: (startFilter.weekday - 1)));
    }

    endFilter = startFilter.add(Duration(days: 6));

    var todos = await repository.findByPeriod(startFilter, endFilter);

    if (todos.isEmpty) {
      listTodos = {dateFormat.format(DateTime.now()): []};
    } else {
      listTodos =
          groupBy(todos, (TodoModel todo) => dateFormat.format(todo.dataHora));
    }

    this.notifyListeners();
  }

  void checkedOrUncheck(TodoModel todo) {
    todo.finalizado = !todo.finalizado;
    this.notifyListeners();
    repository.checkOrUncheck(todo);
  }

  void filterDone() {
    listTodos = listTodos.map((key, value) {
      var todosDone = value.where((t) => t.finalizado).toList();
      return MapEntry(key, todosDone);
    });
    this.notifyListeners();
  }

  void findTodosBySelectedDay() async {
    var todos = await repository.findByPeriod(daySelected, daySelected);

    if (todos.isEmpty) {
      listTodos = {dateFormat.format(daySelected): []};
    } else {
      listTodos =
          groupBy(todos, (TodoModel todo) => dateFormat.format(todo.dataHora));
    }

    this.notifyListeners();
  }

  Future<void> update() async {
    if (selectedTab == 1) {
      this.findAllForWeek();
    } else if (selectedTab == 2) {
      this.findTodosBySelectedDay();
    }
  }

  Future<void> delete(TodoModel todo) async {
    try {
      loading = true;
      saved = false;
      await repository.delete(todo);
      saved = true;
      loading = false;
    } catch (e) {
      error = 'Erro ao salvar Todo';
    }
    this.update();
    notifyListeners();
  }
}
