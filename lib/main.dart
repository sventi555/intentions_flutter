import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intentions_flutter/firebase_options.dart';
import 'package:intentions_flutter/notifiers/auth_user.dart';
import 'package:intentions_flutter/pages/create/post.dart';
import 'package:intentions_flutter/pages/feed.dart';
import 'package:intentions_flutter/pages/notifications.dart';
import 'package:intentions_flutter/pages/profile.dart';
import 'package:intentions_flutter/pages/search.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }

  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthUserNotifier(),
      child: MaterialApp(
        title: 'Intentions',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        ),
        home: Home(),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: SafeArea(
        child: Scaffold(
          bottomNavigationBar: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.search)),
              Tab(icon: Icon(Icons.create)),
              Tab(icon: Icon(Icons.notifications)),
              Tab(icon: Icon(Icons.account_circle)),
            ],
          ),
          body: TabBarView(
            children: [
              Consumer<AuthUserNotifier>(
                builder: (_, userNotifier, _) {
                  return userNotifier.isLoading ? Placeholder() : FeedTab();
                },
              ),
              Search(),
              CreateTab(),
              Notifications(),
              ProfileTab(),
            ],
          ),
        ),
      ),
    );
  }
}
