import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../mqtt/mqtt_handler.dart';

class ModesScreen extends StatefulWidget {
  const ModesScreen({Key? key}) : super(key: key);

  @override
  State<ModesScreen> createState() => _ModesScreenState();
}

class _ModesScreenState extends State<ModesScreen> {
  MQTTClientManager mqttClientManager = MQTTClientManager();
  final String pubTopic = "fast-pms/status/coils/mobile";
  List<String> received_message = [];
  late AnimationController animationController;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    setupMqttClient();
    setupUpdatesListener();
  }

  bool checkBit(int value, int bit) => (value & (1 << bit)) != 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modes'),),
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
          received_message = pt.split(',') as List<String>;
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
        children: [
          Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: checkBit(int.parse(payload[7]), 3) ? Colors
                      .green : Colors.grey
              ),
              height: 50,
              width: double.infinity,
              child: Center(
                child: Text('Split bus mode: ${checkBit(
                    int.parse(payload[7]), 3) ? 'ON' : 'OFF'}',
                  style: TextStyle(fontSize: 24),),
              )
          ),
          Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: checkBit(int.parse(payload[7]), 4) ? Colors
                      .green : Colors.grey
              ),
              height: 50,
              width: double.infinity,
              child: Center(
                child: Text('Preferred source: ${checkBit(
                    int.parse(payload[7]), 4) ? 'ON' : 'OFF'}',
                  style: TextStyle(fontSize: 24),),
              )
          ),
          Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: checkBit(int.parse(payload[7]), 5) ? Colors
                      .green : Colors.grey
              ),
              height: 50,
              width: double.infinity,
              child: Center(
                child: Text('Preferred Gen: ${checkBit(
                    int.parse(payload[7]), 5) ? 'ON' : 'OFF'}',
                  style: TextStyle(fontSize: 24),),
              )
          ),
          Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: checkBit(int.parse(payload[7]), 6) ? Colors
                      .green : Colors.grey
              ),
              height: 50,
              width: double.infinity,
              child: Center(
                child: Text('Dual Gen: ${checkBit(
                    int.parse(payload[7]), 6) ? 'ON' : 'OFF'}',
                  style: TextStyle(fontSize: 24),),
              )
          ),
          Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: checkBit(int.parse(payload[7]), 7) ? Colors
                      .green : Colors.grey
              ),
              height: 50,
              width: double.infinity,
              child: Center(
                child: Text('Seamless Transfer: ${checkBit(
                    int.parse(payload[7]), 7) ? 'ON' : 'OFF'}',
                  style: TextStyle(fontSize: 24),),
              )
          ),
          Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: checkBit(int.parse(payload[8]), 0) ? Colors
                      .green : Colors.grey
              ),
              height: 50,
              width: double.infinity,
              child: Center(
                child: Text('NBoots Shore A: ${checkBit(
                    int.parse(payload[8]), 0) ? 'ON' : 'OFF'}',
                  style: TextStyle(fontSize: 24),),
              )
          ),
          Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: checkBit(int.parse(payload[8]), 1) ? Colors
                      .green : Colors.grey
              ),
              height: 50,
              width: double.infinity,
              child: Center(
                child: Text('NBoots Shore B: ${checkBit(
                    int.parse(payload[8]), 1) ? 'ON' : 'OFF'}',
                  style: TextStyle(fontSize: 24),),
              )
          ),
          Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: checkBit(int.parse(payload[8]), 2) ? Colors
                      .green : Colors.grey
              ),
              height: 50,
              width: double.infinity,
              child: Center(
                child: Text('Series: ${checkBit(
                    int.parse(payload[8]), 2) ? 'ON' : 'OFF'}',
                  style: TextStyle(fontSize: 24),),
              )
          ),
          Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: checkBit(int.parse(payload[8]), 3) ? Colors
                      .green : Colors.grey
              ),
              height: 50,
              width: double.infinity,
              child: Center(
                child: Text('Preferred swgear: ${checkBit(
                    int.parse(payload[8]), 3) ? 'ON' : 'OFF'}',
                  style: TextStyle(fontSize: 24),),
              )
          ),
          Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: checkBit(int.parse(payload[8]), 4) ? Colors
                      .green : Colors.grey
              ),
              height: 50,
              width: double.infinity,
              child: Center(
                child: Text('Single Shore Combine: ${checkBit(
                    int.parse(payload[8]), 4) ? 'ON' : 'OFF'}',
                  style: TextStyle(fontSize: 24),),
              )
          ),
          Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: checkBit(int.parse(payload[8]), 5) ? Colors
                      .green : Colors.grey
              ),
              height: 50,
              width: double.infinity,
              child: Center(
                child: Text('Split bus off_auto: ${checkBit(
                    int.parse(payload[8]), 5) ? 'ON' : 'OFF'}',
                  style: TextStyle(fontSize: 24),),
              )
          )
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


