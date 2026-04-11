import 'package:flutter/material.dart';
import 'package:wowin_crm/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/router/route_constants.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _agreedToTerms = false;
  String? _selectedSalesType;

  // changed orange -> new green #0D8549
  static const Color _orange = Color(0xFF0D8549);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.agreeTermsError),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      context.read<AuthBloc>().add(
            RegisterSubmitted(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              salesType: _selectedSalesType ?? '',
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            // Auto-login after register: go to dashboard
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
          child: Column(
            children: [
              // ── Orange App Bar ─────────────────────────────────────
              _buildAppBar(),

              // ── Scrollable body ────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Title & subtitle
                      Text(
                        l10n.createSalesAccount,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.registrationSubtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Form card
                      _buildFormCard(l10n),

                      const SizedBox(height: 24),

                      // OR divider
                      _buildOrDivider(l10n),

                      const SizedBox(height: 20),

                      // Already have an account
                      _buildLoginLink(l10n),

                      const SizedBox(height: 32),
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

  // ---------------------------------------------------------------------------
  // Orange App Bar
  // ---------------------------------------------------------------------------
  Widget _buildAppBar() {
    return Container(
      color: _orange,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(kRouteLogin);
              }
            },
          ),
          const Expanded(
            child: Text(
              'Wowin CRM',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          // Balance the back button
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Form card
  // ---------------------------------------------------------------------------
  Widget _buildFormCard(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Lengkap
          _buildLabel(l10n.fullName),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _nameController,
            hint: l10n.fullNameHint,
            prefixIcon: LucideIcons.user,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? l10n.emailEmptyError // Reusing or adding name empty error
                : null,
          ),
          const SizedBox(height: 16),

          // Work Email
          _buildLabel(l10n.workEmail),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _emailController,
            hint: 'name@company.com',
            prefixIcon: LucideIcons.mail,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.emailEmptyError;
              if (!v.contains('@')) return l10n.invalidEmail;
              return null;
            },
          ),
          const SizedBox(height: 16),

          const SizedBox(height: 16),

          // Password
          _buildLabel(l10n.password),
          const SizedBox(height: 8),
          _buildPasswordField(l10n),
          const SizedBox(height: 16),

          // Sales Type
          _buildLabel('Tipe Sales'),
          const SizedBox(height: 8),
          _buildSalesTypeDropdown(l10n),
          const SizedBox(height: 20),

          // Terms & Conditions checkbox
          _buildTermsCheckbox(l10n),
          const SizedBox(height: 28),

          // Sign Up button
          _buildSignUpButton(l10n),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Re-usable field label
  // ---------------------------------------------------------------------------
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Re-usable text field
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
        hintText: l10n.minCharacters,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 15),
        prefixIcon:
            const Icon(LucideIcons.lock, size: 20, color: Color(0xFFAAAAAA)),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
            size: 20,
            color: const Color(0xFFAAAAAA),
          ),
          onPressed: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
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
      validator: (v) {
        if (v == null || v.isEmpty) return l10n.passwordEmptyError;
        if (v.length < 8) return l10n.passwordEmptyError; // or specific length error
        return null;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Terms & Conditions checkbox
  // ---------------------------------------------------------------------------
  Widget _buildTermsCheckbox(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: _agreedToTerms,
              onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
              activeColor: _orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: const BorderSide(color: Color(0xFFCCCCCC), width: 1.5),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.agreeToTerms,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF3C3C43),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sign Up button
  // ---------------------------------------------------------------------------
  Widget _buildSignUpButton(AppLocalizations l10n) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return SizedBox(
          width: double.infinity,
          height: 54,
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.signUp,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.arrowRight, size: 18),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSalesTypeDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      value: _selectedSalesType,
      items: const [
        DropdownMenuItem(value: 'motoris', child: Text('Motoris')),
        DropdownMenuItem(value: 'task_order', child: Text('Task Order')),
        DropdownMenuItem(value: 'canvas', child: Text('Canvas')),
      ],
      onChanged: (v) => setState(() => _selectedSalesType = v),
      validator: (v) => (v == null || v.isEmpty) ? 'Silahkan pilih tipe sales' : null,
      decoration: InputDecoration(
        hintText: 'Pilih Tipe Sales',
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 15),
        prefixIcon: const Icon(LucideIcons.briefcase, size: 20, color: Color(0xFFAAAAAA)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
      icon: const Icon(LucideIcons.chevronDown, size: 20, color: Color(0xFFAAAAAA)),
      dropdownColor: Colors.white,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
    );
  }

  // ---------------------------------------------------------------------------
  // OR divider
  // ---------------------------------------------------------------------------
  Widget _buildOrDivider(AppLocalizations l10n) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFDDDDDD))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.or,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF8E8E93),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFDDDDDD))),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Already have an account link
  // ---------------------------------------------------------------------------
  Widget _buildLoginLink(AppLocalizations l10n) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${l10n.alreadyHaveAccount} ',
            style: const TextStyle(fontSize: 14, color: Color(0xFF3C3C43)),
          ),
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(kRouteLogin);
              }
            },
            child: Text(
              l10n.login,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE8622A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
