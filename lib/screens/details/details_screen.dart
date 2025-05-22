import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plantapp/screens/details/components/body.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
    );
  }
}
