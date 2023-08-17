import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invidious/globals.dart';
import 'package:invidious/main.dart';
import 'package:invidious/myRouteObserver.dart';
import 'package:invidious/videos/views/screens/video.dart';
import 'package:invidious/videos/views/components/compact_video.dart';

import '../../states/history.dart';
import '../../../utils/views/components/placeholders.dart';

class HistoryVideoView extends StatelessWidget {
  final String videoId;

  const HistoryVideoView({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryItemCubit(HistoryItemState(videoId: videoId)),
      child: BlocBuilder<HistoryItemCubit, HistoryItemState>(builder: (context, _) {
        return AnimatedCrossFade(
          firstChild: const CompactVideoPlaceHolder(),
          secondChild: _.cachedVid != null
              ? CompactVideo(
                  onTap: () => navigatorKey.currentState?.pushNamed(PATH_VIDEO, arguments: VideoRouteArguments(videoId: _.cachedVid!.videoId)),
                  video: _.cachedVid?.toBaseVideo(),
                )
              : const SizedBox.shrink(),
          crossFadeState: _.loading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: animationDuration,
        );
      }),
    );
  }
}
