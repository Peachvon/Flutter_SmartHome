import 'dart:developer';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:mqtt_app/src/config/config.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

MqttServerClient? client;

class _MyHomePageState extends State<MyHomePage> {
  // High
  final Map<String, HighlightedWord> _highlights = {
    'on': HighlightedWord(
      onTap: () => print('on'),
      textStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
    ),
    'off': HighlightedWord(
      onTap: () => print('off'),
      textStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
  };

  // voice
  late stt.SpeechToText _speech;
  bool _isListening = false
  ;
  String _text = 'on/off';
  double _confidence = 1.0;



  mqttConnect() async {
    //init client
    client = new MqttServerClient('35.240.190.171', 'Flutter_test');
    client!.port = 1883;
    client!.keepAlivePeriod = 60;
    client!.autoReconnect = true;
    client!.onConnected = onConnected;
    client!.onDisconnected = onDisconnected;

// connect MQTT
    try {
      await client!.connect();
    } on NoConnectionException catch (e) {
      log(e.toString());
    }
    // Let,s subscribe

    client!.subscribe('/IRDD', MqttQos.exactlyOnce);

    client!.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      if (pt == "STP0") {
        setState(() {
          _valueRF = 0;
        });
      } else if (pt == "STP25") {
        setState(() {
          _valueRF = 1;
        });
      } else if (pt == "STP50") {
        setState(() {
          _valueRF = 2;
        });
      } else if (pt == "STP75") {
        setState(() {
          _valueRF = 3;
        });
      } else if (pt == "STP100") {
        setState(() {
          _valueRF = 4;
        });
      }
      print(_valueRF);
      print(pt);
    });
  }

  void onDisconnected() {
    log('onDisconnected');
  }

  void onConnected() {
    log('Connected');
  }

  void publish(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client!.publishMessage('/IRDD', MqttQos.exactlyOnce, builder.payload!);
  }

  void publishAir(double tem, double fanspeed, bool swing) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    var playload1 = '';
    var playload2 = '';
    var playload3 = '';
    var playloadAll = '';

    int temInt = tem.toInt();

    if (tem == 18 || tem == 27) {
    } else {
      temInt = temInt + 1;
    }
    playload1 = temInt.toString();

    if (fanspeed == 1) {
      playload2 = 'L';
    } else if (fanspeed == 2) {
      playload2 = 'M';
    } else {
      playload2 = 'H';
    }

    if (swing == true) {
      playload3 = 'Y';
    } else {
      playload3 = 'N';
    }

    playloadAll = 'D' + playload1 + playload2 + playload3;

    builder.addString(playloadAll);
    client!.publishMessage('/IRDD', MqttQos.exactlyOnce, builder.payload!);
    log(playloadAll);
  }

  void publishRf(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client!.publishMessage('/I', MqttQos.exactlyOnce, builder.payload!);
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    mqttConnect();
  }

  bool _isVisibleAir = true;
  bool _isVisibleHome = false;
  var _tem = 24.1;
  var _valueFan = 1.0;
  var _valueRF = 0.0;
  bool _status = false;
  String _labelFan = 'Low';
  String _labelRF = '0%';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Container(
          child: ListView(children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            topAppBar(),
            SizedBox(height: 24),
            Container(
              height: 140,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[listItem1(), listItem2()],
              ),
            ),
          ],
        ),
        TextHighlight(
          text: _text,
          words: _highlights,
          textStyle: const TextStyle(
            fontSize: 24.0,
            color: Colors.white,
            fontWeight: FontWeight.w400
          ),
        ),
        air(),
        homerf()
      ])),
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
    );
  }
// _listen

  void _listen() async {
    log('$_isListening');
    log('$_confidence');



    if (!_isListening) {
      log('yes');

      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),

      );
      log('$available');
      if (available) {
        log('yy');
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      log('n');

      setState(() => _isListening = false);
      _speech.stop();
    }
  }
