import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() { 
  runApp(MyApp()); 
} 
 
/// Home screen 
class HomeScreen extends StatelessWidget { 
  const HomeScreen({super.key}); 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar(title: const Text('Home')), 
      body: Center( 
        child: Column( 
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [ 
            ElevatedButton( 
              onPressed: () => context.go('/about'), 
              child: const Text('Go to About'), 
            ), 
            ElevatedButton( 
              onPressed: () => context.go('/details/42'), 
              child: const Text('Go to Details (ID: 42)'), 
            ), 
          ], 
        ), 
      ), 
    ); 
  } 
} 
 
/// About screen 
class AboutScreen extends StatelessWidget { 
  const AboutScreen({super.key}); 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar(title: const Text('About')), 
      body: Center( 
        child: ElevatedButton( 
          onPressed: () => context.pop(), 
          child: const Text('Back'), 
        ), 
      ), 
    ); 
  } 
} 
 
/// Details screen with parameter 
class DetailsScreen extends StatelessWidget { 
  final String id; 
  const DetailsScreen({super.key, required this.id}); 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar(title: Text('Details $id')), 
      body: Center( 
        child: ElevatedButton( 
          onPressed: () => context.pop(), 
          child: const Text('Back'), 
        ), 
      ), 
    ); 
  } 
} 
 
/// Error screen 
class ErrorScreen extends StatelessWidget { 
  final String message; 
  const ErrorScreen({super.key, required this.message}); 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar(title: const Text('Error')), 
      body: Center(child: Text(message)), 
    ); 
  } 
} 
 
/// Main App with GoRouter 
class MyApp extends StatelessWidget { 
  MyApp({super.key}); 
 
  // Define routes 
  final GoRouter _router = GoRouter( 
    routes: [ 
      GoRoute( 
        path: '/', 
        name: 'home', 
        builder: (context, state) => const HomeScreen(), 
      ), 
      GoRoute( 
        path: '/about', 
        name: 'about', 
        builder: (context, state) => const AboutScreen(), 
      ), 
      GoRoute( 
        path: '/details/:id', 
        name: 'details', 
        builder: (context, state) { 
          final id = state.pathParameters['id'] ?? 'unknown'; 
          return DetailsScreen(id: id); 
        }, 
      ), 
    ], 
    errorBuilder: (context, state) => 
        ErrorScreen(message: state.error.toString()), 
  ); 
@override 
  Widget build(BuildContext context) { 
    return MaterialApp.router( 
      title: 'GoRouter Example', 
      routerConfig: _router, 
      theme: ThemeData(primarySwatch: Colors.blue), 
    ); 
  }} 
 