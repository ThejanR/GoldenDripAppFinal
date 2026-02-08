import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import 'temperature_debug_screen.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load user profile when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      profileProvider.loadUserProfile();
    });
  }

  Future<void> _selectImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final profileProvider =
            Provider.of<ProfileProvider>(context, listen: false);
        profileProvider.updateProfileImage(File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _captureImage() async {
    try {
      final XFile? capturedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (capturedFile != null) {
        final profileProvider =
            Provider.of<ProfileProvider>(context, listen: false);
        profileProvider.updateProfileImage(File(capturedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: $e')),
      );
    }
  }

  Future<void> _showImageOptions() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _captureImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _selectImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: profileProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profile Header Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                GestureDetector(
                                  onTap: _showImageOptions,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 2,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      backgroundImage: profileProvider
                                                  .profileImage !=
                                              null
                                          ? FileImage(
                                                  profileProvider.profileImage!)
                                              as ImageProvider
                                          : (profileProvider.user?.profileImage
                                                      ?.startsWith('http') ??
                                                  false)
                                              ? NetworkImage(profileProvider
                                                  .user!.profileImage!)
                                              : null,
                                      child: profileProvider.profileImage ==
                                                  null &&
                                              !(profileProvider
                                                      .user?.profileImage
                                                      ?.startsWith('http') ??
                                                  false)
                                          ? Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              profileProvider.user?.name ?? 'Guest User',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              profileProvider.user?.email ??
                                  'guest@example.com',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Member since ${profileProvider.user?.createdAt != null ? _formatDate(profileProvider.user!.createdAt) : 'Unknown'}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Personal Information Section
                    _buildSectionTitle(context, 'Personal Information'),
                    _buildProfileCard(
                      context,
                      items: [
                        _ProfileMenuItem(
                          icon: Icons.person,
                          title: 'Full Name',
                          subtitle: profileProvider.user?.name ?? 'Not set',
                          onTap: () {},
                        ),
                        _ProfileMenuItem(
                          icon: Icons.email,
                          title: 'Email',
                          subtitle: profileProvider.user?.email ?? 'Not set',
                          onTap: () {},
                        ),
                        _ProfileMenuItem(
                          icon: Icons.phone,
                          title: 'Phone',
                          subtitle: profileProvider.user?.phone ?? 'Not set',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Settings Section
                    _buildSectionTitle(context, 'Settings'),
                    _buildProfileCard(
                      context,
                      items: [
                        _ProfileMenuItem(
                          icon: Icons.history,
                          title: 'Order History',
                          subtitle: 'View your past orders',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const OrderHistoryScreen(),
                              ),
                            );
                          },
                        ),
                        _ProfileMenuItem(
                          icon: Icons.language,
                          title: 'Language',
                          subtitle: 'English',
                          onTap: () {},
                        ),
                        _ProfileMenuItem(
                          icon: Icons.dark_mode,
                          title: 'Theme',
                          subtitle: 'Click light/dark mode',
                          onTap: () {
                            final themeProvider = Provider.of<ThemeProvider>(
                                context,
                                listen: false);
                            themeProvider.toggleTheme();
                          },
                        ),
                        _ProfileMenuItem(
                          icon: Icons.thermostat,
                          title: 'Temperature Debug',
                          subtitle: 'Test temperature controls',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TemperatureDebugScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // About Section
                    _buildSectionTitle(context, 'About'),
                    _buildProfileCard(
                      context,
                      items: [
                        _ProfileMenuItem(
                          icon: Icons.info,
                          title: 'App Version',
                          subtitle: '1.0.0',
                          onTap: () {},
                        ),
                        _ProfileMenuItem(
                          icon: Icons.help,
                          title: 'Help & Support',
                          subtitle: 'Get help and support',
                          onTap: () {},
                        ),
                        _ProfileMenuItem(
                          icon: Icons.privacy_tip,
                          title: 'Privacy Policy',
                          subtitle: 'View privacy policy',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Logout Button
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: InkWell(
                        onTap: () {
                          _showLogoutDialog(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Logout',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onErrorContainer,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context,
      {required List<_ProfileMenuItem> items}) {
    return Card(
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildProfileItem(context, items[i]),
            if (i < items.length - 1)
              Divider(
                height: 1,
                indent: 56,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, _ProfileMenuItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    item.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
