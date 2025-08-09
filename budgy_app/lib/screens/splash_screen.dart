// ignore_for_file: use_build_context_synchronously

import 'package:budgy_app/components/colors.dart';
import 'package:budgy_app/screens/home_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
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
        // const FuturisticBackground(),
        UpperLeftCircularBlur(),
        LowerRightCircularBlur(),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
            ],
          ),
        ),
      ]),
    );
  }
}
