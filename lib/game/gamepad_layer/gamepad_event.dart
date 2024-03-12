import 'package:flutter/material.dart';
import 'package:game_seka/game/model/bet_data.dart';
import 'package:game_seka/game/player_layer/instruction/player_instructions.dart';
import 'package:game_seka/game/player_layer/instruction/util_instruction.dart';
import 'package:jigi_core/core/game/bloc/game_bloc.dart';
import 'package:jigi_core/core/instruction/parent_instruction.dart';

/// When player make some betting this
/// event will be used to notify server
class BetMoveGameEvent extends LocalGameEvent {
  final String status = 'LOCAL_BET';
  final int playerId;
  final int betAmount;
  final String betStatus;
  BetMoveGameEvent({
    required this.playerId,
    required this.betAmount,
    required this.betStatus,
  });
  Map get generateServerMap {
    return {
      'status': this.status,
      'data': {'amount': this.betAmount, 'playerId': this.playerId}
    };
  }

  @override
  InstructionData get generateInstruction =>
      MoveBetInsD(playerId: playerId, betData: BetData(betAmount, betStatus), objectMap: {});

  @override
  List<Object> get props => [betAmount];

  @override
  int get getDuration => 0;

  @override
  String get getId => status;
}

/// When player do not want to proceed beting and
/// just reject given bet through this event
class FoldMoveGameEvent extends LocalGameEvent {
  final String status = 'LOCAL_BET_FOLD';
  final int playerId;

  FoldMoveGameEvent({required this.playerId});

  Map get generateServerMap {
    assert(this.playerId != null, 'LOCAL_BET_FOLD playerId should not be null');
    return {
      'status': this.status,
      'data': {'playerId': this.playerId}
    };
  }

  @override
  InstructionData get generateInstruction =>
      MoveBetInsD(playerId: playerId, betData: BetData(0, BetData.BET_NOT_OK), objectMap: {});

  @override
  List<Object> get props => [playerId];

  @override
  int get getDuration => 0;

  @override
  String get getId => status;
}

/// When player do not want to proceed beting and
/// just reject given bet through this event
class OpenGameEvent extends LocalGameEvent {
  final String status = 'UTIL_CARDS_OPEN';
  final int playerId;

  OpenGameEvent({required this.playerId});

  Map get generateServerMap {
    return {
      'status': this.status,
      'data': {
        "playerId": playerId,
      }
    };
  }

  @override
  InstructionData get generateInstruction => OpenInsD(objectMap: {});

  @override
  List<Object> get props => [playerId];

  @override
  int get getDuration => 0;

  @override
  String get getId => status;
}

/// The user first opt it is visible or invisible mode like [v temnyou]
/// in such case this event will be fetched locally in order to open
/// betting buttons
class CallGameEvent extends LocalGameEvent {
  final String status = 'LOADING_CALL';
  final int playerId;
  final int callValue;

  CallGameEvent({required this.playerId, required this.callValue})
      : super(isLocal: true);

  Map get generateServerMap => {};

  @override
  InstructionData get generateInstruction => LoadingCallInsD(
      objectMap: {"playerId": playerId, "callValue": callValue});

  @override
  List<Object> get props => [playerId, callValue];

  @override
  int get getDuration => 0;

  @override
  String get getId => status;
}
