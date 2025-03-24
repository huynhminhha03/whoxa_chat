import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/Notification/one_signal_service.dart';
import 'package:whoxachat/src/screens/user/api_config_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    navigatToScreen();
    super.initState();
  }

  navigatToScreen() async {
    Future.delayed(
      const Duration(seconds: 3),
      () {
        Get.offAll(
          languageController.appSettingsData.isEmpty
              ? const ApiConfigScreen()
              : const AppScreen(),
          transition: Transition.downToUp,
        );
        OnesignalService().initialize();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite,
      body: Center(
        child: Obx(
          () => languageController.isAppSettingsLoading.value == true
              ? const SizedBox()
              : languageController.appSettingsData.isEmpty
                  ? const SizedBox()
                  : Image.network(
                      languageController.appSettingsData[0].appLogo!,
                      height: 150,
                      width: 300,
                      fit: BoxFit.contain,
                    ),
        ),
      ),
    );
  }
}
