import 'error.dart';
import 'package:mobx/mobx.dart';
import 'package:validators/validators.dart';
import '../services/prefs.dart';
import '../services/api.dart';

part 'form.g.dart';

class FormStore = _FormStore with _$FormStore;

abstract class _FormStore with Store {
  final FormErrorStore formErrorStore = FormErrorStore();

  final ErrorStore errorStore = ErrorStore();

  _FormStore() {
    _setupValidations();
  }

  // disposers
  List<ReactionDisposer> _disposers;

  void _setupValidations() {
    _disposers = [
      reaction((_) => userEmail, validateUserEmail),
      reaction((_) => password, validatePassword),
      reaction((_) => confirmPassword, validateConfirmPassword)
    ];
  }

  @observable
  String userEmail = '';

  @observable
  String password = '';

  @observable
  String confirmPassword = '';

  @observable
  bool success = false;

  @observable
  bool loading = false;

  @computed
  bool get canLogin =>
      !formErrorStore.hasErrorsInLogin &&
      userEmail.isNotEmpty &&
      password.isNotEmpty;

  @computed
  bool get canRegister =>
      !formErrorStore.hasErrorsInRegister &&
      userEmail.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty;

  @computed
  bool get canForgetPassword =>
      !formErrorStore.hasErrorInForgotPassword && userEmail.isNotEmpty;

  // actions
  @action
  void setUserId(String value) {
    userEmail = value;
  }

  @action
  void setPassword(String value) {
    password = value;
  }

  @action
  void setConfirmPassword(String value) {
    confirmPassword = value;
  }

  @action
  void validateUserEmail(String value) {
    if (value.isEmpty) {
      formErrorStore.userEmail = "Usuário não pode ser em branco.";
    } else if (!isAlphanumeric(value)) {
      formErrorStore.userEmail = 'Usuário inválido.';
    } else if (!isLength(value, 3, 32)) {
      formErrorStore.userEmail = 'Usuário inválido.';
    } else {
      formErrorStore.userEmail = null;
    }
  }

  @action
  void validatePassword(String value) {
    if (value.isEmpty) {
      formErrorStore.password = "Senha não pode ser em branco.";
    } else if (value.length < 4) {
      formErrorStore.password = "Senha muito curta.";
    } else {
      formErrorStore.password = null;
    }
  }

  @action
  void validateConfirmPassword(String value) {
    if (value.isEmpty) {
      formErrorStore.confirmPassword = "Confirm password can't be empty";
    } else if (value != password) {
      formErrorStore.confirmPassword = "Password doesn't match";
    } else {
      formErrorStore.confirmPassword = null;
    }
  }

  @action
  Future register() async {
    loading = true;
  }

  @action
  Future login() async {
    loading = true;
    String callId;

    callId = await api.checkCredencials(userEmail, password);

    success = callId != null;

    if (!success)
      errorStore.errorMessage = api.getError();
    else {
      // store the session
      Prefs.setBool('active', true);
      Prefs.setString('username', userEmail);
      Prefs.setString('password', password);
      Prefs.setString('callid', callId);
      Prefs.setInt('callid_count', 1);
      Prefs.setInt('created', DateTime.now().toUtc().millisecondsSinceEpoch);
    }

    loading = false;
  }

  @action
  Future forgotPassword() async {
    loading = true;
  }

  @action
  Future logout() async {
    loading = true;
  }

  // general methods
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }

  void validateAll() {
    validatePassword(password);
    validateUserEmail(userEmail);
  }
}

class FormErrorStore = _FormErrorStore with _$FormErrorStore;

abstract class _FormErrorStore with Store {
  @observable
  String userEmail;

  @observable
  String password;

  @observable
  String confirmPassword;

  @computed
  bool get hasErrorsInLogin => userEmail != null || password != null;

  @computed
  bool get hasErrorsInRegister =>
      userEmail != null || password != null || confirmPassword != null;

  @computed
  bool get hasErrorInForgotPassword => userEmail != null;
}
