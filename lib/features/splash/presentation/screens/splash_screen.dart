import 'dart:async';

import 'package:fluttea/app/router/routes.dart';
import 'package:fluttea/core/constants/app/app_info.dart';
import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/state/session_state_provider.dart';
import 'package:fluttea/core/widgets/layout/app_scaffold.dart';
import 'package:fluttea/core/widgets/loading/app_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_initAndNavigate());
  }

  Future<void> _initAndNavigate() async {
    // Small delay to simulate splash display and ensure bootstrap is stable
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final session = ref.read(sessionProvider);
    if (session.isAuthenticated) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.coffee_rounded, size: 64, color: context.colors.primary),
            const SizedBox(height: Spacing.md),
            Text(
              AppInfo.name,
              style: context.text.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              context.l10n.splashTagline,
              style: context.text.bodyMedium?.copyWith(color: context.colors.outline),
            ),
            const SizedBox(height: Spacing.xl),
            const AppLoader(size: 24),
          ],
        ),
      ),
    );
  }
}
