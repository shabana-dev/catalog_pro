import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controllers/auth_bloc/auth_bloc.dart';
import '../../controllers/auth_bloc/auth_event.dart';
import '../../controllers/auth_bloc/auth_state.dart';
import '../../core/localization/app_localizations.dart';
import '../auth/login_view.dart';
import '../main_navigation.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );

    _controller.forward();
    
    // Start auth check
    context.read<AuthBloc>().add(AppStarted());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Minimum delay to show the beautiful splash screen
        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted) return;
          if (state is Authenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainNavigation()),
            );
          } else if (state is Unauthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginView()),
            );
          }
        });
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Brand Icon
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_cart_rounded,
                      size: 80,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // App Name
                  Text(
                    l10n.translate('app_name'),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle/Slogan
                  Text(
                    l10n.translate('app_slogan'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[400],
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Subtle Loading
                  SizedBox(
                    width: 40,
                    child: LinearProgressIndicator(
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      color: theme.primaryColor,
                      minHeight: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
