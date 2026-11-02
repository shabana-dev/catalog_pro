import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../controllers/favourite_bloc/favourite_bloc.dart';
import '../../controllers/favourite_bloc/favourite_event.dart';
import '../../controllers/favourite_bloc/favourite_state.dart';
import '../../widgets/product_card.dart';
import '../../core/localization/app_localizations.dart';

class FavouritesView extends StatelessWidget {
  const FavouritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.translate('favourites'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: BlocBuilder<FavouriteBloc, FavouriteState>(
        builder: (context, favState) {
          if (favState is FavouriteLoading) {
            return _buildShimmerGrid();
          }

          if (favState is FavouriteLoaded) {
            if (favState.favouriteProducts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border_rounded, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      l10n.translate('no_favourites'),
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<FavouriteBloc>().add(LoadFavourites());
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: favState.favouriteProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: favState.favouriteProducts[index]);
                },
              ),
            );
          }

          if (favState is FavouriteError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('${l10n.translate('error')}: ${favState.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<FavouriteBloc>().add(LoadFavourites()),
                    child: Text(l10n.translate('retry')),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
