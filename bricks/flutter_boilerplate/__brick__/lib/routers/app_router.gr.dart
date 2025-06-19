// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [ExampleDetailPage]
class ExampleDetailRoute extends PageRouteInfo<ExampleDetailRouteArgs> {
  ExampleDetailRoute({
    required String id,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          ExampleDetailRoute.name,
          args: ExampleDetailRouteArgs(id: id, key: key),
          rawPathParams: {'id': id},
          initialChildren: children,
        );

  static const String name = 'ExampleDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ExampleDetailRouteArgs>(
        orElse: () => ExampleDetailRouteArgs(id: pathParams.getString('id')),
      );
      return ExampleDetailPage(id: args.id, key: args.key);
    },
  );
}

class ExampleDetailRouteArgs {
  const ExampleDetailRouteArgs({required this.id, this.key});

  final String id;

  final Key? key;

  @override
  String toString() {
    return 'ExampleDetailRouteArgs{id: $id, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ExampleDetailRouteArgs) return false;
    return id == other.id && key == other.key;
  }

  @override
  int get hashCode => id.hashCode ^ key.hashCode;
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}
