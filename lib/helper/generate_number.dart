import 'dart:math';

String generateRandomNumber(int length) {
  Random random = Random();
  String randomNumber = '';

  for (int i = 0; i < length; i++) {
    randomNumber += random.nextInt(10).toString(); // Generate random digit (0-9)
  }

  return randomNumber;
}

