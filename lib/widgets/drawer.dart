import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../services/prefs.dart';

Widget buildDrawer(context) {
  var username = Prefs.getString('username');
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text(
            username.toUpperCase() ?? 'USUÁRIO',
            style: themeData.primaryTextTheme.headline6,
          ),
          accountEmail: Text(
            //username.toLowerCase() + "@digitalsat.com.br",
            "Base de " + ["Produção", "Teste"][Prefs.getInt("database")],
            style: themeData.primaryTextTheme.headline6,
          ),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                ? Colors.orange
                : Colors.white,
            child: Text(
              username != null ? username[0].toUpperCase() : 'U',
              style: TextStyle(fontSize: 40.0),
            ),
          ),
        ),
        ExpansionTile(
          title: Text("Inventário"),
          children: <Widget>[
            ListTile(
              title: Text('- Contagem'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/inventario_contagem');
              },
            ),
            ListTile(
              title: Text('- Recontagem'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/inventario_recontagem');
              },
            ),
          ],
        ),
        ListTile(
          title: Text(
            'Consulta produto',
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/consulta_produto');
          },
        ),
        ExpansionTile(
          title: Text("Conferência",
              style: TextStyle(decoration: TextDecoration.lineThrough)),
          children: <Widget>[
            ListTile(
              title: Text('- Conferência',
                  style: TextStyle(decoration: TextDecoration.lineThrough)),
              onTap: () {},
            ),
            ListTile(
              title: Text('- Recontagem',
                  style: TextStyle(decoration: TextDecoration.lineThrough)),
              onTap: () {},
            ),
          ],
        ),
        ListTile(
          title: Text('Armazenagem',
              style: TextStyle(decoration: TextDecoration.lineThrough)),
          onTap: () {},
        ),
        ListTile(
          title: Text('Separação',
              style: TextStyle(decoration: TextDecoration.lineThrough)),
          onTap: () {},
        ),
        ListTile(
          title: Text('Conferência de volumes',
              style: TextStyle(decoration: TextDecoration.lineThrough)),
          onTap: () {},
        ),
        ListTile(
          title: Text('Reabastecimento',
              style: TextStyle(decoration: TextDecoration.lineThrough)),
          onTap: () {},
        ),
        Divider(),
        ListTile(
          title: Text(
            'Configurações',
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/configuracoes');
          },
        ),
        ListTile(
          title: Text(
            'Sair',
          ),
          onTap: () {
            Prefs.logout();
            Navigator.pushNamed(context, '/login');
          },
        ),
      ],
    ),
  );
}
