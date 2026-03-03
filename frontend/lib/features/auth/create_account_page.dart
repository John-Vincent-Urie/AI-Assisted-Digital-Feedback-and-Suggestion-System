import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/api_service.dart';
import '../../core/app_session.dart';
import '../../widgets/emotune_logo.dart';
import '../../widgets/primary_pill_button.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              const Center(child: EmoTuneLogo(size: 90)),
              const SizedBox(height: 20),
              const _FieldLabel('Username'),
              TextField(
                controller: _username,
                decoration: const InputDecoration(hintText: 'Enter username'),
              ),
              const SizedBox(height: 12),
              const _FieldLabel('Email'),
              TextField(
                controller: _email,
                decoration: const InputDecoration(hintText: 'Enter email'),
              ),
              const SizedBox(height: 12),
              const _FieldLabel('Password'),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(hintText: '********'),
              ),
              const SizedBox(height: 12),
              const _FieldLabel('Confirm password'),
              TextField(
                controller: _confirm,
                obscureText: true,
                decoration: const InputDecoration(hintText: '********'),
              ),
              const SizedBox(height: 18),
              PrimaryPillButton(
                label: _isLoading ? 'Creating...' : 'Create',
                onPressed: _isLoading ? null : _createAccount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createAccount() async {
    final username = _username.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    final confirm = _confirm.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.register(
        email: email,
        password: password,
        displayName: username,
      );
      AppSession.email = (response['email'] ?? '').toString();
      AppSession.displayName = (response['display_name'] ?? username).toString();

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.text),
      ),
    );
  }
}
