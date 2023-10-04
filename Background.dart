import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kitx/Utils/Network.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signalr_core/signalr_core.dart';

class Background
{
  static bool izin = false;
  static int index = 0;
  static String? userId;

  static final hubConnection = HubConnectionBuilder().withUrl('https://kursdefteri.com.tr/ip-hub').build();
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const android = AndroidNotificationDetails(
    'kitx',
    'kitx_channel',
    priority: Priority.high,
    importance: Importance.max,
    icon: "@mipmap/ic_launcher",
  );

  static bildirim({required String mesage}) async
  {
      await flutterLocalNotificationsPlugin.show(
        index,
        "Birisi kitinizi buldu",
        mesage,
        const NotificationDetails(android: android),
      );
  }

  static request() async
  {
    var status = await Permission.notification.request();
    if (status.isGranted)
    {
      izin = true;
    }
    else if (status.isDenied)
    {
      izin = false;
    }
    else if (status.isPermanentlyDenied)
    {
      izin = false;
      openAppSettings();
    }
  }

  static listenToNotificationStart() async
  {
    listenToNotificationStop();
    request();
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

  static listenToNotificationStop() async
  {
    if (hubConnection.state == HubConnectionState.connected)
    {
      await hubConnection.stop();
    }
  }
}