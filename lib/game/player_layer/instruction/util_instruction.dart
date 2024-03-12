import 'package:game_seka/game/model/seka_player_state.dart';
import 'package:game_seka/game/player_layer/instruction/player_instructions.dart';
import 'package:jigi_card/core/model/card_data.dart';
import 'package:jigi_communication/layer/throw_layer/driver.dart';
import 'package:jigi_core/core/instruction/parent_instruction.dart';
import 'package:jigi_core/core/model/user/player_data.dart';
import 'package:jigi_core/core/util/normalizer.dart';
import 'package:jigi_card/core/model/cards_to_players.dart';
import 'package:jigi_core/layer/bank_layer/driver.dart';
import 'package:jigi_core/layer/server_message_layer/driver.dart';
import 'package:jigi_invite/invite_layer/driver.dart';
import 'package:jigi_core/core/util/extension/map_error_extension.dart';

class DistributionInsD extends InstructionData {
  static const String STATUS = 'DISTRIBUTION';

  final CardData? trumpCard;
  final List<CardsToPlayer> playersIdToCards;

  DistributionInsD(
      {required this.trumpCard,
      required this.playersIdToCards,
      required Map objectMap})
      : super(STATUS, objectMap, duration: 1000);

  static DistributionInsD parseMap(Map objectMap) {
    DistributionInsD instance = DistributionInsD(
        trumpCard: objectMap['trumpCard'] == null
            ? null
            : CardData.parseMap(objectMap['trumpCard']),
        playersIdToCards: CardsToPlayer.parseList(objectMap['cards']),
        objectMap: objectMap);
    return instance;
  }
}

/// When new game start initial must money
/// gathering get money from players
class InitialBetInsD extends InstructionData
    with Normalizer, PlayersInventoryDriver, BankCollectDriver {
  static const String STATUS = 'UTIL_START_BET';
  InitialBetInsD({required Map objectMap})
      : super(STATUS, objectMap, duration: 100) {
    this.parsePlayersInventoryDriver(objectMap);
    this.parseBankCollectDriver(objectMap);
  }

  static InitialBetInsD parseMap(Map objectMap) {
    return InitialBetInsD(objectMap: objectMap);
  }

  String get totalChipsNormalized => normalizeNumber(bankValue);
}

class OpenInsD extends InstructionData {
  static const String STATUS = 'UTIL_CARDS_OPEN';

  OpenInsD({required Map objectMap}) : super(STATUS, objectMap);

  static OpenInsD parseMap(Map objectMap) {
    return OpenInsD(objectMap: objectMap);
  }
}

/// The staff used in banking agent
class CompletedBetInsD extends InstructionData
    with Normalizer, PlayersInventoryDriver, BankCollectDriver {
  static const String STATUS = 'UTIL_TOTAL_BET';
  CompletedBetInsD({required Map objectMap})
      : super(STATUS, objectMap, duration: 600) {
    this.parsePlayersInventoryDriver(objectMap);
    this.parseBankCollectDriver(objectMap);
  }

  static CompletedBetInsD parseMap(Map objectMap) {
    return CompletedBetInsD(objectMap: objectMap);
  }

  String get totalChipsNormalized => normalizeNumber(bankValue);
}

/// In the end of the game round
/// when winner is established
class TotalWinInsD extends InstructionData
    with PlayersInventoryDriver, BankChipsDriver, BankWinnerDriver, Normalizer {
  static const String STATUS = 'UTIL_TOTAL_WIN';
  final List<CardCombination> cardCombinations;
  final int wonAmount;

  TotalWinInsD(
      {required this.cardCombinations,
      required this.wonAmount,
      required Map objectMap})
      : super(STATUS, objectMap, duration: 2200) {
    this.parsePlayersInventoryDriver(objectMap);
    this.parseBankWinnerDriver(objectMap);
    this.initBankChipsDriver(0); // TO SET 0 TO THE CENTRAL BANK
  }

  // Expected map fomat
  static TotalWinInsD parseMap(Map objectMap) {
    return TotalWinInsD(
      wonAmount: objectMap['wonAmount'],
      cardCombinations:
          CardCombination.parseList(objectMap['usedCombinations'])!,
      objectMap: objectMap,
    );
  }

  String get getWonAmount => normalizeNumber(this.wonAmount);
}

