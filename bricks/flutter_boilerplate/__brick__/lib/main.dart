import 'package:flutter/material.dart';
import 'package:{{project_name}}/di/dependency_injector.dart';
import 'package:{{project_name}}/routers/app_router.dart';
import 'package:{{project_name}}/theme/AppTheme.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  /*
  await FirebaseConfig.init();
  await SupabaseConfig.init();
  */


  runApp(const {{project_name.pascalCase()}}App());
}

class {{project_name.pascalCase()}}App extends StatelessWidget {
  const {{project_name.pascalCase()}}App({super.key});

  @override
  Widget build(BuildContext context) {
  final appRouter = AppRouter();

    return DependencyInjector(
           child: MaterialApp.router(
      title: '{{project_name.titleCase()}}',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter.config(),
    ));
  }
}

