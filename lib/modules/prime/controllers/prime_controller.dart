import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/data/data.dart';
import 'package:frontend/modules/modules.dart';
import 'package:get/get.dart';

import '../../../providers/providers.dart';
import '../../../shared/index.dart';

class PrimeController extends GetxController {
  final _apiRepository = Get.find<ApiRepository>();
  final homeController = Get.put(HomeController());

  final fade = true.obs;

  final order = Rxn<Order>();
  final services = <Service>[].obs;
  final subServices = <SubService>[].obs;
  final lawyers = <User>[].obs;
  final times = <Time>[].obs;

  final loading = false.obs;
  final selectedService = "".obs;
  final selectedSubService = "".obs;

  final selectedExpiredTime = "".obs;
// order select date
  final selectedLawyer = Rxn<User?>();
  final selectedDate = DateTime.now().millisecondsSinceEpoch.obs;
  final selectedDay = Rxn<AvailableTime>();
  final selectedTime = Rxn<SelectedTime>();
  // final selectedServiceType = Rxn<ServiceTypes>();
  // final lawyerPrice = <ServicePrice>[].obs;
  final selectedAvailableDays =
      AvailableDay(serviceId: "", serviceTypeTime: []).obs;
  final orders = <Order>[].obs;

  @override
  void onInit() async {
    await start();
    Future.delayed(const Duration(milliseconds: 800), () {
      fade.value = false;
    });
    super.onInit();
  }

  getTimeLawyer(BuildContext context) async {
    try {
      loading.value = true;

      final res =
          await _apiRepository.getTimeLawyer(selectedLawyer.value!.sId!);
      selectedDate.value = res.timeDetail!.first.time!;
      res.timeDetail?.forEach((d) {
        if (selectedDate > d.time!) {
          selectedDate.value = d.time!;
        }
      });
      Navigator.of(context).push(createRoute(const OrderTimeView()));
      times.value = [res];
      loading.value = false;

      loading.value = false;
    } on DioError catch (e) {
      loading.value = false;
      print(e.response);
      Get.snackbar('Уучлаарай', "Таны сонгосон хуульч үнэ оруулаагүй байна");
    }
  }

  getTimeService(BuildContext context) async {
    try {
      loading.value = true;
      final res = await _apiRepository.getTimeService(
          order.value!.serviceId!, order.value!.serviceType!);
      times.value = res;
      selectedDate.value = res.first.timeDetail!.first.time!;
      for (var t in res) {
        t.timeDetail?.forEach((d) {
          if (selectedDate > d.time!) {
            selectedDate.value = d.time!;
          }
        });
      }
      Navigator.of(context).push(createRoute(const OrderTimeView()));

      loading.value = false;
    } on DioError catch (e) {
      loading.value = false;
      print(e.response);
      Get.snackbar('Уучлаарай', "Цаг олдсонгүй.");
    }
  }

  sendOrder(BuildContext context) async {
    try {
      loading.value = true;
      // DateTime date = DateTime(
      //     selectedDate.value.year,
      //     selectedDate.value.month,
      //     int.parse(selectedDay.value!.day!),
      //     int.parse(selectedDay.value!.time![0].substring(0, 2)));

      // final res = await _apiRepository.createOrder(
      //     date.millisecondsSinceEpoch,
      //     selectedLawyer.value!.sId!,
      //     selectedServiceType.value!.expiredTime!,
      //     selectedServiceType.value!.price!,
      //     selectedServiceType.value!.serviceType!,
      //     selectedService.value,
      //     selectedSubService.value,
      //     homeController.user!.sId!);
      // print(res);
      // Navigator.of(context).push(createRoute(AlertView(
      //     status: 'success',
      //     text:
      //         'Таны сонгосон хуульчтайгаа ${date.year} / ${date.month} / ${date.day}-ны өдрийн ${date.hour}:00 дуудлагаа хийнэ үү ')));
      loading.value = false;
    } on DioError catch (e) {
      loading.value = false;
      print(e.response);
      Get.snackbar(
        'Error',
        'Something went wrong',
      );
    }
  }

  getChannelToken(String orderId, String channelName, String type,
      BuildContext context) async {
    try {
      loading.value = true;

      if (channelName == 'string') {
        channelName = DateTime.now().millisecondsSinceEpoch.toString();
      }

      Agora token = await _apiRepository.getAgoraToken(channelName, '2');

      // if (token.rtcToken != null) {
      //   bool res = await _apiRepository.setChannel(
      //       orderId, channelName, token.rtcToken!);
      // }

      loading.value = false;
    } on DioError catch (e) {
      loading.value = false;
      print(e.response);
      Get.snackbar(
        'Error',
        'Something went wrong',
      );
    }
  }

  getOrderList(bool isLawyer, BuildContext context) async {
    try {
      loading.value = true;
      final res = await _apiRepository.orderList();
      orders.value = res;
      Navigator.of(context).push(createRoute(OrdersView(
        title: 'Захиалгууд',
        isLawyer: isLawyer,
      )));
      loading.value = false;
    } on DioError catch (e) {
      loading.value = false;
      Get.snackbar(
        'Error',
        e.response?.data ?? 'Something went wrong',
      );
    }
  }

  getSuggestLawyer(String? title, String? description, String sId,
      BuildContext context) async {
    try {
      loading.value = true;
      Navigator.of(context).push(createRoute(SubServiceView(
        title: title,
        description: description,
      )));
      selectedSubService.value = sId;
      // final lRes = await _apiRepository.suggestedLawyersByCategory(
      //     selectedService.value, sId);
      // lawyers.value = lRes;

      loading.value = false;
    } on DioError catch (e) {
      loading.value = false;
      Get.snackbar(
        'Error',
        e.response?.data ?? 'Something went wrong',
      );
    }
  }

  Future<bool> getSubServices(String id) async {
    try {
      loading.value = true;
      order.value?.serviceId = id;
      final res = await _apiRepository.subServiceList(id);
      subServices.value = res;

      loading.value = false;
      return true;
    } on DioError catch (e) {
      loading.value = false;
      Get.snackbar(
        'Error',
        e.response?.data ?? 'Something went wrong',
      );
      return false;
    }
  }

  start() async {
    try {
      loading.value = true;
      final res = await _apiRepository.servicesList();
      services.value = res;
      final lRes = await _apiRepository.suggestedLawyers();
      lawyers.value = lRes;
      final ordersRes = await _apiRepository.orderList();
      orders.value = ordersRes;

      loading.value = false;
    } on DioError catch (e) {
      loading.value = false;
      Get.snackbar(
        'Error',
        e.response?.data ?? 'Something went wrong',
      );
    }
  }

  @override
  onClose() {
    super.onClose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }
}