/// In the end of the game round
/// when winner is established
class SvaraInsD extends InstructionData
    with PlayersInventoryDriver, CallDriver, Normalizer, ServerMessageDriver {
  static const String STATUS = 'UTIL_SVARA';
  final List<CardCombination>? cardCombinations;
  final List<int>? joinSvaraIds;
  final List<int>? svaraPlayerIds;

  SvaraInsD(
      {required this.joinSvaraIds,
      required this.svaraPlayerIds,
      required this.cardCombinations,
      Map? objectMap})
      : super(STATUS, objectMap, duration: 1500) {
    if (objectMap != null) {
      this.parsePlayersInventoryDriver(objectMap);
      this.parseCallDriver(objectMap);
      this.initServerMessageDriver(
          message: 'SVARA', status: ServerMessageDriver.SUCCESS);
    }
  }
  factory SvaraInsD.fake() {
    return SvaraInsD(
        joinSvaraIds: null, svaraPlayerIds: null, cardCombinations: null);
  }

  // Expected map fomat
  static SvaraInsD parseMap(Map objectMap) {
    return SvaraInsD(
      joinSvaraIds: objectMap['playerIds'] == null
          ? []
          : List<int>.from(objectMap['playerIds']),
      svaraPlayerIds: List<int>.from(objectMap['svaraPlayerIds']),
      cardCombinations:
          CardCombination.parseList(objectMap['usedCombinations'])!,
      objectMap: objectMap,
    );
  }

  String get getCallvalue => normalizeNumber(callValue!);
}

/// RECONNECTING
/// [1] when game not really start when only players joining
/// [2] the betting stage when users just start betting
/// [3] game stage when winner is determend or in svara case
class FirstCaseInsD extends InstructionData
    with
        PlayersInventoryDriver,
        CurrentPlayerInventoryDriver,
        ThrowInventoryAmountDriver,
        BookedPlacesDriver {
  static const String STATUS = 'CONNECTED_TO_SERVER_CASE_ONE';
  final List<PlayerData> players;

  FirstCaseInsD({required this.players, required Map objectMap})
      : super(STATUS, objectMap) {
    this.parsePlayersInventoryDriver(objectMap);
    this.parseCurrentPlayerInventoryDriver(objectMap);
    this.parseThrowInventoryAmountDriver(objectMap);
  }

  static FirstCaseInsD parseMap(Map objectMap) {
    FirstCaseInsD instance = FirstCaseInsD(
        players: parsePlayers(objectMap['players'] == null
            ? objectMap['otherPlayers'] // This will used in second/third cases
            : objectMap['players']),
        objectMap: objectMap);
    return instance;
  }

  static List<PlayerData> parsePlayers(List players) {
    List<PlayerData> tempOtherPlayers = [];
    for (var player in players) {
      PlayerData instance = PlayerData.parseMap(player);
      tempOtherPlayers.add(instance);
    }
    return tempOtherPlayers;
  }
}

