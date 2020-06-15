import 'package:flutter/material.dart';
import 'package:shimulia_post_office/src/routes/routes.dart';
import 'package:shimulia_post_office/src/screens/chat_detail.dart';

void main(){
    runApp(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: ChatDetailsPage(
          ),
        )
    );
}
