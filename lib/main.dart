import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants.dart';
import 'core/design_system.dart';
import 'presentation/routes/app_router.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase via helper
  await SupabaseService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Bugatti Cars | بوقاتي كار',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Use the new dark theme
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRoutes.splash, // Start with the splash screen
    );
  }
}
