class AppSession {
  static String? email;
  static String? displayName;

  static String? lastMoodText;
  static String? lastEmotion;
  static List<Map<String, dynamic>> lastTracks = <Map<String, dynamic>>[];

  static bool get isLoggedIn => email != null && email!.isNotEmpty;

  static void clear() {
    email = null;
    displayName = null;
    lastMoodText = null;
    lastEmotion = null;
    lastTracks = <Map<String, dynamic>>[];
  }
}
