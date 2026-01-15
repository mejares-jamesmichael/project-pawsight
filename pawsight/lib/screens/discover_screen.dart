import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../models/cat_breed.dart';
import '../models/http_cat_image.dart';
import '../providers/cat_api_provider.dart';

/// Discover screen showcasing cat facts, breeds, and fun cat images
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CatApiProvider>();
      provider.loadRandomFacts(amount: 5);
      provider.loadBreeds();
      provider.loadRandomImages(limit: 10);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: theme.colors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(FIcons.arrowLeft, color: theme.colors.foreground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Discover',
          style: theme.typography.lg.copyWith(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colors.primary,
          unselectedLabelColor: theme.colors.mutedForeground,
          indicatorColor: theme.colors.primary,
          tabs: const [
            Tab(text: 'Facts', icon: Icon(FIcons.sparkles, size: 18)),
            Tab(text: 'Breeds', icon: Icon(FIcons.cat, size: 18)),
            Tab(text: 'Gallery', icon: Icon(FIcons.image, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _FactsTab(),
          _BreedsTab(),
          _GalleryTab(),
        ],
      ),
    );
  }
}

/// Tab showing random cat facts
class _FactsTab extends StatelessWidget {
  const _FactsTab();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<CatApiProvider>();

    if (provider.isLoadingFacts && provider.facts.isEmpty) {
      return const Center(child: FProgress());
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadRandomFacts(amount: 5),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Current Fact Card
          if (provider.currentFact != null) ...[
            _FactCard(
              fact: provider.currentFact!.text,
              isHighlighted: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: FButton(
                onPress: provider.isLoadingFacts ? null : () => provider.refreshFact(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (provider.isLoadingFacts)
                      const SizedBox(
                        width: AppSpacing.lg,
                        height: AppSpacing.lg,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      const Icon(FIcons.shuffle, size: AppSpacing.lg),
                    const SizedBox(width: AppSpacing.sm),
                    const Text('New Fact'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],

          // More Facts
          Text(
            'More Cat Facts',
            style: theme.typography.lg.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          ...provider.facts.skip(1).map((fact) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _FactCard(fact: fact.text),
              )),

          // HTTP Cat Fun Section
          const SizedBox(height: AppSpacing.xl),
          Text(
            'HTTP Cats',
            style: theme.typography.lg.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Fun cat images for HTTP status codes!',
            style: theme.typography.sm.copyWith(color: theme.colors.mutedForeground),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: HttpCatImage.popularStatusCodes.length,
              itemBuilder: (context, index) {
                final code = HttpCatImage.popularStatusCodes[index];
                final cat = HttpCatImage.fromStatusCode(code);
                return _HttpCatCard(cat: cat);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab showing cat breeds from TheCatAPI
class _BreedsTab extends StatefulWidget {
  const _BreedsTab();

  @override
  State<_BreedsTab> createState() => _BreedsTabState();
}

class _BreedsTabState extends State<_BreedsTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<CatApiProvider>();

    if (provider.isLoadingBreeds && provider.breeds.isEmpty) {
      return const Center(child: FProgress());
    }

    final filteredBreeds = _searchQuery.isEmpty
        ? provider.breeds
        : provider.breeds
            .where((b) =>
                b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (b.temperament?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
            .toList();

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: FTextField(
            hint: 'Search breeds...',
            onChange: (value) => setState(() => _searchQuery = value),
          ),
        ),

        // Breeds List
        Expanded(
          child: filteredBreeds.isEmpty
              ? Center(
                  child: Text(
                    'No breeds found',
                    style: theme.typography.base.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: filteredBreeds.length,
                  itemBuilder: (context, index) {
                    final breed = filteredBreeds[index];
                    return _BreedCard(breed: breed);
                  },
                ),
        ),
      ],
    );
  }
}

/// Tab showing cat image gallery
class _GalleryTab extends StatelessWidget {
  const _GalleryTab();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<CatApiProvider>();

    if (provider.isLoadingImages && provider.catImages.isEmpty) {
      return const Center(child: FProgress());
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadRandomImages(limit: 10),
      child: CustomScrollView(
        slivers: [
          // CATAAS Fun Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cat Says...',
                    style: theme.typography.lg.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.network(
                      provider.getCatSaysUrl('PawSight!', fontColor: 'white'),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          color: theme.colors.secondary,
                          child: const Center(child: FProgress()),
                        );
                      },
                      errorBuilder: (context, error, stack) => Container(
                        height: 200,
                        color: theme.colors.secondary,
                        child: const Center(child: Icon(FIcons.imageOff)),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: FButton(
                      onPress: () {
                        // Force refresh by setting state
                        (context as Element).markNeedsBuild();
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FIcons.rotateCw, size: AppSpacing.lg),
                          SizedBox(width: AppSpacing.sm),
                          Text('New Cat'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TheCatAPI Gallery
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cat Gallery',
                    style: theme.typography.lg.copyWith(fontWeight: FontWeight.bold),
                  ),
                  FButton(
                    onPress: provider.isLoadingImages
                        ? null
                        : () => provider.loadRandomImages(limit: 10),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FIcons.rotateCw, size: AppSpacing.lg),
                        SizedBox(width: AppSpacing.sm),
                        Text('Refresh'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Image Grid
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= provider.catImages.length) return null;
                  final image = provider.catImages[index];
                  return _GalleryImageCard(
                    imageUrl: image.url,
                    breed: image.hasBreedInfo ? image.breeds.first.name : null,
                  );
                },
                childCount: provider.catImages.length,
              ),
            ),
          ),

          // GIF Cat Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Random GIF Cat',
                    style: theme.typography.lg.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.network(
                      provider.getRandomGifUrl(),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          color: theme.colors.secondary,
                          child: const Center(child: FProgress()),
                        );
                      },
                      errorBuilder: (context, error, stack) => Container(
                        height: 200,
                        color: theme.colors.secondary,
                        child: const Center(child: Icon(FIcons.imageOff)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// =============================================================================
// WIDGETS
// =============================================================================

class _FactCard extends StatelessWidget {
  final String fact;
  final bool isHighlighted;

  const _FactCard({
    required this.fact,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isHighlighted
            ? theme.colors.primary.withValues(alpha: 0.1)
            : theme.colors.secondary.withValues(alpha: 0.1),
        border: Border.all(
          color: isHighlighted ? theme.colors.primary : theme.colors.border,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            FIcons.quote,
            size: 20,
            color: isHighlighted ? theme.colors.primary : theme.colors.mutedForeground,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              fact,
              style: theme.typography.base.copyWith(
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HttpCatCard extends StatelessWidget {
  final HttpCatImage cat;

  const _HttpCatCard({required this.cat});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              child: Image.network(
                cat.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: theme.colors.secondary,
                    child: const Center(child: FProgress()),
                  );
                },
                errorBuilder: (context, error, stack) => Container(
                  color: theme.colors.secondary,
                  child: const Center(child: Icon(FIcons.imageOff)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              children: [
                Text(
                  '${cat.statusCode}',
                  style: theme.typography.sm.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  cat.statusText,
                  style: theme.typography.xs.copyWith(color: theme.colors.mutedForeground),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreedCard extends StatelessWidget {
  final CatBreed breed;

  const _BreedCard({required this.breed});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        title: Text(
          breed.name,
          style: theme.typography.base.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: breed.origin != null
            ? Text(
                breed.origin!,
                style: theme.typography.xs.copyWith(color: theme.colors.mutedForeground),
              )
            : null,
        children: [
          if (breed.description != null) ...[
            Text(
              breed.description!,
              style: theme.typography.sm.copyWith(height: 1.5),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (breed.temperament != null) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: breed.temperamentList
                  .take(5)
                  .map((trait) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: theme.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          trait,
                          style: theme.typography.xs.copyWith(color: theme.colors.primary),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          // Stats Row
          Row(
            children: [
              if (breed.lifeSpan != null)
                _BreedStat(label: 'Life Span', value: '${breed.lifeSpan} yrs'),
              if (breed.weight?.metric != null)
                _BreedStat(label: 'Weight', value: '${breed.weight!.metric} kg'),
              if (breed.intelligence != null)
                _BreedStat(label: 'Intelligence', value: '${breed.intelligence}/5'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreedStat extends StatelessWidget {
  final String label;
  final String value;

  const _BreedStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.typography.sm.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: theme.typography.xs.copyWith(color: theme.colors.mutedForeground),
          ),
        ],
      ),
    );
  }
}

class _GalleryImageCard extends StatelessWidget {
  final String imageUrl;
  final String? breed;

  const _GalleryImageCard({
    required this.imageUrl,
    this.breed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: theme.colors.secondary,
                child: const Center(child: FProgress()),
              );
            },
            errorBuilder: (context, error, stack) => Container(
              color: theme.colors.secondary,
              child: const Center(child: Icon(FIcons.imageOff)),
            ),
          ),
          if (breed != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  breed!,
                  style: theme.typography.xs.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
