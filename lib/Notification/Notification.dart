import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NoticationService {
  final Firestore _db = Firestore.instance;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  saveUserToken(String topic) async {
    String authUser = "mps@magna";
    String _fcmToken = await _firebaseMessaging.getToken();

    if (_fcmToken != null)
      _firebaseMessaging.subscribeToTopic(topic).then((val) {
        print("topic save as $topic");
      });
  }

  NoticationService() {
    firebaseCloudMessaging_Listeners();
  }
}
