import 'package:flutter/material.dart';
import 'package:shimulia_post_office/constants/appcolours.dart';

class SelectName extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        return _willPop(context);
      },
      child: Scaffold(
        body: Material(
            child: Container (
                padding: const EdgeInsets.all(30.0),
                color: Colors.white,
                child: Container(
                  child: Center(
                      child: Column(
                          children : [
                            Spacer(),
                            Text('তোমার নাম কি?',
                              style: TextStyle(color: hexToColor("#F2A03D"), fontSize: 25.0),),
                            SizedBox(height: 50,),
                            TextFormField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: "শিমুল",
                                labelText: "এখানে নাম লিখুন",
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide(
                                  ),
                                ),
                                //fillColor: Colors.green
                              ),
                              keyboardType: TextInputType.text,
                              maxLength: 33,
                              maxLines: 5,
                              maxLengthEnforced: true,
                              initialValue: 'fdfsfsd',
                              style: TextStyle(
                                fontFamily: "Poppins",
                              ),
                            ),
                            SizedBox(height: 100,),
                            InkWell(
                              onTap: (){
                                _willPop(context);
                              },
                              splashColor: primaryColor,
                              hoverColor: secondaryColor,
                              child: Container(
                                height: 50,
                                margin: EdgeInsets.symmetric(horizontal: 55),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: profileDialogBgColor,
                                ),
                                child: Center(
                                  child: Text(
                                    'OK',
                                    style:
                                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            Spacer(),
                          ]
                      )
                  ),
                )
            )
        ),
      ),
    );
  }

  Color hexToColor(String code) {
    return new Color(int.tryParse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  Future<bool> _willPop(BuildContext context)async{
    if(_controller.text !=null && _controller.text.isNotEmpty){
      Navigator.of(context).pop(_controller.text);
      return false;
    }
    else{
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
            SnackBar(
              content: Text(
                  'ওই বেটা তোর কি নাম নাই?'
              ),
              duration: Duration(
                seconds: 1,
              ),
            )
        );
      return false;
    }
  }

}
