class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  final int id;
  final int userId;
  final String title;
  final String body;

  factory Post.fromJson(Map<String, dynamic> j) => Post(
    id: (j['id'] as num).toInt(),
    userId: (j['userId'] as num?)?.toInt() ?? 0,
    title: j['title'] as String? ?? '',
    body: j['body'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'body': body,
  };
}
