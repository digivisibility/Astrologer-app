// ignore_for_file: file_names

import 'dart:convert';
import 'dart:developer';
import 'package:astrowaypartner/Courses/screen/MyCoursesListScreen.dart';
import 'package:astrowaypartner/controllers/HomeController/chat_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/productController.dart';
import 'package:astrowaypartner/controllers/following_controller.dart';
import 'package:astrowaypartner/controllers/panchangController.dart';
import 'package:astrowaypartner/utils/global.dart';
import 'package:astrowaypartner/views/HomeScreen/Profile/follower_list_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/todays_panchang/panchangScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import '../../../Courses/screen/coursesScreen.dart';
import '../../../constants/messageConst.dart';
import '../../../controllers/AssistantController/add_assistant_controller.dart';
import '../../../controllers/Authentication/signup_controller.dart';
import '../../../controllers/HomeController/astrology_blog_controller.dart';
import '../../../controllers/HomeController/call_controller.dart';
import '../../../controllers/HomeController/home_controller.dart';
import '../../../controllers/HomeController/report_controller.dart';
import '../../../controllers/HomeController/wallet_controller.dart';
import '../../../controllers/dailyHoroscopeController.dart';
import '../../../models/user_model.dart';
import '../../../services/apiHelper.dart';
import '../Drawer/Wallet/Wallet_screen.dart';
import '../Drawer/customer_review_screen.dart';
import '../FloatingButton/AstroBlog/astrology_blog_screen.dart';
import '../FloatingButton/DailyHoroscope/dailyHoroscopeScreen.dart';
import '../FloatingButton/DailyHoroscope/dailyHoroscopeVedic.dart';
import '../FloatingButton/FreeKundli/kundliScreen.dart';
import '../FloatingButton/KundliMatching/kundli_matching_screen.dart';
import '../Report_Module/report_request_screen.dart';
import '../call/hms/hmsLivescreen.dart';
import '../call/zegocloud/zegoLiveScreen.dart';
import '../history/HistroryScreen.dart';
import '../live/live_screen.dart';
import '../poojaModule/mycustompuja.dart';
import '../poojaModule/poojaOrderScreen.dart';
import '../products/productScreen.dart';
import '../tabs/callTab.dart';
import '../tabs/chatTab.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  final signupController = Get.find<SignupController>();
  final apiHelper = APIHelper();
  final assistantController = Get.find<AddAssistantController>();
  final walletController = Get.find<WalletController>();
  final productController = Get.find<Productcontroller>();
  final chatController = Get.find<ChatController>();
  final callController = Get.find<CallController>();
  final reportController = Get.put(ReportController());
  final followingController = Get.put(FollowingController());
  final panchangController = Get.put(PanchangController());
  final dailyhoroscopeController = Get.find<DailyHoroscopeController>();

  Widget _buildHomeButton({
    required VoidCallback onTap,
    required String title,
    required Color color,
    required Widget icon,
    int? badgeCount,
  }) {
    return SizedBox(
      width: 13.h,
      height: 13.h,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.w, horizontal: 1.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: icon,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        title,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp,
                          fontFamily: 'OpenSans',
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ).tr(),
                    ],
                  ),
                ),
              ),
              if (badgeCount != null && badgeCount > 0)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: EdgeInsets.all(0.5.w),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 4.w,
                      minHeight: 4.w,
                    ),
                    child: Center(
                      // Center the badge count text
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeController) => RefreshIndicator(
        onRefresh: () async {
          Future.wait<void>([
            chatController.getChatList(false, isLoading: 0),
            callController.getCallList(false, isLoading: 0),
            reportController.getReportList(false, isLoading: 0),
            followingController.followingList(false, isLoading: 0),
            signupController.astrologerProfileById(false, isLoading: 0),
            walletController.getAmountList(),
          ]);
        },
        child: GetBuilder<ChatController>(
          builder: (chatController) => SizedBox(
            height: 80.h,
            width: 100.w,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  // Only show the online/offline section when isSelectedBottomIcon == 1
                  if (homeController.isSelectedBottomIcon == 1)
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: GetBuilder<SignupController>(
                        builder: (signupController) => Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "You are Currently",
                              style: TextStyle(
                                color: signupController.oflinestatus ==
                                    true
                                    ? Colors.green
                                    : Get.theme.primaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp,
                              ),
                            ).tr(),
                            Row(
                              children: [
                                Text(
                                  signupController.oflinestatus == true
                                      ? "Online"
                                      : "Offline",
                                  style: TextStyle(
                                    color:
                                    signupController.oflinestatus ==
                                        true
                                        ? Colors.green
                                        : Get.theme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.sp,
                                  ),
                                ).tr(),
                                SizedBox(width: 2.w),
                                Transform.scale(
                                  scale: 0.6,
                                  child: Switch(
                                    trackOutlineColor:
                                    MaterialStateProperty.all(
                                      Colors.transparent,
                                    ),
                                    value:
                                    signupController.oflinestatus ??
                                        false,
                                    activeColor: Colors.green,
                                    activeTrackColor:
                                    Colors.green.withOpacity(0.5),
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: Get
                                        .theme.primaryColor
                                        .withOpacity(0.6),
                                    onChanged: (bool value) {
                                      setState(() {
                                        signupController.oflinestatus =
                                            value;
                                        signupController.update();
                                        if (signupController
                                            .oflinestatus ==
                                            true) {
                                          apiHelper
                                              .setAstrologerOnOffBusyline(
                                              'Online');
                                        } else {
                                          apiHelper
                                              .setAstrologerOnOffBusyline(
                                              'Offline');
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  // First Row - Requests
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.5.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildHomeButton(
                          onTap: () {
                            Get.to(() => const ChatTab());
                          },
                          title: "Chat Request",
                          color: Colors.green,
                          icon: const Icon(Icons.chat, color: Colors.green),
                          badgeCount: chatController.chatList.length,
                        ),
                        _buildHomeButton(
                          onTap: () {
                            Get.to(() => const CallTab());
                          },
                          title: "Call Request",
                          color: Colors.orange,
                          icon: const Icon(Icons.call, color: Colors.orange),
                          badgeCount: callController.callList.length,
                        ),
                        _buildHomeButton(
                          onTap: () {
                            Get.to(() => ReportRequestScreen());
                          },
                          title: "Report\nRequest",
                          color: Get.theme.primaryColor,
                          icon: Icon(Icons.picture_as_pdf_outlined,
                              color: Get.theme.primaryColor),
                          badgeCount: reportController.reportList.length,
                        ),
                      ],
                    ),
                  ),

                  // Second Row - Horoscope & Kundli
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ///daily horoscope
                        _buildHomeButton(
                          onTap: () async {
                            // MAIN CALL
                            global.showOnlyLoaderDialog();
                            await dailyhoroscopeController.initHoroscopeFlow();
                            global.hideLoader();
                            if (dailyhoroscopeController.calltype == 2) {
                              Get.to(() => const DailyHoroscopeScreen());
                            } else if (dailyhoroscopeController.calltype == 3) {
                              Get.to(() => const DailyHoroscopeVedic());
                            }
                          },
                          title: "Daily\nHoroscope",
                          color: Colors.purple,
                          icon: Image.asset(
                            'assets/images/daily_horoscope.png',
                            height: 3.h,
                            width: 12.w,
                            color: Colors.purple,
                          ),
                        ),
                        _buildHomeButton(
                          onTap: () {
                            Get.to(() => const KundaliScreen());
                          },
                          title: "Free Kundli",
                          color: Colors.redAccent,
                          icon: Image.asset(
                            'assets/images/free_kundli.png',
                            height: 3.h,
                            width: 11.w,
                            color: Colors.redAccent,
                          ),
                        ),
                        _buildHomeButton(
                          onTap: () {
                            Get.to(() => KundliMatchingScreen());
                          },
                          title: "Kundli\nMatching",
                          color: Colors.lightGreen,
                          icon: Image.asset(
                            'assets/images/kundli_matching.png',
                            height: 3.h,
                            width: 10.w,
                            color: Colors.lightGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.5.h),

                  // Third Row - Puja & Products
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        _buildHomeButton(
                          onTap: () async {
                            Get.to(
                                    () => const PoojaOrderScreen(showAppbar: true));
                          },
                          title: "My Puja",
                          color: Colors.orangeAccent,
                          icon: Image.asset(
                            'assets/images/pujaicon.png',
                            height: 4.h,
                            color: Colors.orangeAccent,
                          ),
                        ),

                        _buildHomeButton(
                          onTap: () async {
                            Get.to(() => const MyCustomPujaListScreen());
                          },
                          title: "Custom Puja",
                          color: Colors.brown,
                          icon: const Icon(Icons.shopping_bag_outlined,
                              color: Colors.brown),
                        ),
                        _buildHomeButton(
                          onTap: () async {
                            await walletController.getAmountList();
                            Get.to(() => WalletScreen());
                          },
                          title: "Wallet\nTransactions",
                          color: Colors.deepPurple,
                          icon: Image.asset(
                            'assets/images/drawericons/wallet.png',
                            height: 2.5.h,
                            width: 10.w,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.5.h),

                  // Fourth Row - Courses & Wallet
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ///getcourses
                        _buildHomeButton(
                          onTap: () {
                            Get.to(() => const Coursesscreen());
                          },
                          title: "Get Course",
                          color: Colors.red,
                          icon: const Icon(Icons.video_collection_outlined,
                              color: Colors.red),
                        ),

                        //mycourses
                        _buildHomeButton(
                          onTap: () async {
                            Get.to(() => const MyCoursesListScreen());
                          },
                          title: "My Courses",
                          color: Colors.purple,
                          icon: const Icon(Icons.airplay, color: Colors.purple),
                        ),
                        _buildHomeButton(
                          onTap: () async {
                            Get.to(() => Productscreen(
                                astroId: 0, isFromHomeScreen: true));
                          },
                          title: "Products",
                          color: Colors.lightBlue,
                          icon: const Icon(Icons.shopping_bag_outlined,
                              color: Colors.lightBlue),
                        ),

                      ],
                    ),
                  ),
                  SizedBox(height: 1.5.h),

                  // Fifth Row - Live & History
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GetBuilder<SignupController>(
                          builder: (signupcontroller) => signupcontroller
                                      .astrologerList.isNotEmpty &&
                                  signupcontroller.astrologerList[0]
                                          ?.isshowlivesections ==
                                      MessageConstants.ISLIVE_ENABLE
                              ? _buildHomeButton(
                                  onTap: () async {
                                    await signupController
                                        .astrologerProfileById(false,
                                            isLoading: 0);
                                    LiveBottomSheet.show(
                                      context,
                                      onInstant: () {
                                        log("callmethod is ->  ${signupcontroller.astrologerList[0]?.callmethod}");

                                        liveAstrologerController.isImInLive =
                                            true;
                                        if (signupcontroller.astrologerList[0]
                                                ?.callmethod ==
                                            "hms") {
                                          Get.to(() => const HMSLiveScreen());
                                        } else if (signupcontroller
                                                .astrologerList[0]
                                                ?.callmethod ==
                                            "agora") {
                                          Get.to(() => const LiveScreen());
                                        } else if (signupcontroller
                                                .astrologerList[0]
                                                ?.callmethod ==
                                            "zegocloud") {
                                          //call to get token
                                          fetchToken();
                                        }
                                        homeController.update();
                                      },
                                      onLater: (dateTime) async {
                                        homeController.scheduleLiveSession(
                                            dateTime,
                                            signupcontroller
                                                    .astrologerList[0]?.id
                                                    .toString() ??
                                                "");
                                        global.showToast(
                                            message:
                                                "You will be notified When live Started");
                                      },
                                    );
                                  },
                                  title: "Go Live",
                                  color: Colors.brown,
                                  icon: Image.asset(
                                    'assets/images/bottombaricons/live.png',
                                    height: 3.h,
                                    width: 12.w,
                                  ),
                                )
                              : const SizedBox(),
                        ),
                        _buildHomeButton(
                          onTap: () async {
                            await signupController.astrologerProfileById(true);
                            Get.to(() => const HistoryScreen());
                          },
                          title: "History",
                          color: Colors.purple,
                          icon: Image.asset(
                            'assets/images/bottombaricons/history.png',
                            height: 3.h,
                            width: 11.w,
                            color: Colors.purple,
                          ),
                        ),
                        _buildHomeButton(
                          onTap: () async {
                            signupController.astrologerList.clear();
                            signupController.clearReply();
                            await signupController.astrologerProfileById(false);
                            signupController.update();
                            Get.to(() => CustomeReviewScreen());
                          },
                          title: "Customer\nReview",
                          color: Colors.pink,
                          icon: Image.asset(
                            'assets/images/drawericons/feedback.png',
                            height: 3.h,
                            width: 9.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.5.h),

                  // Sixth Row - Blog, Panchang & Followers
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildHomeButton(
                          onTap: () async {
                            AstrologyBlogController blogController =
                                Get.find<AstrologyBlogController>();
                            global.showOnlyLoaderDialog();
                            blogController.astrologyBlogs = [];
                            blogController.astrologyBlogs.clear();
                            blogController.isAllDataLoaded = false;
                            blogController.update();
                            await blogController.getAstrologyBlog("", false);
                            global.hideLoader();
                            Get.to(() => AstrologyBlogScreen());
                          },
                          title: "Astrology\nBlog",
                          color: Colors.orangeAccent,
                          icon: Image.asset(
                            'assets/images/astrology_blog.png',
                            height: 3.h,
                            width: 12.w,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        _buildHomeButton(
                          onTap: () async {
                            DateTime dateBasic = DateTime.now();
                            int formattedYear =
                                int.parse(DateFormat('yyyy').format(dateBasic));
                            int formattedDay =
                                int.parse(DateFormat('dd').format(dateBasic));
                            int formattedMonth =
                                int.parse(DateFormat('MM').format(dateBasic));
                            int formattedHour =
                                int.parse(DateFormat('HH').format(dateBasic));
                            int formattedMint =
                                int.parse(DateFormat('mm').format(dateBasic));
                            global.showOnlyLoaderDialog();
                            await panchangController.getBasicPanchangDetail(
                                day: formattedDay,
                                hour: formattedHour,
                                min: formattedMint,
                                month: formattedMonth,
                                year: formattedYear,
                                lat: 21.1255,
                                lon: 73.1122,
                                tzone: 5);
                            panchangController.getPanchangVedic(DateTime.now());
                            global.hideLoader();
                            Get.to(() => const PanchangScreen());
                          },
                          title: "Today's\nPanchang",
                          color: Colors.red,
                          icon: Image.asset(
                            'assets/images/worship.png',
                            height: 3.h,
                            width: 8.w,
                            color: Colors.red,
                          ),
                        ),
                        GetBuilder<FollowingController>(
                            builder: (followingController) {
                          return _buildHomeButton(
                            onTap: () async {
                              followingController.followerList.clear();
                              followingController.followingList(false);
                              Get.to(() => FollowerListScreen());
                            },
                            title: "My\nFollowers",
                            color: Colors.pinkAccent,
                            icon: const Icon(Icons.people_outline,
                                color: Colors.pinkAccent),
                          );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void fetchToken() async {
    sp = await SharedPreferences.getInstance();
    CurrentUser userData = CurrentUser.fromJson(
      json.decode(sp!.getString("currentUser") ?? ""),
    );

    log('zego appid is ${global.getSystemFlagValue(global.systemFlagNameList.zegoAppId)} and zegotoken is ${global.getSystemFlagValue(global.systemFlagNameList.zegoAppSignIn)}');

    await liveAstrologerController.sendLiveToken(
        currentUserId, 'ZegoLive_$currentUserId', '', "");
    global.zegoLiveChannelName = 'ZegoLive_$currentUserId';

    Get.to(() => zegoLiveHostScreen(
          isHost: true,
          username: userData.name,
          userid: userData.id.toString(),
          profile: userData.imagePath,
        ));
  }
}

class LiveBottomSheet {
  static void show(BuildContext context,
      {required Function onInstant,
      required Function(DateTime dateTime) onLater}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 50,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                "Go Live",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Would you like to go live instantly or schedule it for later?",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onInstant();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Go Live Instantly"),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );

                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (pickedTime != null) {
                      final scheduledDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );

                      Navigator.pop(context);
                      onLater(scheduledDateTime);
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: Colors.blueAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Schedule for Later",
                  style: TextStyle(
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}
