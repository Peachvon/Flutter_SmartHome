import 'dart:math';
import 'package:smarthome/src/screen/home/air/air_screen.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
//import 'dart:developer';

MqttServerClient? client;

void onDisconnected() {
  print('onDisconnected');
}

void onConnected() {
  print('Connected');
}

mqttConnect(String IP, String? topic) async {
  String username = 'user';
  for (var i = 0; i < 10; i++) {
    username += Random().nextInt(10).toString();
  }
  print(username);
  //init client
  client = new MqttServerClient(IP, username);
  client!.port = 1883;
  client!.keepAlivePeriod = 60;
  client!.autoReconnect = true;
  client!.onConnected = onConnected;
  client!.onDisconnected = onDisconnected;

// connect MQTT
  try {
    await client!.connect();
    x();
  } on NoConnectionException catch (e) {
    print(e.toString());
  }
  // Let,s subscribe
  if (topic != null) {
    client!.subscribe(topic, MqttQos.exactlyOnce);
  }
  // client!.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
  //   final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
  //   final String pt =
  //       MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
  // if (pt == "STP0") {
  //   setState(() {
  //     _valueRF = 0;
  //   });
  // } else if (pt == "STP25") {
  //   setState(() {
  //     _valueRF = 1;
  //   });
  // } else if (pt == "STP50") {
  //   setState(() {
  //     _valueRF = 2;
  //   });
  // } else if (pt == "STP75") {
  //   setState(() {
  //     _valueRF = 3;
  //   });
  // } else if (pt == "STP100") {
  //   setState(() {
  //     _valueRF = 4;
  //   });
  // }
  // print(_valueRF);
  //   print(pt);
  // });
}

void disconnectMqtt() {
  client!.disconnect();
}

void publish(String topic, String message) {
  final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
  builder.addString(message);
  client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
}


    

  // void ss() {
  //   client!.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
  //     final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
  //     final String pt =
  //         MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
  //     if (pt == "STP0") {
  //       setState(() {
  //         _valueRF = 0;
  //       });
  //     } else if (pt == "STP25") {
  //       setState(() {
  //         _valueRF = 1;
  //       });
  //     } else if (pt == "STP50") {
  //       setState(() {
  //         _valueRF = 2;
  //       });
  //     } else if (pt == "STP75") {
  //       setState(() {
  //         _valueRF = 3;
  //       });
  //     } else if (pt == "STP100") {
  //       setState(() {
  //         _valueRF = 4;
  //       });
  //     }
  //     print(_valueRF);
  //     print(pt);
  //   });
  // }