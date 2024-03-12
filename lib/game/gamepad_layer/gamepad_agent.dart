import 'package:flutter/material.dart';
import 'package:game_seka/game/gamepad_layer/ui/gamepad_controller.dart';
import 'package:game_seka/game/model/seka_player_state.dart';
import 'package:jigi_core/core/agent/agent.dart';
import 'package:jigi_core/core/instruction/parent_instruction.dart';

class GamepadAgent extends ParentAgent {
  GamepadAgent(
    ParentAgentConfig config,
  ) : super(config);

  GlobalKey<GamepadControllerState> _controller =
      GlobalKey<GamepadControllerState>();

  @override
  Widget build() {
    return GamepadController(
      key: _controller,
      currentPlayer: currentPlayer as SekaPlayerState,
    );
  }

  @override
  void instructionToAction(InstructionData instruction) {
    if (_controller.currentState! != null) {
      _controller.currentState!.update();
    }
  }

  @override
  Map<String, InstructionData Function(Map objectMap)> get instructions => {};
}
