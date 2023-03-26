import 'package:flutter/material.dart';

import '../models/settings_categories.dart';
import '../utils/utils.dart';

class ShoreOneScreen extends StatefulWidget {
  const ShoreOneScreen({Key? key}) : super(key: key);

  @override
  State<ShoreOneScreen> createState() => _ShoreOneScreenState();
}

class _ShoreOneScreenState extends State<ShoreOneScreen> {
  final List<SettingCategory> _categories = const [
    SettingCategory(1, "400 V", "#A9CCE3"),
    SettingCategory(2, "400 V", "#C5F0B3"),
    SettingCategory(3, "400 V", "#A9CCE3"),
    SettingCategory(4, "30 A", "#C5F0B3"),
    SettingCategory(5, "32 A", "#A9CCE3"),
    SettingCategory(6, "29 A", "#C5F0B3")
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shore power 1'),),
      body:  Container(
        margin: EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: _categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemBuilder: (context, index) {
            return TileCategory(_categories[index]);
          },
        ),
      )
    );
  }
}

class TileCategory extends StatelessWidget {
  final SettingCategory _category;
  const TileCategory(this._category, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(4.0),
          onTap: () {
            _navigateToBooksWithCategory(context, _category);
          },
          child: Container(
              alignment: AlignmentDirectional.center ,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: hexToColor(_category.colorBg)
              ),
              child: Text(
                _category.name,
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center,)),
        ));
  }

  void _navigateToBooksWithCategory(BuildContext context, SettingCategory category) {

  }
}