//Air

  air() {
    return Visibility(
        visible: _isVisibleAir,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              TempSlider(),
              SizedBox(height: 20),
              Text('Fan speed',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
              SizedBox(height: 10),
              Slider(
                value: _valueFan,
                min: 1,
                max: 3,
                divisions: 2,
                activeColor: activeColor1,
                inactiveColor: Colors.black,
                onChanged: (newValue) {
                  setState(() {
                    _valueFan = newValue;
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
                },
                label: _labelFan,
              ),
              Text('Swing',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              Switch(
                  value: _status,
                  onChanged: (newStatus) {
                    setState(() {
                      _status = newStatus;
                      log(_status.toString());
                    });
                  }),
              SizedBox(height: 5),
              iconSwithAir(),
            ]));
  }

//Home RF
  homerf() {
    return Visibility(
        visible: _isVisibleHome,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 150),
              Text('HomeRF',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
              SizedBox(height: 20),
              Slider(
                value: _valueRF,
                min: 0,
                max: 4,
                divisions: 4,
                activeColor: activeColor1,
                inactiveColor: Colors.black,
                onChanged: (newValue) {
                  setState(() {
                    switch (_valueRF.toInt().toString()) {
                      case '0':
                        {
                          _labelRF = '0%';
                        }
                        break;
                      case '1':
                        {
                          _labelRF = '25%';
                        }
                        break;
                      case '2':
                        {
                          _labelRF = '50%';
                        }
                        break;
                      case '3':
                        {
                          _labelRF = '75%';
                        }
                        break;
                      case '4':
                        {
                          _labelRF = '100%';
                        }

                        break;
                      default:
                    }
                  });
                },
                label: _labelRF,
              ),
              SizedBox(height: 30),
              iconPerRF(),
              iconSwithRF(),
            ]));
  }

