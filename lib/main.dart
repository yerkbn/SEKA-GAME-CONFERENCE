import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_seka/config.dart';
import 'package:game_seka/game/game_page.dart';
import 'package:game_seka/static/card_combinations_page.dart';
import 'package:jigi_app/navigation/main_navigation.dart';
import 'package:jigi_core/core/config/app_config.dart';
import 'package:jigi_core/core/config/game_config.dart';
import 'package:jigi_core/core/model/user/view_config.dart';
import 'package:jigi_core/core/model/vector/vector.dart';
import 'package:jigi_core/core/sizer/sizer.dart';
import 'package:jigi_core/module/network_provider/network_provider.dart';
import 'package:jigi_core/module/user_repository/user_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

void main() async {
  // await Firebase.initializeApp();

  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  /// Initializing Network Provider
  NetworkProvider.init(
      appToken: BACKEND_APP_TOKEN,
      url: BACKEND_URL,
      defaultUrlKey: 'main',
      socketUrl: BACKEND_SOCKET,
      userRepository: UserRepositorySP());

  /// initializing general parameters
  AppConfig.init(
      appIdentifier: AppConfig.SEKA,
      hasherToken: HASHER_TOKEN,
      gameName: 'Seka',
      currentVersion: 17,
      androidGoldIds: {
        '???',
        '???',
        '???',
        '???',
      },
      iosLink: UPDATE_IOS,
      androidLink: UPDATE_ANDROID,
      adApId: AD_APP_ID,
      shareLink: SHARE_LINK);

  /// initializing Game Parameters
  GameConfig.init(
      playerViewConfiguration: PlayersViewConfig(
          [
        PlayerView(
            index: 0,
            initialPosition: const Vector(20, 1000),
            cardPosition:
                const Vector(AVATAR_DIAMATER + 180, AVATAR_DIAMATER + 850),
            chipsPosition:
                const Vector(AVATAR_DIAMATER + 30, AVATAR_DIAMATER + 900),
            isLeft: false),
        PlayerView(
            index: 1,
            initialPosition: const Vector(80, 420),
            cardPosition:
                const Vector(AVATAR_DIAMATER + 180, AVATAR_DIAMATER + 500),
            chipsPosition:
                const Vector(AVATAR_DIAMATER + 90, AVATAR_DIAMATER + 400),
            isLeft: false),
        PlayerView(
            index: 2,
            initialPosition: const Vector(430, 100),
            cardPosition: const Vector(GAME_WIDTH / 2, AVATAR_DIAMATER + 300),
            chipsPosition: const Vector(
                (GAME_WIDTH - CHIP_LENGTH) / 2, AVATAR_DIAMATER + 220),
            isLeft: false),
        PlayerView(
            index: 3,
            initialPosition: const Vector(1000 - AVATAR_DIAMATER, 420),
            cardPosition: const Vector(
                GAME_WIDTH - (AVATAR_DIAMATER + CHIP_LENGTH + 90) + 90,
                AVATAR_DIAMATER + 500),
            chipsPosition: const Vector(
                GAME_WIDTH - (AVATAR_DIAMATER + CHIP_LENGTH + 90),
                AVATAR_DIAMATER + 400),
            isLeft: true),
        PlayerView(
            index: 4,
            initialPosition: const Vector(1060 - AVATAR_DIAMATER, 1000),
            cardPosition: const Vector(
                GAME_WIDTH - (AVATAR_DIAMATER + CHIP_LENGTH + 90) + 90,
                AVATAR_DIAMATER + 850),
            chipsPosition: const Vector(
                GAME_WIDTH - (AVATAR_DIAMATER + CHIP_LENGTH + 30),
                AVATAR_DIAMATER + 900),
            isLeft: true),
      ],
          PlayerView(
              index: -1,
              initialPosition: const Vector(430, 1350),
              cardPosition: const Vector(GAME_WIDTH / 2, 1270),
              chipsPosition:
                  const Vector((GAME_WIDTH - CHIP_LENGTH) / 2 + 180, 1300),
              isLeft: true)));

  /// Disable top system status bar
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  runApp(MainNavigation(
    gameManual: CardCombinationsPage(),
    gameCreator:
        (BuildContext context, RouteObserver<Route<dynamic>> observer) =>
            GamePage(
      routeObserver: observer as RouteObserver<PageRoute<dynamic>>,
    ),
  ));
}
