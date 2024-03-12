import 'package:flutter/material.dart';
import 'package:game_seka/game/gamepad_layer/gamepad_agent.dart';
import 'package:game_seka/game/model/seka_player_state.dart';
import 'package:game_seka/game/player_layer/player_agent.dart';
import 'package:jigi_communication/layer/communication_layer/communication_agent.dart';
import 'package:jigi_core/core/agent/agent.dart';
import 'package:jigi_core/core/agent/player_state_holder.dart';
import 'package:jigi_core/core/instruction/parent_instruction.dart';
import 'package:jigi_core/core/model/user/player_data.dart';
import 'package:jigi_core/core/sounder/sounder.dart';
import 'package:jigi_core/layer/bank_layer/bank_agent.dart';
import 'package:jigi_core/layer/server_message_layer/server_message_agent.dart';
import 'package:jigi_invite/invite_layer/invite_agent.dart';

// typedef AgentCreatorFunc ParentAgent Function(ParentAgentConfig config);

class SekaAgent extends ParentAgent {
  final List<ParentAgent> _agents;

  /// This mechanizm is required to ignore some agents
  /// for instance we recieve list of agent names to ignore
  static Map<String, ParentAgent Function(ParentAgentConfig config)>
      _agentsCreator = {
    'BankAgent': (ParentAgentConfig config) => BankAgent(config),
    'InviteAgent': (ParentAgentConfig config) => InviteAgent(config),
    'PlayerAgent': (ParentAgentConfig config) => PlayerAgent(config),
    'ServerMessageAgent': (ParentAgentConfig config) =>
        ServerMessageAgent(config),
    'GamepadAgent': (ParentAgentConfig config) => GamepadAgent(config),
    'CommunicationAgent': (ParentAgentConfig config) =>
        CommunicationAgent(config),
  };

  SekaAgent({
    required ParentAgentConfig config,
  })  : _agents = ParentAgent.generateAgents(_agentsCreator, config),
        super(config);

  @override
  Widget build() {
    return Stack(
        children:
            _agents.map((ParentAgent element) => element.build()).toList());
  }

  @override
  void instructionToAction(InstructionData instruction) {
    try {
      for (ParentAgent element in _agents)
        element.instructionToAction(instruction);
    } catch (err) {
      print(':::: (seka_agent) execution error -> $err');
    }
  }

  /// This static method will be called inside a game agent in lib
  /// to create Specific game Agent for particular game
  static SekaAgent agentCreator(AgentCreatorHolder holder) {
    /// Any additional parameter will be added here and will be availible in each agent
    ParentAgentConfig parentConfigurations = ParentAgentConfig(
        playersHolder: PlayerStatesHolder(
          SekaPlayerState(
              playerData: PlayerData.fromCurrentUser(holder.currentUser),
              playerView: holder.configuration.currentPlayerConfig,
              isCurrentUser: true),
        ),
        playersViewConfig: holder.configuration,
        sounder: Sounder(),
        agentsToIgnore: holder.agentsToIgnore);
    return SekaAgent(
      config: parentConfigurations,
    );
  }

  @override
  Map<String, InstructionData Function(Map objectMap)> get instructions =>
      {for (ParentAgent element in _agents) ...element.instructions};
}