class SecondCaseInsD extends InstructionData
    with
        Normalizer,
        PlayersInventoryDriver,
        CurrentPlayerInventoryDriver,
        BankChipsDriver,
        ThrowInventoryAmountDriver,
        BookedPlacesDriver {
  static const String STATUS = 'CONNECTED_TO_SERVER_CASE_TWO';
  final List<PlayerData> players;
  final DistributionInsD distribution;
  final bool isCardOpen;
  final List<MoveBetInsD> bets;
  final InstructionData currentBet;

  SecondCaseInsD(
      {required this.distribution,
      required this.isCardOpen,
      required this.players,
      required this.bets,
      required this.currentBet,
      required Map objectMap})
      : super(STATUS, objectMap, duration: 1000) {
    this.parsePlayersInventoryDriver(objectMap);
    this.parseCurrentPlayerInventoryDriver(objectMap);
    this.parseBankChipsDriver(objectMap);
    this.parseThrowInventoryAmountDriver(objectMap);
    this.parseBookedPlacesDriver(objectMap);
  }

  static SecondCaseInsD parseMap(Map objectMap) {
    SecondCaseInsD instance = SecondCaseInsD(
        players: FirstCaseInsD.parsePlayers(objectMap['otherPlayers']),
        distribution: DistributionInsD.parseMap(objectMap['cardsData']),
        isCardOpen: objectMap['cardsData']['isOpen'],
        bets: MoveBetInsD.parseList(objectMap['betStates']),

        /// InstructionMapper must be initialized becuase
        /// only then it has instructions to parse
        currentBet: OpenInsD(objectMap: {}),
        // currentBet: InstructionMapper(
        //         additionalInstructions: SekaAgent(config: null).instructions)
        //     .mapping(objectMap['currentBet']),

        objectMap: objectMap);
    return instance;
  }

  String get getBankValue => normalizeNumber(bankValue);
}

class ThirdCaseInsD extends InstructionData
    with
        Normalizer,
        PlayersInventoryDriver,
        CurrentPlayerInventoryDriver,
        ServerMessageDriver,
        BankChipsDriver,
        ThrowInventoryAmountDriver,
        BookedPlacesDriver {
  static const String STATUS = 'CONNECTED_TO_SERVER_CASE_THREE';
  final List<PlayerData> players;
  final DistributionInsD distribution;
  final List<MoveBetInsD> bets;
  final int svaraValue;
  final List<CardCombination> cardCombinations;
  final List<int>
      playerIdsToJoinSvara; // user in loading stage which will join svara
  final List<int> svaraPlayerIds;

  ThirdCaseInsD(
      {required this.distribution,
      required this.svaraValue,
      required this.players,
      required this.bets,
      required this.cardCombinations,
      required this.playerIdsToJoinSvara,
      required this.svaraPlayerIds,
      required Map objectMap})
      : super(STATUS, objectMap, duration: 1000) {
    this.parsePlayersInventoryDriver(objectMap);
    this.parseCurrentPlayerInventoryDriver(objectMap);
    this.parseBankChipsDriver(objectMap);
    this.parseThrowInventoryAmountDriver(objectMap);
    this.parseBookedPlacesDriver(objectMap);
    this.initServerMessageDriver(
        message: 'SVARA', status: ServerMessageDriver.SUCCESS);
  }

  static ThirdCaseInsD parseMap(Map objectMap) {
    ThirdCaseInsD instance = ThirdCaseInsD(
        players: FirstCaseInsD.parsePlayers(objectMap['otherPlayers']),
        distribution: DistributionInsD.parseMap(objectMap['cardsData']),
        bets: MoveBetInsD.parseList(objectMap['betStates']),
        svaraValue: objectMap['svaraValue'],
        cardCombinations:
            CardCombination.parseList(objectMap['usedCombinations'])!,
        playerIdsToJoinSvara: parseList(objectMap['playerIdsToJoinSvara']),
        svaraPlayerIds: List<int>.from(objectMap['svaraPlayerIds']),
        objectMap: objectMap);
    return instance;
  }

  static List<int> parseList(List items) {
    if (items != null) {
      return List<int>.from(items);
    }
    return [];
  }

  String get getBankValue => normalizeNumber(bankValue);
}

/// MESSAGEINNG

/// Throw instruction it might come from front
/// or backend
class ServerMessageInsD extends InstructionData with ServerMessageDriver {
  static const String STATUS = 'UTIL_SERVER_MESSAGE';
  ServerMessageInsD({required Map objectMap})
      : super(STATUS, objectMap, duration: 1500) {
    this.parseServerMessageDriver(objectMap);
  }

  static ServerMessageInsD parseMap(Map objectMap) {
    return ServerMessageInsD(objectMap: objectMap);
  }
}
