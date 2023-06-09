import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:frontend/data/data.dart';
import 'package:frontend/providers/api_repository.dart';
import 'package:frontend/shared/index.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../modules.dart';

class HomeController extends GetxController
    with StateMixin<User>, WidgetsBindingObserver {
  final ApiRepository _apiRepository = Get.find();
  final authController = Get.put(AuthController(apiRepository: Get.find()));

  final showPerformanceOverlay = false.obs;
  final currentIndex = 0.obs;
  final isLoading = false.obs;
  final rxUser = Rxn<User?>();
  final currentUserType = 'user'.obs;
  final our = false.obs;
  final emergencyOrder = Rxn<Order?>();
  late IO.Socket socket;
  User? get user => rxUser.value;
  set user(value) => rxUser.value = value;

  Future<void> setupApp() async {
    isLoading.value = true;
    try {
      user = await _apiRepository.getUser();
      change(user, status: RxStatus.success());
      if (user?.userType == 'lawyer') {
        currentUserType.value = 'lawyer';
      }
      if (user?.userType == 'our') {
        currentUserType.value = 'our';
      }
      if (user != null) {
        socket = IO.io(
            "https://lawyernestjs-production.up.railway.app", <String, dynamic>{
          'autoConnect': false,
          'transports': ['websocket'],
        });
        socket.connect();
        socket.onConnect(
          (data) => {
            print('connect $data'),
            if (user?.userType == 'our') {our.value = true}
          },
        );

        socket.onDisconnect((_) => {
              print('dis'),
              if (user?.userType == 'our') {our.value = false}
            });
        socket.onConnectError((data) => {
              print(data),
              if (user?.userType == 'our') {our.value = false}
            });
        socket.onError((error) => {
              print(error),
              if (user?.userType == 'our') {our.value = false}
            });
        socket.on(('response_emergency_order'), ((data) {
          Order order = Order.fromJson(
              jsonDecode(jsonEncode(data)) as Map<String, dynamic>);
          if (our.value || order.clientId?.sId == user?.sId) {
            emergencyOrder.value = order;

            callkit(order);
          }
        }));
        socket.on(
            ('onlineEmergency'),
            ((data) => {
                  if ((data as List).contains(socket.id) == true)
                    {print(socket.id)}
                }));
      }
      isLoading.value = false;
    } on DioError catch (e) {
      isLoading.value = false;

      Get.find<SharedPreferences>().remove(StorageKeys.token.name);
      update();
    }
  }

  getChannelToken(Order order, bool isLawyer, String? profileImg) async {
    try {
      print('a');
      Order getOrder = await _apiRepository.getChannel(order.sId!);
      Get.to(() => Scaffold(
            body: WaitingChannelWidget(
              isLawyer: isLawyer,
            ),
          ));
      String channelName = getOrder.channelName!;
      if (getOrder.channelName == 'string') {
        channelName = DateTime.now().millisecondsSinceEpoch.toString();
      }

      Order res = await _apiRepository.setChannel(
        isLawyer,
        order.sId!,
        channelName,
      );
      print(res.toJson());
      Get.to(
        () => AudioView(
            order: res,
            isLawyer: isLawyer,
            channelName: res.channelName ?? '',
            token: isLawyer ? res.lawyerToken ?? '' : res.userToken ?? '',
            name: isLawyer
                ? res.clientId?.lastName ?? ''
                : res.lawyerId == null
                    ? 'Lawmax'
                    : order.lawyerId?.lastName ?? '',
            uid: isLawyer ? 2 : 1),
      );
    } on DioError catch (e) {
      print(e.response);
      Get.snackbar(
        'Error',
        'Something went wrong',
      );
    }
  }

  callkit(Order order) async {
    CallKitParams params = CallKitParams(
      id: order.sId,
      nameCaller: order.clientId?.firstName,
      appName: "Lawmax",
      avatar: "https://i.pravata.cc/100",
      handle: order.clientId?.firstName,
      type: 0,
      textAccept: "Accept",
      textDecline: "Decline",
      duration: 30000,
      extra: {'userId': order.clientId?.sId},
      ios: IOSParams(
          iconName: "Lawmax",
          handleType: 'generic',
          supportsVideo: true,
          maximumCallGroups: 2,
          maximumCallsPerCallGroup: 1,
          audioSessionMode: 'default',
          audioSessionActive: true,
          audioSessionPreferredSampleRate: 44100.0,
          audioSessionPreferredIOBufferDuration: 0.005,
          supportsDTMF: true,
          supportsHolding: true,
          supportsGrouping: false,
          ringtonePath: 'system_ringtone_default'),
      android: AndroidParams(
          isCustomNotification: true,
          isShowLogo: false,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: "#0955fa",
          backgroundUrl: "https://i.pravata.cc/500",
          actionColor: "#4CAF50",
          incomingCallNotificationChannelName: "Дуудлага ирж байна",
          missedCallNotificationChannelName: "Аваагүй дуудлага"),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      switch (event!.event) {
        case Event.actionCallIncoming:
          // TODO: received an incoming call
          break;
        case Event.actionCallStart:
          // TODO: started an outgoing call
          // TODO: show screen calling in Flutter
          break;
        case Event.actionCallAccept:
          await getChannelToken(order, true, user?.profileImg ?? '');

          break;
        case Event.actionCallDecline:
          // TODO: declined an incoming call
          break;
        case Event.actionCallEnded:
          // TODO: ended an incoming/outgoing call
          break;
        case Event.actionCallTimeout:
          // TODO: missed an incoming call
          break;

        case Event.actionDidUpdateDevicePushTokenVoip:
          // TODO: Handle this case.
          break;
        case Event.actionCallCallback:
          // TODO: Handle this case.
          break;
        case Event.actionCallToggleHold:
          // TODO: Handle this case.
          break;
        case Event.actionCallToggleMute:
          // TODO: Handle this case.
          break;
        case Event.actionCallToggleDmtf:
          // TODO: Handle this case.
          break;
        case Event.actionCallToggleGroup:
          // TODO: Handle this case.
          break;
        case Event.actionCallToggleAudioSession:
          // TODO: Handle this case.
          break;
        case Event.actionCallCustom:
          // TODO: Handle this case.
          break;
      }
    });
  }

  createEmergencyOrder(
    String lawyerId,
    int expiredTime,
    int price,
    String serviceType,
    String reason,
    LocationDto location,
  ) {
    Map data = {
      "userId": user!.sId,
      "date": DateTime.now().millisecondsSinceEpoch,
      "reason": reason,
      "lawyerId": lawyerId,
      "location": location,
      "expiredTime": expiredTime,
      "serviceType": serviceType,
      "serviceStatus": "pending",
      "channelName": "string",
      "channelToken": "string",
      "price": "$price",
      "lawyerToken": "string",
      "userToken": "string",
    };
    socket.emit('create_emergency_order', data);
  }

  // changeOrderStatus(String id, String status) {
  //   Map data = {"id": id, "status": status};
  //   socket.emit('change_order_status', data);
  // }

  @override
  void onInit() async {
    await setupApp();
    super.onInit();
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  @override
  void onClose() {
    super.onClose();
  }

  @override
  onReady() {
    super.onReady();
  }
}
