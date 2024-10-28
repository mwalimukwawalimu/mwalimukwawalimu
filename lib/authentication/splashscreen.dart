import 'package:edvolutionhub/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:edvolutionhub/screens/feaures/auth/signin.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  
  @override
  State<SplashScreen> createState() => _SplashScreenState ();
}


class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      // Navigate to the next screen after 5 seconds
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Stack(
      children: [
        Center(
      child: Lottie.asset(
        'assets/animations/Anim2.json',
        repeat: true,
        width: 250,
        height: 250,
        ),
      ),

        Positioned(
          bottom: 220, // Adjust position as needed
          left: 0,
          right: 0,
          child: Row(
            children: [
              const SizedBox(width: 20.0, height: 100.0),
              const Text(
                'Discuss',
                style: TextStyle(
                  fontSize: 35.0,
                  color: kPrimary
                  ),
              ),
              const SizedBox(width: 20.0, height: 100.0),
              DefaultTextStyle(
                style: const TextStyle(
                  color: kSecondary,
                  fontSize: 35.0,
                  fontFamily: 'Horizon',
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    RotateAnimatedText('TECHNOLOGY'),
                    RotateAnimatedText('CURRICULUM'),
                    RotateAnimatedText('KNOWLEDGE'),
                  ],
                  isRepeatingAnimation: true,
                  // onTap: () {
                  //   print("Tap Event");
                  // },
                ),
              ),
            ],
          ),
        ),
     ],
    );
    
  }
  
}
