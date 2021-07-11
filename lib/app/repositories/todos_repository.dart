import 'package:todolist/app/database/connection.dart';
import 'package:todolist/app/models/todo_model.dart';

class TodosRepository {
  Future<List<TodoModel>> findByPeriod(DateTime start, DateTime end) async {
    var startFilter = DateTime(start.year, start.month, start.day, 0, 0, 0);
    var endFilter = DateTime(end.year, end.month, end.day, 23, 59, 59);

    var conn = await Connection().instance;
    var result = await conn.rawQuery(
      "select * from todo where data_hora between ? and ? order by data_hora",
      [startFilter.toIso8601String(), endFilter.toIso8601String()],
    );

    return result.map((t) => TodoModel.fromMap(t)).toList();
  }

  Future<void> save(DateTime dateTimeTask, String descricao) async {
    var conn = await Connection().instance;
    await conn.rawInsert(
      'insert into todo values(?,?,?,?)',
      [null, descricao, dateTimeTask.toIso8601String(), 0],
    );
  }

  Future<void> checkOrUncheck(TodoModel todo) async {
    var conn = await Connection().instance;
    await conn.rawUpdate(
      'update todo set finalizado = ? where id = ?',
      [todo.finalizado ? 1 : 0, todo.id],
    );
  }

  Future<void> delete(TodoModel todo) async {
    var conn = await Connection().instance;
    await conn.rawDelete(
      'delete from todo where id = ?',
      [todo.id],
    );
  }
}
