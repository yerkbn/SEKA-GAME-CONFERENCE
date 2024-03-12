import 'package:flutter/material.dart';
import 'package:game_seka/game/model/bet_data.dart';
import 'package:game_seka/game/model/seka_player_state.dart';
import 'package:game_seka/game/player_layer/instruction/player_instructions.dart';
import 'package:game_seka/game/player_layer/instruction/util_instruction.dart';
import 'package:game_seka/game/player_layer/ui/players_controller.dart';
import 'package:jigi_card/core/model/cards_to_players.dart';
import 'package:jigi_core/core/agent/agent.dart';
import 'package:jigi_core/core/instruction/parent_instruction.dart';
import 'package:jigi_core/core/model/user/player_data.dart';

/// This agent is responsile for players
/// for their movement and so on
class PlayerAgent extends ParentAgent {
  final GlobalKey<PlayersControllerState> _playersController =
      GlobalKey<PlayersControllerState>();

  PlayerAgent(
    ParentAgentConfig config,
  ) : super(config);

  @override
  Widget build() {
    return PlayersController(
      key: _playersController,
      currentPlayer: currentPlayer as SekaPlayerState,
    );
  }

  /// With player data we create [SekaPlayerState]
  /// which will be used in UI
  SekaPlayerState _createPlayerState(PlayerData data) {
    return SekaPlayerState(
        playerData: data,
        playerView: playersViewConfig.byTablePlace(data.tablePlace!),
        isCurrentUser: data.id == currentPlayer.id);
  }

  void _playerJoined(SekaPlayerState otherPlayer) {
    _playersController.currentState!.playerJoined(otherPlayer);
    config.playersHolder.add(otherPlayer);
  }

  void _playerLeave(int playerId) {
    _playersController.currentState!.playerLeave(playerId);
    config.playersHolder.delete(playerId);
  }

  void _resetPlayers() {
    _playersController.currentState!.allPlayersReset();
  }

  void _setBet(int playerId, BetData bet) {
    /// if player [fold] it means that he no longer play that is why
    /// we turn off player

    if (bet.betStatus == BetData.BET_NOT_OK) {
      _playersController.currentState!.setTurn(playerId, StatusOffInsD());
      _playersController.currentState!.setBet(playerId, BetData.initDefault());
    } else {
      playChip();
      _playersController.currentState!.setBet(playerId, bet);
    }
  }

  /// Distribution is implemented here because
  /// Card is distributed to current player
  /// and to Other player. It will be perfect if
  /// we found a way to distribute it among others
  void _distribute(DistributionInsD data, {isOpen: false, isAnimated: true}) {
    _resetPlayers();
    if (isAnimated) playCardDistribute();

    /// because distribution is start of ne game
    int activationIndexCounter = 1; // counter of when to release each card
    for (int eachCard = 0; eachCard < 3; eachCard++) {
      // This will run to define card turn
      for (CardsToPlayer playerIdToCards in data.playersIdToCards) {
        // card distribution stage
        try {
          _playersController.currentState!.playerToOn(playerIdToCards.playerId);
          _playersController.currentState!.cardDistribute(
            card: playerIdToCards.playerCards[eachCard],
            playerId: playerIdToCards.playerId,
            activationIndex: activationIndexCounter,
            isAnimated: isAnimated,
          );
          activationIndexCounter++;
        } catch (err) {
          print('USER UNEXPEDETLY LEAVE A GAME $err');
        }
      }
    }

    /// Open cards if it was requested
    if (isOpen)
      Future.delayed(Duration(milliseconds: 200),
          () => _playersController.currentState!.openCurrentPlayerCards());
  }

  void _commonReconnecting({
    required List<SekaPlayerState> players,
    required DistributionInsD distribution,
    required bool isCardOpen,
    required List<MoveBetInsD> bets,
  }) {
    // adding otherPlayers
    for (SekaPlayerState player in players) {
      _playerJoined(player);
    }

    // distribution
    _distribute(distribution, isAnimated: false, isOpen: isCardOpen);

    // setting bets
    for (MoveBetInsD betInstruction in bets)
      _setBet(betInstruction.playerId, betInstruction.betData);
  }

  void caseTwo(SecondCaseInsD instruction) {
    _commonReconnecting(
        distribution: instruction.distribution,
        players: instruction.players
            .map<SekaPlayerState>((PlayerData data) => _createPlayerState(data))
            .toList(),
        isCardOpen: instruction.isCardOpen,
        bets: instruction.bets);

    // if currently some other user loading set it
    PlayerIdDriver? playerDriver =
        PlayerIdDriver.transformTo(instruction.currentBet);
    if (playerDriver != null) {
      _playersController.currentState!
          .setTurn(playerDriver.playerId, instruction.currentBet);
    }
  }

  void caseThree(ThirdCaseInsD instruction) async {
    _commonReconnecting(
        distribution: instruction.distribution,
        players: instruction.players
            .map<SekaPlayerState>((PlayerData data) => _createPlayerState(data))
            .toList(),
        isCardOpen: true,
        bets: instruction.bets);

    for (int id in instruction.playerIdsToJoinSvara)
      _playersController.currentState!.setTurn(id, SvaraInsD.fake());

    /// this dalay required because cards not fully rendered below is
    /// required time to render cards
    await Future.delayed(Duration(milliseconds: 100));
    _playersController.currentState!.openCardCombinations(
        instruction.cardCombinations, instruction.svaraPlayerIds, 0);
  }

