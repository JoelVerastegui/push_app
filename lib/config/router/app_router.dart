import 'package:go_router/go_router.dart';
import 'package:push_app/presentation/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: '/push-details/:pushMessageId',
      name: DetailsScreen.name,
      builder: (context, state) {
        final pushMessageId = state.pathParameters['pushMessageId'] ?? '';

        return DetailsScreen(pushMessageId: pushMessageId);
      },
    )
  ]
);