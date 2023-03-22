import 'package:flutter/material.dart';
import 'package:frontend/modules/auth/auth.dart';
import 'package:frontend/modules/prime/prime.dart';
import 'package:frontend/shared/index.dart';
import 'package:get/get.dart';

class PrimeView extends GetView<PrimeController> {
  const PrimeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrimeController());
    final authController = Get.put(AuthController(apiRepository: Get.find()));
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: MainAppBar(
        title: 'Нүүр',
        calendar: true,
        settings: true,
        settingTap: () async {
          await authController.logout();
        },
        calendarTap: () async {
          await controller.getOrderList();
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
            onRefresh: () async {
              await controller.start();
            },
            child: SingleChildScrollView(
              child: Container(
                color: bg,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(origin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                        left: medium,
                        right: medium,
                        top: large,
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(34),
                          image: const DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1449157291145-7efd050a4d0e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
                              ),
                              fit: BoxFit.cover)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lawyer for personalized help ',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          space8,
                          Text(
                            'Protect your family and your rights with expert legal help',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          space24,
                          TextButton(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          horizontal: 12)),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.5),
                                  )),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white)),
                              onPressed: () {},
                              child: Text(
                                'Click here to listen',
                                style: Theme.of(context).textTheme.displaySmall,
                              ))
                        ],
                      ),
                    ),
                    space32,
                    Text(
                      'Үйлчилгээ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    space16,
                    Flexible(
                        child: Obx(
                      () => controller.loading.value
                          ? CircularProgressIndicator()
                          : GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              childAspectRatio: 2.5,
                              mainAxisSpacing: small,
                              shrinkWrap: true,
                              crossAxisSpacing: small,
                              children: controller.services
                                  .map((s) => GestureDetector(
                                        onTap: () => controller.getSubServices(
                                            s.sId!, s.title!),
                                        child: Container(
                                          padding: EdgeInsets.zero,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      origin)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        origin),
                                                                topLeft: Radius
                                                                    .circular(
                                                                        origin)),
                                                        image: DecorationImage(
                                                            image: NetworkImage(
                                                              'https://images.unsplash.com/photo-1449157291145-7efd050a4d0e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
                                                            ),
                                                            fit: BoxFit.cover)),
                                                  )),
                                              space6,
                                              Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    s.title ?? '',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall,
                                                  )),
                                              space6,
                                              Expanded(
                                                  child: Icon(
                                                Icons.arrow_forward_ios,
                                                color: line,
                                              ))
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList()),
                    )),
                    space32,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Хуульчид',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton(
                            onPressed: () {},
                            child: Text(
                              'Бүгдийг харах',
                              style: TextStyle(
                                  color: gray,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            )),
                      ],
                    ),
                    space16,
                    Flexible(
                        flex: 2,
                        child: Obx(
                          () => controller.loading.value
                              ? CircularProgressIndicator()
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: controller.lawyers.length,
                                  itemBuilder: (context, index) => Container(
                                      child: GestureDetector(
                                    onTap: () {
                                      Get.to(() => PrimeLawyer(
                                            description:
                                                controller.lawyers[index].bio ??
                                                    "",
                                            experience: controller
                                                .lawyers[index].experience
                                                .toString(),
                                            name: controller
                                                    .lawyers[index].lastname ??
                                                "",
                                            profession: "Хуульч",
                                            ratings: controller
                                                .lawyers[index].rating,
                                            rating: controller
                                                .lawyers[index].ratingAvg
                                                .toString(),
                                          ));
                                    },
                                    child: MainLawyer(
                                      experience: controller
                                          .lawyers[index].experience
                                          .toString(),
                                      name:
                                          controller.lawyers[index].lastname ??
                                              "",
                                      profession: "Хуульч",
                                      rating: controller
                                          .lawyers[index].ratingAvg
                                          .toString(),
                                    ),
                                  )),
                                ),
                        )),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
