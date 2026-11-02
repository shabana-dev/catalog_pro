import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/product_model.dart';
import '../../controllers/favourite_bloc/favourite_bloc.dart';
import '../../controllers/favourite_bloc/favourite_event.dart';
import '../../controllers/favourite_bloc/favourite_state.dart';
import '../../core/localization/app_localizations.dart';

class ProductDetailsView extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Image Header with Parallax & Stretch
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.3),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.3),
                  child: BlocConsumer<FavouriteBloc, FavouriteState>(
                    listener: (context, state) {
                      if (state is FavouriteLoaded) {
                        final isFavourite = state.favouriteIds.contains(product.id);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.translate(isFavourite
                                  ? 'added_to_favourites'
                                  : 'removed_from_favourites'),
                            ),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                    listenWhen: (previous, current) {
                      if (previous is FavouriteLoaded && current is FavouriteLoaded) {
                        return (previous.favouriteIds.contains(product.id) !=
                            current.favouriteIds.contains(product.id));
                      }
                      return false;
                    },
                    builder: (context, state) {
                      bool isFavourite = false;
                      if (state is FavouriteLoaded) {
                        isFavourite = state.favouriteIds.contains(product.id);
                      }
                      return IconButton(
                        icon: Icon(
                          isFavourite ? Icons.favorite : Icons.favorite_border,
                          color: isFavourite ? Colors.red : Colors.white,
                        ),
                        onPressed: () {
                          context.read<FavouriteBloc>().add(ToggleFavourite(product));
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: product.images.isNotEmpty
                  ? PageView.builder(
                      itemCount: product.images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          product.images[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[200]!,
                              highlightColor: Colors.white,
                              child: Container(color: Colors.white),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                        );
                      },
                    )
                  : const Center(child: Icon(Icons.image_not_supported, size: 50)),
            ),
          ),

          // 2. Product Details Content
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -30, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, -5),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            product.category.toUpperCase(),
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                              const SizedBox(width: 4),
                              Text(
                                product.rating.toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      product.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Price
                    Text(
                      '\$${product.price}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Divider(height: 48, thickness: 1, color: Colors.black12),

                    // Brand Info (Robust check)
                    if (product.brand != null && product.brand!.trim().isNotEmpty) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.storefront_rounded, color: Colors.grey, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.translate('brand'),
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              ),
                              Text(
                                product.brand!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Description Label
                    Text(
                      l10n.translate('description'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description Text
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
