import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _hoverPassword = false;
  bool _hoverLogin = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // Sign in with Firebase Auth
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        // Special case: Auto-initialize admin account if it doesn't exist
        if (email == 'admin@edushare.com' &&
            password == 'admin123' &&
            (e.code == 'user-not-found' || e.code == 'invalid-credential')) {
          try {
            // Create the admin account
            final userCredential = await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );

            if (userCredential.user != null) {
              // Set admin flags in Firestore immediately
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userCredential.user!.uid)
                  .set({
                    'name': 'Administrator',
                    'email': email,
                    'isAdmin': true,
                    'role': 'admin',
                    'createdAt': FieldValue.serverTimestamp(),
                  });
            }
          } catch (createError) {
            debugPrint('Error auto-initializing admin: $createError');
            throw e; // Rethrow original error if creation also fails
          }
        } else {
          rethrow;
        }
      }

      if (!mounted) return;

      if (email == 'admin@edushare.com') {
        context.go('/admin');
      } else {
        context.go('/home');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Login failed")));
    } catch (e) {
      if (!mounted) return;
      debugPrint('Unexpected login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToRegister() {
    context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final isTablet = size.width >= 600 && size.width <= 900;
    final isDesktop = size.width > 900;
    final isSmallHeight = size.height < 700;

    // Responsive values
    final horizontalPadding = isMobile
        ? 16.0
        : isTablet
        ? 32.0
        : 40.0;
    final formPadding = isMobile
        ? 24.0
        : isTablet
        ? 32.0
        : 40.0;
    final logoSize = isMobile ? 32.0 : 40.0;
    final heroFontSize = isMobile
        ? 28.0
        : isTablet
        ? 36.0
        : 48.0;
    final subtitleFontSize = isMobile
        ? 14.0
        : isTablet
        ? 16.0
        : 18.0;
    final formHeaderFontSize = isMobile
        ? 24.0
        : isTablet
        ? 28.0
        : 32.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Background gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/Book_Library_zoom_backgrounds_charlene_chronicles_33-1024x576.png',
                      ),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.3),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
              ),

              // Background pattern - responsive size
              Positioned(
                top: isMobile ? -50 : -100,
                right: isMobile ? -50 : -100,
                child: Container(
                  width: isMobile
                      ? 150
                      : isTablet
                      ? 200
                      : 300,
                  height: isMobile
                      ? 150
                      : isTablet
                      ? 200
                      : 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(13, 232, 234, 237),
                  ),
                ),
              ),

              // Main content
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: isMobile ? 10 : 20,
                    ),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: child,
                          ),
                        );
                      },
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isMobile ? double.infinity : 1200,
                          minHeight:
                              constraints.maxHeight - (isMobile ? 20 : 40),
                        ),
                        child: isMobile || (isTablet && isSmallHeight)
                            ? _buildMobileLayout(
                                context,
                                size,
                                formPadding,
                                formHeaderFontSize,
                                logoSize,
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  /// LEFT SIDE - Branding & Hero
                                  if (isDesktop && !isSmallHeight)
                                    Expanded(
                                      flex: 6,
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                          isSmallHeight ? 30 : 60,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Logo
                                            Row(
                                              children: [
                                                Container(
                                                  width: logoSize,
                                                  height: logoSize,
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                        const LinearGradient(
                                                          colors: [
                                                            Color(0xFF3B82F6),
                                                            Color(0xFF1D4ED8),
                                                          ],
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.school,
                                                    color: Colors.white,
                                                    size: logoSize * 0.6,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'EduShare',
                                                  style: TextStyle(
                                                    fontSize: isTablet
                                                        ? 24
                                                        : 28,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color.fromARGB(
                                                      255,
                                                      255,
                                                      255,
                                                      255,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              height: isSmallHeight ? 20 : 40,
                                            ),

                                            // Hero text
                                            RichText(
                                              text: TextSpan(
                                                style: TextStyle(
                                                  fontSize: heroFontSize,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color.fromARGB(
                                                    255,
                                                    255,
                                                    255,
                                                    255,
                                                  ),
                                                  height: 1.2,
                                                ),
                                                children: [
                                                  const TextSpan(
                                                    text: 'Buy, Sell & Share\n',
                                                  ),
                                                  const TextSpan(
                                                    text: 'Study Materials',
                                                    style: TextStyle(
                                                      color: Color(0xFF3B82F6),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            SizedBox(
                                              height: isSmallHeight ? 12 : 20,
                                            ),

                                            // Subtitle
                                            Text(
                                              'Join thousands of students exchanging knowledge,\nnotes, and textbooks securely.',
                                              style: TextStyle(
                                                fontSize: subtitleFontSize,
                                                color: const Color.fromARGB(
                                                  255,
                                                  250,
                                                  248,
                                                  248,
                                                ),
                                                height: 1.5,
                                              ),
                                            ),

                                            SizedBox(
                                              height: isSmallHeight ? 30 : 60,
                                            ),

                                            // Features
                                            _buildFeature(
                                              icon: Icons.verified_user,
                                              title: 'Secure Transactions',
                                              subtitle:
                                                  'Protected payments & verified sellers',
                                              isMobile: false,
                                            ),
                                            SizedBox(
                                              height: isSmallHeight ? 12 : 20,
                                            ),
                                            _buildFeature(
                                              icon: Icons.bolt,
                                              title: 'Instant Access',
                                              subtitle:
                                                  'Download immediately after purchase',
                                              isMobile: false,
                                            ),
                                            SizedBox(
                                              height: isSmallHeight ? 12 : 20,
                                            ),
                                            _buildFeature(
                                              icon: Icons.attach_money,
                                              title: 'Earn Money',
                                              subtitle:
                                                  'Sell your notes and earn extra income',
                                              isMobile: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  if (isDesktop && !isSmallHeight)
                                    SizedBox(width: isTablet ? 20 : 40),

                                  /// RIGHT SIDE - Login Form
                                  Expanded(
                                    flex: isDesktop && !isSmallHeight ? 4 : 1,
                                    child: Center(
                                      child: Container(
                                        margin: EdgeInsets.all(
                                          isDesktop ? horizontalPadding : 0,
                                        ),
                                        padding: EdgeInsets.all(formPadding),
                                        constraints: BoxConstraints(
                                          maxWidth: isMobile
                                              ? double.infinity
                                              : isTablet
                                              ? 500
                                              : 600,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            isMobile ? 20 : 24,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.05,
                                              ),
                                              blurRadius: isMobile ? 20 : 40,
                                              spreadRadius: 0,
                                              offset: const Offset(0, 10),
                                            ),
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.03,
                                              ),
                                              blurRadius: isMobile ? 5 : 10,
                                              spreadRadius: 0,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Form(
                                          key: _formKey,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              // Form header
                                              Text(
                                                'Welcome Back',
                                                style: TextStyle(
                                                  fontSize: formHeaderFontSize,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(
                                                    0xFF3B82F6,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: isMobile ? 6 : 8,
                                              ),
                                              Text(
                                                'Sign in to continue to EduShare',
                                                style: TextStyle(
                                                  fontSize: isMobile ? 14 : 16,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              SizedBox(
                                                height: isMobile ? 24 : 40,
                                              ),

                                              // Email field
                                              _buildTextField(
                                                controller: emailController,
                                                icon: Icons.email_outlined,
                                                label: 'Email Address',
                                                hintText: 'Enter your email',
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter your email';
                                                  }
                                                  if (!value.contains('@') ||
                                                      !value.contains('.')) {
                                                    return 'Please enter a valid email';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(
                                                height: isMobile ? 20 : 24,
                                              ),

                                              // Password field with hover
                                              MouseRegion(
                                                onEnter: (_) => setState(
                                                  () => _hoverPassword = true,
                                                ),
                                                onExit: (_) => setState(
                                                  () => _hoverPassword = false,
                                                ),
                                                child: AnimatedScale(
                                                  scale: _hoverPassword
                                                      ? 1.02
                                                      : 1.0,
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  curve: Curves.easeOut,

                                                  child: _buildTextField(
                                                    controller:
                                                        passwordController,
                                                    icon: Icons.lock_outline,
                                                    label: 'Password',
                                                    hintText:
                                                        'Enter your password',
                                                    obscureText:
                                                        _obscurePassword,
                                                    suffixIcon: IconButton(
                                                      icon: Icon(
                                                        _obscurePassword
                                                            ? Icons
                                                                  .visibility_outlined
                                                            : Icons
                                                                  .visibility_off_outlined,
                                                        color: Colors
                                                            .grey
                                                            .shade400,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          _obscurePassword =
                                                              !_obscurePassword;
                                                        });
                                                      },
                                                    ),
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please enter your password';
                                                      }
                                                      if (value.length < 6) {
                                                        return 'Password must be at least 6 characters';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: isMobile ? 16 : 20,
                                              ),

                                              // Remember me & Forgot password
                                              Row(
                                                children: [
                                                  MouseRegion(
                                                    cursor: SystemMouseCursors
                                                        .click,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          _rememberMe =
                                                              !_rememberMe;
                                                        });
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 20,
                                                            height: 20,
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    4,
                                                                  ),
                                                              border: Border.all(
                                                                color:
                                                                    _rememberMe
                                                                    ? const Color(
                                                                        0xFF3B82F6,
                                                                      )
                                                                    : Colors
                                                                          .grey
                                                                          .shade400,
                                                                width: 2,
                                                              ),
                                                              color: _rememberMe
                                                                  ? const Color(
                                                                      0xFF3B82F6,
                                                                    )
                                                                  : Colors
                                                                        .transparent,
                                                            ),
                                                            child: _rememberMe
                                                                ? const Icon(
                                                                    Icons.check,
                                                                    size: 14,
                                                                    color: Colors
                                                                        .white,
                                                                  )
                                                                : null,
                                                          ),
                                                          const SizedBox(
                                                            width: 12,
                                                          ),
                                                          Text(
                                                            'Remember me',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey
                                                                  .shade700,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  MouseRegion(
                                                    cursor: SystemMouseCursors
                                                        .click,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        // Forgot password action
                                                      },
                                                      child: Text(
                                                        'Forgot Password?',
                                                        style: TextStyle(
                                                          color: const Color(
                                                            0xFF3B82F6,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: isMobile ? 24 : 32,
                                              ),

                                              // Login button
                                              MouseRegion(
                                                onEnter: (_) => setState(
                                                  () => _hoverLogin = true,
                                                ),
                                                onExit: (_) => setState(
                                                  () => _hoverLogin = false,
                                                ),
                                                child: AnimatedScale(
                                                  scale: _hoverLogin
                                                      ? 1.02
                                                      : 1.0,
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  curve: Curves.easeOut,

                                                  child: ElevatedButton(
                                                    onPressed: _isLoading
                                                        ? null
                                                        : _login,
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                            0xFF3B82F6,
                                                          ),
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: isMobile
                                                                ? 16
                                                                : 18,
                                                            horizontal: isMobile
                                                                ? 24
                                                                : 32,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      elevation: _hoverLogin
                                                          ? 4
                                                          : 0,
                                                      shadowColor: const Color(
                                                        0xFF3B82F6,
                                                      ).withValues(alpha: 0.3),
                                                    ),
                                                    child: _isLoading
                                                        ? const SizedBox(
                                                            width: 24,
                                                            height: 24,
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                          )
                                                        : Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              const Text(
                                                                'Sign In',
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              if (_hoverLogin) ...[
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                const Icon(
                                                                  Icons
                                                                      .arrow_forward,
                                                                  size: 20,
                                                                ),
                                                              ],
                                                            ],
                                                          ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: isMobile ? 32 : 40,
                                              ),

                                              // Sign up link
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Don't have an account? ",
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  MouseRegion(
                                                    cursor: SystemMouseCursors
                                                        .click,
                                                    child: GestureDetector(
                                                      onTap:
                                                          _navigateToRegister,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 24,
                                                              vertical: 12,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              const Color.fromARGB(
                                                                217,
                                                                14,
                                                                91,
                                                                214,
                                                              ).withValues(
                                                                alpha: 0.1,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                30,
                                                              ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              'Sign Up Free',
                                                              style: TextStyle(
                                                                color:
                                                                    const Color(
                                                                      0xFF3B82F6,
                                                                    ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            const Icon(
                                                              Icons
                                                                  .arrow_forward,
                                                              size: 16,
                                                              color: Color(
                                                                0xFF3B82F6,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Mobile layout builder
  Widget _buildMobileLayout(
    BuildContext context,
    Size size,
    double formPadding,
    double formHeaderFontSize,
    double logoSize,
  ) {
    final isSmallHeight = size.height < 700;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Logo and branding (compact for mobile)
        if (!isSmallHeight) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.school,
                  color: Colors.white,
                  size: logoSize * 0.6,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'EduShare',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Buy, Sell & Share Study Materials',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join thousands of students exchanging knowledge',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
        ],

        // Login Form Card
        Container(
          padding: EdgeInsets.all(formPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 5,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Form header
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: formHeaderFontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in to continue to EduShare',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),

                // Email field
                _buildTextField(
                  controller: emailController,
                  icon: Icons.email_outlined,
                  label: 'Email Address',
                  hintText: 'Enter your email',
                  isMobile: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password field
                _buildTextField(
                  controller: passwordController,
                  icon: Icons.lock_outline,
                  label: 'Password',
                  hintText: 'Enter your password',
                  obscureText: _obscurePassword,
                  isMobile: true,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey.shade400,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Remember me & Forgot password
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _rememberMe = !_rememberMe;
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _rememberMe
                                    ? const Color(0xFF3B82F6)
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                              color: _rememberMe
                                  ? const Color(0xFF3B82F6)
                                  : Colors.transparent,
                            ),
                            child: _rememberMe
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Remember me',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        // Forgot password action
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: const Color(0xFF3B82F6),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Login button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // Sign up link
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _navigateToRegister,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            217,
                            14,
                            91,
                            214,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Sign Up Free',
                              style: TextStyle(
                                color: const Color(0xFF3B82F6),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: Color(0xFF3B82F6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    bool isMobile = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            style: TextStyle(
              fontSize: isMobile ? 15 : 16,
              color: Colors.grey.shade800,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: isMobile ? 14 : 16,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                icon,
                color: Colors.grey.shade500,
                size: isMobile ? 20 : 24,
              ),
              suffixIcon: suffixIcon,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 14 : 16,
                vertical: isMobile ? 16 : 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isMobile = false,
  }) {
    final iconSize = isMobile ? 40.0 : 48.0;
    final iconInnerSize = isMobile ? 20.0 : 24.0;
    return Row(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF3B82F6),
            size: iconInnerSize,
          ),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
