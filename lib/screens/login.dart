import '../routes.dart';
import '../constants/config.dart';
import '../constants/theme.dart';
import '../stores/form.dart';
import '../widgets/app_icon.dart';
import '../widgets/empty_app_bar.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/rounded_button.dart';
import '../widgets/textfield.dart';
import '../services/prefs.dart';
import '../widgets/messagebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;

  TextEditingController _userEmailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  FocusNode _passwordFocusNode;

  final _store = FormStore();

  int consecutiveTaps = 0, lastTap = 0;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
    getLastUsername(); // inicia com o último username utilizado
  }

  void getLastUsername() async {
    final String userId = Prefs.getString('username');
    if (userId != null) {
      setState(() {
        this._userEmailController.text = userId;
        _store.setUserId(_userEmailController.text);
      });
      return;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: EmptyAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Material(
      child: Stack(
        children: <Widget>[
          MediaQuery.of(context).orientation == Orientation.landscape
              ? Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: _buildLeftSide(),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildRightSide(),
                    ),
                  ],
                )
              : Center(child: _buildRightSide()),
          Observer(
            builder: (context) {
              return _store.success
                  ? navigate(context)
                  : _showErrorMessage(_store.errorStore.errorMessage);
            },
          ),
          Observer(
            builder: (context) {
              return Visibility(
                visible: _store.loading,
                child: CustomProgressIndicatorWidget(),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildLeftSide() {
    return SizedBox.expand(
      child: Image.asset(
        Config.loginBackground,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildRightSide() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                int now = DateTime.now().millisecondsSinceEpoch;
                if (now - lastTap < 500) {
                  consecutiveTaps++;
                  if (consecutiveTaps == 5) {
                    // com 5 taps abre o menu de configuração
                    Navigator.pushNamed(context, '/configuracoes');
                  }
                } else {
                  consecutiveTaps = 0;
                }
                lastTap = now;
              },
              behavior: HitTestBehavior.translucent,
              child: AppIconWidget(image: Config.appLogo),
            ),
            SizedBox(height: 24.0),
            _buildUserIdField(),
            _buildPasswordField(),
            _buildSignInButton()
          ],
        ),
      ),
    );
  }

  Widget _buildUserIdField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: "Usuário",
          inputType: TextInputType.emailAddress,
          icon: Icons.person,
          textController: _userEmailController,
          inputAction: TextInputAction.next,
          autoFocus: false,
          onChanged: (value) {
            _store.setUserId(_userEmailController.text);
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          errorText: _store.formErrorStore.userEmail,
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return Observer(
      builder: (context) {
        return Padding(
            padding: EdgeInsets.only(top: 16.0, bottom: 32.0),
            child: TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              onChanged: (value) {
                _store.setPassword(_passwordController.text);
              },
              autofocus: false,
              obscureText: _obscureText,
              maxLength: 25,
              style: Theme.of(context).textTheme.bodyText1,
              decoration: InputDecoration(
                hintText: "Senha",
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Colors.grey),
                errorText: _store.formErrorStore.password,
                counterText: '',
                icon: Icon(Icons.lock, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                    size: 18.0,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ));
      },
    );
  }

  Widget _buildSignInButton() {
    return RoundedButtonWidget(
      buttonText: "Conectar",
      buttonColor: AppColors.digital[500],
      textColor: Colors.white,
      onPressed: () async {
        if (_store.canLogin) {
          _store.login();
        } else {
          _showErrorMessage('Credenciais inválidas.');
        }
      },
    );
  }

  Widget navigate(BuildContext context) {
    Future.delayed(Duration(milliseconds: 0), () {
      Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.home, (Route<dynamic> route) => false);
    });

    return Container();
  }

  _showErrorMessage(String message) {
    if (message != null && message.isNotEmpty) {
      Messagebar.error(message, context);
    }

    return SizedBox.shrink();
  }

  @override
  void dispose() {
    _userEmailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
