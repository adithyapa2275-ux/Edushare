import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class ApiService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Simple in-memory cache to prevent redundant calls and help with rate limits
  final Map<String, List<Book>> _cache = {};
  // Track in-progress requests to prevent redundant simultaneous calls
  final Map<String, Future<List<Book>>> _inProgressRequests = {};

  static final List<Book> _fallbackBooks = [
    Book(
      id: 'ncert1',
      title: 'NCERT Mathematics Class 12',
      author: 'NCERT',
      imageUrl:
          'https://books.google.com/books/content?id=9W9DAAAAYAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api',
      price: 150,
      description: 'Standard textbook for Class 12 Mathematics.',
      rating: 4.5,
      reviewCount: 120,
    ),
    Book(
      id: 'engg1',
      title: 'Engineering Mathematics',
      author: 'B.S. Grewal',
      imageUrl:
          'https://books.google.com/books/content?id=mOskEAAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api',
      price: 450,
      description: 'Higher Engineering Mathematics for technical students.',
      rating: 4.8,
      reviewCount: 850,
    ),
    Book(
      id: 'it1',
      title: 'Introduction to Algorithms',
      author: 'Cormen, Leiserson',
      imageUrl:
          'https://books.google.com/books/content?id=i-SNDwAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api',
      price: 899,
      description: 'The definitive guide to algorithms.',
      rating: 4.9,
      reviewCount: 3200,
    ),
    Book(
      id: 'mbbs1',
      title: 'Gray\'s Anatomy for Students',
      author: 'Richard Drake',
      imageUrl:
          'https://books.google.com/books/content?id=XmYpEAAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api',
      price: 1200,
      description: 'Essential anatomy textbook for medical students.',
      rating: 4.7,
      reviewCount: 540,
    ),
  ];

  /// Searches books using Google Books API with basic retry logic for 429s
  Future<List<Book>> searchBooks(String query, {int retries = 0}) async {
    if (query.isEmpty) return [];

    // Check cache first
    if (_cache.containsKey(query)) {
      print('ApiService: Cache hit for $query');
      return _cache[query]!;
    }

    // Check if a request for this query is already in progress
    if (_inProgressRequests.containsKey(query)) {
      print('ApiService: Request already in progress for $query, waiting...');
      return _inProgressRequests[query]!;
    }

    print('ApiService: Starting search for $query (Attempt ${retries + 1})');
    final Future<List<Book>> requestFuture = _performSearch(
      query,
      retries: retries,
    );
    _inProgressRequests[query] = requestFuture;

    try {
      final results = await requestFuture;
      _cache[query] = results;
      return results;
    } catch (e) {
      print('ApiService: Fatal error for $query: $e');
      return _fallbackBooks;
    } finally {
      _inProgressRequests.remove(query);
    }
  }

  Future<List<Book>> _performSearch(String query, {int retries = 0}) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?q=${Uri.encodeComponent(query)}&maxResults=20&printType=books',
      );

      // Aggressive timeout for Google Books (3s)
      final response = await http.get(url).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];
        return items.map((item) => _mapGoogleBookToBook(item)).toList();
      } else {
        print(
          'ApiService: Google Error ${response.statusCode}. Trying Open Library.',
        );
        return await _searchOpenLibrary(query);
      }
    } catch (e) {
      print(
        'ApiService: Google Timeout/Exception for $query. Trying Open Library.',
      );
      return await _searchOpenLibrary(query);
    }
  }

  /// Searches books using Open Library API as a backup
  Future<List<Book>> _searchOpenLibrary(String query) async {
    try {
      final url = Uri.parse(
        'https://openlibrary.org/search.json?q=${Uri.encodeComponent(query)}&limit=20',
      );

      // Aggressive timeout for Open Library (5s)
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final docs = data['docs'] as List<dynamic>? ?? [];
        return docs.map((doc) => _mapOpenLibraryBookToBook(doc)).toList();
      } else {
        return _generateMockBooks(query);
      }
    } catch (e) {
      print(
        'ApiService: OL Timeout/Exception for $query. Using Mock Fallback.',
      );
      return _generateMockBooks(query);
    }
  }

  /// Generates mock books so the app NEVER stays stuck or empty
  List<Book> _generateMockBooks(String query) {
    print('ApiService: Generating mock books for "$query"');
    return List.generate(5, (index) {
      return Book(
        id: 'mock_${query.replaceAll(' ', '_')}_$index',
        title: '$query - Volume ${index + 1}',
        author: 'EduShare Author',
        imageUrl: '', // Will trigger default placeholder
        price: 200.0 + (index * 50),
        description: 'Quality study material for $query.',
        rating: 4.0 + (index * 0.2),
        reviewCount: 50 + (index * 10),
      );
    });
  }

  /// Fetches Indian study materials by combining results from key terms
  Future<List<Book>> fetchIndianStudyMaterials() async {
    try {
      // Parallelize requests for efficiency
      final futures = [
        searchBooks('NCERT CBSE Indian Textbooks'),
        searchBooks('Engineering Medical textbooks India'),
      ];

      final results = await Future.wait(futures);

      // Flatten and deduplicate
      final allBooks = results.expand((x) => x).toList();
      final uniqueBooks = <String, Book>{};
      for (var book in allBooks) {
        if (!uniqueBooks.containsKey(book.id)) {
          uniqueBooks[book.id] = book;
        }
      }
      return uniqueBooks.values.toList()..shuffle();
    } catch (e) {
      print('Error fetching Indian materials: $e');
      return [];
    }
  }

  /// Maps a Google Books JSON item to our Book model
  Book _mapGoogleBookToBook(dynamic item) {
    final volumeInfo = item['volumeInfo'] as Map<String, dynamic>? ?? {};
    final saleInfo = item['saleInfo'] as Map<String, dynamic>? ?? {};

    String id = item['id'] ?? 'unknown_id';
    String title = volumeInfo['title'] ?? 'Unknown Title';

    List<dynamic> authorsList = volumeInfo['authors'] as List<dynamic>? ?? [];
    String author = authorsList.isNotEmpty
        ? authorsList.join(', ')
        : 'Unknown Author';

    String description =
        volumeInfo['description'] ?? 'No description available.';

    // Image handling
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>? ?? {};
    String imageUrl =
        imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'] ?? '';
    // Google Books thumbnails often use http, force https for security/loading
    if (imageUrl.startsWith('http://')) {
      imageUrl = imageUrl.replaceFirst('http://', 'https://');
    }

    // Rating
    double rating = (volumeInfo['averageRating'] as num?)?.toDouble() ?? 4.0;
    int reviewCount = (volumeInfo['ratingsCount'] as num?)?.toInt() ?? 0;

    // Price - Google Books specifically has saleInfo
    double price = 0.0;
    if (saleInfo['saleability'] == 'FOR_SALE' &&
        saleInfo['listPrice'] != null) {
      price = (saleInfo['listPrice']['amount'] as num?)?.toDouble() ?? 0.0;
    } else {
      // Mock price if not for sale (common for previews)
      price = 15.0 + (title.length % 50);
    }

    return Book(
      id: id,
      title: title,
      author: author,
      imageUrl: imageUrl,
      price: price,
      description: description,
      rating: rating,
      reviewCount: reviewCount,
    );
  }

  Book _mapOpenLibraryBookToBook(dynamic doc) {
    String id =
        doc['key']?.split('/').last ??
        'ol_${DateTime.now().millisecondsSinceEpoch}';
    String title = doc['title'] ?? 'Unknown Title';

    List<dynamic> authorsList = doc['author_name'] as List<dynamic>? ?? [];
    String author = authorsList.isNotEmpty
        ? authorsList.join(', ')
        : 'Unknown Author';

    // Open Library search doesn't always provide descriptions in the docs
    String description = 'Published in ${doc['first_publish_year'] ?? 'N/A'}.';

    // Cover ID to Image URL
    String imageUrl = '';
    if (doc['cover_i'] != null) {
      imageUrl = 'https://covers.openlibrary.org/b/id/${doc['cover_i']}-L.jpg';
    }

    // Mock price as Open Library is information-only
    double price = 20.0 + (title.length % 60);

    return Book(
      id: id,
      title: title,
      author: author,
      imageUrl: imageUrl,
      price: price,
      description: description,
      rating: 4.2, // Neutral rating
      reviewCount: 10 + (title.length % 100),
    );
  }

  // Helper for deprecated calls if any remain, mapping them to search
  Future<List<Book>> fetchBooksBySubject(String subject) async {
    return searchBooks('subject:$subject');
  }

  Future<List<Book>> fetchTrendingBooks() async {
    return searchBooks('trending books India');
  }

  /// Fetches a single book by ISBN
  Future<Book?> fetchBookByISBN(String isbn) async {
    if (isbn.isEmpty) return null;
    final url = Uri.parse('$_baseUrl?q=isbn:$isbn');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];
        if (items.isNotEmpty) {
          return _mapGoogleBookToBook(items.first);
        }
      }
    } catch (e) {
      print('ApiService: Error fetching book by ISBN: $e');
    }
    return null;
  }
}
