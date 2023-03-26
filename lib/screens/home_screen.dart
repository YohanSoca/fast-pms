import 'dart:async';
import 'package:fast_pms_app/mqtt/mqtt_handler.dart';
import 'package:fast_pms_app/screens/port_gen_screen.dart';
import 'package:fast_pms_app/screens/shore_one_screen.dart';
import 'package:fast_pms_app/screens/shore_two_screen.dart';
import 'package:fast_pms_app/screens/stbd_gen_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:mqtt_client/mqtt_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  MQTTClientManager mqttClientManager = MQTTClientManager();
  final String pubTopic = "fast-pms/status/registers/mobile";
  List<String> received_message = [];
  late AnimationController animationController;
  int _counter = 0;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    setupMqttClient();
    setupUpdatesListener();

    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(milliseconds: 2000),
    );
    animationController.forward();
    animationController.addListener(() {
      setState(() {
        if (animationController.status == AnimationStatus.completed) {
          animationController.stop(canceled: true);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    if(mqttClientManager.client.connectionStatus!.state == MqttConnectionState.connected && received_message.length > 35) {
      return MediaQuery.of(context).orientation == Orientation.portrait ?
        PortraitHomeScreen(received_message, animationController) : LandscapeHomeScreen(received_message);
    } else {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red,),
      );
    }
  }

  Future<void> setupMqttClient() async {
    await mqttClientManager.connect();
    mqttClientManager.subscribe(pubTopic);
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
      // print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
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

class LandscapeHomeScreen extends StatefulWidget {
  final List<String> payload;
  const LandscapeHomeScreen(this.payload, {Key? key}) : super(key: key);

  @override
  State<LandscapeHomeScreen> createState() => _LandscapeHomeScreenState();
}

class _LandscapeHomeScreenState extends State<LandscapeHomeScreen> {
  @override
  Widget build(BuildContext context) {
    var available_height = MediaQuery.of(context).size.height;
    var available_width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    width: 80,
                    height: 60,
                    decoration: const BoxDecoration(
                        image: DecorationImage(image: AssetImage("assets/images/Logo.png"),)),
                  ),
                  Container(
                    width: 60,
                    height: 30,
                    decoration: const BoxDecoration(
                        image: DecorationImage(image: AssetImage("assets/images/alert.png"),)),
                  )
                ],
              ),
              Text('Manual mode ON', style: TextStyle(fontSize: 20),),
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 60,
                    decoration: const BoxDecoration(
                        image: DecorationImage(image: AssetImage("assets/images/reset.png"),)),
                  ),
                  Container(
                    width: 80,
                    height: 60,
                    decoration: const BoxDecoration(
                        image: DecorationImage(image: AssetImage("assets/images/Logo.png"),)),
                  )
                ],
              )
            ],
          ),
          // Pms layout
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 0, top: 15),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: Offset(0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        width: available_width / 5,
                        height: available_height / 4,

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(width: 60, child: Image.asset('assets/images/shore_plug.png'),),
                            SizedBox(width: 10,),
                            Container(
                                padding: EdgeInsets.all(6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('400 V', style: TextStyle(fontSize: 22),),
                                    Text('39 A', style: TextStyle(fontSize: 22),),
                                    Text('50 Hz', style: TextStyle(fontSize: 22),),
                                  ],
                                )
                            ),
                          ],
                        ),
                      ),
                      Container(margin: EdgeInsets.only(left: 3), color: Colors.green, height: 20, width: 30,),
                      Transform.rotate(angle: 45, child: Container(
                        color: Colors.grey,
                        width: 40,
                        height: 20,
                      ),),
                      Container(color: Colors.green, height: 20, width: 30,)
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 0, top: 15),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: Offset(0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        width: available_width / 5,
                        height: available_height / 4,

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(width: 60, child: Image.asset('assets/images/generator.png'),),
                            SizedBox(width: 10,),
                            Container(
                                padding: EdgeInsets.all(6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('400 V', style: TextStyle(fontSize: 22),),
                                    Text('39 A', style: TextStyle(fontSize: 22),),
                                    Text('50 Hz', style: TextStyle(fontSize: 22),),
                                  ],
                                )
                            ),
                          ],
                        ),
                      ),
                      Container(margin: EdgeInsets.only(left: 3), color: Colors.green, height: 20, width: 30,),
                      Transform.rotate(angle: 45, child: Container(
                        color: Colors.grey,
                        width: 40,
                        height: 20,
                      ),),
                      Container(color: Colors.green, height: 20, width: 30,)
                    ],
                  )
                ],
              ),
              //Main bus A
              Container(
                width: 20,
                height: 200,
                child: Container(
                  color: Colors.green,
                  height: double.infinity,
                  width: 20,
                ),
              ),
              //Tie breaker row
              Container(
                margin: EdgeInsets.only(top: 180),
                child: Row(
                  children: [
                    Container(
                      color: Colors.white60,
                      width: 20,
                      height: 20,
                      child: Container(
                        color: Colors.green,
                        height: double.infinity,
                        width: 20,
                      ),
                    ),
                    Transform.rotate(angle: 45, child: Container(
                      color: Colors.grey,
                      width: 50,
                      height: 20,
                    ),),
                    Container(
                      color: Colors.white60,
                      width: 20,
                      height: 20,
                      child: Container(
                        color: Colors.green,
                        height: double.infinity,
                        width: 20,
                      ),
                    ),
                  ],
                ),
              ),
              // Main bus bar B
              Container(
                margin: EdgeInsets.only(left: 0),
                color: Colors.white60,
                width: 20,
                height: 200,
                child: Container(
                  color: Colors.green,
                  height: double.infinity,
                  width: 20,
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Container(color: Colors.green, height: 20, width: 30,),
                      Transform.rotate(angle: 45, child: Container(
                        color: Colors.grey,
                        width: 40,
                        height: 20,
                      ),),
                      Container(margin: EdgeInsets.only(right: 3), color: Colors.green, height: 20, width: 30,),
                      Container(
                        margin: EdgeInsets.only(left: 0, top: 10),
                       decoration: BoxDecoration(
                         boxShadow: [
                           BoxShadow(
                             color: Colors.green.withOpacity(0.5),
                             spreadRadius: 1,
                             blurRadius: 1,
                             offset: Offset(0, 1), // changes position of shadow
                           ),
                       ],
                       ),
                        width: available_width / 5,
                        height: available_height / 4,

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('400 V', style: TextStyle(fontSize: 22),),
                                  Text('39 A', style: TextStyle(fontSize: 22),),
                                  Text('50 Hz', style: TextStyle(fontSize: 22),),
                                ],
                              )
                            ),
                            SizedBox(width: 10,),
                            Container(width: 60, child: Image.asset('assets/images/shore_plug.png'),),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(color: Colors.green, height: 20, width: 30,),
                      Transform.rotate(angle: 45, child: Container(
                        color: Colors.grey,
                        width: 40,
                        height: 20,
                      ),),
                      Container(margin: EdgeInsets.only(right: 3), color: Colors.green, height: 20, width: 30,),
                      Container(
                        margin: EdgeInsets.only(left: 0, top: 15),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: Offset(0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        width: available_width / 5,
                        height: available_height / 4,

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                padding: EdgeInsets.all(6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('400 V', style: TextStyle(fontSize: 22),),
                                    Text('39 A', style: TextStyle(fontSize: 22),),
                                    Text('50 Hz', style: TextStyle(fontSize: 22),),
                                  ],
                                )
                            ),
                            SizedBox(width: 10,),
                            Container(width: 60, child: Image.asset('assets/images/generator.png'),),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class PortraitHomeScreen extends StatefulWidget {
  final List<String> payload;
  final AnimationController _animationController;
  const PortraitHomeScreen(this.payload, this._animationController, {Key? key}) : super(key: key);

  @override
  State<PortraitHomeScreen> createState() => _PortraitHomeScreenState();
}

