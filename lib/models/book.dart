import 'dart:math';

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final double price;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String> categories;
  final bool isNewArrival;
  final bool isBestSeller;
  final String? key; // Open Library Work Key (e.g. /works/OL123W)

  const Book({
    required this.id,
    this.key,
    required this.title,
    required this.author,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    this.categories = const [],
    this.isBestSeller = false,
    this.isNewArrival = false,
  });

  factory Book.fromOpenLibrary(Map<String, dynamic> json) {
    // Helper to safely get the first author
    String authorName = 'Unknown Author';
    if (json['authors'] != null && (json['authors'] as List).isNotEmpty) {
      authorName = json['authors'][0]['name'] ?? 'Unknown Author';
    }

    // Helper to build cover URL
    String coverUrl = 'https://via.placeholder.com/150';
    if (json['cover_id'] != null) {
      coverUrl =
          'https://covers.openlibrary.org/b/id/${json['cover_id']}-L.jpg';
    }

    // Extract subjects/categories
    List<String> categories = [];
    if (json['subject'] != null) {
      categories = (json['subject'] as List)
          .map((e) => e.toString())
          .take(3) // Limit to 3 categories
          .toList();
    }

    // Randomize Price and Rating since API doesn't provide them
    final random = Random();
    double price = 50.0 + random.nextDouble() * 650.0; // 50 - 700
    double rating = 3.0 + random.nextDouble() * 2.0; // 3.0 - 5.0
    int reviewCount = random.nextInt(5000) + 50;

    return Book(
      id: json['key'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      key: json['key'],
      title: json['title'] ?? 'No Title',
      author: authorName,
      description:
          'No description available for this book.', // Subject API often omits text description
      price: price,
      rating: double.parse(rating.toStringAsFixed(1)),
      reviewCount: reviewCount,
      imageUrl: coverUrl,
      categories: categories,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'title': title,
      'author': author,
      'description': description,
      'price': price,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'categories': categories,
      'isBestSeller': isBestSeller,
      'isNewArrival': isNewArrival,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map, String id) {
    return Book(
      id: id,
      key: map['key'],
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      categories: List<String>.from(map['categories'] ?? []),
      isBestSeller: map['isBestSeller'] ?? false,
      isNewArrival: map['isNewArrival'] ?? false,
    );
  }

  // Mock Data
  static List<Book> get mockBooks {
    return [
      // Best Sellers / Fiction
      const Book(
        id: '1',
        title: 'The Midnight Library',
        author: 'Matt Haig',
        description:
            'Between life and death there is a library, and within that library, the shelves go on forever.',
        price: 499.00,
        rating: 4.5,
        reviewCount: 1250,
        imageUrl:
            'https://images-na.ssl-images-amazon.com/images/I/71ZlavTmFRL.jpg',
        categories: ['Fiction', 'Story Books'],
        isBestSeller: true,
      ),
      const Book(
        id: '2',
        title: 'Atomic Habits',
        author: 'James Clear',
        description:
            'No matter your goals, Atomic Habits offers a proven framework for improving--every day.',
        price: 650.00,
        rating: 4.8,
        reviewCount: 5000,
        imageUrl:
            'https://m.media-amazon.com/images/I/91bYsX41DVL._AC_UF1000,1000_QL80_.jpg',
        categories: ['Self-Help', 'Business'],
        isBestSeller: true,
      ),

      // Academics
      const Book(
        id: 'a1',
        title: 'Introduction to Algorithms',
        author: 'Thomas H. Cormen',
        description:
            'A comprehensive update of the leading algorithms text, with new material on matchings in bipartite graphs, online algorithms, machine learning, and other topics.',
        price: 125.00,
        rating: 4.7,
        reviewCount: 800,
        imageUrl:
            'https://m.media-amazon.com/images/I/61Mw06x2XcL._AC_UF1000,1000_QL80_.jpg',
        categories: ['Academics', 'Computers'],
      ),
      const Book(
        id: 'a2',
        title: 'Concepts of Physics',
        author: 'H.C. Verma',
        description: 'A classic textbook for physics students.',
        price: 430.00,
        rating: 4.9,
        reviewCount: 12000,
        imageUrl:
            'https://m.media-amazon.com/images/I/71M2+5J2CIL._AC_UF1000,1000_QL80_.jpg',
        categories: ['Academics', 'Physics'],
      ),

      // Story Books (Children/Young Adult)
      const Book(
        id: 's1',
        title: 'Harry Potter and the Sorcerer\'s Stone',
        author: 'J.K. Rowling',
        description:
            'Harry Potter has no idea how famous he is. That\'s because he\'s being raised by his miserable aunt and uncle who are terrified Harry will learn that he\'s really a wizard.',
        price: 399.00,
        rating: 4.9,
        reviewCount: 50000,
        imageUrl:
            'https://m.media-amazon.com/images/I/71-++hbbERL._AC_UF1000,1000_QL80_.jpg',
        categories: ['Story Books', 'Fantasy'],
        isBestSeller: true,
      ),
      const Book(
        id: 's2',
        title: 'Percy Jackson: The Lightning Thief',
        author: 'Rick Riordan',
        description:
            'Percy Jackson is a good kid, but he can\'t seem to focus on his schoolwork or control his temper.',
        price: 399.00,
        rating: 4.8,
        reviewCount: 8000,
        imageUrl:
            'https://m.media-amazon.com/images/I/91RQ5d-eIqL._AC_UF1000,1000_QL80_.jpg',
        categories: ['Story Books', 'Fantasy'],
      ),

      // Question Banks & Guides
      const Book(
        id: 'q1',
        title: 'JEE Main Question Bank',
        author: 'Arihant Experts',
        description:
            'Chapterwise Topicwise Solved Papers Physics, Chemistry & Mathematics.',
        price: 299.00,
        rating: 4.4,
        reviewCount: 300,
        imageUrl:
            'https://m.media-amazon.com/images/I/81L-eI+q+CL._AC_UF1000,1000_QL80_.jpg',
        categories: ['Question Banks', 'Academics'],
      ),
      const Book(
        id: 'q2',
        title: 'NEET Objectve Biology',
        author: 'Dr. Ali',
        description:
            'Objective Biology for NEET and other medical entrance examinations.',
        price: 299.00,
        rating: 4.6,
        reviewCount: 500,
        imageUrl:
            'https://m.media-amazon.com/images/I/81k7jY+sHhL._AC_UF1000,1000_QL80_.jpg',
        categories: ['Question Banks', 'Academics'],
      ),
      const Book(
        id: 'g1',
        title: 'UPSC Civil Services Guide',
        author: 'Disha Experts',
        description:
            'General Studies for Civil Services Preliminary Examination.',
        price: 299.00,
        rating: 4.5,
        reviewCount: 400,
        imageUrl:
            'https://m.media-amazon.com/images/I/71x+d+k+C4L._AC_UF1000,1000_QL80_.jpg',
        categories: ['Guides', 'Academics'],
      ),

      // New Arrivals (Mixed)
      const Book(
        id: '3',
        title: 'Project Hail Mary',
        author: 'Andy Weir',
        description:
            'Ryland Grace is the sole survivor on a desperate, last-chance mission.',
        price: 599.00,
        rating: 4.9,
        reviewCount: 3000,
        imageUrl:
            'https://images-na.ssl-images-amazon.com/images/I/91Gj6-XnQtL.jpg',
        categories: ['Sci-Fi', 'Thriller'],
        isNewArrival: true,
      ),

      // IT Department
      const Book(
        id: 'it1',
        title: 'Clean Code',
        author: 'Robert C. Martin',
        description:
            'A Handbook of Agile Software Craftsmanship. Essential for every developer.',
        price: 600.00,
        rating: 4.8,
        reviewCount: 4500,
        imageUrl:
            'https://m.media-amazon.com/images/I/51E2055ZGUL._AC_UF1000,1000_QL80_.jpg',
        categories: ['IT', 'Computers'],
        isBestSeller: true,
      ),
      const Book(
        id: 'it2',
        title: 'Flutter Apprentice',
        author: 'Ray Wenderlich',
        description: 'Learn to build cross-platform apps with Flutter.',
        price: 650.00,
        rating: 4.9,
        reviewCount: 1200,
        imageUrl:
            'https://m.media-amazon.com/images/I/71e3s6p-tVL._AC_UF1000,1000_QL80_.jpg',
        categories: ['IT', 'Computers'],
      ),

      // Nursing Department
      const Book(
        id: 'nur1',
        title: 'Medical-Surgical Nursing',
        author: 'Brunner & Suddarth',
        description: 'The best-selling textbook for medical-surgical nursing.',
        price: 699.00,
        rating: 4.7,
        reviewCount: 800,
        imageUrl:
            'https://m.media-amazon.com/images/I/81x+r2+-+L._AC_UF1000,1000_QL80_.jpg',
        categories: ['Nursing', 'Academics'],
      ),
      const Book(
        id: 'nur2',
        title: 'Anatomy and Physiology',
        author: 'Ross & Wilson',
        description: 'Foundations of anatomy and physiology for nurses.',
        price: 599.00,
        rating: 4.6,
        reviewCount: 1500,
        imageUrl:
            'https://m.media-amazon.com/images/I/91+tO2-oGZL._AC_UF1000,1000_QL80_.jpg',
        categories: ['Nursing', 'Academics'],
      ),

      // Civil Department
      const Book(
        id: 'civ1',
        title: 'Structural Analysis',
        author: 'R.C. Hibbeler',
        description: 'Comprehensive guide to structural analysis.',
        price: 550.00,
        rating: 4.5,
        reviewCount: 600,
        imageUrl:
            'https://m.media-amazon.com/images/I/71s8dC+-+L._AC_UF1000,1000_QL80_.jpg',
        categories: ['Civil', 'Engineering'],
      ),
      const Book(
        id: 'civ2',
        title: 'Surveying Vol. 1',
        author: 'B.C. Punmia',
        description: 'Standard text for civil engineering students.',
        price: 600.00,
        rating: 4.4,
        reviewCount: 900,
        imageUrl:
            'https://m.media-amazon.com/images/I/81+mC2-o+L._AC_UF1000,1000_QL80_.jpg',
        categories: ['Civil', 'Engineering'],
      ),

      // Plus Two
      const Book(
        id: 'p2_1',
        title: 'Physics Part 1 - Class 12',
        author: 'NCERT',
        description: 'Official NCERT textbook for Class 12 Physics.',
        price: 150.00,
        rating: 4.9,
        reviewCount: 5000,
        imageUrl:
            'https://m.media-amazon.com/images/I/81t+r2+-+L._AC_UF1000,1000_QL80_.jpg',
        categories: ['Plus Two', 'Academics'],
        isBestSeller: true,
      ),
      // nursing
      const Book(
        id: 'p2_1',
        title: 'Phycology 2026 - Nursing',
        author: 'NCERT',
        description: 'Official Guide for Nursing Entrance Exam.',
        price: 150.00,
        rating: 4.9,
        reviewCount: 5000,
        imageUrl:
            'c:\Users\Adithya\OneDrive\Pictures\71Ous1tgIPL._AC_UF1000,1000_QL80_.jpg',
        categories: ['Nursing', 'Entrance'],
        isBestSeller: true,
      ),

      const Book(
        id: 'p2_2',
        title: 'Chemistry Part 1 - Class 12',
        author: 'NCERT',
        description: 'Official NCERT textbook for Class 12 Chemistry.',
        price: 150.00,
        rating: 4.8,
        reviewCount: 4500,
        imageUrl:
            'https://m.media-amazon.com/images/I/81+xC2-o+L._AC_UF1000,1000_QL80_.jpg',
        categories: ['Plus Two', 'Academics'],
      ),
    ];
  }
}
