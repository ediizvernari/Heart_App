import 'package:flutter/material.dart';
import 'package:frontend/utils/auth_store.dart';

class AutoCheck extends StatefulWidget {
  const AutoCheck({Key? key}) : super(key: key);

  @override
  State<AutoCheck> createState() => _AutoCheckState();
}

class _AutoCheckState extends State<AutoCheck> {
  bool _hasRun = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasRun) {
      _hasRun = true;
      AuthStore.ensureSession(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
