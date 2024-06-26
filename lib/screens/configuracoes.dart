import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../constants/config.dart';
import '../services/api.dart';

List _connName = ["Rede interna", "Rede externa"];
List _baseName = ["Produção", "Teste"];
int _connIndex = 0;
int _baseIndex = 0;

class ConfiguracoesScreen extends StatefulWidget {
  @override
  _ConfiguracoesPageState createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesScreen> {
  bool _loading = false;

  Future<void> changeLoading(bool value) async {
    setState(() {
      _loading = value;
    });
  }

  PackageInfo _packageInfo = PackageInfo(
    appName: '-',
    packageName: '-',
    version: '-',
    buildNumber: '-',
  );
  Map<String, String> _androidInfo = {
    'brand': '-',
    'model': '-',
    'version': '-',
    'id': '-',
  };

  @override
  Future<void> initState() {
    super.initState();
    _initInfo();
  }

  Future<void> _initInfo() async {
    changeLoading(true);
    final info = await PackageInfo.fromPlatform();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo;
    try {
      androidInfo = await deviceInfo.androidInfo;
      _androidInfo = {
        'brand': androidInfo?.brand ?? "Desconhecida",
        'model': androidInfo?.model ?? "",
        'version': 'Android ' + androidInfo?.version?.release.toString() ??
            "desconhecido",
        'id': androidInfo?.androidId ?? "Desconhecido",
      };
    } catch (e) {
      print(e);
    }
    setState(() {
      _packageInfo = info;
      _connIndex = api.getConnection();
      _baseIndex = api.getDatabase();
    });
    changeLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
      ),
      body: buildSettingsList(),
    );
  }

  Widget buildSettingsList() {
    return SettingsList(
      sections: [
        SettingsSection(
          titlePadding:
              EdgeInsets.only(left: 15.0, right: 15.0, bottom: 6.0, top: 15.0),
          title: 'Geral',
          tiles: [
            SettingsTile(
              title: 'Conexão',
              subtitle: _connName[_connIndex],
              leading: Icon(Icons.network_wifi),
              onPressed: (context) async {
                api.setBaseUrl();
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ConnectionScreen(),
                ));
                setState(() {});
              },
            ),
            SettingsTile(
              title: 'Base de dados',
              subtitle: _baseName[_baseIndex],
              leading: Icon(Icons.cloud_queue),
              onPressed: (context) async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => DatabaseScreen(),
                ));
                setState(() {});
              },
            ),
          ],
        ),
        SettingsSection(
          titlePadding:
              EdgeInsets.only(left: 15.0, right: 15.0, bottom: 6.0, top: 15.0),
          title: 'Dispositivo',
          tiles: [
            SettingsTile(
              title: 'Modelo',
              subtitle: "${_androidInfo['model'][0].toUpperCase()}" +
                  "${_androidInfo['model'].substring(1)} " +
                  "(${_androidInfo['brand'][0].toUpperCase()}" +
                  "${_androidInfo['brand'].substring(1)})",
              leading: Icon(Icons.perm_device_info),
            ),
            SettingsTile(
              title: 'Sistema',
              subtitle: _androidInfo['version'],
              leading: Icon(Icons.android),
            ),
            SettingsTile(
              title: 'ID',
              subtitle: _androidInfo['id'],
              leading: Icon(Icons.info),
            ),
          ],
        ),
        CustomSection(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 22, bottom: 8),
                child: Image.asset(
                  Config.appLogo,
                  height: 80,
                  width: 80,
                  color: Color(0xFF777777),
                ),
              ),
              Text(_packageInfo.appName,
                  style: TextStyle(color: Color(0xFF777777))),
              Text(
                _packageInfo.version +
                    ' (build ' +
                    _packageInfo.buildNumber +
                    ")",
                style: TextStyle(color: Color(0xFF777777)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ConnectionScreen extends StatefulWidget {
  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Conexão')),
      body: SettingsList(
        sections: [
          SettingsSection(tiles: [
            SettingsTile(
              title: _connName[0],
              trailing: trailingWidget(0),
              onPressed: (BuildContext context) {
                changeConnection(0);
              },
            ),
            SettingsTile(
              title: _connName[1],
              trailing: trailingWidget(1),
              onPressed: (BuildContext context) {
                changeConnection(1);
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget trailingWidget(int index) {
    return (_connIndex == index)
        ? Icon(Icons.check, color: Colors.black)
        : Icon(null);
  }

  void changeConnection(int index) {
    setState(() {
      _connIndex = index;
    });
    api.setBaseUrl(_connIndex, _baseIndex);
  }
}

class DatabaseScreen extends StatefulWidget {
  @override
  _DatabaseScreenState createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Base de dados')),
      body: SettingsList(
        sections: [
          SettingsSection(tiles: [
            SettingsTile(
              title: _baseName[0],
              trailing: trailingWidget(0),
              onPressed: (BuildContext context) {
                changeDatabase(0);
              },
            ),
            SettingsTile(
              title: _baseName[1],
              trailing: trailingWidget(1),
              onPressed: (BuildContext context) {
                changeDatabase(1);
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget trailingWidget(int index) {
    return (_baseIndex == index)
        ? Icon(Icons.check, color: Colors.black)
        : Icon(null);
  }

  void changeDatabase(int index) {
    setState(() {
      _baseIndex = index;
    });
    api.setBaseUrl(_connIndex, _baseIndex);
  }
}
