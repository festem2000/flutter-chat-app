import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

mostrarAlerta(BuildContext context, String titulo, String subtitulo) {
  //Verificar si la ALerta de muestra para Android o para IOS
  if (Platform.isAndroid) {
    //CONSTRUCCION DEL DIALOG ALERTA
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(subtitulo),
        actions: [
          MaterialButton(
            child: Text('ok'),
            elevation: 5,
            textColor: Colors.blue,
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  // Si el aplicactivo esta en un Sistema operativo IOS se despliega este Cuadro dialgo Alerta
  showCupertinoDialog(
    context: context,
    builder: (_) => CupertinoAlertDialog(
      title: Text(titulo),
      content: Text(subtitulo),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          child: Text('ok'),
          onPressed: () => Navigator.pop(context),
        )
      ],
    ),
  );
}
