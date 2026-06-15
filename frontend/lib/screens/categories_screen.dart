import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/app_snack_bar.dart';
import '../l10n/app_localizations.dart';
import '../widgets/section_header.dart';
import '../widgets/gradient_button.dart';
import '../widgets/glass_card.dart';

class CategoriesScreen extends StatefulWidget {
  final ApiService apiService;

  const CategoriesScreen({super.key, required this.apiService});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<dynamic> _categories = [];
  bool _isLoading = false;
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final data = await widget.apiService.getCategories();
      setState(() {
        _categories = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) AppSnackBar.fromException(context, e);
    }
  }

  Future<void> _addCategory() async {
    final name = _categoryController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await widget.apiService.addCategory(name);
      _categoryController.clear();
      _loadCategories();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) AppSnackBar.fromException(context, e);
    }
  }

  Future<void> _deleteCategory(String name) async {
    setState(() => _isLoading = true);
    try {
      await widget.apiService.deleteCategory(name);
      _loadCategories();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) AppSnackBar.fromException(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.categoriesTitle,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: _isLoading && _categories.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : RefreshIndicator(
              onRefresh: _loadCategories,
              color: const Color(0xFF6C63FF),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 8.0),
                children: [
                  Text(
                    l10n.categoriesSubtitle,
                    style:
                        GoogleFonts.inter(color: Colors.white38, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // Add category input
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _categoryController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: l10n.categoriesNewHint,
                              hintStyle:
                                  const TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onSubmitted: (_) => _addCategory(),
                          ),
                        ),
                        GradientButton(
                          label: l10n.categoriesAdd,
                          onPressed: _addCategory,
                          verticalPadding: 12,
                          borderRadius: 16,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_categories.isEmpty)
                    GlassCard(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          l10n.categoriesEmpty,
                          style:
                              GoogleFonts.inter(color: Colors.white38),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.8,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final catName = _categories[index].toString();
                        return GlassCard(
                          radius: 20,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  catName,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                onPressed: () => _deleteCategory(catName),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
