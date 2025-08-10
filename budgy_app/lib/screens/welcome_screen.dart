// ignore_for_file: use_build_context_synchronously

import 'package:budgy_app/components/colors.dart';
import 'package:budgy_app/components/text.dart';
import 'package:budgy_app/screens/home_screen.dart';
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

    // // Navigate after 3 seconds
    // Future.delayed(const Duration(seconds: 3), () {
    //   Navigator.pushReplacementNamed(context, '/home');
    // });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(children: [
        const FuturisticBackground(),
        UpperLeftCircularBlur(),
        LowerRightCircularBlur(),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/home');
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Container()),
                SizedBox.square(
                  dimension: screenHeight * 0.40,
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
                AppText(text: 'Your money, your rules', size: 'large', color: AppColors.white),
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
                              Navigator.pushNamed(context, '/home');
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: AppColors.purple,
                              foregroundColor: AppColors.white,
                            ),
                            child: const AppText(
                              text: 'Start',
                              size: "large",
                              color: AppColors.white,
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
