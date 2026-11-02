import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controllers/auth_bloc/auth_bloc.dart';
import '../../controllers/auth_bloc/auth_event.dart';
import '../../controllers/settings_cubit/settings_cubit.dart';
import '../../core/localization/app_localizations.dart';
import '../../views/auth/login_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 12),
            Text(
              l10n.translate('logout_confirm_title'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(l10n.translate('logout_confirm_message')),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.translate('cancel'),
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              
              // Trigger BLoC logout
              context.read<AuthBloc>().add(LogoutRequested());
              
              // Show confirmation SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.translate('logged_out_message')),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );

              // Reset navigation to Login screen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginView()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(l10n.translate('logout')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: Text(
          l10n.translate('settings'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Setting Card
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: BlocBuilder<SettingsCubit, Locale>(
              builder: (context, locale) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: const Icon(Icons.language, color: Colors.blue, size: 20),
                  ),
                  title: Text(
                    l10n.translate('language'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    locale.languageCode == 'en' ? 'English' : 'العربية',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Switch(
                    activeColor: Colors.blue,
                    value: locale.languageCode == 'ar',
                    onChanged: (value) {
                      context.read<SettingsCubit>().toggleLanguage();
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Logout Card
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: CircleAvatar(
                backgroundColor: Colors.red.withOpacity(0.1),
                child: const Icon(Icons.logout, color: Colors.red, size: 20),
              ),
              title: Text(
                l10n.translate('logout'),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () => _showLogoutDialog(context),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
