import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  debugPaintSizeEnabled = false;
  runApp(new HomePage());
}

class HomePage extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}

class HomeState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(home: new MyApp());
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

//start api build and application

String jsonbody = "";
var qrValue = ""; //value for qr scanner, needs to be decoded once production
var amount = "100"; //amount for money in eurocents, needs to come from qrValue
var callbackurl =
    "http://api.qr.al:1880/rest/payments"; //callbackurl for payconiq api
var description = "Test Payment for opening lock";
var reference = "1";
var url = "https://api.ext.payconiq.com/v3/payments"; //payconiq api url
var authorization =
    "306af5de-883f-4961-b4c8-62ecfcd4f21a"; //api code, needs to be in backend at one point

/*
void sendInfo(

//end api build start application
*/
class _MyAppState extends State<MyApp> {
  String qr;
  bool camState = false;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('QR-Pay app'),
      ),
      body: new Center(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Expanded(
                child: camState
                    ? new Center(
                        child: new SizedBox(
                          width: 300.0,
                          height: 600.0,
                          child: new QrCamera(
                            onError: (context, error) => Text(
                              error.toString(),
                              style: TextStyle(color: Colors.red),
                            ),
                            qrCodeCallback: (code) {
                              setState(() {
                                qr = code;
                                var qrValue = code;
//NEED TO GET THIS API CONNECTING! TODO
                                //api
                                {
                                  if (qrValue.isNotEmpty) {
                                    http
                                        .post(url,
                                            headers: {
                                              "Authorization": authorization
                                            },
                                            body: json.encode({
                                              "amount": amount,
                                              "description": description,
                                              "reference": reference,
                                              "callbackurl": callbackurl,
                                            }))
                                        .then((response) {
                                      http.post(callbackurl,
                                          headers: {
                                            "Content-Type": "application/json"
                                          },
                                          body: json.encode({
                                            "body": response.body.toString(),
                                          }));
                                    });
                                  }
                                }
                              });
                            },
                            child: new Container(
                              decoration: new BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                    color: Colors.orange,
                                    width: 10.0,
                                    style: BorderStyle.solid),
                              ),
                            ),
                          ),
                        ),
                      )
                    : new Center(child: new Text("Camera inactive"))),
            new Text("QRCODE &: $qr"),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
          child: new Text(
            "press me",
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            setState(() {
              camState = !camState;
            });
          }),
    );
  }
}
