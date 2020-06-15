import 'package:shimulia_post_office/src/screens/chat_detail.dart';
import 'package:flutter/material.dart';
import 'package:shimulia_post_office/src/screens/select_name.dart';
class Routes {

  static final String chatRoute = '/chat';
  static final String selectName = '/';

  static final routes = <String, WidgetBuilder>{
    selectName : (_) => SelectName(),
    chatRoute : (_) => ChatDetailsPage(),
  };


}