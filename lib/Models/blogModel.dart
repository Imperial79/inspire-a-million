class Blog {
  String? blogId;
  String? uid;
  String? description;
  String? userDisplayName;
  DateTime? time;
  String? profileImage;
  List? likes;
  int? comments = 0;
  String? tokenId;
  List? tags;

  Blog({
    this.blogId,
    this.comments,
    this.description,
    this.likes,
    this.profileImage,
    this.tags,
    this.time,
    this.tokenId,
    this.uid,
    this.userDisplayName,
  });

  factory Blog.fromMap(Map<String, dynamic> map) {
    return Blog(
      blogId: map['blogId'],
      comments: map['comments'],
      description: map['description'],
      likes: map['likes'],
      profileImage: map['profileImage'],
      tags: map['tags'],
      time: DateTime.tryParse(map['time']),
      tokenId: map['tkenId'],
      uid: map['uid'],
      userDisplayName: map['userDisplayName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "userDisplayName": userDisplayName,
      "description": description,
      "time": time!.toIso8601String(),
      "blogId": blogId,
      "uid": uid,
      "profileImage": profileImage,
      "likes": likes,
      "comments": comments,
      "tokenId": tokenId,
      "tags": tags,
    };
  }
}
