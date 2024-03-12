import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jigi_card/core/card_combinations/combination_item.dart';

class CardCombinationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF141B35),
      appBar: AppBar(),
      body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(40),
                  vertical: ScreenUtil().setHeight(50)),
              child: Column(children: [
                Text('Номинал карт и комбинации',
                    style: Theme.of(context).textTheme.headline5!.copyWith(
                        fontSize: ScreenUtil().setSp(90), color: Colors.white)),
                SizedBox(
                  height: ScreenUtil().setHeight(70),
                ),
                CombinationItem(
                  title: 'Тройка (сека)',
                  description:
                      'Три одинаковые карты. Старшинство троек определяется достоинством. Cамой старшей  являются три шестёрки',
                  images: [
                    CombinationInstance(
                        'packages/jigi_card/assets/cards/v1/kingSPADES.png',
                        true),
                    CombinationInstance(
                        'packages/jigi_card/assets/cards/v1/kingDIMOND.png',
                        true),
                    CombinationInstance(
                        'packages/jigi_card/assets/cards/v1/kingHEART.png',
                        true),
                  ],
                ),
                CombinationItem(
                  title: 'Хлюст',
                  description:
                      'три карты одинаковой масти. Самый старший Туз Джокер 10 (32), самый младший 6 7 8 (21) (21 - 32)',
                  images: [
                    CombinationInstance(
                        'packages/jigi_card/assets/cards/v1/aceSPADES.png',
                        true),
                    CombinationInstance(
                        'packages/jigi_card/assets/cards/v1/tenSPADES.png',
                        true),
                    CombinationInstance(
                        'packages/jigi_card/assets/cards/v1/sixCROSS.png',
                        true),
                  ],
                ),
                CombinationItem(
                  title: 'Два лба',
                  description:
                      'два туза. Перебивает младший хлюст, но проигрывает всем остальным хлюстам 22',
                  images: [
                    CombinationInstance(
                        'packages/jigi_card/assets/cards/v1/aceSPADES.png',
                        true),
                    CombinationInstance(
                        'packages/jigi_card/assets/cards/v1/aceDIMOND.png',
                        true),
                    CombinationInstance(
                        'packages/jigi_card/assets/cards/v1/kingHEART.png',
                        true),
                  ],
                ),
                CombinationItem(
                  title: 'Две одной масти',
                  description: 'Cчитаются ниже двух тузов 13-21',
                  images: [
                    CombinationInstance(
                        'packages/jigi_card/assets/cards/v1/nineCROSS.png',
                        true),
                    CombinationInstance(
                        'packages/jigi_card/assets/cards/v1/kingCROSS.png',
                        true),
                    CombinationInstance(
                        'packages/jigi_card/assets/cards/v1/aceHEART.png',
                        true),
                  ],
                ),
                CombinationItem(
                  title: 'Одна карта',
                  description: 'все карты разных мастей  7 - 11',
                  images: [
                    CombinationInstance(
                        'packages/jigi_card/assets/cards/v1/kingSPADES.png',
                        true),
                    CombinationInstance(
                        'packages/jigi_card/assets/cards/v1/sevenDIMOND.png',
                        true),
                    CombinationInstance(
                        'packages/jigi_card/assets/cards/v1/eightHEART.png',
                        true),
                  ],
                ),
              ]))),
    );
  }
}
