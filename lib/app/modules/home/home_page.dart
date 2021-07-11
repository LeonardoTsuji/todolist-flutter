import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todolist/app/modules/new_task/new_task_page.dart';

import 'home_controller.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      backgroundColor: Colors.white,
      title: Text(
        'Atividades',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
    return Consumer<HomeController>(
      builder: (BuildContext contextConsumer, HomeController controller, _) {
        return Scaffold(
          appBar: appBar,
          bottomNavigationBar: FFNavigationBar(
            theme: FFNavigationBarTheme(
              itemWidth: 60,
              barHeight: 70,
              barBackgroundColor: Theme.of(context).primaryColor,
              unselectedItemIconColor: Colors.white,
              unselectedItemLabelColor: Colors.white,
              selectedItemBorderColor: Colors.white,
              selectedItemBackgroundColor: Theme.of(context).primaryColor,
              selectedItemIconColor: Colors.white,
              selectedItemLabelColor: Colors.black,
            ),
            selectedIndex: controller.selectedTab,
            onSelectTab: (index) =>
                controller.changeSelectedTab(context, index),
            items: [
              FFNavigationBarItem(
                iconData: Icons.check_circle,
                label: 'Finalizados',
              ),
              FFNavigationBarItem(
                iconData: Icons.view_week,
                label: 'Semanal',
              ),
              FFNavigationBarItem(
                iconData: Icons.calendar_today,
                label: 'Selecionar data',
              ),
            ],
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height -
                appBar.preferredSize.height -
                MediaQuery.of(context).padding.top,
            child: RefreshIndicator(
              onRefresh: () => controller.update(),
              child: ListView.builder(
                  itemCount: controller.listTodos?.keys?.length ?? 0,
                  itemBuilder: (_, index) {
                    var dateFormat = DateFormat('dd/MM/yyyy');
                    var listTodos = controller.listTodos;
                    var dayKey = listTodos.keys.elementAt(index);

                    var day = dayKey;
                    var todos = listTodos[dayKey];

                    if (todos.isEmpty && controller.selectedTab == 0) {
                      return SizedBox();
                    }

                    var today = DateTime.now();
                    if (dayKey == dateFormat.format(today)) {
                      day = 'HOJE';
                    } else if (dayKey ==
                        dateFormat.format(today.add(Duration(days: 1)))) {
                      day = 'AMANHÃ';
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 20),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () async => {
                                  await Navigator.of(context).pushNamed(
                                      NewTaskPage.routerName,
                                      arguments: dayKey),
                                  controller.update(),
                                },
                                icon: Icon(
                                  Icons.add_circle,
                                  color: Theme.of(context).primaryColor,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: todos.length,
                            itemBuilder: (_, index) {
                              var todo = todos[index];
                              return Dismissible(
                                key: Key(todo.id.toString()),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) => controller.delete(todo),
                                confirmDismiss: (_) =>
                                    _buildConfirmDelete(context),
                                background: Container(
                                  alignment: AlignmentDirectional.centerEnd,
                                  color: Colors.red,
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                child: CheckboxListTile(
                                  activeColor: Theme.of(context).primaryColor,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  onChanged: (bool value) =>
                                      controller.checkedOrUncheck(todo),
                                  value: todo.finalizado,
                                  title: Text(
                                    todo.descricao,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      decoration: todo.finalizado
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  secondary: Text(
                                    '${todo.dataHora.hour.toString().padLeft(2, '0')}:${todo.dataHora.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              );
                            })
                      ],
                    );
                  }),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _buildConfirmDelete(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Excluir!'),
          content: Text('Confirma a exclusão da task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Confirmar',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}
