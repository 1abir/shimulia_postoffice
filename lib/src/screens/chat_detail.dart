import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimulia_post_office/constants/appcolours.dart';
import 'package:shimulia_post_office/src/screens/chat_util/chat_messages.dart';
import 'package:shimulia_post_office/src/screens/select_name.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import 'chat_util/message_item.dart';
import 'chat_util/web_socket_message_util.dart';


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
  StreamController<bool> _streamController;

  @override
  void initState() {
    super.initState();
    noname = true;
    textFieldController = TextEditingController();
    _streamController = StreamController<bool>();
  }

  @override
  void dispose() async{
//    widget.channel.sink.close(status.goingAway);
    if (channel != null)
      channel.sink.close(status.goingAway);
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(channel == null) {
      MessageLoader _ml = Provider.of<MessageLoader>(context, listen: false);
      channel = _ml.channel;
      _messages = _ml.messages;
    }
    if(_messages == null) {
      _messages = Provider.of<MessageLoader>(context, listen: false).messages;
    }
      return WillPopScope(
        onWillPop: ()async{
          return _onWillPop(context);
        },
        child: Scaffold(
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
//              Icon(
//                Icons.arrow_back,
//                size: 24.0,
//                color: Colors.white,
//              ),
                  Container(
                    margin: EdgeInsets.only(top: 5.0,left: 5.0,bottom: 5.0),
                    child: CircleAvatar(
                      radius: 25.0,
                      backgroundImage: CachedNetworkImageProvider(
                        'https://banner2.cleanpng.com/20180330/gdw/kisspng-iphone-emoji-apple-ios-11-emojis-5abe1fe3470cf8.3253064115224094432911.jpg',
                      ),
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
                            'Friends Forever',
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
          body: _buildBody(),
        ),
      );
  }

  void _sendMessage(BuildContext context) async {
    if (noname) {
      await _callnew(context);
    }
    if (textFieldController.text != null &&
        textFieldController.text.isNotEmpty) {
//      widget.channel.sink.add(textFieldController.text);
      var _toSend = {
        'message': {
          'message': textFieldController.text,
          'name': name
        }
      };
      bool _isSent = true;
      if (channel != null) {
        try {
          channel.sink.add(jsonEncode(_toSend));
        } on WebSocketChannelException {
          _isSent =false;
        } catch (e){
          _isSent =false;
        }
      }
      _doNotAdd = true;
        _messages.insert(
            0,
            new Message(
              content: textFieldController.text,
              timestamp: DateTime.now(),
              isRead: false,
              isYou: true,
              isSent: _isSent,
              sender: name,
            )
        );
        _doNotAdd =false;
      textFieldController.text = '';
    }
  }

  Future<void> _callnew(BuildContext context) async {
    if (noname) {
      noname = false;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      name = prefs.getString('name');
      if (name == null || name.isEmpty) {
        name = await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SelectName()),);
        await prefs.setString('name', name);
      }
    }
  }

  Widget _buildBody() {
    return StreamBuilder(
      stream: _streamController.stream,
      builder: (_, __) {
        if (channel != null)
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Flexible(
                flex: 1,
                child:
                StreamBuilder(
                    stream: channel.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
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
                      } else {
                        if (snapshot.hasData) {
                          var __message = jsonDecode(snapshot.data);
                          String __msg = __message['message']['message'] as String;
                          String __name = __message['message']['name'] as String;
                          if (__name != name ) {
                            _messages.insert(
                                0,
                                Message(
                                  content: __msg,
                                  timestamp: DateTime.now(),
                                  isRead: false,
                                  isYou: false,
                                  isSent: false,
                                  sender: __name,
                                )
                            );
                          }
                          else {
                            if (_doNotAdd)
                              _doNotAdd = false;
                            else {
                              if (_messages[0].content !=
                                  __msg && __message[0].isYou == true) {
                                _messages.insert(
                                    0,
                                    Message(
                                      content: __msg,
                                      timestamp: DateTime.now(),
                                      isRead: false,
                                      isYou: true,
                                      isSent: true,
                                      sender: name,
                                    )
                                );
                              }
                            }
                          }
                        }
                      }

                      return Selector<MessageLoader,int>(
                        selector: (_,msgloader)=>_messages.length,
                        builder:(context,__,___) => ListView.builder(
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
                                sender: _messages[i].sender,
                              );
                            }),
                      );
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
                                textCapitalization: TextCapitalization
                                    .sentences,
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
                        onPressed: () {
                          _sendMessage(context);
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        else {
          return
            Container(
              color: Colors.white,
                child: Center(
                  child: Card(
                    elevation: 7.0,
                    color: Colors.white,
                    child: Center(
                      child: InkWell(
                        onTap: _tryAgain,
                        child: Text(
                          'No Internet\nClick here to try again',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            );
        }
      },
    );
  }

  Future<void> _tryAgain() async {
    if (channel == null) {
      try {
        channel =
            IOWebSocketChannel.connect('ws://www.ragib.me:80/ws/chat/turzo/');
        _streamController.sink.add(true);
      }catch (e){
        debugPrint('$e');
      }
    }
  }

  Future<bool> _onWillPop(BuildContext context) async{
    await Provider.of<MessageLoader>(context,listen: false).writeMessage();
    Navigator.of(context).maybePop();
    return true;
  }

}

