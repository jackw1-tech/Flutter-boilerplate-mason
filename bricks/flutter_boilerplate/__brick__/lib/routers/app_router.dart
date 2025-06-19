part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter({super.navigatorKey});

  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: '/', page: HomeRoute.page, initial: true),
    AutoRoute(
      path: '/detail/:id',
      page: ExampleDetailRoute.page,
      guards: [AuthGuard()],
    ),
  ];
}
