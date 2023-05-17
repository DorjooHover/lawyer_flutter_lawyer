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

  final order = Rxn<Order>(Order(location: Location(lng: 0, lat: 0)));
  final services = <Service>[].obs;
  final subServices = <SubService>[].obs;
  final lawyers = <User>[].obs;
  final times = <SortedTime>[SortedTime(day: 0, time: [])].obs;

  final loading = false.obs;
  final selectedService = "".obs;
  final selectedSubService = "".obs;

  final selectedExpiredTime = "".obs;
// order select date
  final selectedLawyer = Rxn<User?>();
  final selectedDate = DateTime.now().obs;

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

  Future<bool> getTimeLawyer() async {
    try {
      loading.value = true;
      List<int> primaryTimes = [];
      List<Time> res = (await _apiRepository
          .getTimeLawyer(selectedLawyer.value!.sId!)) as List<Time>;
      selectedDate.value = DateTime(2023, 5, 14);

      res.forEach((time) {
        for (var element in time.timeDetail!) {
          if (!primaryTimes.contains(element.time!)) {
            primaryTimes.add(element.time!);
          }
        }
      });
      primaryTimes.sort();
      for (int time in primaryTimes) {
        DateTime date = DateTime.fromMillisecondsSinceEpoch(time);
        int day =
            DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
        int nextDay = DateTime(date.year, date.month, date.day + 1)
            .millisecondsSinceEpoch;
        SortedTime sortedTime = times.firstWhere((t) => t.day == day,
            orElse: () => SortedTime(day: 0, time: []));
        if (sortedTime.day == 0) {
          sortedTime.day = day;
          sortedTime.time?.add(time);
        } else {
          sortedTime.time?.add(time);
        }

        if (times
                .firstWhere((element) => element.day == day,
                    orElse: () => SortedTime(day: 0, time: []))
                .day ==
            0) {
          times.add(sortedTime);
        }
      }
      loading.value = false;

      return true;
    } on DioError catch (e) {
      loading.value = false;

      print(e.response);
      Get.snackbar('Уучлаарай', "Таны сонгосон хуульч үнэ оруулаагүй байна");
      return false;
    }
  }

  Future<bool> getTimeService(String type) async {
    try {
      loading.value = true;
      List<int> primaryTimes = [];
      final res =
          await _apiRepository.getTimeService(order.value!.serviceId!, type);
      res.forEach((time) {
        for (var element in time.timeDetail!) {
          if (!primaryTimes.contains(element.time!)) {
            primaryTimes.add(element.time!);
          }
        }
      });
      primaryTimes.sort();
      for (int time in primaryTimes) {
        DateTime date = DateTime.fromMillisecondsSinceEpoch(time);
        int day =
            DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
        int nextDay = DateTime(date.year, date.month, date.day + 1)
            .millisecondsSinceEpoch;
        SortedTime sortedTime = times.firstWhere((t) => t.day == day,
            orElse: () => SortedTime(day: 0, time: []));
        if (sortedTime.day == 0) {
          sortedTime.day = day;
          sortedTime.time?.add(time);
        } else {
          sortedTime.time?.add(time);
        }

        if (times
                .firstWhere((element) => element.day == day,
                    orElse: () => SortedTime(day: 0, time: []))
                .day ==
            0) {
          times.add(sortedTime);
        }
      }
      selectedDate.value = DateTime(2023, 5, 14);

      loading.value = false;
      return true;
    } on DioError catch (e) {
      loading.value = false;
      print(e.response);
      Get.snackbar('Уучлаарай', "Цаг олдсонгүй.");
      return false;
    }
  }

  Future<bool> sendOrder() async {
    try {
      loading.value = true;
      String lawyerId = selectedLawyer.value?.sId ?? '';
      int price = 0;
      int expiredTime = 0;
      if (lawyerId == '') {
        final lawyer = await _apiRepository.activeLawyer(
            order.value!.serviceId!,
            order.value!.serviceType!,
            selectedDate.value.millisecondsSinceEpoch,
            false);

        lawyerId = lawyer.first.lawyer!;
        price = lawyer.first.serviceType!
            .firstWhere((element) => element.type == order.value!.serviceType!)
            .price!;
        expiredTime = lawyer.first.serviceType!
            .firstWhere((element) => element.type == order.value!.serviceType!)
            .expiredTime!;
      }
      await _apiRepository.createOrder(
          selectedDate.value.millisecondsSinceEpoch,
          lawyerId,
          expiredTime,
          price,
          order.value!.serviceType!,
          order.value!.serviceId!,
          selectedSubService.value,
          order.value!.location!);
      loading.value = false;
      return true;
    } on DioError catch (e) {
      loading.value = false;
      print(e.response);
      Get.snackbar(
        'Error',
        'Something went wrong',
      );
      return false;
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