  @override
  void instructionToAction(InstructionData instruction) {
    if (instruction is FirstCaseInsD) {
      for (SekaPlayerState player in instruction.players
          .map<SekaPlayerState>((PlayerData data) => _createPlayerState(data))
          .toList()) {
        _playerJoined(player);
      }
    }

    if (instruction is SecondCaseInsD) caseTwo(instruction);

    if (instruction is ThirdCaseInsD) caseThree(instruction);

    if (instruction is FinishInsD) {
      if (instruction.deepClear) {
        _playersController.currentState!.clearAll();
      } else {
        _resetPlayers();
      }
    }
    if (instruction is PlayerJoinedInsD) {
      _playerJoined(_createPlayerState(instruction.otherPlayer));
    }
    if (instruction is PlayerLeaveInsD) {
      _playerLeave(instruction.playerId);
    }
    if (instruction is OpenInsD) {
      playCard();
      _playersController.currentState!.openCurrentPlayerCards();
    }
    if (instruction is DistributionInsD) {
      _distribute(instruction, isOpen: false, isAnimated: true);
    }
    if (instruction is InitialBetInsD) {
      playChip();
      _playersController.currentState!.allLoadingToOn();
    }

    if (instruction is CompletedBetInsD) {
      playChip();
      _playersController.currentState!.allLoadingToOn();
      _playersController.currentState!.betReset();
    }

    if (instruction is TotalWinInsD) {
      playCard();
      playChip();
      _playersController.currentState!.allLoadingToOn();
      _playersController.currentState!.openCardCombinations(
          instruction.cardCombinations,
          [instruction.playerId],
          instruction.wonAmount);
    }

    if (instruction is SvaraInsD) {
      _playersController.currentState!.allLoadingToOn();
      _playersController.currentState!.openCardCombinations(
          instruction.cardCombinations!, instruction.svaraPlayerIds!, 0);
      for (int id in instruction.joinSvaraIds!)
        _playersController.currentState!.setTurn(id, instruction);
    }
    if (instruction is MoveBetInsD) {
      _playersController.currentState!
          .setTurn(instruction.playerId, instruction);
      _setBet(instruction.playerId, instruction.betData);
    }

    /// If it is someone turn to move we take [user_id] and
    /// set it to display it
    PlayerIdDriver? playerDriver = PlayerIdDriver.transformTo(instruction);
    if (playerDriver != null) {
      _playersController.currentState!
          .setTurn(playerDriver.playerId, instruction);
    }

    /// Setting all players data if it comme
    // PlayersInventoryDriver playersInventoryDriver =
    PlayersInventoryDriver? playersInventoryDriver =
        PlayersInventoryDriver.transformTo(instruction);
    if (playersInventoryDriver != null) {
      _playersController.currentState!
          .setPlayersInventory(playersInventoryDriver.playersInventoryData);
    }

    /// Setting current player own data
    CurrentPlayerInventoryDriver? currentPlayerInventoryDriver =
        CurrentPlayerInventoryDriver.transformTo(instruction);
    if (currentPlayerInventoryDriver != null) {
      _playersController.currentState!.setCurrentPlayerInventory(
          currentPlayerInventoryDriver.currentPlayerInventorData);
    }
  }

  @override
  Map<String, InstructionData Function(Map objectMap)> get instructions => {
        PlayerJoinedInsD.STATUS: PlayerJoinedInsD.parseMap,
        PlayerLeaveInsD.STATUS: PlayerLeaveInsD.parseMap,
        DistributionInsD.STATUS: DistributionInsD.parseMap,
        // UTILL STAFF
        InitialBetInsD.STATUS: InitialBetInsD.parseMap,
        OpenInsD.STATUS: OpenInsD.parseMap,
        CompletedBetInsD.STATUS: CompletedBetInsD.parseMap,
        TotalWinInsD.STATUS: TotalWinInsD.parseMap,
        SvaraInsD.STATUS: SvaraInsD.parseMap,
        FinishInsD.STATUS: FinishInsD.parseMap,
        // LOADING
        ...LoadingCallInsD.generateMapper(),
        LoadingCallBlindInsD.STATUS: LoadingCallBlindInsD.parseMap,
        LoadingRaiseInsD.STATUS: LoadingRaiseInsD.parseMap,
        LoadingRaiseCallInsD.STATUS: LoadingRaiseCallInsD.parseMap,
        LoadingAllInInsD.STATUS: LoadingAllInInsD.parseMap,
        // MOVE
        MoveBetInsD.STATUS: MoveBetInsD.parseMap,
        // RECONNECTING
        FirstCaseInsD.STATUS: FirstCaseInsD.parseMap,
        SecondCaseInsD.STATUS: SecondCaseInsD.parseMap,
        ThirdCaseInsD.STATUS: ThirdCaseInsD.parseMap,
      };
}
