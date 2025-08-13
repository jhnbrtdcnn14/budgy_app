// ignore_for_file: use_build_context_synchronously

import 'package:budgy_app/components/colors.dart';
import 'package:budgy_app/components/text.dart';
import 'package:budgy_app/screens/create_wallet_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      body: Stack(children: [
        const FuturisticBackground(),
        UpperLeftCircularBlur(),
        LowerRightCircularBlur(),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/wallet');
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Container()),
                SizedBox.square(
                  dimension: screenHeight * 0.30,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset(
                        'assets/icons/budgy_logo.png',
                        fit: BoxFit.cover, // This makes the image fit the container
                      ),
                    ),
                  ),
                ),
                AppText(text: 'Your money, your rules', size: 'large', color: AppColors.primaryLight),
                const SizedBox(
                  height: 10,
                ),
                Expanded(child: Container()),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(64.0),
                        child: SizedBox(
                          height: 64,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/wallet');
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: AppColors.purple,
                              foregroundColor: AppColors.primaryLight,
                            ),
                            child: AppText(
                              text: 'Start',
                              size: "large",
                              color: AppColors.textButton,
                              isBold: true,
                              isCenter: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class LowerRightCircularBlur extends StatelessWidget {
  const LowerRightCircularBlur({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: -100,
      bottom: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration:  BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment(0.5, 0.9),
            radius: 1.2,
            colors: [
              AppColors.primaryDark,
              AppColors.darkpurple,
            ],
            stops: [
              0.0,
              1.0
            ],
          ),
        ),
      ),
    );
  }
}

class UpperLeftCircularBlur extends StatelessWidget {
  const UpperLeftCircularBlur({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: -100,
      top: -150,
      child: Container(
        width: 300,
        height: 300,
        decoration:  BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment(-0.5, -0.8),
            radius: 1.2,
            colors: [
              AppColors.primaryDark,
              AppColors.darkpurple,
            ],
            stops: [
              0.0,
              1.0
            ],
          ),
        ),
      ),
    );
  }
}
