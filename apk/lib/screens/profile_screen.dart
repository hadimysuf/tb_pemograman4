import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = 'Hadi M Yusuf';
  String email = 'hadi@email.com';
  String npm = '714230019';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ================= HEADER =================
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: AppTheme.primarySoft,
                    child: const Icon(
                      Icons.person,
                      size: 42,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(email, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// ================= INFO CARD =================
            _infoTile('Nama', name),
            _infoTile('Email', email),
            _infoTile('NPM', npm),

            const SizedBox(height: 24),

            /// ================= ACTION =================
            _primaryButton(
              icon: Icons.edit,
              label: 'Edit Profil',
              onTap: _editProfile,
            ),

            const SizedBox(height: 12),

            _outlineButton(
              icon: Icons.lock,
              label: 'Ganti Password',
              onTap: _changePassword,
            ),

            const SizedBox(height: 12),

            _dangerButton(icon: Icons.logout, label: 'Logout', onTap: _logout),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// ================= COMPONENT =================

  Widget _infoTile(String label, String value) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(title: Text(label), subtitle: Text(value)),
    );
  }

  Widget _primaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _outlineButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _dangerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.red),
      label: Text(label, style: const TextStyle(color: Colors.red)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: Colors.red),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// ================= ACTION =================

  void _editProfile() {
    final nameController = TextEditingController(text: name);
    final emailController = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                name = nameController.text;
                email = emailController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ganti Password'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (oldPassController.text.isEmpty ||
                  newPassController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua field wajib diisi')),
                );
                return;
              }
              if (newPassController.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password baru minimal 8 karakter'),
                  ),
                );
                return;
              }

              final ok = await ApiService.changePassword(
                oldPassController.text,
                newPassController.text,
              );

              if (!context.mounted) return;

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? 'Password berhasil diubah' : 'Gagal mengubah password',
                  ),
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Lama',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Baru',
                hintText: 'Minimal 8 karakter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah kamu yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ApiService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
