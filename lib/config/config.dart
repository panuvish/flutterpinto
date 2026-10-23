import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> loadEnv() async {
  try {
    await dotenv.load(fileName: '.env');
    print('Loaded .env file');
  } catch (e) {
    print('Error loading .env file: $e');
  }
}
