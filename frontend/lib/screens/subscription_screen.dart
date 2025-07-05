import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_video_app/providers/auth_provider.dart';
import 'package:flutter_video_app/services/api_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:flutter_video_app/utils/js_stub.dart'
    if (dart.library.js) 'dart:js'
    as js;

class Plan {
  final String id;
  final String stripePriceId;
  final String name;
  final String price;
  final String description;

  const Plan({
    required this.id,
    required this.stripePriceId,
    required this.name,
    required this.price,
    required this.description,
  });
}

class SubscriptionScreen extends StatefulWidget {
  static const String routeName = '/subscription';

  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  Plan? _selectedPlan;
  bool _isLoading = false;

  

  final List<Plan> _plans = [
    Plan(
      id: 'basic',
      stripePriceId:
          'price_1RYDjQFJqSjpkwgi7LpWIYfj', // Your Basic Plan Price ID from Stripe
      name: 'Basic Plan',
      price: '\$5/month',
      description: 'Access to basic features.',
    ),
    Plan(
      id: 'premium',
      stripePriceId:
          'price_1RYDgNFJqSjpkwgim7nwsQ4F', // Your Premium Plan Price ID from Stripe
      name: 'Premium Plan',
      price: '\$10/month',
      description: 'Access to all premium features.',
    ),
  ];

  void _handlePlanSelection(Plan plan) {
    setState(() {
      _selectedPlan = plan;
    });
    print('Selected plan: ${plan.name}');
  }

  Future<void> _handlePayment(Plan plan) async {
    setState(() => _isLoading = true);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    try {
      if (kIsWeb) {
        // Web: Use Stripe Checkout session
        final response = await ApiService.createCheckoutSession(
          plan.stripePriceId,
        );
        if (response['url'] != null) {
          js.context.callMethod('open', [response['url']]);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please complete your payment in the new tab.'),
              duration: Duration(seconds: 8),
            ),
          );
        } else {
          throw Exception('Stripe Checkout URL not received.');
        }
      } else {
        // Mobile: Use native Stripe SDK
        final result = await ApiService.createSubscription(
          plan.stripePriceId,
        );
        final clientSecret = result['clientSecret'];
        final subscriptionId = result['subscriptionId'];

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Movie App',
            style: ThemeMode.dark,
          ),
        );
        await Stripe.instance.presentPaymentSheet();

        // Confirm the subscription on the backend
        await ApiService.confirmSubscription(subscriptionId);

        // Refresh user data to update subscription status
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).refreshUserData();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Thank you for subscribing to ${plan.name}!'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a Subscription Plan')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _plans.length,
                itemBuilder: (context, index) {
                  final Plan plan = _plans[index]; // <-- FIX: Strongly typed
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      // <-- FIX: Clean and type-safe property access
                      title: Text(plan.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan.price),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(plan.description),
                          ),
                        ],
                      ),
                      trailing:
                          _selectedPlan?.id == plan.id
                              ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                              : const Icon(Icons.radio_button_unchecked),
                      onTap: () => _handlePlanSelection(plan),
                    ),
                  );
                },
              ),
      floatingActionButton:
          _selectedPlan != null
              ? FloatingActionButton.extended(
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          if (_selectedPlan != null) {
                            _handlePayment(_selectedPlan!);
                          }
                        },
                label: const Text('Proceed to Payment'),
                icon: const Icon(Icons.payment),
              )
              : null,
    );
  }
}
