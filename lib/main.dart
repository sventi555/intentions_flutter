import 'package:flutter/material.dart';
import 'package:intentions_flutter/pages/create/post.dart';
import 'package:intentions_flutter/pages/feed.dart';
import 'package:intentions_flutter/pages/notifications.dart';
import 'package:intentions_flutter/pages/profile.dart';
import 'package:intentions_flutter/pages/search.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intentions',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: const Preview(),
    );
  }
}

class Preview extends StatelessWidget {
  const Preview({super.key});

  @override
  Widget build(BuildContext context) {
    return Home();
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
          body: const TabBarView(
            children: [
              Feed(),
              Search(),
              CreateTab(),
              Notifications(),
              Profile(),
            ],
          ),
        ),
      ),
    );
  }
}
