import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spotify/spotify.dart';

// Save Spotify API Credentials to FlutterSecureStorage
Future<void> saveSpotifyCredentials(
    SpotifyApi spotifyApi, String fbDocId) async {
  const storage = FlutterSecureStorage();
  SpotifyApiCredentials credentials = await spotifyApi.getCredentials();
  await storage.write(key: "tunestreak_clientId", value: credentials.clientId);
  await storage.write(
      key: "tunestreak_clientSecret", value: credentials.clientSecret);
  await storage.write(
      key: "tunestreak_accessToken", value: credentials.accessToken);
  await storage.write(
      key: "tunestreak_refreshToken", value: credentials.refreshToken);
  await storage.write(
      key: "tunestreak_scopes", value: jsonEncode(credentials.scopes));
  await storage.write(
      key: "tunestreak_expiration", value: credentials.expiration.toString());
  await storage.write(key: "tunestreak_fbDocId", value: fbDocId);
}
