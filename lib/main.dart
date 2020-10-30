import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupRemoteConfig();
  runApp(GetMaterialApp(
    initialRoute: '/page1',
    title: '',
    theme: ThemeData.light().copyWith(primaryColor: Colors.green),
    darkTheme: ThemeData.dark().copyWith(
      primaryColor: Colors.purple,
    ),
    themeMode: ThemeMode.light,
    getPages: [
      //Simple GetPage
      GetPage(name: '/page1', page: () => Page1()),
      GetPage(name: '/page2', page: () => Page2()),
      // GetPage with custom transitions and bindings
    ],
  ));
}

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Page 2'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            RaisedButton(
              child: Text('Go to Page 1'),
              onPressed: () {
                Get.changeThemeMode(ThemeMode.light); //STEP 3 - change themes
                Get.toNamed('/page1');
              },
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Page 1'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            RaisedButton(
              child: Text('Go to Page 2'),
              onPressed: () {
                Get.changeThemeMode(ThemeMode.dark);
                Get.toNamed('/page2');
              },
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Future<RemoteConfig> setupRemoteConfig() async {
  await Firebase.initializeApp();
  final RemoteConfig remoteConfig = await RemoteConfig.instance;
  remoteConfig.setConfigSettings(RemoteConfigSettings(debugMode: true));
  remoteConfig.setDefaults(<String, dynamic>{
    'background_colour': 0xFFB71000,
    'primary_colour': 0xFFB74093,
    'text_body_colour': 0xFFB71000,
    'appbar_colour':  0xFFB71000,
    'theme': 'system',
    'enable_custom_theme': false,
  });

  try {
    // Using default duration to force fetching from remote server.
    await remoteConfig.fetch(expiration: const Duration(seconds: 0));
    await remoteConfig.activateFetched();

    bool enableCustomTheme = await remoteConfig.getBool('enable_custom_theme');
    int primaryColour = await remoteConfig.getInt('primary_colour');
    int textBodyColour = await remoteConfig.getInt('text_body_colour');
    int appBarColour = await remoteConfig.getInt('appbar_colour');
    String theme = await remoteConfig.getString('theme');

    if (enableCustomTheme) {
      switch (theme) {
        case 'dark':
          {
            Get.changeTheme(ThemeData.dark().copyWith(
              appBarTheme: AppBarTheme(color: Color(appBarColour)),
              primaryColor: Color(primaryColour),
              textTheme: TextTheme(
                bodyText1: TextStyle(),
                bodyText2: TextStyle(),
              ).apply(
                bodyColor: Color(textBodyColour),
                displayColor: Color(textBodyColour),
              ),
            ));
          }
          break;

        case 'light':
          {
            Get.changeTheme(ThemeData.light().copyWith(
              appBarTheme: AppBarTheme(color: Color(appBarColour)),
              primaryColor: Color(primaryColour),
              textTheme: TextTheme(
                bodyText1: TextStyle(),
                bodyText2: TextStyle(),
              ).apply(
                bodyColor: Color(textBodyColour),
                displayColor: Color(textBodyColour),
              ),
            ));
          }
          break;
        default:
          {
            //statements;
          }
          break;
      }
    }

    print('cloud app theme ${enableCustomTheme}');
    print('cloud app theme ${theme}');
  } on FetchThrottledException catch (exception) {
    print(exception);
  } catch (exception) {
    print('Unable to fetch remote config. Cached or default values will be '
        'used');
  }

  return remoteConfig;
}
