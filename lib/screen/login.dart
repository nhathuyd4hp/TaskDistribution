import 'dart:ui'; // Cần import để dùng ImageFilter
import 'package:fluent_ui/fluent_ui.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // State flags
  bool _showPassword = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    // Setup Animation: Fade in + Trượt nhẹ từ dưới lên
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.1), // Bắt đầu thấp hơn 1 chút
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // --- LOGIC MOCKUP ---
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Please enter both email and password.");
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isGoogleLoading = false);
  }

  void _showError(String message) {
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: const Text('Error'),
        content: Text(message),
        severity: InfoBarSeverity.error,
        onClose: close,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Stack(
        fit: StackFit.expand,
        children: [
          // 1. BACKGROUND LAYER
          // Bạn có thể thay bằng Image.asset("assets/bg.jpg", fit: BoxFit.cover)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF0F2027),
                        const Color(0xFF203A43),
                        const Color(0xFF2C5364),
                      ] // Gradient tối (Dark Blue/Teal)
                    : [
                        const Color(0xFFabbaab),
                        const Color(0xFFffffff),
                      ], // Gradient sáng (Grey/White)
              ),
            ),
          ),

          // 2. ORNAMENT (Trang trí)
          // Thêm các vòng tròn mờ để tạo chiều sâu (Bokeh effect)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.accentColor.withOpacity(0.3),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.2),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // 3. LOGIN CARD (GLASSMORPHISM)
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ClipRRect(
                  // Clip bo góc cho hiệu ứng Blur không bị tràn
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 10,
                      sigmaY: 10,
                    ), // Độ mờ kính
                    child: Container(
                      width: 400,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        // Màu nền bán trong suốt (Acrylic style)
                        color: theme.cardColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.resources.dividerStrokeColorDefault
                              .withOpacity(0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo / Header
                          Center(
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: theme.accentColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                FluentIcons.robot,
                                size: 40,
                                color: theme.accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Welcome Back",
                            textAlign: TextAlign.center,
                            style: theme.typography.title?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Inputs
                          InfoLabel(
                            label: "Email",
                            child: TextBox(
                              controller: _emailController,
                              placeholder: "nhathuyd4hp@gmail.com",
                              prefix: const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(FluentIcons.mail),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          InfoLabel(
                            label: "Password",
                            child: TextBox(
                              controller: _passwordController,
                              placeholder: "••••••••",
                              obscureText: !_showPassword,
                              prefix: const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(FluentIcons.lock),
                              ),
                              suffix: IconButton(
                                icon: Icon(
                                  _showPassword
                                      ? FluentIcons.hide3
                                      : FluentIcons.red_eye,
                                ),
                                onPressed: () => setState(
                                  () => _showPassword = !_showPassword,
                                ),
                              ),
                              onSubmitted: (_) => _handleLogin(),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Actions
                          SizedBox(
                            height: 42, // Nút cao hơn chút cho dễ bấm
                            child: FilledButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              child: _isLoading
                                  ? const ProgressRing(strokeWidth: 2.5)
                                  : const Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  "OR",
                                  style: theme.typography.caption,
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            height: 42,
                            child: Button(
                              onPressed: _isGoogleLoading
                                  ? null
                                  : _handleGoogleLogin,
                              child: _isGoogleLoading
                                  ? const ProgressRing(strokeWidth: 2.5)
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(FluentIcons.globe, size: 20),
                                        const SizedBox(width: 10),
                                        const Text("Continue with Google"),
                                      ],
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
          ),

          // 4. COPYRIGHT FOOTER
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "© 2024 Task Distribution. All rights reserved.",
                style: theme.typography.caption?.copyWith(
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
