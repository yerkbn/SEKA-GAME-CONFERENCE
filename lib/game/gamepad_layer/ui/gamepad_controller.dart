import 'package:flutter/material.dart';
import 'package:game_seka/game/gamepad_layer/ui/bet_buttons.dart';
import 'package:game_seka/game/model/seka_player_state.dart';
import 'package:game_seka/game/player_layer/instruction/player_instructions.dart';
import 'package:jigi_core/core/sizer/sizer.dart';

class GamepadController extends StatefulWidget {
  final SekaPlayerState currentPlayer;
  GamepadController({
    required this.currentPlayer,
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return GamepadControllerState();
  }
}

class GamepadControllerState extends State<GamepadController> {
  SekaPlayerState get _player => widget.currentPlayer;

  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        width: GAME_WIDTH,
      ),

      /// It first check does it [LoadingCallBlindInsD]
      /// if so, [OpenBlindButtons] will ask do you want to play
      /// blind/open based to this player will make some event
      _player.status is LoadingCallBlindInsD
          ? OpenBlindButtons(
              currentPlayer: _player,
              callBlind: _player.status as LoadingCallBlindInsD,
            )
          : _player.isTurn
              ? BetButtons(
                  instructionData: _player.status,
                  currentPlayer: _player,
                )
              : Container(),
    ]);
  }

  /// Because Turn will be setted by PlayerAgent
  /// To listen and update when player status
  /// change we have to rebuild
  void update() => setState(() {});
}
