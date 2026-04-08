import 'package:flutter/material.dart';
import 'package:wowin_crm/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/router/route_constants.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/utils/animation_extensions.dart';
import '../../../../core/widgets/full_loading_overlay.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  // Wowin brand orange -> changed to green #0D8549
  static const Color _orange = Color(0xFF0D8549);
  // light tint changed to light green
  static const Color _orangeLight = Color(0xFFEFFBF5);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      context.read<AuthBloc>().add(
            LoginSubmitted(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final isLoading = authState is AuthLoading;
          
          return Stack(
            children: [
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is Authenticated) {
                    context.goNamed(kRouteDashboard);
                  } else if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // ── Orange Header ──────────────────────────────────────
                        _buildHeader(),
          
                        // ── White Card Form ────────────────────────────────────
                        _buildFormCard(context, l10n).animateEntrance(
                          delay: const Duration(milliseconds: 200),
                        ),
          
                        // ── Bottom Footer ──────────────────────────────────────
                        _buildFooter(l10n).animateEntrance(
                          delay: const Duration(milliseconds: 400),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Full Screen Loading Overlay
              FullLoadingOverlay(
                isLoading: isLoading,
                message: l10n.loading, // Assuming 'loading' exists in l10n
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header: orange background, logo icon, title
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _orange,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo container
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _orangeLight,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ).animateScale(delay: const Duration(milliseconds: 100)),
          const SizedBox(height: 16),
          const Text(
            'Wowin CRM',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ).animateEntrance(offset: const Offset(0, 10)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Form Card: white rounded card with all form fields
  // ---------------------------------------------------------------------------
  Widget _buildFormCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Center(
                child: Text(
                  l10n.welcomeBack,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  l10n.loginSubtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Email / Username label
              Text(
                l10n.emailOrUsername,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hint: l10n.emailHint,
                prefixIcon: LucideIcons.user,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.emailEmptyError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password label + Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.password,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: navigate to forgot password
                    },
                    child: Text(
                      l10n.forgotPassword,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildPasswordField(l10n),
              const SizedBox(height: 16),

              // Remember me checkbox
              GestureDetector(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (v) =>
                            setState(() => _rememberMe = v ?? false),
                        activeColor: _orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: const BorderSide(
                          color: Color(0xFFCCCCCC),
                          width: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.rememberMe,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3C3C43),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Login Button
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _orange,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _orange.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              l10n.login,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Divider
              const Divider(color: Color(0xFFEEEEEE), height: 1),
              const SizedBox(height: 20),

              // Don't have an account
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${l10n.dontHaveAccount} ",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3C3C43),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.goNamed(kRouteRegister);
                      },
                      child: Text(
                        l10n.createAccount,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Reusable text field
  // ---------------------------------------------------------------------------
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 15),
        prefixIcon: Icon(prefixIcon, size: 20, color: const Color(0xFFAAAAAA)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _orange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  // ---------------------------------------------------------------------------
  // Password field with visibility toggle
  // ---------------------------------------------------------------------------
  Widget _buildPasswordField(AppLocalizations l10n) {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: l10n.passwordHint,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 15),
        prefixIcon:
            const Icon(LucideIcons.lock, size: 20, color: Color(0xFFAAAAAA)),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
            size: 20,
            color: const Color(0xFFAAAAAA),
          ),
          onPressed: () {
            setState(() => _isPasswordVisible = !_isPasswordVisible);
          },
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _orange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.passwordEmptyError;
        }
        return null;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Footer: copyright + policy links
  // ---------------------------------------------------------------------------
  Widget _buildFooter(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32, top: 8),
      child: Column(
        children: [
          Text(
            l10n.copyright,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8E8E93),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _footerLink(l10n.privacyPolicy),
              const SizedBox(width: 4),
              const Text('·', style: TextStyle(color: Color(0xFF8E8E93))),
              const SizedBox(width: 4),
              _footerLink(l10n.termsOfService),
              const SizedBox(width: 4),
              const Text('·', style: TextStyle(color: Color(0xFF8E8E93))),
              const SizedBox(width: 4),
              _footerLink(l10n.contactSupport),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String label) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF8E8E93),
          decoration: TextDecoration.underline,
          decorationColor: Color(0xFF8E8E93),
        ),
      ),
    );
  }
}
