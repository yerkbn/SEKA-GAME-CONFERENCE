import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_seka/game/game_agent/seka_agent.dart';
import 'package:game_seka/game/mock_seka.dart';
import 'package:jigi_core/core/agent/agent.dart';
import 'package:jigi_core/core/game/bloc/game_bloc.dart';
import 'package:jigi_core/core/game/mock.dart';
import 'package:jigi_core/core/model/room/room_data.dart';
import 'package:jigi_core/core/bridge/game_bridge.dart';
import 'package:jigi_core/core/sizer/sizer.dart';
import 'package:jigi_core/module/auth/bloc/bloc.dart';
import 'package:jigi_core/module/table/game_table.dart';

/// This is main page where azi game is
/// going
/// but main porpose is getting user info from
/// shared preference and pass it to azi bloc
/// by child
class GamePage extends StatefulWidget {
  final RouteObserver<PageRoute> routeObserver;

  const GamePage({Key? key, required this.routeObserver}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

GameAgentCreator _createSekaAgent = (AgentCreatorHolder holder) {
  return SekaAgent.agentCreator(holder);
};

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    final RoomRouteParameter arg =
        // RoomRouteParameter(createRoom: null, roomId: 1);
        ModalRoute.of(context)!.settings.arguments as RoomRouteParameter;
    Sizer.instance.init(context: context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (BuildContext context, AuthState state) {
          if (state is AuthenticatedAuthState) {
            return GameBridge(
              isTesting: false,
              mockCreator: (MockConfig config) {
                return MockSeka(config);
              },
              routeObserver: widget.routeObserver,
              currentUser: state.user,
              parameter: arg,
              agentCreator: _createSekaAgent,
              createGameTable: (ParentAgent agent) {
                return GameTable(
                  gameAgent: agent,
                );
              },
            );
          }
          return const Center(child: Text('Not user found'));
        },
      ),
    );
  }
}
