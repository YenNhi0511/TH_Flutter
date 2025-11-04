import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mangxahoi/features/posts/domain/entities/post.dart';
import 'package:mangxahoi/features/posts/domain/entities/comment.dart';

class RemotePostDatasource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  RemotePostDatasource({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  Future<void> createPost({
    required String userId,
    required String userName,
    required String? userPhotoUrl,
    required String imagePath,
    required String? caption,
  }) async {
    final postId = _firestore.collection('posts').doc().id;
    final ref = _storage.ref().child('posts/$userId/$postId.jpg');

    await ref.putFile(
      File(imagePath),
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final imageUrl = await ref.getDownloadURL();
    final now = DateTime.now();

    final post = Post(
      id: postId,
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      imageUrl: imageUrl,
      caption: caption,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore.collection('posts').doc(postId).set(post.toMap());

    // Update user's post count
    await _firestore.collection('users').doc(userId).update({
      'postsCount': FieldValue.increment(1),
    });
  }

  Future<List<Post>> getPosts({int limit = 20}) async {
    final snapshot = await _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => Post.fromMap(doc.data())).toList();
  }

  Future<List<Post>> getUserPosts(String userId, {int limit = 10}) async {
    final snapshot = await _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => Post.fromMap(doc.data())).toList();
  }

  Future<Post?> getPostById(String postId) async {
    final doc = await _firestore.collection('posts').doc(postId).get();
    if (!doc.exists) return null;
    return Post.fromMap(doc.data()!);
  }

  Future<void> likePost({
    required String postId,
    required String userId,
  }) async {
    await _firestore.collection('posts').doc(postId).update({
      'likes': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> unlikePost({
    required String postId,
    required String userId,
  }) async {
    await _firestore.collection('posts').doc(postId).update({
      'likes': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> deletePost(String postId) async {
    // Get post to find image
    final post = await getPostById(postId);
    if (post != null) {
      // Delete image from storage
      try {
        await _storage.refFromURL(post.imageUrl).delete();
      } catch (e) {
        // Image deletion failed, but continue with post deletion
      }

      // Update user's post count
      await _firestore.collection('users').doc(post.userId).update({
        'postsCount': FieldValue.increment(-1),
      });
    }

    // Delete post document
    await _firestore.collection('posts').doc(postId).delete();

    // Delete all comments
    final comments = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get();

    for (var comment in comments.docs) {
      await comment.reference.delete();
    }
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String userPhotoUrl,
    required String text,
  }) async {
    final commentId = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc()
        .id;

    final now = DateTime.now();
    final comment = Comment(
      id: commentId,
      postId: postId,
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      text: text,
      createdAt: now,
    );

    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .set(comment.toMap());

    // Update comment count
    await _firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  Future<List<Comment>> getComments(String postId) async {
    final snapshot = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Comment.fromMap(doc.data())).toList();
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();

    // Update comment count
    await _firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(-1),
    });
  }
}
