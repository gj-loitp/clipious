import 'package:flutter_test/flutter_test.dart';
import 'package:invidious/globals.dart';
import 'package:invidious/subscription_management/states/subscribe_button.dart';
import 'package:invidious/videos/states/add_to_playlist.dart';

import '../utils/memorydb.dart';
import '../utils/server.dart';

void main() {
  setUpAll(() async {
    db = MemoryDB();
    var server = await getLoggedInTestServer();
    db.upsertServer(server);
  });

  tearDown(() async {
    // remove all playlists
    var playlists = await service.getUserPlaylists();
    for (var pl in playlists) {
      await service.deleteUserPlaylist(pl.playlistId);
    }
  });

  test('like video', () async {
    const videoId = 'dQw4w9WgXcQ';
    var cubit = AddToPlaylistCubit(AddToPlaylistController.init(videoId));
    await cubit.onReady();
    expect(cubit.state.playlists.length, 0);
    expect(cubit.state.playListCount, 0);
    expect(cubit.state.isVideoLiked, false);

    await cubit.toggleLike();
    await cubit.onReady();
    // liking a video, should create the like playlist if it does not exist
    expect(cubit.state.playlists.length, 1);
    expect(cubit.state.playlists.any((element) => element.title == likePlaylistName), true);
    expect(cubit.state.playListCount, 1);
    expect(cubit.state.isVideoLiked, true);

    await cubit.toggleLike();
    await cubit.onReady();

    expect(cubit.state.playlists.length, 1);
    expect(cubit.state.playlists.any((element) => element.title == likePlaylistName), true);
    expect(cubit.state.playListCount, 0);
    expect(cubit.state.isVideoLiked, false);
  });

  test('add to playlist ', () async {
    // creating a new playlist
    await service.createPlayList("test playlist", "public");

    const videoId = 'dQw4w9WgXcQ';
    var cubit = AddToPlaylistCubit(AddToPlaylistController.init(videoId));
    await cubit.onReady();
    expect(cubit.state.playlists.length, 1);
    expect(cubit.state.playListCount, 0);
    expect(cubit.state.isVideoLiked, false);

    await cubit.addToPlaylist(cubit.state.playlists.first.playlistId);
    await cubit.onReady();

    expect(cubit.state.playlists.length, 1);
    expect(cubit.state.playListCount, 1);
    expect(cubit.state.isVideoLiked, false);


  });
}
