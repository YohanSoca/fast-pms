import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_pms_app/screens/categories_screen.dart';
import 'package:fast_pms_app/screens/home_screen.dart';
import 'package:fast_pms_app/screens/settings_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fast_pms_app/firebase_options.dart';


import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async   {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      message.notification!.body.toString(), htmlFormatBigText: true,
      contentTitle: message.notification!.title.toString(), htmlFormatContent: true
  );
  AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'dbfood', 'dbfood', importance: Importance.high,
      styleInformation: bigTextStyleInformation, priority: Priority.high, playSound: true
  );
  NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.show(0, message.notification!.title, message.notification!.body, notificationDetails, payload: message.data['title']);
}

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  runApp(const FastPMSApp());
}

class FastPMSApp extends StatefulWidget {
  const FastPMSApp({Key? key}) : super(key: key);

  @override
  State<FastPMSApp> createState() => _FastPMSAppState();
}

class _FastPMSAppState extends State<FastPMSApp> {

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermision();
    getToken();
    getInfo();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          /* light theme settings */
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          /* dark theme settings */
        ),
        themeMode: ThemeMode.dark,
        /* ThemeMode.system to follow system theme,
         ThemeMode.light for light theme,
         ThemeMode.dark for dark theme
      */
        debugShowCheckedModeBanner: false,
      title: 'Fast PMS App',
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('FAST PMS'),
          ),
          bottomNavigationBar: BottomNavigationWidget(),
        ),
      ),
      );
  }

  void requestPermision() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: false,
        sound: true
    );
    if(settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      setState(() {

      });
    }
    if(settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
      setState(() {

      });
    }
    else {
      print("User has not accented permission");
      setState(() {

      });
    }
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        print("Token is $token");
      });
      saveToken(token!);
    });
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance.collection("pms").add({"token": token});
  }

  void getInfo() async {
    var android = AndroidInitializationSettings('mipmap/ic_launcher');
    var ios =  DarwinInitializationSettings();
    var platform = InitializationSettings(android: android, iOS: ios);

    flutterLocalNotificationsPlugin?.initialize(platform,
        onDidReceiveNotificationResponse: (payload) {
          try {

          } catch(e) {

          }
          return;
        });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("-------------on message-------------------");
      print("On message: ${message.notification?.title}/${message.notification?.body}");

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
          message.notification!.body.toString(), htmlFormatBigText: true,
          contentTitle: message.notification!.title.toString(), htmlFormatContent: true
      );
      AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
          'dbfood', 'dbfood', importance: Importance.max,
          styleInformation: bigTextStyleInformation, priority: Priority.max, playSound: true
      );
      NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
      await flutterLocalNotificationsPlugin.show(0, message.notification!.title, message.notification!.body, notificationDetails, payload: message.data['title']);
    });
  }
}

class BottomNavigationWidget extends StatefulWidget {
  const BottomNavigationWidget({Key? key}) : super(key: key);

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  int _selectedIndex = 0;

  static const List<Widget> _selections = [
    HomeScreen(),
    CategoriesScreen(),
    SettingScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MediaQuery.of(context).orientation == Orientation.portrait ? AppBar(title: Text('PMS'),) : null,
        bottomNavigationBar: MediaQuery.of(context).orientation == Orientation.portrait ? BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.install_mobile), label: "Installer"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Setup")
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ) : null,
        body: _selections[_selectedIndex]
    );
  }

  void _onItemTapped(int value) {
    setState(() {
      _selectedIndex = value;
    });
  }
}



