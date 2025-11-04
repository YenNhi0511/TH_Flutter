class Post {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String imageUrl;
  final String? caption;
  final List<String> likes;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.imageUrl,
    this.caption,
    this.likes = const [],
    this.commentCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Check if current user has liked this post
  bool isLikedByUser(String userId) => likes.contains(userId);

  get likeCount => likes.length;

  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? imageUrl,
    String? caption,
    List<String>? likes,
    int? commentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'imageUrl': imageUrl,
      'caption': caption,
      'likes': likes,
      'commentCount': commentCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Unknown',
      userPhotoUrl: map['userPhotoUrl'],
      imageUrl: map['imageUrl'] ?? '',
      caption: map['caption'],
      likes: List<String>.from(map['likes'] ?? []),
      commentCount: map['commentCount'] ?? 0,
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
