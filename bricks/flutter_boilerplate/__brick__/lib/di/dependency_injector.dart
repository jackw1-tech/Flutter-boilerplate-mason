import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pine/pine.dart';
import 'package:provider/single_child_widget.dart';

part 'blocs.dart';
part 'mappers.dart';
part 'providers.dart';
part 'repositories.dart';

class DependencyInjector extends StatelessWidget {
  final Widget child;

  const DependencyInjector({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => DependencyInjectorHelper(
    blocs: blocs,
    mappers: _mappers,
    repositories: repositories,
    providers: _providers,
    child: child,
  );
}
