import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_seka/game/gamepad_layer/gamepad_event.dart';
import 'package:game_seka/game/model/bet_data.dart';
import 'package:game_seka/game/model/seka_player_state.dart';
import 'package:game_seka/game/player_layer/instruction/player_instructions.dart';
import 'package:game_seka/game/player_layer/instruction/util_instruction.dart';
import 'package:jigi_core/core/animation/animation_item.dart';
import 'package:jigi_core/core/game/bloc/game_bloc.dart';
import 'package:jigi_core/core/model/vector/vector.dart';
import 'package:jigi_core/core/sizer/sizer.dart';
import 'package:jigi_core/ui/gamepad/gamepad_slider.dart';
import 'package:jigi_core/ui/gamepad/bet_button.dart';
import 'package:jigi_core/core/instruction/parent_instruction.dart';
import 'package:jigi_core/core/util/normalizer.dart';

class BetButtons extends StatefulWidget {
  final InstructionData instructionData;
  final SekaPlayerState currentPlayer;

  const BetButtons(
      {Key? key, required this.instructionData, required this.currentPlayer})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _BetButtons();
  }
}

class _BetButtons extends State<BetButtons> with Normalizer {
  InstructionData get _instruction => widget.instructionData;
  SekaPlayerState get _player => widget.currentPlayer;

  static const double OPEN_HEIGHT = 1800;
  static const double HIDDEN_HEIGHT = 2100;
  GlobalKey<AnimationItemState> _controller = GlobalKey<AnimationItemState>();
  bool _isRaiseOpen = false; // This flag responsible only for slider
  int _max = 10;
  int _min = 0;
  double _value = 0; // Slider value which will be given to the slider as value

  @override
  void initState() {
    super.initState();

    /// Setting slider value
    /// If new Raise instruction is added implement it here
    InstructionData temInstraction = _instruction;
    if (temInstraction is LoadingRaiseCallInsD) {
      setState(() {
        _value = temInstraction.start!.toDouble();
        _min = temInstraction.start!;
        _max = temInstraction.end!;
      });
    }
    SchedulerBinding.instance.addPostFrameCallback((_) => show());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      _isRaiseOpen
          ? SliderWidget(
              max: _max,
              min: _min,
              value: _value,
              onSliderChange: (double val) {
                setState(() {
                  _value = val;
                });
              },
              sliderHeight: Sizer().getHeight(120),
            )
          : Container(),
      AnimationItem(
        child1: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Theme.of(context).focusColor,
              spreadRadius: 0,
              blurRadius: Sizer().getSp(100),
            )
          ]),
          width: Sizer().getWidth(GAME_WIDTH),
          height: Sizer().getHeight(150),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(),
                BetButton(
                    onTap: () {
                      laizyClose(() {
                        BlocProvider.of<GameBloc>(context)
                            .add(FoldMoveGameEvent(playerId: _player.id));
                      });
                    },
                    child: Icon(Icons.close,
                        color: Colors.white, size: Sizer().getSp(55)),
                    title: 'БРОСИТЬ'),
                _getCall,
                _getRaise,
              ]),
        ),
        child2: Container(),
        initialParameters: AnimationParameters(
            positionDuration: 100,
            curve: Curves.easeOutQuint,
            angle: 0,
            size: Vector(GAME_WIDTH, 150),
            position: Vector(GAME_WIDTH / 2, HIDDEN_HEIGHT)),
        key: _controller,
      ),
    ]);
  }

  Widget get _getRaise {
    if (_instruction is RaiseDriver) {
      return BetButton(
          onTap: () {
            if (_isRaiseOpen) {
              laizyClose(() {
                BlocProvider.of<GameBloc>(context).add(BetMoveGameEvent(
                    playerId: _player.id,
                    betStatus: BetData.BET_OK_RAISE,
                    betAmount: _value.toInt()));
              });
            } else {
              setState(() {
                _isRaiseOpen = true;
              });
            }
          },
          child: _isRaiseOpen
              ? Text(
                  '$getValue',
                  style: Theme.of(context).textTheme.headline1!.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )
              : Icon(Icons.trending_up,
                  color: Colors.white, size: Sizer().getSp(55)),
          title: 'ПОДНЯТЬ');
    }
    return Container();
  }

  Widget get _getCall {
    /// IF new [CallDriver] instruction is implemented
    /// add the instruction here
    String buttonText = 'УРОВНЯТЬ';
    InstructionData temInstraction = _instruction;
    CallDriver callDriver = CallDriver()
      ..callValue = 0; // this is temporory solution
    String call = '';
    if (temInstraction is LoadingCallInsD) {
      call = temInstraction.getCallvalue;
      callDriver = temInstraction;
    }

    if (temInstraction is LoadingRaiseCallInsD) {
      call = temInstraction.getCallValue;
      callDriver = temInstraction;
    }
    if (temInstraction is SvaraInsD) {
      call = temInstraction.getCallvalue;
      callDriver = temInstraction;
      buttonText = 'СВАРА';
    }
    if (temInstraction is LoadingAllInInsD) {
      call = temInstraction.getCallvalue;
      callDriver = temInstraction;
      buttonText = 'ВА-БАНК';
    }
    if (_instruction is CallDriver) {
      return BetButton(
          onTap: () {
            laizyClose(() {
              BlocProvider.of<GameBloc>(context).add(BetMoveGameEvent(
                  playerId: _player.id,
                  betStatus: BetData.BET_OK_RAISE,
                  betAmount: callDriver.callValue!));
            });
          },
          child: Text(
            call,
            style: Theme.of(context)
                .textTheme
                .headline1!
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          title: buttonText);
    }
    return Container();
  }

  String get getValue {
    return normalizeNumber(_value);
  }

  /// Public API
  void show() {
    _controller.currentState!.toPosition(Vector(GAME_WIDTH / 2, OPEN_HEIGHT));
  }

  void laizyClose(void Function() callBack) {
    setState(() {
      _isRaiseOpen = false;
    });
    _controller.currentState!
        .toPosition(Vector(GAME_WIDTH / 2, HIDDEN_HEIGHT))
        .whenComplete(callBack);
  }
}

