import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/spotify_session.dart';

class SpotifyCallbackPage extends StatefulWidget {
  const SpotifyCallbackPage({super.key});

  @override
  State<SpotifyCallbackPage> createState() => _SpotifyCallbackPageState();
}

class _SpotifyCallbackPageState extends State<SpotifyCallbackPage> {
  String _message = 'Connecting your Spotify account...';

  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Map<String, String> _extractParams() {
    final direct = Uri.base.queryParameters;
    if (direct.isNotEmpty) {
      return direct;
    }

    final fragment = Uri.base.fragment;
    final index = fragment.indexOf('?');
    if (index == -1 || index == fragment.length - 1) {
      return {};
    }

    return Uri.splitQueryString(fragment.substring(index + 1));
  }

  Future<void> _handleCallback() async {
    final params = _extractParams();
    final error = params['error'];

    if (error != null && error.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _message = 'Spotify connection failed: $error';
      });
      return;
    }

    SpotifySession.accessToken = params['access_token'];
    SpotifySession.refreshToken = params['refresh_token'];
    SpotifySession.expiresIn = params['expires_in'];
    SpotifySession.spotifyId = params['spotify_id'];
    SpotifySession.displayName = params['display_name'];
    SpotifySession.email = params['email'];

    if (!SpotifySession.isConnected) {
      if (!mounted) return;
      setState(() {
        _message = 'Spotify connection did not return an access token.';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _message = 'Spotify connected. Redirecting to home...';
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _message,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
