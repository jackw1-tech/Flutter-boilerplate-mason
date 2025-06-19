import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:{{project_name.pascalCase()}}/routers/auth_guard.dart';
import 'package:{{project_name.pascalCase()}}/ui/pages/detail_page.dart';
import 'package:{{project_name.pascalCase()}}/ui/pages/home_page.dart';

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
