// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smarthome/shared_widget/dialog.dart';
import 'package:smarthome/src/config/theme.dart' as custom_theme;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthome/src/models/device_model.dart';
import 'package:smarthome/src/screen/home/home.dart';
import 'package:http/http.dart' as http;

class AddItem extends StatefulWidget {
  const AddItem({Key? key}) : super(key: key);

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  List<Map> item = [];

  Check() {
    _errorName = null;
    _errorCode = null;
    _errorPassword = null;
    _errorData = null;

    if (nameController.text == '') {
      _errorName = 'กรุณาใส่ชื่ออุปกรณ์';
    }
    if (codeController.text == '') {
      _errorCode = 'กรุณาใส่หมายเลขอุปกรณ์';
    }

    if (typeValue == '0') {
      _errorData = 'เลือกชนิดอุปกรณ์';
    }

    if (passwordController.text == '') {
      _errorPassword = 'กรุณาใส่รหัสผ่านอุปกรณ์';
    }
    setState(() {});
    if (_errorName == null &&
        _errorCode == null &&
        _errorPassword == null &&
        _errorData == null) {
      return true;
    } else if (_errorData == null) {
      _errorData = 'กรุณากรอกข้อมูลให้ครบ';
      return false;
    } else {
      return false;
    }
  }

  AddItem() async {
    String JsonString = '';
    List<String> listItem = [];
    Map mapItem = {
      'Name': nameController.text,
      'Type': typeValue,
      'IP': Device!.ip,
      'Topic': Device!.topic,
      'Brand': Device!.model
    };
    // Map mapItem = {
    //   'Name': nameController.text,
    //   'Type': typeValue,
    //   'IP': "35.240.190.171",
    //   'Topic': "/RFID",
    //   'Brand': "bsm"
    // };

    print(mapItem);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? itemValue = prefs.getStringList('item');

    if (itemValue != null) {
      itemValue.add(jsonEncode(mapItem));

      prefs.setStringList('item', itemValue);
    } else {
      listItem.add(jsonEncode(mapItem));

      prefs.setStringList('item', listItem);
    }
    // itemValue = prefs.getStringList('item');
    // print(itemValue!.length);
    //prefs.clear();
    //  prefs.setStringList('cart', listItem);
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          void push() {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
                (route) => false);
          }

          return DialogCustomWidget(
            titleColor: custom_theme.Theme.MainTheme,
            title: 'สำเร็จ',
            content: 'เพิ่มอุปกรณืสำเร็จแล้ว',
            status: 'success',
            buttom1: 'ตกลง',
            func1: push,
          );
        });
  }

  ////////
  var nameController = new TextEditingController();
  var codeController = new TextEditingController();
  var passwordController = new TextEditingController();

  String typeValue = '0';

  String? _errorName;
  String? _errorCode;
  String? _errorPassword;
  String? _errorData;

  _setStringToSharedPreferences($key, $text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString($key, $text);
  }

  _getStringFromSharedPreferences($key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String? stringValue = prefs.getString($key);
    return stringValue;
  }

  DeviceModel? Device;
  Future AddDevice() async {
    var url = Uri.parse(
        'http://localhost:3001/add_item?model=${typeValue}&id=${codeController.text}&password=${passwordController.text}');
    var response = await http.get(url);
    print(response.body);
    if (response.statusCode == 200) {
      Device = deviceModelFromJson(response.body);
      print(Device!.status);
      if (Device!.status == 'success') {
        AddItem();
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: custom_theme.Theme.MainTheme,
        title: Text('เพิ่มอุปกรณ์'),
      ),
      body: Center(
        // ignore: prefer_const_literals_to_create_immutables
        child: Column(children: [
          Text('ใส่รายละเอียดตามคู่มือ'),
          // ignore: prefer_const_constructors
          TextField(
            keyboardType: TextInputType.text,
            controller: nameController,
            onChanged: (value) {},
            decoration: InputDecoration(
                labelText: 'ชื่ออุปกรณ์',
                icon: Icon(Icons.device_unknown),
                errorText: _errorName),
          ),
          TextField(
            //keyboardType: TextInputType.values,
            controller: codeController,
            onChanged: (value) {},
            decoration: InputDecoration(
                labelText: 'หมายเลขอุปกรณ์',
                icon: Icon(Icons.device_unknown),
                errorText: _errorCode),
          ),
          TextField(
            //keyboardType: TextInputType.values,
            controller: passwordController,
            onChanged: (value) {},
            decoration: InputDecoration(
                labelText: 'รหัสผ่านอุปกรณ์',
                icon: Icon(Icons.device_unknown),
                errorText: _errorPassword),
          ),
          DropdownButton<String>(
            value: typeValue,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 18,
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: custom_theme.Theme.MainTheme,
            ),
            onChanged: (String? newValue) {
              setState(() {
                typeValue = newValue!;
              });
            },
            items: typeMap
                .map((item) => DropdownMenuItem<String>(
                      value: item['key'],
                      child: Text(
                        item['value'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ))
                .toList(),
          ),

          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: custom_theme.Theme.MainTheme,
              ),
              onPressed: () {
                if (Check() == true) {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        void pop() {
                          Navigator.pop(context);
                        }

                        void push() {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyHomePage()),
                              (route) => false);
                        }

                        return FutureBuilder(
                            future: AddDevice(),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data == true) {
                                  return DialogCustomWidget(
                                    titleColor: custom_theme.Theme.MainTheme,
                                    title: 'สำเร็จ',
                                    content: 'เพิ่มอุปกรณืสำเร็จแล้ว',
                                    status: 'success',
                                    buttom1: 'ตกลง',
                                    func1: push,
                                  );
                                } else {
                                  return DialogCustomWidget(
                                    titleColor: Colors.red,
                                    title: 'เกิดข้อผิดพลาด',
                                    content: 'ไม่สามารถเพิ่มอุปกรณ์ได้',
                                    status: 'error',
                                    buttom1: 'ตกลง',
                                    func1: pop,
                                  );
                                }
                              } else {
                                return Container(
                                    alignment: Alignment.center,
                                    height: MediaQuery.of(context).size.height -
                                        kToolbarHeight -
                                        100,
                                    child: CircularProgressIndicator(
                                      color: custom_theme.Theme.MainTheme,
                                    ));
                              }
                            });
                      });
                }
              },
              child: Text('เพิ่มอุปกรณ์'))
        ]),
      ),
    );
  }

  List<Map<String, dynamic>> typeMap = [
    {
      'key': '0',
      'value': '-เลือกประเภท-',
    },
    {
      'key': '1',
      'value': 'แอร์',
    },
    {
      'key': '2',
      'value': 'ประตูอัตโนมัติ',
    },
  ];
}
