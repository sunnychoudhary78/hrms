import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lms/app/app_routes.dart';
import 'package:lms/core/providers/app_restart_provider.dart';
import 'package:lms/core/providers/global_loading_provider.dart';
import 'package:lms/core/theme/app_theme_provider.dart';
import 'package:lms/core/theme/theme_mode_provider.dart';
import 'package:lms/shared/widgets/global_error.dart';
import 'package:lms/shared/widgets/global_loader.dart';
import 'package:lms/shared/widgets/global_sucess.dart';
import 'app/app_root.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    const ProviderScope(
      child: Root(), // 🔥 ProviderScope must wrap everything
    ),
  );
}

class Root extends ConsumerWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restartKey = ref.watch(appRestartProvider);

    return KeyedSubtree(
      key: ValueKey(restartKey), // 🔥 This forces full rebuild
      child: const MyApp(),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = ref.watch(appThemeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),

      home: const AppRoot(),
      routes: AppRoutes.routes,

      builder: (context, child) {
        return Consumer(
          builder: (context, ref, _) {
            final overlay = ref.watch(globalLoadingProvider);

            return Stack(
              children: [
                child!,

                /// Loading
                if (overlay.isLoading) GlobalLoader(message: overlay.message),

                /// Success (placeholder for now)
                if (overlay.isSuccess) GlobalSuccess(message: overlay.message),

                /// Error (placeholder for now)
                if (overlay.isError) GlobalError(message: overlay.message),
              ],
            );
          },
        );
      },
    );
  }
}
