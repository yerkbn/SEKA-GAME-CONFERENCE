import 'package:flutter/material.dart';
import 'package:game_seka/game/model/bet_data.dart';
import 'package:game_seka/game/model/seka_player_state.dart';
import 'package:jigi_core/core/config/game_config.dart';
import 'package:jigi_core/core/model/user/view_config.dart';
import 'package:jigi_core/core/sizer/sizer.dart';
import 'package:jigi_core/ui/currency/currency_item.dart';
import 'package:jigi_core/ui/player/player_bet.dart';
import 'package:jigi_core/ui/player/player_avatar.dart';

class PlayerItem extends StatefulWidget {
  final SekaPlayerState playerInitial;
  PlayerItem({Key? key, required this.playerInitial}) : super(key: key);
  PlayerItemState createState() => PlayerItemState();
}

class PlayerItemState extends State<PlayerItem> with TickerProviderStateMixin {
  SekaPlayerState get _player => widget.playerInitial;
  PlayerView get _config => widget.playerInitial.playerView;
  // final GlobalKey<ChipItemState> _chip = GlobalKey<ChipItemState>();

  bool get isBet => !_player.isDisabled && (_player.bet.betAmount > 0);

  // CONTROLLERS

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PlayerAvatar(
          wonAmount: _player.wonAmount,
          betChild: _buildBet(_player.bet.betStatus),
          x: _config.position.x,
          y: _config.position.y,
          highlight: _player.isWin,
          isActive: _player.isPlaying,
          isLoadding: _player.isTurn,
          player: _player,
        ),
        _player.bet.betStatus != BetData.BET_DEFAULT
            ? _buildStaticChip(_player.bet.betAmountNormalized)
            : Container(),
        _buildPoint,
      ],
    );
  }

  Widget _buildStaticChip(String val) {
    return Positioned(
      left: Sizer().getWidth(_config.chipsPosition.x),
      top: Sizer().getHeight(_config.chipsPosition.y),
      child: Container(
        width: Sizer().getWidth(CHIP_LENGTH),
        child: Center(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              CurrencyItem.chip(l: 30),
              Text(
                val,
                style: Theme.of(context)
                    .textTheme
                    .headline4!
                    .copyWith(fontWeight: FontWeight.bold),
              )
            ])),
      ),
    );
  }

  Widget get _buildPoint => _player.getPoint != null
      ? Positioned(
          left: Sizer().getWidth(_config.position.x + AVATAR_DIAMATER - 80),
          top: Sizer().getHeight(_config.position.y + AVATAR_DIAMATER - 80),
          child: Container(
            width: Sizer().getWidth(80),
            height: Sizer().getWidth(80),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(Sizer().getWidth(100)),
            ),
            child: Center(
              child: Text(
                _player.getPoint.toString(),
                style:
                    TextStyle(color: Colors.white, fontSize: Sizer().getSp(40)),
              ),
            ),
          ),
        )
      : Container();

  Widget _buildBet(String betStatus) {
    String text = '';
    Color color = Colors.transparent;
    switch (betStatus) {
      case BetData.BET_NOT_OK:
        {
          text = 'СБРОСИЛ';
          color = Theme.of(context).primaryColor;
          break;
        }
      case BetData.BET_OK:
        {
          text = 'УРОВНЯЛ';
          color = Theme.of(context).focusColor;
          break;
        }
      case BetData.BET_OK_RAISE:
        {
          text = 'ПОДНЯЛ';
          color = Colors.redAccent;
          break;
        }
      case BetData.ALL_IN:
        // case BetData.BET_DEFAULT:
        {
          text = 'ВО-БАНК';
          color = Colors.red;
          break;
        }
      case BetData.BET_DEFAULT:
        {
          return Container();
        }
      default:
        return Container();
    }
    return PlayerBet(
      text: text,
      color: color,
    );
  }
}
