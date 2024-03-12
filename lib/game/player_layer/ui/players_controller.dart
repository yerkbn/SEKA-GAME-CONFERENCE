import 'package:flutter/material.dart';
import 'package:game_seka/game/model/bet_data.dart';
import 'package:game_seka/game/model/seka_player_state.dart';
import 'package:game_seka/game/player_layer/ui/player_item.dart';
import 'package:jigi_card/core/model/card_data.dart';
import 'package:jigi_card/core/ui/card_item.dart';
import 'package:jigi_core/core/animation/animation_item.dart';
import 'package:jigi_core/core/config/game_config.dart';
import 'package:jigi_core/core/global_key/global_key.dart';
import 'package:jigi_core/core/instruction/parent_instruction.dart';
import 'package:jigi_core/core/model/user/player_data.dart';
import 'package:jigi_core/core/model/vector/vector.dart';
import 'package:jigi_core/core/sizer/sizer.dart';

class PlayersController extends StatefulWidget {
  final SekaPlayerState currentPlayer;

  PlayersController({
    Key? key,
    required this.currentPlayer,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PlayersControllerState();
  }
}

class PlayersControllerState extends State<PlayersController>
    with TickerProviderStateMixin {
  final GlobalKeyToIdManager<PlayerItemState, SekaPlayerState> _players =
      GlobalKeyToIdManager([]);

  @override
  void initState() {
    super.initState();
    // Adding current player at the begining
    _addingCurrentPlayer();
  }

  _addingCurrentPlayer() {
    GlobalKey<PlayerItemState> key = GlobalKey<PlayerItemState>();
    _players
        .add(GlobalKeyToId(widget.currentPlayer.id, key, widget.currentPlayer));
  }

  List<Widget> get _buildCards {
    List<Widget> cardsWidget = [];
    for (GlobalKeyToId<PlayerItemState, SekaPlayerState> eachPlayer
        in _players.list) {
      for (GlobalKeyToId<AnimationItemState, CardData> eachCard
          in eachPlayer.data.cards.list) {
        cardsWidget.add(CardItem(
          parameters: AnimationParameters(
              angle: 0,
              position: Vector(GAME_WIDTH / 2, 700),
              size: Vector(BIG_CARD_WIDTH, BIG_CARD_HEIGHT)),
          cardData: eachCard.data,
          key: eachCard.globalKey,
        ));
      }
    }
    return cardsWidget;
  }

  List<Widget> get _buildPlayers {
    List<Widget> players = [];
    for (GlobalKeyToId<PlayerItemState, SekaPlayerState> globalKeyToId
        in _players.list) {
      PlayerItem otherPlayerItem = PlayerItem(
        playerInitial: globalKeyToId.data,
        key: globalKeyToId.globalKey,
      );
      if (otherPlayerItem != null) players.add(otherPlayerItem);
    }
    return players;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Stack(
          children: _buildCards,
        ),
        Stack(children: _buildPlayers),
      ],
    );
  }

  openCurrentPlayerCards() {
    setState(() {
      _players.findById(widget.currentPlayer.id).data.openCards();
    });
  }

  /// in total win or in svara case when all cards
  /// will be opened the cards will be opened with combinations
  /// and set Point
  openCardCombinations(
      List<CardCombination> items, List<int> winners, int winAmount) async {
    for (CardCombination item in items) {
      SekaPlayerState player = _players.findById(item.playerId).data;
      setState(() {
        player.setPoint = item.point;
      });
      if (winners.contains(player.id)) {
        setState(() {
          player.setWin = WinData(winAmount);
        });
      }
      player.openCards();
      await Future.delayed(Duration(milliseconds: 100));
      player.hilightCombination(item.cardIds);
    }
  }

  reset(int playerId) {
    setState(() {
      _players.findById(playerId).data.setStatus = StatusOffInsD();
    });
  }

  void playerJoined(SekaPlayerState otherPlayer) {
    GlobalKey<PlayerItemState> key = GlobalKey<PlayerItemState>();
    setState(() {
      _players.add(GlobalKeyToId(otherPlayer.id, key, otherPlayer));
    });
  }

  void playerLeave(int playerId) => setState(() => _players.pop(playerId));

  void setCurrentPlayerInventory(PlayerInventoryData data) {
    setState(() {
      _players.findById(widget.currentPlayer.id).data.setInventory = data;
    });
  }

  void setPlayersInventory(List<PlayerInventoryData> items) {
    setState(() {
      for (PlayerInventoryData item in items) {
        _players.findById(item.playerId).data.setInventory = item;
      }
    });
  }

  void setTurn(int playerId, InstructionData instruction) =>
      setState(() => _players.findById(playerId).data.setStatus = instruction);

  void setBet(int playerId, BetData bet) =>
      setState(() => _players.findById(playerId).data.setBet = bet);

  /// When bet is finished, and CompleteBet come
  /// all bet will be set to default
  void betReset() {
    setState(() {
      for (GlobalKeyToId<PlayerItemState, SekaPlayerState> eachPlayer
          in _players.list) {
        eachPlayer.data.setBet = BetData.initDefault();
      }
    });
  }

  void cardDistribute(
      {required CardData card,
      required int playerId,
      required activationIndex,
      isAnimated = true}) {
    setState(() {
      _players
          .findById(playerId)
          .data
          .addCard(card, activationIndex, isAnimated: isAnimated);
    });
  }

  /// This function clear all user data and make
  /// set status to Off
  void allPlayersReset() {
    setState(() {
      for (GlobalKeyToId<PlayerItemState, SekaPlayerState> eachPlayer
          in _players.list) eachPlayer.data.resetPlayer();
    });
  }

  void clearAll() {
    setState(() {
      _players.clear();
      _addingCurrentPlayer();
    });
  }

  /// To activate user, it means that after this
  /// user will play. it will be used after card
  /// Distribution, based on this we will determin
  /// does user plaing or not
  void playerToOn(int playerId) {
    setState(() {
      _players.findById(playerId).data.setStatus = StatusOnInsD();
    });
  }

  // access to other Player by key
  GlobalKeyToId<PlayerItemState, SekaPlayerState> getById(int playerId) =>
      _players.findById(playerId);

  List<GlobalKeyToId<PlayerItemState, SekaPlayerState>> getPlayers() =>
      _players.list;

  /// When user is loading it means that we waiting to some call from
  /// user, when come move we set all loading users to ON status
  void allLoadingToOn() {
    setState(() {
      for (GlobalKeyToId<PlayerItemState, SekaPlayerState> eachPlayer
          in _players.list) {
        if (eachPlayer.data.isTurn) {
          eachPlayer.data.setStatus = StatusOnInsD();
        }
      }
    });
  }
}
