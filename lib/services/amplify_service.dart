import 'dart:developer';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:teia/amplify/amplifyconfiguration.dart';

class AmplifyService {
  static configure() async {
    try {
      // Amplify plugins
      AmplifyAuthCognito amplifyAuthCognito = AmplifyAuthCognito();
      AmplifyAPI api = AmplifyAPI(modelProvider: ModelProvider.instance);
      await Amplify.addPlugins([
        amplifyAuthCognito,
        //api,
      ]);

      // Configure Amplify
      await Amplify.configure(amplifyconfig);
    } catch (e) {
      log('An error has occurred while configuring Amplify Services - $e');
    }
  }
}
