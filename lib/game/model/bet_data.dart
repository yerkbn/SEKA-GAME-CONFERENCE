import 'package:flutter/material.dart';
import 'package:jigi_core/core/util/normalizer.dart';

class BetData with Normalizer {
  // BET STAUSES
  static const String BET_DEFAULT = 'DEFAULT';
  static const String BET_OK = 'CHECK';
  static const String BET_NOT_OK = 'FOLD';
  static const String ALL_IN = 'ALLIN';
  static const String BET_OK_RAISE = 'RAISE';

  final int _betAmount;
  final String _betStatus;

  factory BetData.initDefault() {
    return BetData(0, BET_DEFAULT);
  }

  BetData(this._betAmount, this._betStatus);
  factory BetData.init() {
    return BetData(0, BetData.BET_DEFAULT);
  }

  factory BetData.parseMap({required objectMap}) {
    int amount =
        objectMap['amount'] == null // becuse in reconect case 2 it is different
            ? objectMap['betAmount']
            : objectMap['amount'];
    return BetData(amount, objectMap['betStatus']);
  }

  // getters
  int get betAmount => _betAmount;
  String get betStatus => _betStatus;
  String get betAmountNormalized {
    return normalizeNumber(_betAmount);
  }
}
