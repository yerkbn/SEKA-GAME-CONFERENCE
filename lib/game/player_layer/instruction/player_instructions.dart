import 'package:flutter/material.dart';
import 'package:game_seka/game/model/bet_data.dart';
import 'package:jigi_core/core/instruction/parent_instruction.dart';
import 'package:jigi_core/core/util/normalizer.dart';

/// [MIXINS]
/// For sharing simple characteristic

class CallDriver {
  int? callValue;

  void parseCallDriver(Map objectMap) {
    assert((objectMap['callValue'] != null && objectMap['callValue'] is int),
        ':::: (parent_instruction) -> CallField)');
    callValue = objectMap['callValue'];
  }
}

class RaiseDriver {
  int? start;
  int? end;

  void parseRaiseDriver(Map objectMap) {
    assert(
        (objectMap['raiseRange'] != null &&
            objectMap['raiseRange'].length == 2),
        ':::: (parent_instruction) -> RaiseField)');
    start = objectMap['raiseRange'][0];
    end = objectMap['raiseRange'][1];
  }
}

/// LOADING
/// When in bettinng stage we have 3 possible outcome
/// [call_value] when display only call_value and fold
/// [raise_value]  when display only raise_value and fold
/// [all in]  is same as [call_value] value but here type is important
/// [call_value, raise_value] when display only raise_value, call_value and fold
class LoadingCallInsD extends MultipleStatusInstructionData
    with PlayerIdDriver, CallDriver, Normalizer {
  static const List<String> STATUSES = [
    'LOADING_CALL',
    'LOADING_AZI_BEGIN',
    'LOADING_AZI_CONTINUE',
    'LOADING_BET_LAST'
  ];

  LoadingCallInsD({
    required Map objectMap,
  }) : super(STATUSES, objectMap) {
    this.parsePlayerIdDriver(objectMap);
    this.parseCallDriver(objectMap);
  }

  static LoadingCallInsD parseMap(Map objectMap) {
    return LoadingCallInsD(
      objectMap: objectMap,
    );
  }

  String get getCallvalue => normalizeNumberSlim(callValue!);

  static Map<String, InstructionData Function(Map objectMap)>
      generateMapper() => MultipleStatusInstructionData.generateMapper(
          LoadingCallInsD.parseMap, STATUSES);
}






class LoadingCallBlindInsD extends InstructionData
    with PlayerIdDriver, CallDriver, Normalizer {
  static const String STATUS = 'LOADING_TURN_BLIND_BET';

  LoadingCallBlindInsD({
    required Map objectMap,
  }) : super(STATUS, objectMap) {
    this.parsePlayerIdDriver(objectMap);
    this.parseCallDriver(objectMap);
  }

  static LoadingCallBlindInsD parseMap(Map objectMap) {
    return LoadingCallBlindInsD(
      objectMap: objectMap,
    );
  }

  String get getCallvalue => normalizeNumberSlim(callValue!);
}

class LoadingAllInInsD extends InstructionData
    with PlayerIdDriver, CallDriver, Normalizer {
  static const String STATUS = 'LOADING_ALL_IN';
  // LoadingAllInInsD(String status, Map objectMap) : super(status, objectMap);
  LoadingAllInInsD({required Map objectMap}) : super(STATUS, objectMap) {
    this.parsePlayerIdDriver(objectMap);
    this.parseCallDriver(objectMap);
  }
  static LoadingAllInInsD parseMap(Map objectMap) {
    return LoadingAllInInsD(
      objectMap: objectMap,
    );
  }

  String get getCallvalue => normalizeNumberSlim(callValue!);
}

class LoadingRaiseInsD extends InstructionData
    with PlayerIdDriver, RaiseDriver {
  static const String STATUS = 'LOADING_RAISE';

  LoadingRaiseInsD({
    required Map objectMap,
  }) : super(STATUS, objectMap) {
    this.parsePlayerIdDriver(objectMap);
    this.parseRaiseDriver(objectMap);
  }

  static LoadingRaiseInsD parseMap(Map objectMap) {
    return LoadingRaiseInsD(
      objectMap: objectMap,
    );
  }
}

class LoadingRaiseCallInsD extends InstructionData
    with PlayerIdDriver, CallDriver, RaiseDriver, Normalizer {
  static const String STATUS = 'LOADING_TURN_BET';

  LoadingRaiseCallInsD({
    required Map objectMap,
  }) : super(STATUS, objectMap) {
    this.parsePlayerIdDriver(objectMap);
    this.parseCallDriver(objectMap);
    this.parseRaiseDriver(objectMap);
  }

  static LoadingRaiseCallInsD parseMap(Map objectMap) {
    return LoadingRaiseCallInsD(
      objectMap: objectMap,
    );
  }

  String get getCallValue => normalizeNumberSlim(callValue!);
}

/// [MOVE]
/// The Actions that happen instantly from
/// any one in the room it is fast action
/// When Someone make some movement

class MoveBetInsD extends InstructionData {
  static const String STATUS = 'MOVE_TURN_BET';
  final BetData betData;
  final int playerId;

  MoveBetInsD(
      {required this.playerId, required this.betData, required Map objectMap})
      : super(STATUS, objectMap);

  static MoveBetInsD parseMap(Map objectMap) {
    return MoveBetInsD(
        playerId: objectMap['playerId'],
        betData: BetData.parseMap(objectMap: objectMap),
        objectMap: objectMap);
  }

  static List<MoveBetInsD> parseList(List bets) {
    List<MoveBetInsD> result = [];
    for (var bet in bets) {
      result.add(MoveBetInsD.parseMap(bet));
    }
    return result;
  }
}
