import 'package:flutter/material.dart';
import '../constants/config.dart';
import '../constants/theme.dart';
import '../services/prefs.dart';
import '../widgets/drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeScreen> {
  List<Widget> _buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        onPressed: () {
          Prefs.logout();
          Navigator.pushNamed(context, '/login');
        },
        icon: Icon(
          Icons.power_settings_new,
        ),
      ),
    ];
  }

  Widget _buildDashboard(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
      child: GridView.count(
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          crossAxisCount:
              MediaQuery.of(context).orientation == Orientation.landscape
                  ? 4
                  : 2,
          childAspectRatio: .90,
          children: <Widget>[
            _buildDashboardCard(
                'Inventário',
                {
                  'inventario_contagem': 'Contagem',
                  'inventario_recontagem': 'Recontagem',
                  //'inventario_lista': 'Relatório da contagem'
                },
                Icons.layers),
            _buildDashboardCard(
                'Consulta produto', 'consulta_produto', Icons.find_in_page),
            _buildDashboardCard(
                'Armazenagem', '' /*armazenagem'*/, Icons.widgets),
            _buildDashboardCard(
                'Conferência',
                '' /*
                {
                  'conferencia': 'Conferência',
                  'recontagem' : 'Recontagem'
                }*/
                ,
                Icons.check_box),
            _buildDashboardCard(
                'Separação', '' /*separacao'*/, Icons.shopping_cart),
            _buildDashboardCard(
                'Conferência de volumes', '', Icons.library_add_check),
            _buildDashboardCard('Reabastecimento', '' /*reabastecimento'*/,
                Icons.download_sharp),
          ]),
    );
  }

  Widget _buildDashboardCard(String text, dynamic route, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (route.isNotEmpty) {
          // Se tem opção única ou várias
          if (route is String)
            Navigator.pushNamed(context, '/' + route);
          else if (route is Map) _showModalBottomSheet(route, context);
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon,
                size: 40.0,
                color: route.isNotEmpty
                    ? themeData.primaryColor
                    : Color.fromRGBO(155, 155, 155, 50)),
            SizedBox(height: 8.0),
            Text(text, textAlign: TextAlign.center),
          ],
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Esse método é executado toda vez que o setState é chamado
    return Scaffold(
      appBar: AppBar(
        title: Text(Config.appName),
        actions: _buildActions(context),
      ),
      body: _buildDashboard(context),
      drawer: buildDrawer(context),
    );
  }

  Future<dynamic> _showModalBottomSheet(Map items, BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            child: ListView.separated(
              separatorBuilder: (BuildContext context, int index) => Divider(),
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                String key = items.keys.elementAt(index);
                return ListTile(
                  leading: null,
                  title: Text('${items[key]}'),
                  trailing: new Icon(Icons.navigate_next),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/' + key);
                  },
                );
              },
            ),
          );
        });
  }
}
