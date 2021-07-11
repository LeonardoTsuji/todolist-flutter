import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:todolist/app/modules/home/home_page.dart';
import 'package:todolist/app/repositories/todos_repository.dart';

import 'app/database/connection.dart';
import 'app/modules/home/home_controller.dart';
import 'app/modules/new_task/new_task_controller.dart';
import 'app/modules/new_task/new_task_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    var connection = Connection();
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        connection.closeConnection();
        break;
      case AppLifecycleState.paused:
        connection.closeConnection();
        break;
      case AppLifecycleState.detached:
        connection.closeConnection();
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => TodosRepository(),
        )
      ],
      child: MaterialApp(
          title: 'ToDo List',
          theme: ThemeData(
            primaryColor: Color(0xFFFF9129),
            buttonColor: Color(0xFFFF9129),
            textTheme: GoogleFonts.robotoTextTheme(),
          ),
          home: ChangeNotifierProvider(
            create: (_) =>
                HomeController(repository: _.read<TodosRepository>()),
            child: HomePage(),
          ),
          routes: {
            NewTaskPage.routerName: (_) => ChangeNotifierProvider(
                  create: (context) => NewTaskController(
                      repository: context.read<TodosRepository>(),
                      day: ModalRoute.of(_).settings.arguments),
                  child: NewTaskPage(),
                )
          }),
    );
  }
}
