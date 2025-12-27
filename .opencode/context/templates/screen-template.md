# Screen Template

Use this template when creating new screens in PawSight.

## Basic Screen with Provider

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/{feature}_provider.dart';

class {FeatureName}Screen extends StatelessWidget {
  const {FeatureName}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{Feature Title}'),
      ),
      body: Consumer<{FeatureName}Provider>(
        builder: (context, provider, child) {
          // Handle loading state
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Handle error state
          if (provider.error != null) {
            return _buildErrorView(context, provider);
          }

          // Handle empty state
          if (provider.items.isEmpty) {
            return _buildEmptyView();
          }

          // Main content
          return _buildContent(provider);
        },
      ),
    );
  }

  Widget _buildContent({FeatureName}Provider provider) {
    return ListView.builder(
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        final item = provider.items[index];
        return _buildItem(item);
      },
    );
  }

  Widget _buildItem(Item item) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text(item.description),
      onTap: () => _handleItemTap(item),
    );
  }

  Widget _buildErrorView(BuildContext context, {FeatureName}Provider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            provider.error!,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              provider.clearError();
              provider.loadItems();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Text('No items found'),
    );
  }

  void _handleItemTap(Item item) {
    // Handle item tap
  }
}
```

## Screen with Search and Filters

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/{feature}_provider.dart';

class {FeatureName}Screen extends StatelessWidget {
  const {FeatureName}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{Feature Title}'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: Consumer<{FeatureName}Provider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return _buildErrorView(context, provider);
                }

                if (provider.items.isEmpty) {
                  return _buildEmptyView();
                }

                return _buildItemList(provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Consumer<{FeatureName}Provider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              provider.setSearchQuery(value);
            },
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return Consumer<{FeatureName}Provider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              _buildFilterChip('Filter 1', provider),
              _buildFilterChip('Filter 2', provider),
              _buildFilterChip('Filter 3', provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, {FeatureName}Provider provider) {
    final isSelected = provider.selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          provider.setFilter(label);
        },
      ),
    );
  }

  Widget _buildItemList({FeatureName}Provider provider) {
    return ListView.builder(
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        return _buildItem(provider.items[index]);
      },
    );
  }

  Widget _buildItem(Item item) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text(item.description),
      onTap: () => _handleItemTap(item),
    );
  }

  Widget _buildErrorView(BuildContext context, {FeatureName}Provider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(provider.error!),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: provider.loadItems,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Text('No items found'),
    );
  }

  void _handleItemTap(Item item) {
    // Navigate to detail screen or show dialog
  }
}
```

## Key Points

1. **StatelessWidget** - Always use with Provider
2. **Consumer** - Wraps parts that need to rebuild
3. **Loading/Error/Empty** - Always handle these states
4. **Extract methods** - Keep build() clean and readable
5. **const constructors** - Use where possible for performance
6. **Handle all states** - Loading, error, empty, content

## Common Patterns

**Action Button**:
```dart
ElevatedButton(
  onPressed: () {
    context.read<MyProvider>().doSomething();
  },
  child: const Text('Action'),
)
```

**FloatingActionButton**:
```dart
floatingActionButton: FloatingActionButton(
  onPressed: () {
    // Navigate or trigger action
  },
  child: const Icon(Icons.add),
)
```

**RefreshIndicator**:
```dart
RefreshIndicator(
  onRefresh: () async {
    await context.read<MyProvider>().refresh();
  },
  child: ListView(...),
)
```
