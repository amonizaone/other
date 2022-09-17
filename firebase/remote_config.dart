//import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseRemoteConfigUtil {
  Future<FirebaseRemoteConfig> setupRemoteConfig() async {
    //await Firebase.initializeApp(
    //  options: const FirebaseOptions(
    //      apiKey: 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0',
    //      authDomain: 'react-native-firebase-testing.firebaseapp.com',
    //      databaseURL: 'https://react-native-firebase-testing.firebaseio.com',
    //      projectId: 'react-native-firebase-testing',
    //      storageBucket: 'react-native-firebase-testing.appspot.com',
    //      messagingSenderId: '448618578101',
    //      appId: '1:448618578101:web:772d484dc9eb15e9ac3efc',
    //      measurementId: 'G-0N1G9FLDZE'),
    //);
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    //await remoteConfig.setDefaults(<String, dynamic>{
    //  'welcome': 'default welcome',
    //  'hello': 'default hello',
    //});
    RemoteConfigValue(null, ValueSource.valueStatic);
    return remoteConfig;
  }
}
