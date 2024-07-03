import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> createPaymentIntent({
  required String name,
  required String address,
  required String pin,
  required String city,
  required String state,
  required String country,
  required String currency,
  required String amount,
}) async {
  final url = Uri.parse("https://api.stripe.com/v1/payment_intents");
  const secretKey =
      "sk_test_51PYQi6HGhuuw9ifThX8AQ8tIyKzD7SdIyzSQy7l9L8wqBFIvdqQIlR1pHllfjej9WFiOKeHuzrvcGdGCmdlxvevF00ihyngl9f";
  final body = {
    'amount': amount,
    'currency': currency.toLowerCase(),
    'automatic_payment_methods[enabled]': 'true',
    'description': 'Quyên góp thử nghiệm',
    'shipping[name]': name,
    'shipping[address][line1]': address,
    'shipping[address][postal_code]': pin,
    'shipping[address][city]': city,
    'shipping[address][state]': state,
    'shipping[address][country]': country,
  };

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: body,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to create payment intent');
  }
}
