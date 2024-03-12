import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:game_seka/game/model/bet_data.dart';
import 'package:game_seka/game/player_layer/instruction/player_instructions.dart';
import 'package:game_seka/game/player_layer/instruction/util_instruction.dart';
import 'package:jigi_card/core/model/card_data.dart';
import 'package:jigi_core/core/animation/animation_item.dart';
import 'package:jigi_core/core/config/game_config.dart';
import 'package:jigi_core/core/global_key/global_key.dart';
import 'package:jigi_core/core/instruction/parent_instruction.dart';
import 'package:jigi_core/core/model/user/player_data.dart';
import 'package:jigi_core/core/model/user/player_state.dart';
import 'package:jigi_core/core/model/user/view_config.dart';
import 'package:jigi_core/core/model/vector/vector.dart';
import 'package:jigi_core/core/util/normalizer.dart';

/// This will hold does current user is Win or in Svara
/// uf [chips] is null it means in svara
class WinData extends Equatable {
  final int wonAmount;

  bool get isSvara => wonAmount == null;

  WinData(this.wonAmount);

  @override
  List<Object> get props => [wonAmount];
}

class SekaPlayerState extends PlayerState {
  BetData _bet = BetData.init();
  // when winner is determined we set point for each based on his cards`
  int? _point;
  WinData? _win;
  final GlobalKeyToIdManager<AnimationItemState, CardData> _cards =
      GlobalKeyToIdManager<AnimationItemState, CardData>([]);

  //INITIALIZING
  SekaPlayerState(
      {required PlayerData playerData,
      required PlayerView playerView,
      required isCurrentUser})
      : super(
            playerData: playerData,
            playerView: playerView,
            isCurrentUser: isCurrentUser);

  // !Setters
  set setBet(BetData newBet) => _bet = newBet;
  set setPoint(int val) => _point = val;
  set setWin(WinData val) => _win = val;

  // !Getters
  GlobalKeyToIdManager<AnimationItemState, CardData> get cards => _cards;
  BetData get bet => _bet;
  int? get getPoint => _point;
  bool get isWin => _win != null;
  bool get isSvara => _win == null ? false : _win!.isSvara;
  String? get wonAmount {
    if (_win == null || _win!.wonAmount == null) return null;
    return normalizeNumber(_win!.wonAmount);
  }

  bool get isPlaying {
    return !isDisabled;
  }

  /// When player not playing right now
  /// it is in wating stage
  bool get isDisabled {
    if (status is StatusOffInsD) return true;
    return false;
  }

  /// It us used when this user in loading
  bool get isTurn {
    if (status is LoadingRaiseCallInsD ||
        status is LoadingRaiseInsD ||
        status is LoadingCallInsD ||
        status is LoadingCallBlindInsD ||
        status is SvaraInsD ||
        status is LoadingAllInInsD) return true;
    return false;
  }

  // !Manipulations

  /// When game finnish we clear user
  /// with this method
  /// if user just [Fold] we set [StatusOffInsD]
  void resetPlayer() {
    this.setStatus = StatusOffInsD();
    this._cards.clear();
    this._bet = BetData.init();
    this._point = null;
    this._win = null;
  }

