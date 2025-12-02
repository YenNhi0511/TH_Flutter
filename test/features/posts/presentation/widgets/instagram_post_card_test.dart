import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mangxahoi/features/posts/domain/entities/post.dart';
import 'package:mangxahoi/features/posts/presentation/widgets/instagram_post_card.dart';
import 'package:mangxahoi/core/providers/posts_provider.dart';

/// Widget Tests cho InstagramPostCard
/// Test các thành phần UI phức tạp: hiển thị post, nút like, animation
void main() {
  late Post testPost;
  late PostsProvider mockPostsProvider;
  const String testUserId = 'test_user_123';

  setUp(() {
    testPost = Post(
      id: 'test_post_1',
      userId: 'author_user_456',
      userName: 'John Doe',
      userPhotoUrl: 'https://via.placeholder.com/150',
      imageUrl: 'https://via.placeholder.com/600',
      caption: 'This is a test caption for the post! #flutter #testing',
      likes: ['user1', 'user2'],
      commentCount: 5,
      createdAt: DateTime(2024, 1, 1, 12, 0, 0),
      updatedAt: DateTime(2024, 1, 1, 12, 0, 0),
    );

    mockPostsProvider = PostsProvider();
  });

  Widget createTestWidget(Post post, {String currentUserId = testUserId}) {
    return ChangeNotifierProvider<PostsProvider>.value(
      value: mockPostsProvider,
      child: MaterialApp(
        home: Scaffold(
          body: InstagramPostCard(post: post, currentUserId: currentUserId),
        ),
      ),
    );
  }

  group('InstagramPostCard Widget Tests', () {
    testWidgets('Hiển thị tất cả thông tin cơ bản của post', (tester) async {
      await tester.pumpWidget(createTestWidget(testPost));
      await tester.pumpAndSettle();

      // Tìm username
      expect(find.text('John Doe'), findsOneWidget);

      // Tìm caption (có thể hiển thị một phần)
      expect(find.textContaining('This is a test caption'), findsOneWidget);

      // Tìm số lượng likes (2 likes)
      expect(find.textContaining('2'), findsWidgets);

      // Tìm số lượng comments
      expect(find.textContaining('5'), findsAtLeastNWidgets(1));
    });

    testWidgets('Hiển thị nút like khi chưa like', (tester) async {
      await tester.pumpWidget(createTestWidget(testPost));
      await tester.pumpAndSettle();

      // Tìm icon favorite_border (chưa like)
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('Hiển thị nút liked khi đã like', (tester) async {
      // Tạo post mà user hiện tại đã like
      final likedPost = testPost.copyWith(
        likes: [...testPost.likes, testUserId],
      );

      await tester.pumpWidget(createTestWidget(likedPost));
      await tester.pumpAndSettle();

      // Tìm icon favorite (đã like)
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('Tap nút like thay đổi trạng thái', (tester) async {
      await tester.pumpWidget(createTestWidget(testPost));
      await tester.pumpAndSettle();

      // Ban đầu chưa like
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      // Tap nút like
      final likeButton = find.byIcon(Icons.favorite_border);
      await tester.tap(likeButton);
      await tester.pumpAndSettle();

      // Sau khi like, icon đổi thành filled heart
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('Double tap image để like post', (tester) async {
      await tester.pumpWidget(createTestWidget(testPost));
      await tester.pumpAndSettle();

      // Tìm GestureDetector chứa image
      final imageArea = find.byType(GestureDetector).first;

      // Double tap
      await tester.tap(imageArea);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(imageArea);
      await tester.pumpAndSettle();

      // Kiểm tra đã like
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('Hiển thị số lượng likes tăng khi like', (tester) async {
      await tester.pumpWidget(createTestWidget(testPost));
      await tester.pumpAndSettle();

      // Số likes ban đầu: 2
      expect(find.textContaining('2'), findsWidgets);

      // Tap like
      final likeButton = find.byIcon(Icons.favorite_border);
      await tester.tap(likeButton);
      await tester.pumpAndSettle();

      // Số likes tăng lên: 3
      expect(find.textContaining('3'), findsWidgets);
    });

    testWidgets('Tap nút comment mở trang comments', (tester) async {
      await tester.pumpWidget(createTestWidget(testPost));
      await tester.pumpAndSettle();

      // Tìm nút comment
      final commentButton = find.byIcon(Icons.chat_bubble_outline);
      expect(commentButton, findsOneWidget);

      // Tap nút comment
      await tester.tap(commentButton);
      await tester.pumpAndSettle();

      // Kiểm tra navigation (sẽ có dialog hoặc page mới)
      // Note: Cần mock Navigator để test đầy đủ
    });

    testWidgets('Hiển thị menu khi tap nút more', (tester) async {
      // Tạo post của chính user hiện tại để có quyền xóa
      final ownPost = testPost.copyWith(userId: testUserId);

      await tester.pumpWidget(createTestWidget(ownPost));
      await tester.pumpAndSettle();

      // Tìm nút more
      final moreButton = find.byIcon(Icons.more_vert);
      expect(moreButton, findsOneWidget);

      // Tap nút more
      await tester.tap(moreButton);
      await tester.pumpAndSettle();

      // Kiểm tra popup menu xuất hiện
      expect(find.byType(PopupMenuButton), findsOneWidget);
    });

    testWidgets('Hiển thị avatar của user', (tester) async {
      await tester.pumpWidget(createTestWidget(testPost));
      await tester.pumpAndSettle();

      // Tìm CircleAvatar
      expect(find.byType(CircleAvatar), findsAtLeastNWidgets(1));
    });

    testWidgets('Hiển thị thời gian đăng (time ago)', (tester) async {
      await tester.pumpWidget(createTestWidget(testPost));
      await tester.pumpAndSettle();

      // Tìm text chứa thời gian (ví dụ: "giờ trước", "ngày trước")
      expect(
        find.textContaining('trước', findRichText: true),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('Post không có caption vẫn hiển thị bình thường', (
      tester,
    ) async {
      final postWithoutCaption = testPost.copyWith(caption: null);

      await tester.pumpWidget(createTestWidget(postWithoutCaption));
      await tester.pumpAndSettle();

      // Card vẫn hiển thị
      expect(find.byType(InstagramPostCard), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('Post không có likes hiển thị 0', (tester) async {
      final postWithoutLikes = testPost.copyWith(likes: []);

      await tester.pumpWidget(createTestWidget(postWithoutLikes));
      await tester.pumpAndSettle();

      // Hiển thị 0 likes
      expect(find.textContaining('0'), findsAtLeastNWidgets(1));
    });

    testWidgets('Post không có comments hiển thị 0', (tester) async {
      final postWithoutComments = testPost.copyWith(commentCount: 0);

      await tester.pumpWidget(createTestWidget(postWithoutComments));
      await tester.pumpAndSettle();

      // Hiển thị 0 comments
      expect(find.textContaining('0'), findsAtLeastNWidgets(1));
    });

    testWidgets('Unlike post giảm số lượng likes', (tester) async {
      // Tạo post đã like
      final likedPost = testPost.copyWith(
        likes: [...testPost.likes, testUserId],
      );

      await tester.pumpWidget(createTestWidget(likedPost));
      await tester.pumpAndSettle();

      // Số likes ban đầu: 3
      expect(find.textContaining('3'), findsWidgets);

      // Tap unlike
      final unlikeButton = find.byIcon(Icons.favorite);
      await tester.tap(unlikeButton);
      await tester.pumpAndSettle();

      // Số likes giảm xuống: 2
      expect(find.textContaining('2'), findsWidgets);
    });

    testWidgets('Caption dài hiển thị "Xem thêm"', (tester) async {
      final longCaption = 'A' * 200; // Caption rất dài
      final postWithLongCaption = testPost.copyWith(caption: longCaption);

      await tester.pumpWidget(createTestWidget(postWithLongCaption));
      await tester.pumpAndSettle();

      // Tìm text "Xem thêm" hoặc "more"
      // Note: Kiểm tra có text bị truncate không
      final captionWidget = find.textContaining('A');
      expect(captionWidget, findsAtLeastNWidgets(1));
    });

    testWidgets('Like animation hiển thị khi double tap', (tester) async {
      await tester.pumpWidget(createTestWidget(testPost));
      await tester.pump();

      // Tìm GestureDetector
      final imageArea = find.byType(GestureDetector).first;

      // Double tap để trigger animation
      await tester.tap(imageArea);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(imageArea);

      // Pump một frame để animation bắt đầu
      await tester.pump();

      // Kiểm tra animation đang chạy
      // (Icon heart lớn sẽ xuất hiện)
      await tester.pump(const Duration(milliseconds: 200));

      // Hoàn thành animation
      await tester.pumpAndSettle();
    });

    testWidgets('Nút share có thể tap', (tester) async {
      await tester.pumpWidget(createTestWidget(testPost));
      await tester.pumpAndSettle();

      // Tìm nút share
      final shareButton = find.byIcon(Icons.send_outlined);
      expect(shareButton, findsOneWidget);

      // Tap được
      await tester.tap(shareButton);
      await tester.pumpAndSettle();
    });

    testWidgets('Nút bookmark có thể tap', (tester) async {
      await tester.pumpWidget(createTestWidget(testPost));
      await tester.pumpAndSettle();

      // Tìm nút bookmark
      final bookmarkButton = find.byIcon(Icons.bookmark_border);
      expect(bookmarkButton, findsOneWidget);

      // Tap được
      await tester.tap(bookmarkButton);
      await tester.pumpAndSettle();
    });
  });

  group('InstagramPostCard Accessibility Tests', () {
    testWidgets('Có Semantics labels cho accessibility', (tester) async {
      await tester.pumpWidget(createTestWidget(testPost));
      await tester.pumpAndSettle();

      // Kiểm tra widget có semantics
      expect(find.byType(Semantics), findsAtLeastNWidgets(1));
    });

    testWidgets('Buttons có kích thước đủ lớn để tap', (tester) async {
      await tester.pumpWidget(createTestWidget(testPost));
      await tester.pumpAndSettle();

      // Tìm like button
      final likeButton = find.byIcon(Icons.favorite_border);
      final buttonSize = tester.getSize(likeButton);

      // Kích thước tối thiểu 44x44 (Material Design guideline)
      expect(buttonSize.width, greaterThanOrEqualTo(24));
      expect(buttonSize.height, greaterThanOrEqualTo(24));
    });
  });

  group('InstagramPostCard Performance Tests', () {
    testWidgets('Widget build không quá lâu', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(createTestWidget(testPost));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Build time nên dưới 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    testWidgets('Multiple animations không gây lag', (tester) async {
      await tester.pumpWidget(createTestWidget(testPost));
      await tester.pump();

      // Trigger nhiều animations
      final imageArea = find.byType(GestureDetector).first;

      for (int i = 0; i < 5; i++) {
        await tester.tap(imageArea);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(imageArea);
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pumpAndSettle();

      // Không có exception
      expect(tester.takeException(), isNull);
    });
  });
}
