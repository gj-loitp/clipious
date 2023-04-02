import 'package:get/get.dart';

import '../globals.dart';

class SubscribeButtonController extends GetxController {
  static generateTags(String channelId) {
    return 'subscribe-button-$channelId';
  }

  String channelId;
  bool isSubscribed = false;
  bool loading = true;
  final bool isLoggedIn = db.isLoggedInToCurrentServer();

  SubscribeButtonController({required this.channelId});

  toggleSubscription() async {
    if (this.isSubscribed) {
      await service.unSubscribe(channelId);
    } else {
      await service.subscribe(channelId);
    }
    bool isSubscribed = await service.isSubscribedToChannel(channelId);
    this.isSubscribed = isSubscribed;
    update();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    bool isSubscribed = await service.isSubscribedToChannel(channelId);
    this.isSubscribed = isSubscribed;
    loading = false;
    update();
  }
}