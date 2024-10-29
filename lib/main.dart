import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mwalimukwawalimu/common/constants.dart';
import 'package:mwalimukwawalimu/models/user_models.dart';
import 'package:mwalimukwawalimu/authentication/splash.dart';
import 'package:mwalimukwawalimu/services/notification_service.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseApi notificationService = FirebaseApi();
  await notificationService.initNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 825),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MultiProvider(
          providers: [
            StreamProvider<CustomUser?>.value(
              value: AuthService().userStream,
              initialData: null,
            ),
          ],
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'First Method',
            theme: ThemeData(
              scaffoldBackgroundColor: kOffWhite,
              iconTheme: const IconThemeData(
                  color: Color.fromARGB(255, 252, 245, 245)),
              primarySwatch: Colors.grey,
            ),
            home:
                const SplashScreen(), // Keep the SplashScreen as the home widget
          ),
        );
      },
    );
  }
}
