import 'package:flutter/material.dart';
import 'package:servifix_flutter/views/notification.dart';
import 'package:servifix_flutter/views/request_offer.dart';
import 'package:servifix_flutter/views/login.dart';
import 'package:provider/provider.dart';
import 'api/provider/AuthModel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Authmodel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: RequestOffer(),
      //home : ProfileScreen(),
    );
  }
}
