import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foot_bro/entity/user/user.dart';
import 'package:foot_bro/pages/homePage.dart';
import 'package:foot_bro/pages/loginPage.dart';
import 'package:foot_bro/pages/registerPage.dart';
import 'package:foot_bro/service/authService.dart';
import 'package:foot_bro/store/storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FootBro',
      showPerformanceOverlay: false,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      // Inizia con la splash screen invece del login
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MyHomePage(title: 'FootBro Home'),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  static const Duration _validationDelay = Duration(seconds: 1);

  bool _isConnecting = false;
  bool _showRetryButton = false;
  int _retryCount = 0;
  String _errorMessage = '';

  // Animazioni
  late AnimationController _logoAnimationController;
  late AnimationController _ballAnimationController;
  late AnimationController _pulseAnimationController;

  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _ballSlideAnimation;
  late Animation<double> _ballRotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
    // Aspetta che le animazioni iniziali finiscano prima di controllare il login
    Future.delayed(const Duration(milliseconds: 2000), () {
      _checkLoginStatus();
    });
  }

  void _initAnimations() {
    // Animazione logo
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Animazione pallone
    _ballAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Animazione pulse per il loading
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    _ballSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: const Offset(1.5, 0),
    ).animate(CurvedAnimation(
      parent: _ballAnimationController,
      curve: Curves.easeInOut,
    ));

    _ballRotationAnimation = Tween<double>(
      begin: 0,
      end: 6 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _ballAnimationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _logoAnimationController.forward();

    // Inizia l'animazione del pallone dopo un po'
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _ballAnimationController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _ballAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final String? token = await _getStoredToken();

      if (token == null || token.isEmpty) {
        _navigateToLogin();
        return;
      }

      await _validateTokenWithRetry(token);
    } catch (e) {
      _handleUnexpectedError(e);
    }
  }

  Future<String?> _getStoredToken() async {
    return await getToken();
  }

  Future<void> _validateTokenWithRetry(String token) async {
    setState(() {
      _isConnecting = true;
      _retryCount = 0;
      _showRetryButton = false;
      _errorMessage = '';
    });

    _pulseAnimationController.repeat(reverse: true);

    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        await Future.delayed(_validationDelay);
        final bool isValid = await _validateTokenWithBackend(token);

        if (isValid) {
          final userJson = await getUserJson();
          if (userJson == null) {
            _navigateToLogin();
            return;
          }
          final User user = User.fromJson(jsonDecode(userJson));
          _navigateToHome(user);
          return;
        } else {
          await _clearStoredData();
          _navigateToLogin();
          return;
        }
      } catch (e) {
        _retryCount = attempt + 1;

        if (_retryCount < _maxRetries) {
          setState(() {
            _errorMessage = 'Tentativo $_retryCount di $_maxRetries fallito';
          });
          await Future.delayed(_retryDelay);
        } else {
          _showRetryOption(e);
          return;
        }
      }
    }
  }

  Future<bool> _validateTokenWithBackend(String token) async {
    final AuthService authService = AuthService();
    return authService.validateToken(token);
  }

  Future<void> _clearStoredData() async {

    await clearUserData();
  }

  void _showRetryOption(dynamic error) {
    _pulseAnimationController.stop();
    setState(() {
      _isConnecting = false;
      _showRetryButton = true;
      _errorMessage = 'Impossibile connettersi al server.\nVerifica la tua connessione internet.';
    });
  }

  void _handleUnexpectedError(dynamic error) {
    _pulseAnimationController.stop();
    setState(() {
      _isConnecting = false;
      _showRetryButton = true;
      _errorMessage = 'Si è verificato un errore imprevisto.';
    });

    debugPrint('Errore inaspettato in SplashScreen: $error');
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _navigateToHome(User user) {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home', arguments: user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[700]!,
              Colors.green[500]!,
              Colors.lightGreen[300]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Pallone animato (solo durante il caricamento iniziale)
              if (!_showRetryButton)
                AnimatedBuilder(
                  animation: _ballSlideAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: MediaQuery.of(context).size.height * 0.3,
                      left: MediaQuery.of(context).size.width * 0.5 +
                          _ballSlideAnimation.value.dx * MediaQuery.of(context).size.width * 0.4 - 20,
                      child: AnimatedBuilder(
                        animation: _ballRotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _ballRotationAnimation.value,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.sports_soccer,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

              // Contenuto principale
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo animato
                      AnimatedBuilder(
                        animation: _logoFadeAnimation,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _logoFadeAnimation,
                            child: ScaleTransition(
                              scale: _logoScaleAnimation,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 25,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.sports_soccer,
                                  size: 80,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Titolo app
                      AnimatedBuilder(
                        animation: _logoFadeAnimation,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _logoFadeAnimation,
                            child: Text(
                              'FootBro',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.4),
                                    offset: const Offset(3, 3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      AnimatedBuilder(
                        animation: _logoFadeAnimation,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _logoFadeAnimation,
                            child: Text(
                              'Il tuo compagno di squadra digitale',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 80),

                      // Stato di caricamento
                      if (_isConnecting) ...[
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Connessione in corso...',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_errorMessage.isNotEmpty && _retryCount > 0) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],

                      // Bottone retry
                      if (_showRetryButton) ...[
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.wifi_off,
                            size: 40,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _isConnecting ? null : _checkLoginStatus,
                          icon: const Icon(Icons.refresh),
                          label: const Text(
                            'Riprova',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green[600],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 8,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => _navigateToLogin(),
                          child: Text(
                            'Accedi con un altro account',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}