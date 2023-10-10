import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kitx/Utils/Network.dart';
import 'package:kitx/Utils/Permissions.dart';
import 'package:signalr_core/signalr_core.dart';
//import 'package:flutter_background_service/flutter_background_service.dart';
//import 'package:flutter_background/flutter_background.dart';

// Background.listenToNotificationStart();

class Background
{
  static int index = 1;
  static String? userId;

  static final hubConnection = HubConnectionBuilder().withUrl('https://kursdefteri.com.tr/ip-hub').build();
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const android = AndroidNotificationDetails(
    "kitx",
    "kitx_channel",
    priority: Priority.high,
    importance: Importance.high,
    icon: "@mipmap/ic_launcher",
    //ongoing: true
  );

  // static final ios = IOSNotificationDetails(
  //   presentAlert: true,
  //   presentBadge: true,
  //   presentSound: true,
  //   badgeNumber: 1,
  // );

  static const notDet = NotificationDetails(
      android: android,
      // iOS: ios
  );

  static request() async
  {
    await Izinler.bildirimRequest();
  }

  static bildirim({required String mesage}) async
  {
    if(Izinler.bildirimIzin)
    {
      await flutterLocalNotificationsPlugin.show(
        index,
        "Birisi kitinizi buldu",
        mesage,
        notDet,
      );
    }
  }

  static listenToNotificationStart() async
  {
    if (hubConnection.state == HubConnectionState.disconnected)
    {
      await request();
      userId = await storage.read(key: "userId");
      await hubConnection.start();
      hubConnection.on('QrCodeRead', (arguments)
      {
        String veri = arguments.toString();
        int UserIndex = veri.indexOf("UserId:");
        int IpIndex = veri.indexOf("IPAddress:");
        int IpIndexLast = veri.indexOf("|");

        if(veri.substring(UserIndex+7,veri.length-1) == userId)
        {
          bildirim(mesage: "İp Adresi: ${veri.substring(IpIndex+10,IpIndexLast)}");
          index++;
        }
      });
    }
  }
  static listenToNotificationStop() async
  {
    if (hubConnection.state == HubConnectionState.connected)
    {
      await hubConnection.stop();
    }
  }

  // static void kaliciGoster() async
  // {
  //   final androidConfig = FlutterBackgroundAndroidConfig(
  //     notificationTitle: "flutter_background example app",
  //     notificationText: "Background notification for keeping the example app running in the background",
  //     notificationImportance: AndroidNotificationImportance.Default,
  //     notificationIcon: AndroidResource(name: '@mipmap/ic_launcher', defType: 'drawable'),
  //   );
  //   bool success = await FlutterBackground.initialize(androidConfig: androidConfig);
  // }

  // static void kaliciGoster() async
  // {
  //   await FlutterBackgroundService.start(
  //     onStart: ()
  //     {
  //       // Hizmet başlatıldı.
  //     },
  //     onRun: ()
  //     {
  //       // Arka planda çalışırken.
  //     },
  //     onStop: ()
  //     {
  //       // Hizmet durduruldu.
  //     },
  //   );
  // }

  // static void kaliciGoster() async
  // {
  //   final service = FlutterBackgroundService();
  //   await service.configure(
  //       iosConfiguration: IosConfiguration(),
  //       androidConfiguration: AndroidConfiguration(
  //       onStart: bildirim(mesage: "mesaj bu"),
  //       autoStart: true,
  //       isForegroundMode: true,
  //       notificationChannelId: "kitx_channel",
  //       initialNotificationTitle: 'AWESOME SERVICE',
  //       initialNotificationContent: 'Initializing',
  //       foregroundServiceNotificationId: 0,
  //   ));
  // }
}