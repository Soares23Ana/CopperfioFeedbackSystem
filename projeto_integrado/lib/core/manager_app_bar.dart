import 'package:flutter/material.dart';
import 'package:projeto_integrado/core/theme_provider.dart';

class ManagerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ThemeProvider themeProvider;
  final VoidCallback? onBack;
  final List<Widget>? extraActions;
  final bool centerTitle;
  final bool showProfileIcon;

  const ManagerAppBar({
    super.key,
    required this.themeProvider,
    this.onBack,
    this.extraActions,
    this.centerTitle = true,
    this.showProfileIcon = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.isDarkMode;
    const primaryColor = Color(0xFF8C1D18);

    return AppBar(
      backgroundColor: isDark ? Colors.transparent : primaryColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: onBack != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBack,
            )
          : null,
      centerTitle: centerTitle,
      title: const Text(
        'COPPERFIO',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 18,
          letterSpacing: 0.5,
        ),
      ),
      titleSpacing: 0,
      actions: [
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          onPressed: themeProvider.toggleTheme,
        ),
        if (showProfileIcon) ...[
          CircleAvatar(
            radius: 14,
            backgroundColor: primaryColor.withAlpha((0.2 * 255).round()),
            child: const Icon(Icons.person, color: primaryColor, size: 18),
          ),
          const SizedBox(width: 16),
        ],
        if (extraActions != null) ...extraActions!,
      ],
    );
  }
}
