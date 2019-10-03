import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

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

var qrValue = ""; //value for qr scanner, needs to be decoded once production
//start api build and application

var amount = "1"; //amount for money in eurocents, needs to come from qrValue
var callbackurl =
    "http://api.qr.al:1880/rest/payments"; //callbackurl for payconiq api
var description = "Machine Nootjes";
var reference = "1";
var url = "https://api.ext.payconiq.com/v3/payments"; //payconiq api url
var authorization =
    "306af5de-883f-4961-b4c8-62ecfcd4f21a"; //api code, needs to be in backend at one point
var confirmation = "Confirmed";
var _deeplink = "";
var contenttype = "application/json";

class _MyAppState extends State<MyApp> {
  String qr;
  bool camState = true;

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
                          height: 300.0,
                          child: new QrCamera(
                            onError: (context, error) => Text(
                              error.toString(),
                              style: TextStyle(color: Colors.red),
                            ),
                            qrCodeCallback: (code) {
                              setState(() {
                                qr =
                                    code; //in future you need to parse the qr link into sections for feeding the api
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
            new Text("QRCODE &: $qrValue"),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
          child: new Text(
            "press me to pay",
            textAlign: TextAlign.center,
          ),
          onPressed: () async {
            http.post(callbackurl,
                body: ({
                  "amount": amount,
                  "description": description,
                  "reference": reference
                }));
          }
          //TODO this thing needs to connect to api when pressed
          //todo open deeplink on pressed
          ),
    );
  }

/* http
                  .post(url,
                      headers: {
                        "Authorization": authorization,
                        "Content-Type": contenttype
                      },
                      body: json.encode({
                        "amount": amount,
                        "description": description,
                        "reference": reference,
                        "callbackurl": callbackurl,
                      }))
                  .then((response) {
                //TODO opendeeplink from response

                /*jsonbody = json.decode(response.body);
                print(jsonbody);
                qr = jsonbody.toString();
                /* http.post(callbackurl,
                                          body: json.encode({
*/

                                          }));
*/
              });*/
}
