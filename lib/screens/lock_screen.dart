import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

    const LockScreen({super.key, required this.onUnlocked});

    @override
    State<LockScreen> createState() => _LockScreenState();
  }

  class _LockScreenState extends State<LockScreen> {
    bool _isAuthenticating = false;

    @override
    void initState() {
      super.initState();
      _tryAuthenticate();
    }

    Future<void> _tryAuthenticate() async {
      setState(() => _isAuthenticating = true);
      final success = await AuthService.authenticate();
      if (success && mounted) {
        widget.onUnlocked();
      } else if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.green[700]),
              const SizedBox(height: 24),
              const Text(
                'Gestor Financeiro',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Toque para desbloquear',
                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              ),
              const SizedBox(height: 40),
              if (_isAuthenticating)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _tryAuthenticate,
                  icon: const Icon(Icons.fingerprint, size: 28),
                  label: const Text('Autenticar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
        ),
      );
    }
  }