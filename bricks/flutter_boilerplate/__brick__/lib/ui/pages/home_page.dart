import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:{{project_name.pascalCase()}}/routers/app_router.dart';
import 'package:{{project_name.pascalCase()}}/theme/ColorPalette.dart';
import 'package:{{project_name.pascalCase()}}/theme/Dimensions.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pine Architecture'),
        backgroundColor: ColorPalette.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildArchitectureHeader(),
              const SizedBox(height: 40),
              _buildArchitectureExplainer(),
              const SizedBox(height: 40),
              _buildCounterSection(),
              const SizedBox(height: 40),
              _buildNavigationDemo(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildArchitectureHeader() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.architecture, size: 80, color: ColorPalette.primary),
          const SizedBox(height: 16),
          Text(
            'Pine Architecture Skeleton',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: ColorPalette.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'A lightweight architecture for Flutter projects',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildArchitectureExplainer() {
    return Card(
      elevation: Dimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Architecture Components:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildArchitectureComponent(
              icon: Icons.map,
              title: 'Mappers',
              description: 'Convert DTOs to Models and vice versa',
            ),
            _buildArchitectureComponent(
              icon: Icons.miscellaneous_services,
              title: 'Services',
              description: 'Handle API/DB communication',
            ),
            _buildArchitectureComponent(
              icon: Icons.inventory_2,
              title: 'Repositories',
              description: 'Domain logic and data orchestration',
            ),
            _buildArchitectureComponent(
              icon: Icons.timeline,
              title: 'BLoCs',
              description: 'Business Logic Components for state management',
            ),
            _buildArchitectureComponent(
              icon: Icons.widgets,
              title: 'UI Widgets',
              description: 'Presentation layer components',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchitectureComponent({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorPalette.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: ColorPalette.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterSection() {
    return Card(
      elevation: Dimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingMedium),
        child: Column(
          children: [
            Text(
              'State Management Demo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Counter: $_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Press the + button to update state'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationDemo() {
    return Card(
      elevation: Dimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingMedium),
        child: Column(
          children: [
            Text(
              'Navigation Demo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text('Pine uses auto_route for type-safe navigation'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.router.push(ExampleDetailRoute(id: '123'));
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Navigate to Detail'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
