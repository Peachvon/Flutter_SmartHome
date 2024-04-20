// ignore_for_file: prefer_const_constructors, non_constant_identifier_names
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:smarthome/src/config/theme.dart' as custom_theme;
import 'package:smarthome/src/screen/shared_widget.dart';
import 'package:smarthome/src/service/mqtt_connect/matt_connect.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:web_socket_channel/io.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:web_socket_channel/status.dart' as status;

class DoorScreen extends StatefulWidget {
  const DoorScreen({
    Key? key,
    required this.name,
    required this.ip,
    required this.topic,
  }) : super(key: key);

  final String name;
  final String ip;
  final String topic;

  @override
  State<DoorScreen> createState() => _DoorScreenState();
}

class _DoorScreenState extends State<DoorScreen> {
  // late stt.SpeechToText _speech;
  bool _isListening = false;
  Color _ColorStatusConnec = Colors.red;
  int showPercent = 0;

  var _valueSensorPercent = 1.0;
  var _valueDoorPercen = 1.0;

  void SUB() async {
    client!.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      if (pt == "STP0" || pt == "CK0") {
        _valueSensorPercent = 1;
        showPercent = 0;
      } else if (pt == "STP25" || pt == "CK25") {
        _valueSensorPercent = 2;
        showPercent = 25;
      } else if (pt == "STP50" || pt == "CK50") {
        _valueSensorPercent = 3;
        showPercent = 50;
      } else if (pt == "STP75" || pt == "CK75") {
        _valueSensorPercent = 4;
        showPercent = 75;
      } else if (pt == "STP100" || pt == "CK100") {
        _valueSensorPercent = 5;
        showPercent = 100;
      }
      if (pt == 'connected') {
        _ColorStatusConnec = Colors.green;
      }
      print(pt);
      setState(() {});
    });
  }

  void setMQTT() async {
    await mqttConnect(widget.ip, widget.topic);
    SUB();
    publish(widget.topic, 'GET');
    publish(widget.topic, 'doorstatus');
  }

  final channel = IOWebSocketChannel.connect('ws://35.240.190.171:9999');

  @override
  void initState() {
    // channel.stream.listen((message) {
    //   print(message);
    //   // channel.sink.add('received!');
    //   // channel.sink.close(status.goingAway);
    // });
    super.initState();
    // _speech = stt.SpeechToText();
    setMQTT();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    channel.sink.close();
    super.dispose();
  }

  void sendMqtt(int temp, double fan, bool swing) {
    String _temp = temp.toString();
    String _fan = '';
    String _swing = '';
    switch (fan.toInt().toString()) {
      case '1':
        _fan = 'L';
        break;
      case '2':
        _fan = 'M';
        break;
      case '3':
        _fan = 'H';
        break;
      default:
    }
    switch (swing) {
      case true:
        _swing = 'Y';
        break;
      case false:
        _swing = 'N';
        break;

      default:
    }
    String Message = 'D' + _temp + _fan + _swing;
    publish(widget.topic, Message);
    print(Message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text('door'),
        leading: InkWell(
          onTap: () {
            disconnectMqtt();
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios),
        ),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                height: MediaQuery.of(context).size.height * 1,
                width: MediaQuery.of(context).size.width * 0.984,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  border: Border.all(
                    width: 3,
                    color: custom_theme.Theme.MainTheme,
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              Spacer(flex: 5),
              StatusConnec(
                Connec: _ColorStatusConnec,
              ),
              Spacer(flex: 1),
              header(),
              Spacer(flex: 5),
              cctv(),
              SizedBox(height: 10),
              SliderSensor(),
              Spacer(flex: 2),
              Text('${showPercent}%'),
              Spacer(flex: 2),
              SliderDoorPercen(),
              Spacer(flex: 1),
              sendBunton(),
              Spacer(flex: 2),
              ButtonTap(),
              Spacer(flex: 7),
            ],
          ),
          // mic(),
        ],
      ),
    );
  }

  Slider SliderSensor() {
    return Slider(
      value: _valueSensorPercent,
      min: 1,
      max: 5,
      divisions: 4,
      activeColor: custom_theme.Theme.MainTheme,
      inactiveColor: Colors.black,

      onChanged: (newValue) {},

      // label: _labelFan,
    );
  }

  Slider SliderDoorPercen() {
    return Slider(
      value: _valueDoorPercen,
      min: 1,
      max: 5,
      divisions: 4,
      activeColor: custom_theme.Theme.MainTheme,
      inactiveColor: Colors.black,
      onChanged: (newValue) {},
    );
  }

  Padding sendBunton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (_valueSensorPercent > 1) {
                  publish(widget.topic, 'Fix0R');
                } else {}

                _valueDoorPercen = 1;
              });
            },
            child: Text(
              '0',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                if (_valueSensorPercent < 2) {
                  publish(widget.topic, 'Fix25F');
                } else if (_valueSensorPercent > 2) {
                  publish(widget.topic, 'Fix25R');
                }

                _valueDoorPercen = 2;
              });
            },
            child: Text(
              '25',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                if (_valueSensorPercent < 3) {
                  publish(widget.topic, 'Fix50F');
                } else if (_valueSensorPercent > 3) {
                  publish(widget.topic, 'Fix50R');
                }
                _valueDoorPercen = 3;
              });
            },
            child: Text(
              '50',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                if (_valueSensorPercent < 4) {
                  publish(widget.topic, 'Fix75F');
                } else if (_valueSensorPercent > 4) {
                  publish(widget.topic, 'Fix75R');
                }
                _valueDoorPercen = 4;
              });
            },
            child: Text(
              '75',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                if (_valueSensorPercent < 5) {
                  publish(widget.topic, 'Fix100F');
                } else {}
                _valueDoorPercen = 5;
              });
            },
            child: Text(
              '100',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  ButtonTap() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: custom_theme.Theme.MainTheme,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_sharp),
              color: Colors.white,
              onPressed: () {
                publish(widget.topic, 'RD');
              },
            )),
        Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: custom_theme.Theme.MainTheme,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.stop),
              color: Colors.white,
              onPressed: () {
                publish(widget.topic, 'ST');
              },
            )),
        Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: custom_theme.Theme.MainTheme,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_forward_ios_sharp),
              color: Colors.white,
              onPressed: () {
                publish(widget.topic, 'FD');
              },
            )),
      ],
    );

    // Switch(
    //     value: _swing,
    //     onChanged: (newStatus) {
    //       setState(() {
    //         _swing = newStatus;
    //       });
    //       sendMqtt(_temp, _valueDoorPercen
    //, _swing);
    //     });
  }

  cctv() {
    return StreamBuilder(
      stream: channel.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator(
            color: Colors.greenAccent,
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return const Center(
            child: Text("Connection Closed !"),
          );
        }
        //? Working for single frames
        return Builder(builder: (context) {
          List<int> list = snapshot.data
              .toString()
              .replaceAll('[', '')
              .replaceAll(']', '')
              .split(',')
              .map<int>((e) {
            return int.parse(
                e); //use tryParse if you are not confirm all content is int or require other handling can also apply it here
          }).toList();

          return Container(
            height: 180,
            width: MediaQuery.of(context).size.width * 0.9,
            child: Image.memory(
              Uint8List.fromList(list),
              gaplessPlayback: true,
              fit: BoxFit.cover,
            ),
          );
        });
      },
    );
    // Container(
    //   height: 180,
    //   width: MediaQuery.of(context).size.width * 0.9,
    //   decoration: BoxDecoration(
    //     border: Border.all(color: custom_theme.Theme.MainTheme, width: 1),
    //   ),
    //   alignment: Alignment.center,
    //   child: WebView(
    //     initialUrl: 'http://35.240.190.171:8800/client',
    //     javascriptMode: JavascriptMode.unrestricted,
    //     initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
    //   ),
    // );
  }

  Padding header() {
    return Padding(
      padding: const EdgeInsets.only(left: 22.0, right: 22.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.name,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          SizedBox(),
        ],
      ),
    );
  }

  // Container mic() {
  //   return Container(
  //     alignment: Alignment.topRight,
  //     height: MediaQuery.of(context).size.height,
  //     width: MediaQuery.of(context).size.width,
  //     child: AvatarGlow(
  //       endRadius: 50.0,
  //       glowColor: custom_theme.Theme.MainTheme,
  //       animate: _isListening,
  //       duration: const Duration(milliseconds: 2000),
  //       repeatPauseDuration: const Duration(milliseconds: 100),
  //       repeat: true,
  //       child: FloatingActionButton(
  //         backgroundColor: custom_theme.Theme.MainTheme,
  //         foregroundColor: Colors.white,
  //         onPressed: _listen,
  //         child: Icon(_isListening ? Icons.mic : Icons.mic_none),
  //       ),
  //     ),
  //   );
  // }

  // String _text = '';
  // double _confidence = 1.0;
  // void _listen() async {
  //   // log('$_isListening');
  //   // log('$_confidence');

  //   if (!_isListening) {
  //     print('yes');

  //     bool available = await _speech.initialize(
  //       onStatus: (val) {
  //         if (val == 'done') {
  //           setState(() => _isListening = false);

  //           print('onStatuss: $val');
  //         } else {
  //           print('onStatussss: $val');
  //         }
  //       },
  //       onError: (val) {
  //         print('stop');
  //         print('keywoed : $_text');
  //         _speech.stop();
  //         speech_MQTT(_text);
  //         print('onError: $val');
  //       },
  //     );

  //     print('$available');
  //     if (available) {
  //       print('yy');
  //       setState(() => _isListening = true);
  //       _speech.listen(
  //         onResult: (val) {
  //           print('OKYESSER');

  //           setState(
  //             () {
  //               _text = val.recognizedWords;
  //               print('_text >>>>>>>>${_text}');
  //               print('confidence >>>>>>>>${val.confidence}');
  //               print('hasConfidenceRating >>>>>>>>${val.hasConfidenceRating}');
  //               if (val.hasConfidenceRating == true) {
  //                 _confidence = val.confidence;
  //                 print('$_confidence');
  //                 print('keywoed : $_text');
  //                 print('stop');
  //                 _isListening = false;
  //                 _speech.stop();

  //                 speech_MQTT(_text);
  //               }
  //             },
  //           );
  //         },
  //       );
  //     }
  //   } else {
  //     print('stop');
  //     setState(() => _isListening = false);
  //     _speech.stop();

  //     print('$_text');
  //   }
  // }

  // void speech_MQTT(String? keyword) {
  //   keyword = keyword?.toLowerCase();
  //   print('speech_MQTT');
  //   bool check = false;
  //   String? mes;
  //   if (keyword == '' || keyword == null) {
  //     print('>>> null');
  //   } else {
  //     switch (keyword) {
  //       case 'zero':
  //         {
  //           if (_valueSensorPercent > 1) {
  //             publish(widget.topic, 'Fix0R');
  //           } else {}
  //           _valueDoorPercen = 1;
  //         }
  //         break;
  //       case '0':
  //         {
  //           if (_valueSensorPercent > 1) {
  //             publish(widget.topic, 'Fix0R');
  //           } else {}
  //           _valueDoorPercen = 1;
  //         }
  //         break;
  //       case '25':
  //         {
  //           if (_valueSensorPercent < 2) {
  //             publish(widget.topic, 'Fix25F');
  //           } else if (_valueSensorPercent > 2) {
  //             publish(widget.topic, 'Fix25R');
  //           }
  //           _valueDoorPercen = 2;
  //         }
  //         break;
  //       case '50':
  //         {
  //           if (_valueSensorPercent < 3) {
  //             publish(widget.topic, 'Fix50F');
  //           } else if (_valueSensorPercent > 3) {
  //             publish(widget.topic, 'Fix50R');
  //           }
  //           _valueDoorPercen = 3;
  //         }
  //         break;
  //       case '75':
  //         {
  //           if (_valueSensorPercent < 4) {
  //             publish(widget.topic, 'Fix75F');
  //           } else if (_valueSensorPercent > 4) {
  //             publish(widget.topic, 'Fix75R');
  //           }
  //           _valueDoorPercen = 4;
  //         }
  //         break;
  //       case '100':
  //         {
  //           if (_valueSensorPercent < 5) {
  //             publish(widget.topic, 'Fix100F');
  //           } else {}
  //           _valueDoorPercen = 5;
  //         }
  //         break;
  //       default:
  //         {
  //           check = false;
  //         }
  //     }
  //     setState(() {});
  //     // if (check == true) {
  //     //   print('>>> Notnull');
  //     //   if (mes == 'on') {
  //     //     sendMqtt(25, 1.0, true);
  //     //   } else if (mes == 'off') {
  //     //     //    publishAirS('OFF');
  //     //   } else {
  //     //     print(mes);
  //     //   }
  //     // } else {
  //     //   print('cc');
  //     // }
  //   }
  // }
}
