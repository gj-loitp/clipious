// import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:after_layout/after_layout.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:invidious/database.dart';
import 'package:invidious/globals.dart';
import 'package:invidious/main.dart';
import 'package:invidious/models/imageObject.dart';
import 'package:invidious/objectbox.g.dart';
import 'package:invidious/views/channel/info.dart';
import 'package:invidious/views/channel/playlists.dart';
import 'package:invidious/views/channel/videos.dart';
import 'package:invidious/views/components/videoThumbnail.dart';
import 'package:invidious/views/video/comments.dart';
import 'package:invidious/views/video/info.dart';
import 'package:invidious/views/video/recommendedVideos.dart';

import '../models/channel.dart';
import '../models/sponsorSegment.dart';
import '../models/video.dart';
import '../utils.dart';
import 'components/subscribeButton.dart';

class ChannelView extends StatefulWidget {
  final String channelId;

  const ChannelView({super.key, required this.channelId});

  @override
  State<ChannelView> createState() => ChannelViewState();
}

class ChannelViewState extends State<ChannelView> with AfterLayoutMixin<ChannelView> {
  bool isSubscribed = false;
  ScrollController scrollController = ScrollController();
  int selectedIndex = 0;
  Channel? channel;
  bool loading = true;
  double bannerHeight = 200;
  double opacity = 1;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(onScroll);
  }

  @override
  dispose() async {
    super.dispose();
  }

  onScroll() {
    setState(() {
      bannerHeight = max(0, 200 - scrollController.offset);
      opacity = 1 - min(1, ((scrollController.offset) / 200));
    });
  }

  toggleSubscription() async {
    if (this.isSubscribed) {
      await service.unSubscribe(widget.channelId);
    } else {
      await service.subscribe(widget.channelId);
    }
    bool isSubscribed = await service.isSubscribedToChannel(widget.channelId);
    setState(() {
      this.isSubscribed = isSubscribed;
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          channel?.author ?? '',
        ),
        scrolledUnderElevation: 0,
        actions: [
          Visibility(
            visible: channel != null,
            child: GestureDetector(
              onTap: () => showSharingSheet(context, channel!),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.share,
                  color: colorScheme.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: colorScheme.background,
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        elevation: 0,
        onDestinationSelected: (int index) {
          setState(() {
            scrollController.animateTo(0, duration: animationDuration, curve: Curves.easeInOutQuad);
            selectedIndex = index;
          });
        },
        selectedIndex: selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.info), label: 'Info'),
          NavigationDestination(icon: Icon(Icons.play_arrow), label: 'Videos'),
          // NavigationDestination(icon: Icon(Icons.playlist_play), label: 'Playlists')
        ],
      ),
      body: SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: animationDuration,
            child: loading
                ? Container(alignment: Alignment.center, child: const CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8, right: 8),
                        child: AnimatedOpacity(
                          opacity: opacity,
                          duration: Duration.zero,
                          child: Thumbnail(
                              width: double.infinity,
                              height: bannerHeight,
                              thumbnailUrl: ImageObject.getBestThumbnail(channel!.authorThumbnails)?.url ?? '',
                              id: 'channel-banner/${widget.channelId}',
                              decoration: BoxDecoration(color: colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
                      //   child: Text(
                      //     channel!.author,
                      //     style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.normal, fontSize: 20),
                      //     textAlign: TextAlign.start,
                      //   ),
                      // ),
                      Row(
                        children: [
                          SubscribeButton(channelId: channel!.authorId, subCount: compactCurrency.format(channel!.subCount)),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                            child: <Widget>[
                              ChannelInfo(channel: channel!),
                              ChannelVideosView(channel: channel!),
                              // ChannelPlayListsView(channelId: channel!.authorId)
                            ][selectedIndex],
                          ),
                        ),
                      )
                    ],
                  ),
          )),
    );
  }

  @override
  Future<FutureOr<void>> afterFirstLayout(BuildContext context) async {
    bool isSubscribed = await service.isSubscribedToChannel(widget.channelId);
    Channel channel = await service.getChannel(widget.channelId);

    setState(() {
      this.channel = channel;
      loading = false;
      this.isSubscribed = isSubscribed;
    });
  }
}