// on|off
  iconSwithAir() {
    return InkWell(
        borderRadius: BorderRadius.all(Radius.circular(100)),
        onTap: () => {publishAir(_tem, _valueFan, _status)},
        child: Container(
          height: MediaQuery.of(context).size.width * 0.4,
          width: MediaQuery.of(context).size.width * 0.4,
          child: Center(
              child: Icon(Icons.power_settings_new,
                  color: activeColor2, size: 80)),
        ));
  }

  iconSwithRF() {
    return Padding(
        padding: EdgeInsets.all(0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            InkWell(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                onTap: () => {publishRf('RD')},
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.3,
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Center(
                      child: Icon(Icons.chevron_left,
                          color: activeColor2, size: 100)),
                )),
            InkWell(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                onTap: () => {publishRf('ST')},
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.3,
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Center(
                      child: Icon(Icons.do_disturb,
                          color: activeColor2, size: 80)),
                )),
            InkWell(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                onTap: () => {publishRf('FD')},
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.3,
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Center(
                      child: Icon(Icons.chevron_right,
                          color: activeColor2, size: 100)),
                ))
          ],
        ));
  }

  iconPerRF() {
    return Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            InkWell(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                onTap: () => {publishRf('Fix0R')},
                child: Container(
                    decoration: BoxDecoration(
                        color: activeColor2,
                        borderRadius: BorderRadius.all(Radius.circular(100))),
                    height: MediaQuery.of(context).size.width * 0.15,
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: Center(
                      child: Text(
                        '0%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ))),
            InkWell(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                onTap: () => {
                      if (_valueRF < 1)
                        {publishRf('Fix25F')}
                      else if (_valueRF > 1)
                        {publishRf('Fix25R')}
                    },
                child: Container(
                    decoration: BoxDecoration(
                        color: activeColor2,
                        borderRadius: BorderRadius.all(Radius.circular(100))),
                    height: MediaQuery.of(context).size.width * 0.15,
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: Center(
                      child: Text(
                        '25%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ))),
            InkWell(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                onTap: () => {
                      if (_valueRF < 2)
                        {publishRf('Fix50F')}
                      else if (_valueRF > 2)
                        {publishRf('Fix50R')}
                    },
                child: Container(
                    decoration: BoxDecoration(
                        color: activeColor2,
                        borderRadius: BorderRadius.all(Radius.circular(100))),
                    height: MediaQuery.of(context).size.width * 0.15,
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: Center(
                      child: Text(
                        '50%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ))),
            InkWell(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                onTap: () => {
                      if (_valueRF < 3)
                        {publishRf('Fix75F')}
                      else if (_valueRF > 3)
                        {publishRf('Fix75R')}
                    },
                child: Container(
                    decoration: BoxDecoration(
                        color: activeColor2,
                        borderRadius: BorderRadius.all(Radius.circular(100))),
                    height: MediaQuery.of(context).size.width * 0.15,
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: Center(
                      child: Text(
                        '75%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ))),
            InkWell(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                onTap: () => {
                      if (_valueRF < 4)
                        {publishRf('Fix100F')}
                      else if (_valueRF > 4)
                        {publishRf('Fix100R')}
                    },
                child: Container(
                    decoration: BoxDecoration(
                        color: activeColor2,
                        borderRadius: BorderRadius.all(Radius.circular(100))),
                    height: MediaQuery.of(context).size.width * 0.15,
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: Center(
                      child: Text(
                        '100%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )))
          ],
        ));
  }

  // fanspeed
  fanspeedSlider() {}

//TempSlider
  TempSlider() {
    return ClayContainer(
      height: 200,
      width: 200,
      color: primaryColor,
      borderRadius: 200,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: SleekCircularSlider(
          min: 18,
          max: 27,
          initialValue: _tem,
          appearance: CircularSliderAppearance(
              customColors: CustomSliderColors(
                progressBarColors: gradientColors,
                hideShadow: true,
                shadowColor: Colors.transparent,
              ),
              infoProperties: InfoProperties(
                  mainLabelStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                  modifier: (double value) {
                    final roundedValue = value.ceil().toInt().toString();
                    return '$roundedValue \u2103';
                  })),
          onChange: (double value) {
            setState(() {
              _tem = value;
            });
            print(_tem);
          },
        ),
      ),
    );
  }

// Custom App Bar
  topAppBar() {
    return Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ClayContainer(
              height: 40,
              width: 40,
              borderRadius: 20,
              color: primaryColor,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Center(
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
            Text('Air Mqtt',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 26)),
            ClayContainer(
              height: 40,
              width: 40,
              borderRadius: 20,
              color: primaryColor,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            )
          ],
        ));
  }

// listItems
  listItem1() {
    return GestureDetector(
        onTap: () => {
              setState(() {
                backgroundListItem1 = gradientColors;
                backgroundListItem2 = gradientColorsOff;
                _isVisibleAir = true;
                _isVisibleHome = false;
              })
            },
        child: Container(
            padding: EdgeInsets.all(16),
            child: ClayContainer(
              height: 100,
              width: MediaQuery.of(context).size.width * 0.7,
              borderRadius: 12,
              color: primaryColor,
              child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: backgroundListItem1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: ListTile(
                      leading: Icon(
                        Icons.tablet,
                        color: Colors.white,
                        size: 34,
                      ),
                      title: Text(
                        'Air',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                      subtitle: Text('AirSumsung',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 15,
                          )),
                    ),
                  )),
            )));
  }

  listItem2() {
    return GestureDetector(
        onTap: () => {
              setState(() {
                backgroundListItem1 = gradientColorsOff;
                backgroundListItem2 = gradientColors;
                _isVisibleAir = false;
                _isVisibleHome = true;
              })
            },
        child: Container(
            padding: EdgeInsets.all(16),
            child: ClayContainer(
                height: 100,
                width: MediaQuery.of(context).size.width * 0.7,
                borderRadius: 12,
                color: primaryColor,
                child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: backgroundListItem2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(6),
                        child: ListTile(
                          leading:
                              Icon(Icons.tv, color: Colors.white, size: 34),
                          title: Text(
                            'Home RF',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22),
                          ),
                          subtitle: Text(
                            'RF ID 0-100%',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                          ),
                        ))))));
  }
}
