import 'package:go_router/go_router.dart';

import '../../modules/auth/presentation/pages/login_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
  ],
);