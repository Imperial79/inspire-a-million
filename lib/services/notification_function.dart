import 'dart:convert';

import 'package:blog_app/services/globalVariable.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

Future<Response> sendNotification(List<dynamic> tokenIdList, String contents,
    String heading, String largeIconUrl) async {
  return await post(
    Uri.parse('https://onesignal.com/api/v1/notifications'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      "app_id":
          appId, //appId is the App Id that one get from the OneSignal When the application is registered.

      "include_player_ids":
          tokenIdList, //tokenIdList Is the List of All the Token Id to to Whom notification must be sent.

      // android_accent_color reprsent the color of the heading text in the notifiction
      "android_accent_color": "FFBBDEFB",

      "small_icon": "ic_stat_onesignal_default",

      "large_icon": largeIconUrl,

      "headings": {"en": heading},

      "contents": {"en": contents},
    }),
  );
}
