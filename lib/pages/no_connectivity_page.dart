import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';

class NoConnectivityPage extends StatefulWidget {
  @override
  _NoConnectivityPageState createState() => _NoConnectivityPageState();
}

class _NoConnectivityPageState extends State<NoConnectivityPage> {
  Timer timer;

  bool myInterceptor(bool stopDefaultButtonEvent) {
    return true;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // BackButtonInterceptor.add(myInterceptor);
    /*  timer = Timer(Duration(seconds: 40), () {
      SystemNavigator.pop();
    });*/
  }

  @override
  void dispose() {
    BackButtonInterceptor.removeAll();
    //timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          /*   decoration: BoxDecoration(
            image: DecorationImage(
              image: new AssetImage("assets/images/app_bg.jpg"),
              fit: BoxFit.cover,
            ),
          ),*/
          child: Stack(
            children: <Widget>[
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    /*  Icon(
                      Icons.signal_wifi_off,
                      color: Colors.blueAccent,
                      size: 80.0,
                    ),*/
                    Image.asset(
                      "assets/images/no_net.jpeg",
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.3,
                    ),
                    Text(
                      'No Internet Connection',
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black87,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Please try again with Active Internet connection...!',
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontFamily: "Achivo600Bold",
                              color: Colors.black87,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
