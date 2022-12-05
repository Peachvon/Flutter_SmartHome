// ignore_for_file: prefer_const_constructors
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:smarthome/src/config/theme.dart' as custom_theme;
import 'package:smarthome/src/screen/shared_widget.dart';
import 'package:smarthome/src/service/mqtt_connect/matt_connect.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:avatar_glow/avatar_glow.dart';

class AirScreen extends StatefulWidget {
  const AirScreen(
      {Key? key,
      required this.name,
      required this.ip,
      required this.topic,
      required this.brand})
      : super(key: key);

  final String name;
  final String ip;
  final String topic;
  final String brand;

  @override
  State<AirScreen> createState() => _AirScreenState();
}

void x() {
  print('najanaja');
}

class _AirScreenState extends State<AirScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  Color _ColorStatusConnec = Colors.red;
  int _temp = 25;
  //int _wind = 2;
  bool _swing = true;
  var _valueTemp = 25.0;
  var _valueFan = 2.0;

  String _labelTemp = '25.0';
  String _labelFan = 'Medium';

  void SUB() async {
    client!.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

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
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    setMQTT();
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
        title: Text('$_text'),
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
              OnOff(),
              Spacer(flex: 1),
              temp(),
              SizedBox(height: 10),
              SliderTemp(),
              UpDownTemp(),
              Spacer(flex: 4),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.air),
                  ],
                ),
              ),
              SliderWind(),
              Spacer(flex: 1),
              Wind(),
              Spacer(flex: 1),
              Swing(),
              Spacer(flex: 7),
            ],
          ),
          mic(),
        ],
      ),
    );
  }

  Slider SliderTemp() {
    return Slider(
      value: _valueTemp,
      min: 18,
      max: 27,
      divisions: 9,
      activeColor: custom_theme.Theme.MainTheme,
      inactiveColor: Colors.black,
      label: _labelTemp,
      onChanged: (newValue) {
        setState(() {
          _valueTemp = newValue;
          _temp = _valueTemp.toInt();
          _labelTemp = _temp.toString();
          print(_valueTemp);
        });
      },
      onChangeEnd: (newValue) {
        sendMqtt(_temp, _valueFan, _swing);
        print('_valueTemp');
      },
      // label: _labelFan,
    );
  }

  Row OnOff() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 22.0),
          child: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: custom_theme.Theme.MainTheme,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                publish(widget.topic, 'DOFF');
                print('send off');
              },
              icon: Icon(
                Icons.power_settings_new,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Slider SliderWind() {
    return Slider(
      value: _valueFan,
      min: 1,
      max: 3,
      divisions: 2,
      activeColor: custom_theme.Theme.MainTheme,
      inactiveColor: Colors.black,
      onChanged: (newValue) {},
      label: _labelFan,
    );
  }

  Padding Wind() {
    ChangedWind(int Chang) {
      setState(() {
        _valueFan = Chang.toDouble();

        switch (_valueFan.toInt().toString()) {
          case '1':
            {
              _labelFan = 'Low';
            }
            break;
          case '2':
            {
              _labelFan = 'Medium';
            }
            break;
          case '3':
            {
              _labelFan = 'High';
            }

            break;
          default:
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          InkWell(
            onTap: () {
              ChangedWind(1);
              sendMqtt(_temp, _valueFan, _swing);
            },
            child: Text(
              'Low',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
          ),
          InkWell(
            onTap: () {
              ChangedWind(2);
              sendMqtt(_temp, _valueFan, _swing);
            },
            child: Text(
              'Mid',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
          ),
          InkWell(
            onTap: () {
              ChangedWind(3);
              sendMqtt(_temp, _valueFan, _swing);
            },
            child: Text(
              'High',
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

  Container Swing() {
    return Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: custom_theme.Theme.MainTheme,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(_swing ? Icons.swipe_down : Icons.swipe),
          color: Colors.white,
          onPressed: () {
            if (_swing == true) {
              _swing = false;
            } else {
              _swing = true;
            }
            setState(() {
              sendMqtt(_temp, _valueFan, _swing);
            });
          },
        ));

    // Switch(
    //     value: _swing,
    //     onChanged: (newStatus) {
    //       setState(() {
    //         _swing = newStatus;
    //       });
    //       sendMqtt(_temp, _valueFan, _swing);
    //     });
  }

  Row UpDownTemp() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      // ignore: prefer_const_literals_to_create_immutables
      children: [
        TextButton(
          onPressed: () {
            if (_temp > 18 && _temp <= 27) {
              setState(() {
                _valueTemp -= 1;
                _temp -= 1;
              });
            }
            sendMqtt(_temp, _valueFan, _swing);
          },
          child: Text(
            '-',
            style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w400,
                color: custom_theme.Theme.MainTheme),
          ),
        ),
        Text(
          'Temper',
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.w700, color: Colors.black),
        ),
        TextButton(
          onPressed: () {
            if (_temp >= 18 && _temp < 27) {
              setState(() {
                _valueTemp += 1;
                _temp += 1;
              });
            }
            sendMqtt(_temp, _valueFan, _swing);
          },
          child: Text(
            '+',
            style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w400,
                color: custom_theme.Theme.MainTheme),
          ),
        ),
      ],
    );
  }

  Container temp() {
    return Container(
      height: 160,
      width: 160,
      decoration: BoxDecoration(
        border: Border.all(color: custom_theme.Theme.MainTheme, width: 1),
        borderRadius: BorderRadius.circular(100),
      ),
      alignment: Alignment.center,
      child: Text(
        '${_temp.toString()}c',
        style: TextStyle(fontSize: 48, color: Colors.black),
      ),
    );
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

  Container mic() {
    return Container(
      alignment: Alignment.topRight,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: AvatarGlow(
        endRadius: 50.0,
        glowColor: custom_theme.Theme.MainTheme,
        animate: _isListening,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          backgroundColor: custom_theme.Theme.MainTheme,
          foregroundColor: Colors.white,
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
    );
  }

  String _text = '';
  double _confidence = 1.0;
  void _listen() async {
    // log('$_isListening');
    // log('$_confidence');

    if (!_isListening) {
      print('yes');

      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done') {
            setState(() => _isListening = false);

            print('onStatuss: $val');
          } else {
            print('onStatussss: $val');
          }
        },
        onError: (val) {
          print('stop');
          print('keywoed : $_text');
          _speech.stop();
          speech_MQTT(_text);
          print('onError: $val');
        },
      );

      print('$available');
      if (available) {
        print('yy');
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            print('OKYESSER');

            setState(
              () {
                _text = val.recognizedWords;
                print('_text >>>>>>>>${_text}');
                print('confidence >>>>>>>>${val.confidence}');
                print('hasConfidenceRating >>>>>>>>${val.hasConfidenceRating}');
                if (val.hasConfidenceRating == true) {
                  _confidence = val.confidence;
                  print('$_confidence');
                  print('keywoed : $_text');
                  print('stop');
                  _isListening = false;
                  _speech.stop();

                  speech_MQTT(_text);
                }
              },
            );
          },
        );
      }
    } else {
      print('stop');
      setState(() => _isListening = false);
      _speech.stop();

      print('$_text');
    }
  }

  void speech_MQTT(String? keyword) {
    keyword = keyword?.toLowerCase();
    print('speech_MQTT');
    bool check = false;
    String? mes;
    if (keyword == '' || keyword == null) {
      print('>>> null');
    } else {
      switch (keyword) {
        case 'on':
          {
            _valueTemp = 25;

            _temp = 25;
            sendMqtt(25, 1.0, true);
          }
          break;
        case 'เปิด':
          {
            _valueTemp = 25;

            _temp = 25;
            sendMqtt(25, 1.0, true);
          }
          break;
        case 'off':
          {
            publish(widget.topic, 'DOFF');
          }
          break;
        case 'ปิด':
          {
            publish(widget.topic, 'DOFF');
          }
          break;
        case '18':
          {
            _temp = 18;
            sendMqtt(_temp, _valueFan, _swing);
          }
          break;
        case '17':
          {
            _temp = 18;
            sendMqtt(_temp, _valueFan, _swing);
          }
          break;
        case '19':
          {
            _temp = 19;
            sendMqtt(_temp, _valueFan, _swing);
          }
          break;
        case '20':
          {
            _temp = 20;
            sendMqtt(_temp, _valueFan, _swing);
          }
          break;
        case '21':
          {
            _temp = 21;
            sendMqtt(_temp, _valueFan, _swing);
          }

          break;
        case '22':
          {
            _temp = 22;
            sendMqtt(_temp, _valueFan, _swing);
          }

          break;
        case '23':
          {
            _temp = 23;
            sendMqtt(_temp, _valueFan, _swing);
          }

          break;
        case '24':
          {
            _temp = 24;
            sendMqtt(_temp, _valueFan, _swing);
          }

          break;
        case '25':
          {
            _temp = 25;
            sendMqtt(_temp, _valueFan, _swing);
          }

          break;
        case '26':
          {
            _temp = 26;
            sendMqtt(_temp, _valueFan, _swing);
          }

          break;
        case '27':
          {
            _temp = 27;
            sendMqtt(_temp, _valueFan, _swing);
          }

          break;
        case 'สูง':
          {
            _valueFan = 3;
            _labelFan = 'High';
            sendMqtt(_temp, _valueFan, _swing);
          }

          break;
        case 'กลาง':
          {
            _valueFan = 2;
            _labelFan = 'Medium';
            sendMqtt(_temp, _valueFan, _swing);
          }

          break;
        case 'ต่ำ':
          {
            _valueFan = 1;
            _labelFan = 'Low';
            sendMqtt(_temp, _valueFan, _swing);
          }

          break;
        case 'High':
          {
            _valueFan = 3;
            _labelFan = 'High';
            sendMqtt(_temp, _valueFan, _swing);
          }

          break;
        case 'Medium':
          {
            _valueFan = 2;
            _labelFan = 'Medium';
            sendMqtt(_temp, _valueFan, _swing);
          }

          break;
        case 'Low':
          {
            _valueFan = 1;
            _labelFan = 'Low';
            sendMqtt(_temp, _valueFan, _swing);
          }

          break;
        default:
          {
            check = false;
          }
      }
      setState(() {});
      // if (check == true) {
      //   print('>>> Notnull');
      //   if (mes == 'on') {
      //     sendMqtt(25, 1.0, true);
      //   } else if (mes == 'off') {
      //     //    publishAirS('OFF');
      //   } else {
      //     print(mes);
      //   }
      // } else {
      //   print('cc');
      // }
    }
  }
}