  /// In distribution each card will be assigned to
  /// each user and this function will gather them
  /// to user hand
  void addCard(CardData cardData, int activationIndex,
      {isAnimated = true, isOpen = false}) {
    if (!isAnimated) activationIndex = 1;
    GlobalKeyToId<AnimationItemState, CardData> newKey =
        GlobalKeyToId<AnimationItemState, CardData>(
            cardData.id, GlobalKey<AnimationItemState>(), cardData);

    _cards.add(newKey);

    Future.delayed(
        Duration(
            milliseconds: CARD_DISTRIBUTION_TIME * activationIndex +
                250 // this time for initial rendering a element to avoid problem
            ), () {
      Vector? newPosition;
      double angle = 0;

      // depends on left or right side
      Vector center = playerView.position;
      if (playerView.isLeft) {
        Vector offset = Vector(10, 50);
        switch (_cards.getIndex(newKey)) {
          case 0:
            newPosition = Vector(center.x, center.y + 40) + offset;
            angle = -1; //60
            break;
          case 1:
            newPosition = Vector(center.x + 5, center.y + 20) + offset;
            angle = -.69; //40
            break;
          case 2:
            newPosition = Vector(center.x + 10, center.y) + offset;
            angle = -.35; //20
            break;
          default:
        }
      } else {
        Vector offset = Vector(200, 50);
        switch (_cards.getIndex(newKey)) {
          case 0:
            newPosition = Vector(center.x + 10, center.y + 40) + offset;
            angle = 1; //60
            break;
          case 1:
            newPosition = Vector(center.x + 5, center.y + 20) + offset;
            angle = .69; //40
            break;
          case 2:
            newPosition = Vector(center.x, center.y) + offset;
            angle = .35; //20
            break;
          default:
        }
      }
      // newKey.globalKey.currentState!
      //     .openChild1(); // to ensure that all distributed cards is closed
      if (isAnimated) {
        newKey.globalKey.currentState!.toPosition(newPosition!);
        newKey.globalKey.currentState!.toAngle(angle);
        newKey.globalKey.currentState!
            .toSize(Vector(HAND_CARD_WIDTH_OTHER, HAND_CARD_HEIGHT_OTHER));
      } else {
        newKey.globalKey.currentState!.toPositionInstant(newPosition!);
        newKey.globalKey.currentState!.toAngleInstant(angle);
        newKey.globalKey.currentState!.toSizeInstant(
            Vector(HAND_CARD_WIDTH_OTHER, HAND_CARD_HEIGHT_OTHER));
      }
    });
  }

  /// In some games like [Seka]
  /// user will open all cards at once
  /// In such cases this function will be used
  void openCards() {
    int queueOrder = 0;
    Vector center = playerView.cardPosition;
    for (GlobalKeyToId<AnimationItemState, CardData> eachCard in _cards.list) {
      Vector? newPosition;
      double angle = 0;
      switch (queueOrder) {
        case 0:
          newPosition = Vector(center.x - 60, center.y);
          angle = -.1; //60
          break;
        case 1:
          newPosition = Vector(center.x, center.y - 3);
          break;
        case 2:
          newPosition = Vector(center.x + 60, center.y);
          angle = .1; //20
          break;
        default:
      }
      eachCard.globalKey.currentState!.openChild2();
      eachCard.globalKey.currentState!.toPosition(newPosition!);
      eachCard.globalKey.currentState!.toAngle(angle);
      eachCard.globalKey.currentState!
          .toSize(Vector(BIG_CARD_WIDTH, BIG_CARD_HEIGHT));
      queueOrder++;
    }
  }

  /// In some games like [Seka]
  /// user will open all cards at once
  /// In such cases this function will be used
  void hilightCombination(List<int> ids) {
    double increaseFactor = 1.1;
    for (int i in ids) {
      _cards.findById(i).globalKey.currentState!.toHilight(Vector(
          BIG_CARD_WIDTH * increaseFactor, BIG_CARD_HEIGHT * increaseFactor));
    }
  }
}

/// When game finish Each player cards will be opened
/// and here we can vew haw many cost it gather
/// and which card combinations counted to get point
class CardCombination extends Equatable with Normalizer {
  final int playerId;
  final List<int> cardIds; // active cards which used to detecte winner
  final int point;

  CardCombination(
      {required this.playerId, required this.cardIds, required this.point});

  factory CardCombination.parseMap(Map objectMap) {
    return CardCombination(
      playerId: objectMap['playerId'],
      cardIds: new List<int>.from(objectMap['cardIds']),
      point: objectMap['point'],
    );
  }

  static List<CardCombination>? parseList(List? items) {
    if (items != null) {
      List<CardCombination> result = [];
      for (var item in items) {
        result.add(CardCombination.parseMap(item));
      }
      return result;
    }
  }

  @override
  List<Object> get props => [playerId, cardIds, point];
}
