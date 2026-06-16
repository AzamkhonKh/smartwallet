import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/app_snack_bar.dart';
import '../services/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/section_header.dart';
import '../widgets/gradient_button.dart';
import '../widgets/glass_card.dart';
import 'categories_screen.dart';
import 'statistics_screen.dart';
import 'exchange_rates_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ApiService apiService;

  const ProfileScreen({super.key, required this.apiService});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  String _userFullName = 'Demo User';
  String _primaryCurrency = 'USD';
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await widget.apiService.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _userFullName = profile['name'] ?? 'Demo User';
        _primaryCurrency = profile['primaryCurrency'] ?? 'USD';
        _nameController.text = _userFullName;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint("Failed to load profile: $e");
    }
  }

  Future<void> _saveProfile(String selectedCurrency) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isLoading = true);
    try {
      await widget.apiService.updateProfile({
        'name': _nameController.text,
        'primaryCurrency': selectedCurrency,
      });
      await _loadProfile();
      if (mounted) AppSnackBar.success(context, l10n.successProfileUpdated);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) AppSnackBar.fromException(context, e);
    }
  }

  void _showEditProfileSheet() {
    final l10n = AppLocalizations.of(context);
    String tempCurrency = _primaryCurrency;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101424),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.profileEditTitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SectionHeader(l10n.profileFullName),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: l10n.profileNameHint,
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.03),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.person_rounded, color: Colors.white60),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SectionHeader(l10n.profilePrimaryCurrency),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: tempCurrency,
                        dropdownColor: const Color(0xFF101424),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white60),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        items: ['USD', 'EUR', 'GBP', 'UZS', 'CAD', 'AUD', 'JPY']
                            .map((code) => DropdownMenuItem(
                                  value: code,
                                  child: Text('$code (${getCurrencySymbol(code)})'),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              tempCurrency = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GradientButton(
                    label: l10n.profileSave,
                    onPressed: () {
                      Navigator.pop(context);
                      _saveProfile(tempCurrency);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLanguagePicker() {
    final l10n = AppLocalizations.of(context);
    final localeProvider = context.read<LocaleProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101424),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.languageSelect,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ...localeOptions.map((option) {
                final isActive = localeProvider.locale == option.locale ||
                    (localeProvider.locale.languageCode == option.locale.languageCode &&
                        localeProvider.locale.scriptCode == option.locale.scriptCode);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  leading: Text(option.flag, style: const TextStyle(fontSize: 28)),
                  title: Text(
                    option.nativeName,
                    style: GoogleFonts.inter(
                      color: isActive ? const Color(0xFF6C63FF) : Colors.white,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    option.scriptLabel,
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                  ),
                  trailing: isActive
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF6C63FF))
                      : null,
                  onTap: () {
                    localeProvider.setLocale(option.locale);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              children: [
                // Avatar Header Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _userFullName.isNotEmpty ? _userFullName[0].toUpperCase() : 'U',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _userFullName,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.profilePrimaryCurrencyLabel(
                          _primaryCurrency,
                          getCurrencySymbol(_primaryCurrency),
                        ),
                        style: GoogleFonts.inter(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        icon: const Icon(Icons.edit_rounded, color: Colors.white60, size: 16),
                        label: Text(
                          l10n.profileEditButton,
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                        ),
                        onPressed: _showEditProfileSheet,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Preferences & Analytics
                SectionHeader(l10n.profilePreferences),
                const SizedBox(height: 12),
                GlassCard(
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.label_outline_rounded,
                        iconColor: const Color(0xFF6C63FF),
                        title: l10n.profileCategories,
                        subtitle: l10n.profileCategoriesSubtitle,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoriesScreen(apiService: widget.apiService),
                          ),
                        ).then((_) => _loadProfile()),
                      ),
                      Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                      _buildSettingsTile(
                        icon: Icons.analytics_outlined,
                        iconColor: const Color(0xFF00D2FF),
                        title: l10n.profileStatistics,
                        subtitle: l10n.profileStatisticsSubtitle,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StatisticsScreen(apiService: widget.apiService),
                          ),
                        ).then((_) => _loadProfile()),
                      ),
                      Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                      _buildSettingsTile(
                        icon: Icons.currency_exchange_rounded,
                        iconColor: Colors.orangeAccent,
                        title: l10n.profileExchangeRates,
                        subtitle: l10n.profileExchangeRatesSubtitle,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExchangeRatesScreen(apiService: widget.apiService),
                          ),
                        ).then((_) => _loadProfile()),
                      ),
                      Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                      _buildSettingsTile(
                        icon: Icons.language_rounded,
                        iconColor: const Color(0xFF6C63FF).withValues(alpha: 0.8),
                        title: l10n.profileLanguage,
                        subtitle: l10n.profileLanguageSubtitle,
                        onTap: _showLanguagePicker,
                        trailing: _buildCurrentLanguageBadge(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Account Operations
                SectionHeader(l10n.profileAccountOps),
                const SizedBox(height: 12),
                GlassCard(
                  child: _buildSettingsTile(
                    icon: Icons.logout_rounded,
                    iconColor: const Color(0xFFC70039),
                    title: l10n.profileLogout,
                    subtitle: l10n.profileLogoutSubtitle,
                    onTap: () => Provider.of<AuthService>(context, listen: false).logout(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCurrentLanguageBadge() {
    final locale = context.watch<LocaleProvider>().locale;
    final option = localeOptions.firstWhere(
      (o) => o.locale.languageCode == locale.languageCode && o.locale.scriptCode == locale.scriptCode,
      orElse: () => localeOptions.first,
    );
    return Text(
      '${option.flag} ${option.nativeName}',
      style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.white38),
      onTap: onTap,
    );
  }
}
