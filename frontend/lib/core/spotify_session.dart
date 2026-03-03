class SpotifySession {
  static String? accessToken;
  static String? refreshToken;
  static String? expiresIn;
  static String? spotifyId;
  static String? displayName;
  static String? email;

  static bool get isConnected => accessToken != null && accessToken!.isNotEmpty;

  static void clear() {
    accessToken = null;
    refreshToken = null;
    expiresIn = null;
    spotifyId = null;
    displayName = null;
    email = null;
  }
}
