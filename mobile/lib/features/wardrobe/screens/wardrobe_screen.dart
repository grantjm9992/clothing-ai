import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/providers.dart';
import '../../../shared/models/wardrobe_item.dart';

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  final List<String> categories = [
    'All',
    'top',
    'bottom',
    'outerwear',
    'dress',
    'shoes',
    'bag',
    'accessory',
  ];

  @override
  Widget build(BuildContext context) {
    final wardrobeState = ref.watch(wardrobeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wardrobe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isAll = category == 'All';
                final isSelected = isAll
                    ? wardrobeState.selectedCategory == null
                    : wardrobeState.selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_getCategoryLabel(category)),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref
                          .read(wardrobeProvider.notifier)
                          .setCategory(isAll ? null : category);
                    },
                    backgroundColor: AppTheme.surface,
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),

          // Items grid
          Expanded(
            child: wardrobeState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : wardrobeState.filteredItems.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: wardrobeState.filteredItems.length,
                        itemBuilder: (context, index) {
                          return WardrobeItemCard(
                            item: wardrobeState.filteredItems[index],
                            onTap: () => _showItemDetails(
                              context,
                              wardrobeState.filteredItems[index],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNewItem(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  String _getCategoryLabel(String category) {
    if (category == 'All') return 'All';
    return category[0].toUpperCase() + category.substring(1);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checkroom_outlined, size: 80, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text('No items yet', style: AppTheme.h3),
          const SizedBox(height: 8),
          Text(
            'Start building your digital wardrobe',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addNewItem(context),
            icon: const Icon(Icons.add),
            label: const Text('Add First Item'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: AppTheme.h2),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.sort),
              title: const Text('Sort by'),
              subtitle: const Text('Recently added'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Color'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.wb_sunny),
              title: const Text('Season'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetails(BuildContext context, WardrobeItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WardrobeItemDetailScreen(item: item),
      ),
    );
  }

  void _addNewItem(BuildContext context) {
    // TODO: Navigate to camera/photo picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add item feature coming soon')),
    );
  }
}

class WardrobeItemCard extends StatelessWidget {
  final WardrobeItem item;
  final VoidCallback onTap;

  const WardrobeItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Container(
                width: double.infinity,
                color: AppTheme.surface,
                child: item.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.checkroom,
                          size: 48,
                          color: AppTheme.textSecondary,
                        ),
                      )
                    : const Icon(
                        Icons.checkroom,
                        size: 48,
                        color: AppTheme.textSecondary,
                      ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayName,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (item.colors.isNotEmpty)
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getColorFromName(item.colors.first),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.border),
                          ),
                        ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.colorDisplay,
                          style: AppTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.formalityLabel,
                      style: AppTheme.caption.copyWith(color: AppTheme.accent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    final colorMap = {
      'black': Colors.black,
      'white': Colors.white,
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'pink': Colors.pink,
      'brown': Colors.brown,
      'gray': Colors.grey,
      'grey': Colors.grey,
      'navy': const Color(0xFF000080),
      'beige': const Color(0xFFF5F5DC),
    };

    return colorMap[colorName.toLowerCase()] ?? Colors.grey;
  }
}

class WardrobeItemDetailScreen extends StatelessWidget {
  final WardrobeItem item;

  const WardrobeItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                width: double.infinity,
                color: AppTheme.surface,
                child: item.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.contain,
                      )
                    : const Icon(Icons.checkroom, size: 120),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.displayName, style: AppTheme.h2),
                  const SizedBox(height: 8),
                  Text(
                    _getCategoryLabel(item.category),
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),

                  _DetailSection(
                    title: 'Colors',
                    content: item.colorDisplay,
                  ),

                  if (item.pattern != null)
                    _DetailSection(
                      title: 'Pattern',
                      content: item.pattern!,
                    ),

                  if (item.material != null)
                    _DetailSection(
                      title: 'Material',
                      content: item.material!,
                    ),

                  _DetailSection(
                    title: 'Formality',
                    content: '${item.formality}/10 - ${item.formalityLabel}',
                  ),

                  if (item.seasonTags.isNotEmpty)
                    _DetailSection(
                      title: 'Seasons',
                      content: item.seasonTags.join(', '),
                    ),

                  if (item.styleTags.isNotEmpty)
                    _DetailSection(
                      title: 'Style Tags',
                      content: item.styleTags.join(', '),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryLabel(String category) {
    return category[0].toUpperCase() + category.substring(1);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // Delete item
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String content;

  const _DetailSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.caption,
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: AppTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
