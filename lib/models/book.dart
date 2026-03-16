import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final double price;
  final double discountPercentage;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String> categories;
  final bool isNewArrival;
  final bool isBestSeller;
  final String? key; // Open Library Work Key (e.g. /works/OL123W)
  final String sellerName;
  final String? uploaderId;
  final DateTime? uploadedAt;
  final String thumbnail;
  final bool isDonation;
  final String isbn;

  const Book({
    required this.id,
    this.key,
    required this.title,
    required this.author,
    required this.description,
    required this.price,
    this.discountPercentage = 0.0,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    this.categories = const [],
    this.isBestSeller = false,
    this.isNewArrival = false,
    this.sellerName = 'EduShare',
    this.uploaderId,
    this.uploadedAt,
    this.thumbnail = '',
    this.isDonation = false,
    this.isbn = '',
  });

  Book copyWith({
    String? id,
    String? key,
    String? title,
    String? author,
    String? description,
    double? price,
    double? discountPercentage,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    List<String>? categories,
    bool? isNewArrival,
    bool? isBestSeller,
    String? sellerName,
    String? uploaderId,
    DateTime? uploadedAt,
    String? thumbnail,
    bool? isDonation,
    String? isbn,
  }) {
    return Book(
      id: id ?? this.id,
      key: key ?? this.key,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      isNewArrival: isNewArrival ?? this.isNewArrival,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      sellerName: sellerName ?? this.sellerName,
      uploaderId: uploaderId ?? this.uploaderId,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      thumbnail: thumbnail ?? this.thumbnail,
      isDonation: isDonation ?? this.isDonation,
      isbn: isbn ?? this.isbn,
    );
  }

  double get originalPrice {
    if (price == 0 || isDonation) return price;
    // Ensure there's always a visual "cut" price if discount is not set or too small
    double effectiveDiscount = discountPercentage >= 5.0
        ? discountPercentage
        : 25.0;
    return price / (1 - (effectiveDiscount / 100));
  }

  double get effectiveDiscountPercentage {
    if (isDonation || price == 0) return 0.0;
    return discountPercentage >= 5.0 ? discountPercentage : 25.0;
  }

  factory Book.fromOpenLibrary(Map<String, dynamic> json) {
    // ... existing logic ...
    String authorName = 'Unknown Author';
    if (json['authors'] != null && (json['authors'] as List).isNotEmpty) {
      authorName = json['authors'][0]['name'] ?? 'Unknown Author';
    }

    String coverUrl = 'https://via.placeholder.com/150';
    if (json['cover_id'] != null) {
      coverUrl =
          'https://covers.openlibrary.org/b/id/${json['cover_id']}-L.jpg';
    }

    List<String> categories = [];
    if (json['subject'] != null) {
      categories = (json['subject'] as List)
          .map((e) => e.toString())
          .take(3)
          .toList();
    }

    // Randomize Price, Discount and Rating
    final random = Random();
    // Base price at least 150 to allow room for "striking" to 110-120
    double price = 110.0 + random.nextDouble() * 500.0;
    double discountPercentage = 20.0 + random.nextInt(15); // 20-35%
    double rating = 3.5 + random.nextDouble() * 1.5;
    int reviewCount = random.nextInt(3000) + 20;

    return Book(
      id: json['key'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      key: json['key'],
      title: json['title'] ?? 'No Title',
      author: authorName,
      description: 'No description available for this book.',
      price: price.clamp(110.0, 5000.0),
      discountPercentage: discountPercentage,
      rating: double.parse(rating.toStringAsFixed(1)),
      reviewCount: reviewCount,
      imageUrl: coverUrl,
      categories: categories,
    );
  }

  Map<String, dynamic> toMap({bool forLocal = false}) {
    return {
      'id': id,
      'key': key,
      'title': title,
      'author': author,
      'description': description,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'categories': categories,
      'isBestSeller': isBestSeller,
      'isNewArrival': isNewArrival,
      'sellerName': sellerName,
      'uploaderId': uploaderId,
      'timestamp': uploadedAt != null
          ? (forLocal
              ? uploadedAt!.millisecondsSinceEpoch
              : Timestamp.fromDate(uploadedAt!))
          : (forLocal ? DateTime.now().millisecondsSinceEpoch : FieldValue.serverTimestamp()),
      'thumbnail': thumbnail,
      'isDonation': isDonation,
      'isbn': isbn,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map, String id) {
    DateTime? uploadedAt;
    if (map['timestamp'] != null) {
      if (map['timestamp'] is Timestamp) {
        uploadedAt = (map['timestamp'] as Timestamp).toDate();
      } else if (map['timestamp'] is int) {
        uploadedAt = DateTime.fromMillisecondsSinceEpoch(map['timestamp']);
      }
    }

    return Book(
      id: id,
      key: map['key'],
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      discountPercentage: (map['isDonation'] == true)
          ? 0.0
          : (map['discountPercentage'] != null &&
                (map['discountPercentage'] as num) > 0)
          ? (map['discountPercentage'] as num).toDouble()
          : 25.0, // Default 25% if missing or 0
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      categories:
          (map['categories'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isBestSeller: map['isBestSeller'] ?? false,
      isNewArrival: map['isNewArrival'] ?? false,
      sellerName: map['sellerName'] ?? 'EduShare',
      uploaderId: map['uploaderId'],
      uploadedAt: uploadedAt,
      thumbnail: map['thumbnail'] ?? map['imageUrl'] ?? '',
      isDonation: map['isDonation'] ?? false,
      isbn: map['isbn'] ?? '',
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
        price: 399.00,
        discountPercentage: 20.0,
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
        price: 550.00,
        discountPercentage: 15.0,
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
        price: 425.00,
        discountPercentage: 10.0,
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
        price: 320.00,
        discountPercentage: 20.0,
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
        price: 299.00,
        discountPercentage: 25.0,
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
        price: 299.00,
        discountPercentage: 25.0,
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
        price: 249.00,
        discountPercentage: 25.0,
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
        price: 249.00,
        discountPercentage: 20.0,
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
        price: 249.00,
        discountPercentage: 30.0,
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
        price: 499.00,
        discountPercentage: 30.0,
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
        price: 450.00,
        discountPercentage: 25.0,
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
        price: 450.00,
        discountPercentage: 30.0,
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
        price: 499.00,
        discountPercentage: 40.0,
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
        price: 419.00,
        discountPercentage: 30.0,
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
        price: 450.00,
        discountPercentage: 25.0,
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
        price: 450.00,
        discountPercentage: 25.0,
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
        price: 120.00,
        discountPercentage: 20.0,
        rating: 4.9,
        reviewCount: 5000,
        imageUrl:
            'https://m.media-amazon.com/images/I/81t+r2+-+L._AC_UF1000,1000_QL80_.jpg',
        categories: ['Plus Two', 'Academics'],
        isBestSeller: true,
      ),
      // nursing
      const Book(
        id: 'p2_nurs',
        title: 'Phycology 2026 - Nursing',
        author: 'NCERT',
        description: 'Official Guide for Nursing Entrance Exam.',
        price: 210.00,
        discountPercentage: 30.0,
        rating: 4.9,
        reviewCount: 5000,
        imageUrl:
            r'c:\Users\Adithya\OneDrive\Pictures\71Ous1tgIPL._AC_UF1000,1000_QL80_.jpg',
        categories: ['Nursing', 'Entrance'],
        isBestSeller: true,
      ),

      const Book(
        id: 'p2_2',
        title: 'Chemistry Part 1 - Class 12',
        author: 'NCERT',
        description: 'Official NCERT textbook for Class 12 Chemistry.',
        price: 150.00,
        discountPercentage: 50.0,
        rating: 4.8,
        reviewCount: 4500,
        imageUrl:
            'https://m.media-amazon.com/images/I/81+xC2-o+L._AC_UF1000,1000_QL80_.jpg',
        categories: ['Plus Two', 'Academics'],
      ),
    ];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Book && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