class OpenBlindButtons extends StatefulWidget {
  final LoadingCallBlindInsD callBlind;
  final SekaPlayerState currentPlayer;

  const OpenBlindButtons(
      {Key? key, required this.callBlind, required this.currentPlayer})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _OpenBlindButtons();
  }
}

class _OpenBlindButtons extends State<OpenBlindButtons> {
  static const double OPEN_HEIGHT = 1800;
  static const double HIDDEN_HEIGHT = 2100;
  GlobalKey<AnimationItemState> _controller = GlobalKey<AnimationItemState>();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => show());
  }

  @override
  Widget build(BuildContext context) {
    return AnimationItem(
      child1: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Theme.of(context).focusColor,
            spreadRadius: 0,
            blurRadius: Sizer().getSp(100),
          )
        ]),
        width: Sizer().getWidth(GAME_WIDTH),
        height: Sizer().getHeight(150),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          BetButton(
              onTap: () {
                laizyClose(() {
                  BlocProvider.of<GameBloc>(context).add(
                      FoldMoveGameEvent(playerId: widget.currentPlayer.id));
                });
              },
              child: Icon(Icons.close,
                  color: Colors.white, size: Sizer().getSp(55)),
              title: 'БРОСИТЬ'),
          BetButton(
              onTap: () {
                BlocProvider.of<GameBloc>(context)
                    .add(OpenGameEvent(playerId: widget.currentPlayer.id));
                laizyClose(() {
                  BlocProvider.of<GameBloc>(context).add(CallGameEvent(
                      callValue: widget.callBlind.callValue!,
                      playerId: widget.callBlind.playerId));
                });
              },
              child: Icon(Icons.visibility,
                  color: Colors.white, size: Sizer().getSp(55)),
              title: 'ОТКРЫТЬ'),
          BetButton(
              onTap: () {
                laizyClose(() {
                  BlocProvider.of<GameBloc>(context).add(CallGameEvent(
                      callValue: widget.callBlind.callValue!,
                      playerId: widget.callBlind.playerId));
                });
              },
              child: Icon(Icons.visibility_off,
                  color: Colors.white, size: Sizer().getSp(55)),
              title: 'В СЛЕПУЮ'),
        ]),
      ),
      child2: Container(),
      initialParameters: AnimationParameters(
          positionDuration: 100,
          curve: Curves.easeOutQuint,
          angle: 0,
          size: Vector(GAME_WIDTH, 150),
          position: Vector(GAME_WIDTH / 2, HIDDEN_HEIGHT)),
      key: _controller,
    );
  }

  /// Public API
  void show() {
    _controller.currentState!.toPosition(Vector(GAME_WIDTH / 2, OPEN_HEIGHT));
  }

  void laizyClose(void Function() callBack) {
    _controller.currentState!
        .toPosition(Vector(GAME_WIDTH / 2, HIDDEN_HEIGHT))
        .whenComplete(callBack);
  }
}
