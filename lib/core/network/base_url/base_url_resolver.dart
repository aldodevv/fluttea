import 'package:dio/dio.dart';

abstract interface class BaseUrlResolver {
  Future<Uri> resolve({RequestOptions? options});
}
