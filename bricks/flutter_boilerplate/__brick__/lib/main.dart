

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