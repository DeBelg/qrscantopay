import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

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

var qrValue; //value for qr scanner, needs to be decoded once production
//start api build and application
var jsonbody;
var amount = "1"; //amount for money in eurocents, needs to come from qrValue
var callbackurl =
    "http://api.qr.al:1880/rest/payments"; //callbackurl for payconiq api
var description = "Machine Nootjes";
var reference = "1";
var url = "https://api.payconiq.com/v3/payments"; //payconiq api url
var authorization =
    "50de94a0-bb7c-43aa-805a-b348bab066a2"; //api code, needs to be in backend at one point
var deeplink;
var links;

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
            new Text("QRCODE &: $qr"),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
          child: new Text(
            "press me to pay",
            textAlign: TextAlign.center,
          ),
          onPressed: () async {
            var capture = await http.post(callbackurl,
                headers: {
                  "Authorization": authorization,
                  "Content-type": "application/json"
                },
                body: jsonEncode({
                  "qr": qr
                })); //capture the url to send to backend for decoding and receiving backend parsed information

            var capturebody = json.decode(capture.body); //gets the jsonbody

            amount = capturebody[
                'amount']; //changes the variables with info form our api side
            description = capturebody['description'];
            reference = capturebody['reference'];

            var response = await http.post(url,
                headers: {
                  "Authorization": authorization,
                  "Content-type": "application/json"
                },
                body: jsonEncode({
                  "amount": amount,
                  "description": description,
                  "callbackUrl": callbackurl,
                  "reference": reference
                })); //sends post request to payconiq

            jsonbody = json.decode(response.body);

            links = jsonbody['_links'];
            var _deeplink = links['deeplink'];
            deeplink = _deeplink[
                'href']; //Parses the deeplink from the jsonbody, double parsing because there's a href from payconiq before the link

            print(deeplink
                .toString()
                .toLowerCase()); //Needs to be lower case because payconiq api sends all in uppercase
            launch(deeplink.toString().toLowerCase()); //opens deeplink from app
          }

          //todo open deeplink on pressed
          ),
    );
  }
}
