import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppAnimationController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void onInit() {
    super.onInit();
    _fadeAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _pulseAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.linear,
    );

    final curvedAnimation = CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.bounceIn,
      reverseCurve: Curves.easeOut,
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void onClose() {
    _fadeAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.onClose();
  }
}

class TextAnimation extends GetView {
  TextAnimation({Key? key, required this.body, this.duration = const Duration(milliseconds: 500), this.curve = Curves.bounceOut}) : super(key: key);

  final Duration duration;
  final Widget body;
  final Curve curve;

  final AppAnimationController ca = Get.put(AppAnimationController());

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: ca._fadeAnimation, child: body
        //return SlideTransition(position: ca._animation, child: body
        );
  }
}

class PulseAnimation extends GetView {
  PulseAnimation({
    Key? key,
    required this.body,
  }) : super(key: key);

  final Widget body;

  final AppAnimationController ca = Get.put(AppAnimationController());

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: ca._pulseAnimation, child: body);
  }
}
