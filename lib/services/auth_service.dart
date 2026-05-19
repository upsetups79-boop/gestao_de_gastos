import 'package:local_auth/local_auth.dart';

  class AuthService {
    static final LocalAuthentication _auth = LocalAuthentication();

    static Future<bool> canAuthenticate() async {
      try {
        final canCheckBiometrics = await _auth.canCheckBiometrics;
        final isDeviceSupported = await _auth.isDeviceSupported();
        return canCheckBiometrics || isDeviceSupported;
      } catch (e) {
        return false;
      }
    }

    static Future<bool> authenticate() async {
      try {
        final canAuth = await canAuthenticate();
        if (!canAuth) return true;
        return await _auth.authenticate(
          localizedReason: 'Desbloqueie para acessar seus dados financeiros',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
          ),
        );
      } catch (e) {
        return false;
      }
    }
  }