class _PortraitHomeScreenState extends State<PortraitHomeScreen> {

  @override
  Widget build(BuildContext context) {
    var available_height = MediaQuery.of(context).size.height;
    print(available_height);
    return Row(
      children: [
        Column(
          children: [
            PowerSource(widget.payload, widget._animationController, 'shore_plug.png', EdgeInsets.only(top: available_height / 50)),
            PowerSource(widget.payload, widget._animationController, 'generator.png', EdgeInsets.only(top: 0)),
            PowerSource(widget.payload, widget._animationController, 'shore_plug.png', EdgeInsets.only(top: available_height / 8)),
            PowerSource(widget.payload, widget._animationController, 'generator.png', EdgeInsets.only(top: 0))
          ],
        ),
        Column(
          children: [
            Expanded(child: Container(
              width: 20,
              color: Colors.green,
            )),
            Transform.rotate(angle: widget.payload[9] == '1' ? 0 : widget._animationController.value, child: Container(
              color: widget.payload[9] == '1' ? Colors.green : Colors.grey,
              width: 20,
              height: available_height / 14,
            ),),
            Expanded(child: Container(
              width: 20,
              color: Colors.green,
            ))
          ],
        )
      ],
    );
  }
}


class PowerSource extends StatefulWidget {
  final List<String> payload;
  final AnimationController _animationController;
  final String img;
  final EdgeInsets edge_insets;
  const PowerSource(this.payload, this._animationController, this.img, this.edge_insets, {Key? key}) : super(key: key);

  @override
  State<PowerSource> createState() => _PowerSourceState();
}

class _PowerSourceState extends State<PowerSource> {
  @override
  Widget build(BuildContext context) {
    var available_height = MediaQuery.of(context).size.height;
    var available_width = MediaQuery.of(context).size.width;
    return Padding(
      padding: widget.edge_insets,
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => StbdGenScreen()));
            },
            child: Container(
              margin: EdgeInsets.only(left: 15, right: 3, top: 15),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(0, 1), // changes position of shadow
                  ),
                ],
              ),
              width: available_width / 2.5,
              height: available_height / 7,

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 60, child: Image.asset('assets/images/${widget.img}'),),
                  SizedBox(width: 10,),
                  Container(
                      padding: EdgeInsets.all(6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('400 V', style: TextStyle(fontSize: 22),),
                          Text('39 A', style: TextStyle(fontSize: 22),),
                          Text('50 Hz', style: TextStyle(fontSize: 22),),
                        ],
                      )
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 40,
            height: 20,

            decoration: BoxDecoration(
              color: Colors.green
            ),
          ),
          Transform.rotate(angle: widget.payload[29] == '1' ? 0 : widget._animationController.value, child: Container(
            color: widget.payload[29] == '1' ? Colors.green : Colors.grey,
            width: available_width / 8,
            height: 20,
          ),),
          Container(
            color: (widget.payload[9] == '1' || widget.payload[19] == '1' || widget.payload[29] == '1') ? Colors.grey : Colors.green,
            width: available_width / 8,
            height: 20,
          )
        ],
      ),
    );
  }
}


