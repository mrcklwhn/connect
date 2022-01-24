import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';

import 'Encryption.dart';


class Storage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<int> readData() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeData(String counter) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$counter');
  }
}

class LocalData {
  static SharedPreferences _preferences;

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static void deleteData() {
    _preferences.clear();
    _preferences.commit();
  }
  static void reload() {
    _preferences.reload();
  }

  static Future<bool> putString(String key, String value) {
    if (_preferences == null) return null;
    return _preferences.setString(key, value);
  }

  // get string
  static String getString(String key, {String defValue = ''}) {
    if (_preferences == null) return defValue;
    return _preferences.getString(key) ?? defValue;
  }

  static bool exitsString(String key) {
    return _preferences.containsKey(key);
  }

  static void clearString(String key) {
    _preferences.remove(key);
    _preferences.commit();
  }

  static bool exits() => _preferences.containsKey('isLocked');

  static Future setBiometricPasswordState(bool state) async =>
      await _preferences.setBool('Biometric_Password_State', state);

  static bool getBiometricPasswordState() =>
      _preferences.getBool('Biometric_Password_State') ?? false;

  static bool isGoogleLogIn() => _preferences.getBool('Google_Log_In') ?? false;

  static Future setGoogleLogIn(bool state) async =>
      await _preferences.setBool('Google_Log_In', state);

  static Future setPasswordState(bool state) async =>
      await _preferences.setBool('Password_State', state);

  static bool getPasswordState() =>
      _preferences.getBool('Password_State') ?? false;

  static Future setAutoDeletePasswordState(bool state) async =>
      await _preferences.setBool('Auto_Delete_Password_State', state);

  static bool getAutoPasswordPasswordState() =>
      _preferences.getBool('Auto_Delete_Password_State') ?? false;

  static Future setLocked(bool state) async =>
      await _preferences.setBool('isLocked', state);

  static bool isLocked() => _preferences.getBool('isLocked') ?? false;

  static Future setAutoDeletePassword(String password) async =>
      await _preferences.setString(
          'Auto_Delete_Password',
          Encryption().encrypt(
              password,
              Encryption()
                  .parsePublicKeyFromPem(LocalData.getString("publicKey"))));

  static String getAutoDeletePassword() => Encryption().decrypt(
      _preferences.get('Auto_Delete_Password'),
      Encryption().parsePrivateKeyFromPem(LocalData.getString("privateKey")));

  static Future setPassword(String password) async =>
      await _preferences.setString(
          'Password',
          Encryption().encrypt(
              password,
              Encryption()
                  .parsePublicKeyFromPem(LocalData.getString("publicKey"))));

  static String getPassword() => Encryption().decrypt(
      _preferences.get('Password'),
      Encryption().parsePrivateKeyFromPem(LocalData.getString("privateKey")));
}
