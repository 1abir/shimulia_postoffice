import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimulia_post_office/src/screens/chat_detail.dart';
import 'package:shimulia_post_office/src/screens/chat_util/web_socket_message_util.dart';

void main(){
    runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_)=>MessageLoader(),
              lazy: false,
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: ChatDetailsPage(
            ),
          ),
        )
    );
}
