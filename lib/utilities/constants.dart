class Userdetails {
  static String uid = '';
  static String uniqueName = '';
  static String userEmail = '';
  static String userDisplayName = '';
  static String userProfilePic = '';
  static String myTokenId = '';
}

List followingUsers = [];
List followers = [];

bool isDarkMode = false;

class Global {
  static const String appId = 'd89e62af-8f8d-4aab-96eb-1defe312dda6';

  static const String inspireLogoUrl =
      'https://firebasestorage.googleapis.com/v0/b/blogged---blog-app.appspot.com/o/inspireLogo-01.png?alt=media&token=b7a59c04-f7c8-4766-8bbb-2246be60b2bf';

  static List<dynamic> followersTokenId = [];
}
