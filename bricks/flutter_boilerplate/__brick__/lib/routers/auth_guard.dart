class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    bool isAuthenticated = true;

    if (isAuthenticated) {
      resolver.next(true);
    } else {}
  }
}
