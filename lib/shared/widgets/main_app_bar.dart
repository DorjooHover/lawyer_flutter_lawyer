import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/modules/home/controllers/controllers.dart';
import 'package:frontend/shared/constants/index.dart';
import 'package:get/get.dart';

const double kToolbarHeight = 76.0;

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  MainAppBar({
    super.key,
    required this.currentIndex,
    this.titleMargin = 0.0,
    this.hasLeading = true,
    this.calendar = false,
    this.paddingBottom = 12.0,
    this.wallet = false,
    this.settingTap,
    this.calendarTap,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.settings = false,
  });
  final int currentIndex;
  final bool hasLeading;
  final bool settings;
  final double paddingBottom;
  final bool calendar;
  final Function()? settingTap;
  final Function()? calendarTap;
  final bool wallet;
  final double titleMargin;
  final MainAxisAlignment mainAxisAlignment;
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  List<String> lawyerTitles = ['Нүүр', 'Захиалгууд', 'Профайл', ''];
  List<String> titles = ['Нүүр', 'Яаралтай', "Захиалгууд", "Профайл"];
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + origin),
      padding: const EdgeInsets.symmetric(horizontal: origin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => controller.currentUserType.value == 'lawyer' ||
                      controller.currentUserType.value == 'our'
                  ? Text(
                      lawyerTitles[controller.currentIndex.value],
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  : Text(
                      titles[controller.currentIndex.value],
                      style: Theme.of(context).textTheme.titleLarge,
                    )),
              Row(
                children: [
                  settings
                      ? IconButton(
                          onPressed: settingTap,
                          icon: SvgPicture.asset(svgSettings))
                      : const SizedBox(),
                  calendar
                      ? IconButton(
                          onPressed: calendarTap,
                          icon: SvgPicture.asset(svgCalendar))
                      : const SizedBox()
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
