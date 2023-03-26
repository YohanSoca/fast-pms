import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../mqtt/mqtt_handler.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({Key? key}) : super(key: key);

  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> {
  MQTTClientManager mqttClientManager = MQTTClientManager();
  final String pubTopic = "fast-pms/sources/data/mobile";
  List<String> received_message = [];
  late AnimationController animationController;
  int _counter = 0;
  late DocumentSnapshot snapshot;

  Future<void> uploadingData(String _productName, String _productPrice,
      String _imageUrl, bool _isFavourite) async {
    await FirebaseFirestore.instance.collection("logs").add({
      'productName': _productName,
      'productPrice': _productPrice,
      'imageUrl': _imageUrl,
      'isFavourite': _isFavourite,
    });
  }
  @override
  void initState() {
    super.initState();
    setupMqttClient();
    setupUpdatesListener();

    uploadingData('Pan con leche', '99', 'assets/images/gen.pns', true);
  }

  bool checkBit(int value, int bit) => (value & (1 << bit)) != 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Registers'),),
        body: mqttClientManager.client.connectionStatus!.state == MqttConnectionState.connected && received_message.length > 10 ?
        ModeItems(received_message) : WaitingScreem(mqttClientManager)
    );
  }

  Future<void> setupMqttClient() async {
    await mqttClientManager.connect();
    mqttClientManager.subscribe(pubTopic);
    setState(() {
      if(mqttClientManager.client.connectionStatus!.state == MqttConnectionState.connected) {
        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text("connected"), duration: Duration(milliseconds: 300),));
      }
    });
  }

  void _publishToBroker(String topic) {
    setState(() {
      _counter++;
      mqttClientManager.publishMessage(topic, "Shore online requested");

    });
  }

  void setupUpdatesListener() {
    mqttClientManager
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
      setState(() {
        if(mqttClientManager.client.connectionStatus!.state == MqttConnectionState.connected) {
          received_message = pt.split(',');
        }
      });
    });
  }
  @override
  void dispose() {
    mqttClientManager.disconnect();
    super.dispose();
  }
}

class ModeItems extends StatelessWidget {
  final List<String> payload;
  const ModeItems(this.payload, {Key? key}) : super(key: key);

  bool checkBit(int value, int bit) => (value & (1 << bit)) != 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Shore A: ${payload.sublist(0, 12)}', style: TextStyle(fontSize: 16),),
          Text('Gen A: ${payload.sublist(13, 25)}', style: TextStyle(fontSize: 16),),
          Text('Shore B: ${payload.sublist(25, 38)}', style: TextStyle(fontSize: 16),),
          Text('Gen B: ${payload.sublist(38, 51)}', style: TextStyle(fontSize: 16),),
        ],
      ),
    );
  }
}


class WaitingScreem extends StatefulWidget {
  final MQTTClientManager _mqttClientManager;
  const WaitingScreem(this._mqttClientManager, {Key? key}) : super(key: key);

  @override
  State<WaitingScreem> createState() => _WaitingScreemState();
}

class _WaitingScreemState extends State<WaitingScreem> {
  late Timer timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timer = Timer(const Duration(seconds: 5), () {
      setState(() {
        widget._mqttClientManager;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}


