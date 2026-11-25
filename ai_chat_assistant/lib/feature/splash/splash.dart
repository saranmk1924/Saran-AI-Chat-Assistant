import 'package:ai_chat_assistant/core/common_widget/chat_background.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/bloc/chat_bloc.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/bloc/chat_event.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/pages/chat_page.dart';
import 'package:ai_chat_assistant/core/dependencies/init_dependencies.dart';
import 'package:ai_chat_assistant/feature/splash/floating_ai_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, _, _) => BlocProvider(
          create: (_) =>
              serviceLocator<ChatBloc>()..add(const LoadHistoryEvent()),
          child: const ChatPage(),
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ChatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Decorative outer circle
                    Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: scheme.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                    ),

                    // Your profile image
                    Hero(
                      tag: 'saran_profile',
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: scheme.primary, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.3),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 76,
                          backgroundImage: AssetImage('assets/app_icon.png'),
                        ),
                      ),
                    ),

                    // AI icons surrounding your image
                    Positioned(
                      top: 12,
                      left: 25,
                      child: FloatingAIIcon(
                        icon: Icons.smart_toy_outlined,
                        color: scheme.primary,
                        duration: const Duration(milliseconds: 1800),
                      ),
                    ),

                    Positioned(
                      top: 35,
                      right: 12,
                      child: FloatingAIIcon(
                        icon: Icons.auto_awesome,
                        color: Colors.blueAccent,
                        duration: const Duration(milliseconds: 2200),
                      ),
                    ),

                    Positioned(
                      bottom: 28,
                      left: 8,
                      child: FloatingAIIcon(
                        icon: Icons.hub_outlined,
                        color: Colors.deepPurpleAccent,
                        duration: const Duration(milliseconds: 2000),
                      ),
                    ),

                    Positioned(
                      bottom: 12,
                      right: 28,
                      child: FloatingAIIcon(
                        icon: Icons.psychology_outlined,
                        color: scheme.primary,
                        duration: const Duration(milliseconds: 2400),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              Text(
                'Saran AI',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
