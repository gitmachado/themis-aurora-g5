import 'package:flutter/material.dart';

/// GlobalKey exposta para toda a app — único ponto de acesso ao Navigator
/// sem precisar de BuildContext nem Riverpod.
///
/// Usado principalmente pelo background message handler do FCM,
/// que roda em um isolate separado e não pode depender de providers.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
