import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/occasion_form/occasion_form_screen.dart';
import 'features/occasion_detail/occasion_detail_screen.dart';
import 'features/checklist/checklist_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/occasions/new',
      builder: (context, state) => const OccasionFormScreen(occasionId: null),
    ),
    GoRoute(
      path: '/occasions/:id/edit',
      builder: (ctx, state) => OccasionFormScreen(
        occasionId: state.pathParameters['id'],
      ),
    ),
    GoRoute(
      path: '/occasions/:id/detail',
      builder: (ctx, state) => OccasionDetailScreen(
        occasionId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/occasions/:id/checklist',
      builder: (ctx, state) => ChecklistScreen(
        occasionId: state.pathParameters['id']!,
      ),
    ),
  ],
);

class MochimonoApp extends StatelessWidget {
  const MochimonoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'カンリィ',
      theme: buildDarkTheme(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
