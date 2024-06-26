import 'package:flutter/material.dart';

Widget buildBadgeActive(String text) {
  Color color;

  if (text == 'S') {
    color = Colors.green;
    text = 'Sim';
  } else if (text == 'N' || text == 'Não') {
    color = Colors.grey;
    text = 'Não';
  } else if (text == 'Abrir' || text == 'Ver') {
    color = Colors.red;
  } else if (text.toLowerCase() == 'inativo') {
    color = Colors.grey;
  } else {
    color = Colors.grey;
  }

  return Container(
    decoration: BoxDecoration(
      color: color,
      border: Border.all(
        color: color,
        width: 3,
      ),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Text(
      text,
      style: TextStyle(color: Colors.white),
    ),
  );
}
