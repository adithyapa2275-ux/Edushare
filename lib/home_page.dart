import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/colors.dart';
import 'core/api_service.dart';
import 'models/book.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/hero_banner.dart';
import 'widgets/section_header.dart';
import 'widgets/book_card.dart';
import 'widgets/footer.dart';
import 'widgets/category_pills.dart';
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
  Future<List<Book>> _donateBooksFuture = Future.value([]);

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchAllBooks();
  }

  Future<void> _fetchAllBooks() async {
    // Trigger all section futures INSTANTLY in parallel
    setState(() {
      _indianStudyMaterialsFuture = _apiService.fetchIndianStudyMaterials();
      _itBooksFuture = _apiService.searchBooks('Computer Science India');
      _nursingBooksFuture = _apiService.searchBooks('Nursing Medical India');
      _engineeringBooksFuture = _apiService.searchBooks(
        'Engineering India S.Chand',
      );
      _class12BooksFuture = _apiService.searchBooks('NCERT CBSE Class 12');
      _donateBooksFuture = _apiService
          .searchBooks('free academic books')
          .then(
            (books) => books
                .map((b) => b.copyWith(isDonation: true, price: 0.0))
                .toList(),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                          childAspectRatio:
                              0.35, // Taller cards to prevent overflow
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
          return _HomePageContent(
            indianStudyMaterialsFuture: _indianStudyMaterialsFuture,
            itBooksFuture: _itBooksFuture,
            nursingBooksFuture: _nursingBooksFuture,
            engineeringBooksFuture: _engineeringBooksFuture,
            class12BooksFuture: _class12BooksFuture,
            donateBooksFuture: _donateBooksFuture,
            onRetry: _fetchAllBooks,
          );
        },
      ),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  final Future<List<Book>> indianStudyMaterialsFuture;
  final Future<List<Book>> itBooksFuture;
  final Future<List<Book>> nursingBooksFuture;
  final Future<List<Book>> engineeringBooksFuture;
  final Future<List<Book>> class12BooksFuture;
  final Future<List<Book>> donateBooksFuture;
  final VoidCallback onRetry;

  const _HomePageContent({
    required this.indianStudyMaterialsFuture,
    required this.itBooksFuture,
    required this.nursingBooksFuture,
    required this.engineeringBooksFuture,
    required this.class12BooksFuture,
    required this.donateBooksFuture,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const HeroBanner(),
          const CategoryPills(),
          _buildSection(
            context,
            '🎁 FREE / Donate Books',
            donateBooksFuture,
            'free books',
          ),
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
            context,
            'NCERT & Indian Study Materials',
            indianStudyMaterialsFuture,
            'NCERT CBSE Indian Textbooks',
          ),
          _buildSection(
            context,
            'IT & Computer Science',
            itBooksFuture,
            'Computer Science India',
          ),
          _buildSection(
            context,
            'Medical & Nursing (MBBS)',
            nursingBooksFuture,
            'Nursing Medical India',
          ),
          _buildSection(
            context,
            'Engineering (B.Tech)',
            engineeringBooksFuture,
            'Engineering India S.Chand',
          ),
          _buildSection(
            context,
            'Class 12 / Plus Two (CBSE)',
            class12BooksFuture,
            'NCERT CBSE Class 12',
          ),
          const SizedBox(height: 48),
          const Footer(),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    Future<List<Book>> future,
    String? query,
  ) {
    return Column(
      children: [
        SectionHeader(
          title: title,
          onMoreTap: query != null
              ? () => context.push(
                  '/category',
                  extra: {'title': title, 'query': query},
                )
              : null,
        ),
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
                        onPressed: onRetry,
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

class _BookList extends StatefulWidget {
  final List<Book> books;
  const _BookList({required this.books});

  @override
  State<_BookList> createState() => _BookListState();
}

class _BookListState extends State<_BookList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Scrollbar(
        controller: _scrollController,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          controller: _scrollController,
          itemCount: widget.books.length,
          itemBuilder: (context, index) {
            return SizedBox(
              width: 200,
              child: BookCard(book: widget.books[index]),
            );
          },
        ),
      ),
    );
  }
}
