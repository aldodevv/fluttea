import 'package:dio/dio.dart';

abstract class AppInterceptor extends Interceptor {
  const new();

  String get name;
  int get order;
  bool get enabled => true;
}
