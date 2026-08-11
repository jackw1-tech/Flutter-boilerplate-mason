import 'package:auto_route/auto_route.dart';

class AuthGuard extends AutoRouteGuard {
  /// Replace with your own authentication check (e.g. a token read from a
  /// repository or from secure storage).
  bool get isAuthenticated => true;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (isAuthenticated) {
      resolver.next(true);
    } else {
      // Block the navigation and redirect to your login route, e.g.:
      // router.push(const LoginRoute());
      resolver.next(false);
    }
  }
}
