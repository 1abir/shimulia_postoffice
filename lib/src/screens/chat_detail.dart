import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimulia_post_office/constants/appcolours.dart';
import 'package:shimulia_post_office/src/screens/chat_util/chat_messages.dart';
import 'package:shimulia_post_office/src/screens/select_name.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import 'chat_util/message_item.dart';


class ChatDetailsPage extends StatefulWidget {
  @override
  _ChatDetailsPageState createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends State<ChatDetailsPage> {
  WebSocketChannel channel;
  String name;
  bool noname;
  TextEditingController textFieldController;
  List<Message> _messages;
  bool _doNotAdd = false;

  @override
  void initState(){
    super.initState();
    noname = true;
    channel = IOWebSocketChannel.connect('ws://www.ragib.me:80/ws/chat/turzo/');
    _messages = List();
    textFieldController = TextEditingController();
  }

  @override
  void dispose(){
//    widget.channel.sink.close(status.goingAway);
  if(channel!=null)
    channel.sink.close(status.goingAway);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: chatDetailScaffoldBgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: FlatButton(
          shape: CircleBorder(),
          padding: const EdgeInsets.only(left: 1.0),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          child: Row(
            children: <Widget>[
              Icon(
                Icons.arrow_back,
                size: 24.0,
                color: Colors.white,
              ),
              CircleAvatar(
                radius: 15.0,
                backgroundImage: CachedNetworkImageProvider(
                  'https://banner2.cleanpng.com/20180330/gdw/kisspng-iphone-emoji-apple-ios-11-emojis-5abe1fe3470cf8.3253064115224094432911.jpg',
              ),
              ),
            ],
          ),
        ),
        title: Material(
          color: Colors.white.withOpacity(0.0),
          child: InkWell(
            highlightColor: highlightColor,
            splashColor: secondaryColor,
            onTap: () {

            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Text(
                        name??'Turzo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Flexible(
            flex: 1,
            child:
//            FutureBuilder(
//              future: widget._prefs,
//              builder:(_,snapshot){
//                if(snapshot.connectionState == ConnectionState.done && snapshot.hasData && !snapshot.hasError)
//                  return
            StreamBuilder(
                  stream: channel.stream,
                  builder: (context, snapshot) {

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }else{
                          if(snapshot.hasData){
                            var __message = jsonDecode(snapshot.data);
                            var __msg = __message['message']['message'];
                            var __name = __message['message']['name'];
                            if(!_doNotAdd) {
                              bool _isYou = false;
                              if(name != null && __name == name ) _isYou = true;
                              _messages.insert(
                                  0,
                                  Message(
                                    content: __msg,
                                    timestamp: DateTime.now(),
                                    isRead: false,
                                    isYou: _isYou,
                                    isSent: _isYou,
                                  )
                              );
                            }else{
                              _doNotAdd = false;
                            }
                          }
                        }

                        return ListView.builder(
                            reverse: true,
                            itemCount: _messages.length,
                            itemBuilder: (context, i) {
                              return MessageItem(
                                content: _messages[i].content,
                                timestamp: _messages[i].timestamp,
                                isYou: _messages[i].isYou,
                                isRead: _messages[i].isRead,
                                isSent: _messages[i].isSent,
                                fontSize: 15.0,
                              );
                            });
                  }),
//                return Container();
//              }
//            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.all(const Radius.circular(30.0)),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          padding: const EdgeInsets.all(0.0),
                          disabledColor: iconColor,
                          color: iconColor,
                          icon: Icon(Icons.insert_emoticon),
                          onPressed: () {},
                        ),
                        Flexible(
                          child: TextField(
                            controller: textFieldController,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.send,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(0.0),
                              hintText: 'Type a message',
                              hintStyle: TextStyle(
                                color: textFieldHintColor,
                                fontSize: 16.0,
                              ),
                              counterText: '',
                            ),
                            onSubmitted: (String text) {
                                _sendMessage(context);
                            },
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            maxLength: 1000,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: FloatingActionButton(
                    elevation: 2.0,
                    backgroundColor: secondaryColor,
                    foregroundColor: Colors.white,
                    child: Icon(Icons.send),
                    onPressed: (){_sendMessage(context);},
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
  void _sendMessage(BuildContext context) async{
    if(noname) {
      await _callnew(context);
    }
    if (textFieldController.text!=null && textFieldController.text.isNotEmpty) {
//      widget.channel.sink.add(textFieldController.text);
      var _toSend = {
        'message': {
          'message': textFieldController.text,
          'name': name
        }
      };
      if (channel != null)
        channel.sink.add(jsonEncode(_toSend));
      _doNotAdd = true;
      setState(() {
        _messages.insert(
            0,
            new Message(
              content: textFieldController.text,
              timestamp: DateTime.now(),
              isRead: false,
              isYou: true,
              isSent: true,
            )
        );
      });
      textFieldController.text = '';
    }
  }

  Future<void> _callnew(BuildContext context) async{
    if(noname){
      noname = false;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      name = await prefs.getString('name');
      debugPrint('got from shared pref');
      debugPrint(prefs.getString('name'));
      if(name == null || name.isEmpty) {
        name = await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SelectName()),);
        await prefs.setString('name', name);
        debugPrint('got from Screen');
        debugPrint(prefs.getString('name'));
      }
    }
  }
}

