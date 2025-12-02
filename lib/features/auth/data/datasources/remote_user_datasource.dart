import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangxahoi/features/auth/domain/entities/user.dart';
import 'package:mangxahoi/core/services/cloudinary_service.dart';

class RemoteUserDatasource {
  final FirebaseFirestore _firestore;
  final CloudinaryService _cloudinary;

  RemoteUserDatasource({
    FirebaseFirestore? firestore,
    CloudinaryService? cloudinary,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _cloudinary = cloudinary ?? CloudinaryService();

  Future<User> createUser({
    required String email,
    required String userId,
    required String displayName,
  }) async {
    final now = DateTime.now();
    final user = User(
      id: userId,
      email: email,
      displayName: displayName,
      username: displayName.toLowerCase().replaceAll(' ', '_'),
      followersCount: 0,
      followingCount: 0,
      postsCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore.collection('users').doc(userId).set(user.toMap());
    return user;
  }

  Future<User?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return User.fromMap(doc.data()!);
  }

  Future<List<User>> searchUsers(String query) async {
    final snapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query.toLowerCase())
        .where('username', isLessThan: '${query.toLowerCase()}\uf8ff')
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
  }

  Future<void> updateUserProfile({
    required String userId,
    required String displayName,
    required String? bio,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'displayName': displayName,
      'bio': bio,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> uploadProfilePhoto(String userId, String localImagePath) async {
    // Upload to Cloudinary instead of Firebase Storage
    final url = await _cloudinary.uploadImage(
      imagePath: localImagePath,
      folder: 'profile_photos',
      userId: userId,
    );

    await _firestore.collection('users').doc(userId).update({
      'photoUrl': url,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    // Add to current user's following list
    await _firestore.collection('users').doc(currentUserId).update({
      'following': FieldValue.arrayUnion([targetUserId]),
      'followingCount': FieldValue.increment(1),
    });

    // Add to target user's followers list
    await _firestore.collection('users').doc(targetUserId).update({
      'followers': FieldValue.arrayUnion([currentUserId]),
      'followersCount': FieldValue.increment(1),
    });
  }

  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    // Remove from current user's following list
    await _firestore.collection('users').doc(currentUserId).update({
      'following': FieldValue.arrayRemove([targetUserId]),
      'followingCount': FieldValue.increment(-1),
    });

    // Remove from target user's followers list
    await _firestore.collection('users').doc(targetUserId).update({
      'followers': FieldValue.arrayRemove([currentUserId]),
      'followersCount': FieldValue.increment(-1),
    });
  }
}
