import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intentions_flutter/firebase_options.dart';

class FirebaseController {
  late final FirebaseApp app;

  late final FirebaseAuth auth;
  late final FirebaseFirestore db;
  late final FirebaseStorage storage;

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (kDebugMode) {
      app = await Firebase.initializeApp(
        name: 'demo-app',
        options: FirebaseOptions(
          apiKey: 'test-api-key',
          projectId: 'demo-intentions',
          appId: '1:5182096725:ios:1f1116e86a9c1e8957dbdc',
          messagingSenderId: '',
        ),
      );
      auth = FirebaseAuth.instanceFor(app: app);
      db = FirebaseFirestore.instanceFor(app: app);
      storage = FirebaseStorage.instanceFor(
        app: app,
        bucket: 'demo-intentions.appspot.com',
      );

      await auth.useAuthEmulator('localhost', 9099);
      db.useFirestoreEmulator('localhost', 8080);
      storage.useStorageEmulator('localhost', 9199);
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      auth = FirebaseAuth.instance;
      db = FirebaseFirestore.instance;
      storage = FirebaseStorage.instance;
    }
  }
}

FirebaseController firebase = FirebaseController();
