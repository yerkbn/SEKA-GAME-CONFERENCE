import 'package:jigi_core/core/game/mock.dart';

class MockSeka extends MockParent {
  MockSeka(MockConfig config) : super(config);

  @override
  void runTest() {
    super.runTest();
    first(duration: 100);
    throwItem(duration: 2000);
    throwItem(duration: 3000);
    throwItem(duration: 4000);
  }

  void throwItem({
    required int duration,

  }) =>
      execute(duration: duration, input: {
        "status": "UTIL_THROW",
        "data": {
          "throwObjId": 1,
          "toPlayerId": cpId,
          "fromPlayerId": 3,
          "inventory": [
            {
              "id": 1,
              "title": "Помидоры",
              "description": "Кинь помидор тому, кто заслуживает унижения",
              "priceRange": [],
              "amount": 174
            },
            {
              "id": 2,
              "title": "Тухлые яйца",
              "description": "Кинь тухлое яйцо тому, кто заслуживает унижения",
              "priceRange": [],
              "amount": 133
            }
          ]
        }
      });

  void first({
    required int duration,
  }) =>
      execute(duration: duration, input: {
        'status': 'CONNECTED_TO_SERVER_CASE_ONE',
        'data': {
          "roomName": "комната #1",
          'players': [
            {
              'id': 3,
              'avatar':
                  'https://lh4.googleusercontent.com/-1uNTxF74Cjk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfn_V5KhBkaeKXLqpv8sPeKJr2irQ/s96-c/photo.jpg',
              'username': 'Vadim',
              'tablePlace': 2
            },
            {
              'id': 4,
              'avatar':
                  'https://i.pinimg.com/originals/30/24/f8/3024f8d283b734bd6b7e4fc5531fe2e9.png',
              'username': 'Kandi',
              'tablePlace': 3
            },
            {
              'id': 5,
              'avatar':
                  'https://i.pinimg.com/originals/30/24/f8/3024f8d283b734bd6b7e4fc5531fe2e9.png',
              'username': 'Asik',
              'tablePlace': 4
            },
            {
              'id': 6,
              'avatar':
                  'https://i.pinimg.com/originals/30/24/f8/3024f8d283b734bd6b7e4fc5531fe2e9.png',
              'username': 'MaxLutor',
              'tablePlace': 5
            },
          ],
          'ownData': {
            "chipsCount": 35183,
            "throwables": [
              {
                "id": 1,
                "title": "Помидоры",
                "description": "Кинь помидор тому, кто заслуживает унижения",
                "priceRange": [],
                "amount": 56
              },
              {
                "id": 2,
                "title": "Тухлые яйца",
                "description":
                    "Кинь тухлое яйцо тому, кто заслуживает унижения",
                "priceRange": [],
                "amount": 186
              }
            ],
            "onHat": null
          },
          "playersShowData": [
            {"playerId": 6, "chips": 600007079, "onHat": null},
            {"playerId": 3, "chips": 35183, "onHat": null},
            {"playerId": 4, "chips": 400007079, "onHat": null},
            {"playerId": 5, "chips": 5183, "onHat": null}
          ],
          "bookedPlaces": []
        }
      });
}
