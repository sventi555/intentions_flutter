import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/pages/create/post.dart';
import 'package:intentions_flutter/pages/feed.dart';
import 'package:intentions_flutter/pages/notifications.dart';
import 'package:intentions_flutter/pages/profile.dart';
import 'package:intentions_flutter/pages/search.dart';

void main() async {
  await firebase.init();

  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
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
              Consumer(
                builder: (_, ref, _) {
                  return ref.watch(authUserProvider).isLoading
                      ? Placeholder()
                      : FeedTab();
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
