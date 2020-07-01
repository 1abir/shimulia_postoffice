import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimulia_post_office/src/screens/chat_util/chat_messages.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessageLoader with ChangeNotifier{
  List<Message> messages;
  WebSocketChannel channel;

  MessageLoader(){
    messages = List();
    try {
      channel =
          IOWebSocketChannel.connect('ws://www.ragib.me:80/ws/chat/turzo/');
    }catch (e){
      debugPrint('$e');
    }
    readMessage().then((f){
      debugPrint('read complete');
    });
  }


  Future<void> readMessage() async {
    try {
      final file = await _localFile;
      bool _exists = await file.exists();
      if(_exists) {
        // Read the file.
        String __contents = await file.readAsString();

        var __messgs = jsonDecode(__contents) as List;
        List<Message> _msgList = __messgs.map((_msgItem) =>
            Message.fromJson(_msgItem)).toList();
          messages.addAll(_msgList);
        messages.forEach((f) {
          debugPrint('${f.content}');
        });
      }else{
        debugPrint('file does not exists');
      }
    } catch (e) {
      // If encountering an error, return 0.
      debugPrint('error : $e');
      return ;
    }
  }


  Future<File> writeMessage() async {
    debugPrint('inside write');
    String _toWrite = jsonEncode(messages);
    final file = await _localFile;
    // Write the file.
    debugPrint(_toWrite);
    return file.writeAsString(_toWrite);
  }


  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/message.txt');
  }


  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}