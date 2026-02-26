import 'package:flutter/material.dart';
import 'core/colors.dart';
import 'core/api_service.dart';
import 'models/book.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/hero_banner.dart';
import 'widgets/section_header.dart';
import 'widgets/book_card.dart';
import 'widgets/footer.dart';
import 'package:provider/provider.dart';
import 'providers/search_provider.dart';
import 'providers/marketplace_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Futures for each section
  Future<List<Book>> _indianStudyMaterialsFuture = Future.value([]);
  Future<List<Book>> _itBooksFuture = Future.value([]);
  Future<List<Book>> _nursingBooksFuture = Future.value([]);
  Future<List<Book>> _engineeringBooksFuture = Future.value([]);
  Future<List<Book>> _class12BooksFuture = Future.value([]);

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchAllBooks();
  }

  Future<void> _fetchAllBooks() async {
    // Fetch user listings from Firestore - unawaited to avoid blocking
    Provider.of<MarketplaceProvider>(
      context,
      listen: false,
    ).fetchRecentListings();

    // Trigger all section futures INSTANTLY in parallel
    setState(() {
      _indianStudyMaterialsFuture = _apiService.fetchIndianStudyMaterials();
      _itBooksFuture = _apiService.searchBooks('Computer Science India');
      _nursingBooksFuture = _apiService.searchBooks('Nursing Medical India');
      _engineeringBooksFuture = _apiService.searchBooks(
        'Engineering India S.Chand',
      );
      _class12BooksFuture = _apiService.searchBooks('NCERT CBSE Class 12');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          if (searchProvider.query.isNotEmpty) {
            // Show Search Results
            if (searchProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (searchProvider.searchResults.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 100),
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No results found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 0.4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return BookCard(
                        book: searchProvider.searchResults[index],
                      );
                    }, childCount: searchProvider.searchResults.length),
                  ),
                ),
              ],
            );
          }

          // Default Home View
          return SingleChildScrollView(
            child: Column(
              children: [
                const HeroBanner(),

                // User Listings Section
                Consumer<MarketplaceProvider>(
                  builder: (context, marketplace, child) {
                    if (marketplace.recentListings.isNotEmpty) {
                      return Column(
                        children: [
                          SectionHeader(
                            title: 'Recently Listed by Students',
                            onMoreTap: () {},
                          ),
                          _BookList(books: marketplace.recentListings),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                _buildSection(
                  'NCERT & Indian Study Materials',
                  _indianStudyMaterialsFuture,
                ),
                _buildSection('IT & Computer Science', _itBooksFuture),
                _buildSection('Medical & Nursing (MBBS)', _nursingBooksFuture),
                _buildSection('Engineering (B.Tech)', _engineeringBooksFuture),
                _buildSection(
                  'Class 12 / Plus Two (CBSE)',
                  _class12BooksFuture,
                ),
                const SizedBox(height: 48),
                const Footer(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, Future<List<Book>> future) {
    return Column(
      children: [
        SectionHeader(title: title, onMoreTap: () {}),
        FutureBuilder<List<Book>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 460,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text('Failed to load $title'),
                      TextButton(
                        onPressed: () => _fetchAllBooks(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(
                height: 100,
                child: Center(child: Text('No books found in this section')),
              );
            }

            return _BookList(books: snapshot.data!);
          },
        ),
      ],
    );
  }
}

class _BookList extends StatelessWidget {
  final List<Book> books;

  const _BookList({required this.books});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 460, // Height for card + shadows + hover space
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        itemBuilder: (context, index) {
          return BookCard(book: books[index]);
        },
      ),
    );
  }
}
