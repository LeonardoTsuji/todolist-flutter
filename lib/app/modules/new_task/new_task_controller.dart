import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolist/app/repositories/todos_repository.dart';

class NewTaskController extends ChangeNotifier {
  final TodosRepository repository;
  DateTime daySelected;
  final dateFormat = DateFormat('dd/MM/yyyy');
  TextEditingController nomeTaskController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  bool saved = false;
  bool loading = false;
  String error;

  String get dayFormated => dateFormat.format(daySelected);

  NewTaskController({@required this.repository, String day}) {
    daySelected = dateFormat.parse(day);
  }

  Future<void> save() async {
    try {
      if (formKey.currentState.validate()) {
        loading = true;
        saved = false;
        await repository.save(daySelected, nomeTaskController.text);
        saved = true;
        loading = false;
      }
    } catch (e) {
      error = 'Erro ao salvar Todo';
    }

    notifyListeners();
  }
}
