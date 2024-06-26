import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar_helper.dart';

class Messagebar {
  Messagebar._();

  static const int duration = 6; // em segundos

  static Future error(String msg, context) async {
    // TODO: Quando atualizar, pode retirar o unfocus() e import<material>
    FocusScope.of(context).unfocus();
    FlushbarHelper.createError(
      message: (msg ?? "Ocorreu um erro não especificado."),
      duration: Duration(seconds: duration),
    )..show(context);
  }

  static Future success(String msg, context) async {
    // TODO: Quando atualizar, pode retirar o unfocus() e import<material>
    FocusScope.of(context).unfocus();
    FlushbarHelper.createSuccess(
      message: msg,
      duration: Duration(seconds: duration),
    )..show(context);
  }

  static Future info(String msg, context) async {
    // TODO: Quando atualizar, pode retirar o unfocus() e import<material>
    FocusScope.of(context).unfocus();
    FlushbarHelper.createInformation(
      message: msg,
      duration: Duration(seconds: duration),
    )..show(context);
  }
}
