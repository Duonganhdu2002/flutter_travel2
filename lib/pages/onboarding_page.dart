import 'package:flutter/material.dart';
import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter_application_1/pages/login_page.dart';

class OnboardingModel {
  final String? title;
  final String? image;
  final Color bgColor;
  final Color textColor;

  const OnboardingModel({
    this.title,
    this.image,
    required this.bgColor,
    required this.textColor,
  });
}

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final pages = [
    const OnboardingModel(
        image: "assets/onboarding/1.png",
        title: "See The World",
        bgColor: Color(0xFFFCC7AA),
        textColor: Color(0xFF55403A)),
    const OnboardingModel(
        image: "assets/onboarding/2.png",
        title: "Make Plans With Friends",
        bgColor: Color(0xFFFDF7CB),
        textColor: Color(0xFF55403A)),
    const OnboardingModel(
        image: "assets/onboarding/3.png",
        title: "Chat Together",
        bgColor: Color(0xFFFFFFFF),
        textColor: Color(0xFF55403A)),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: ConcentricPageView(
        colors: pages.map((p) => p.bgColor).toList(),
        radius: screenWidth * 0.1,
        nextButtonBuilder: (context) => Padding(
          padding: const EdgeInsets.only(left: 3),
          child: Icon(
            Icons.navigate_next,
            size: screenWidth * 0.08,
          ),
        ),
        onFinish: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        itemCount: pages.length,
        itemBuilder: (index) {
          final page = pages[index % pages.length];
          return SafeArea(
            child: _Page(page: page),
          );
        },
      ),
    );
  }
}

class _Page extends StatelessWidget {
  final OnboardingModel page;

  const _Page({required this.page});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    space(double p) => SizedBox(height: screenHeight * p / 100);

    return Column(
      children: [
        space(10),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Image.asset(page.image!),
        ),
        space(30),
        _Text(
          page: page,
          style: TextStyle(
            fontSize: screenHeight * 0.035,
            color: page.textColor,
          ),
        ),
      ],
    );
  }
}

class _Text extends StatelessWidget {
  const _Text({required this.page, this.style});

  final OnboardingModel page;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          page.title!,
          style: style,
        ),
      ],
    );
  }
}
