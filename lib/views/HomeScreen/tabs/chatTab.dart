// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrowaypartner/models/chat_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../constants/colorConst.dart';
import '../../../controllers/HomeController/chat_controller.dart';
import '../../../controllers/networkController.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import '../../../main.dart';
import '../../../utils/constantskeys.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  _ChatTabState createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> with AutomaticKeepAliveClientMixin {
  final chatController = Get.find<ChatController>();
  final networkController = Get.find<NetworkController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getchatlistdata());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title:  Text("Chat Request",
        style: TextStyle(
          color: COLORS().textColor
        ),).tr(),
      ),
      body: GetBuilder<ChatController>(
        builder: (chatController) {
          return chatController.chatList.isEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        right: 10,
                        bottom: 200,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: COLORS().primaryColor,
                        ),
                        onPressed: () async {
                          var status = networkController.connectionStatus.value;
                          if (status <= 0) {
                            global.showToast(message: 'No internet');
                            return;
                          }
                          await chatController.getChatList(false);
                          chatController.update();
                        },
                        child:  Icon(
                          Icons.refresh_outlined,
                          color:COLORS().textColor,
                        ),
                      ),
                    ),
                    Center(
                      child:
                          const Text('You don\'t have chat request yet!').tr(),
                    ),
                  ],
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await chatController.getChatList(true);
                  },
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: chatController.chatList.length,
                    physics: const ClampingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    controller: chatController.scrollController,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 80,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[200],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              '${chatController.chatList[index].profile}',
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                            "assets/images/no_customer_image.png",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: -5,
                                      right: -5,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: const CircleAvatar(
                                          radius: 10,
                                          backgroundColor: Colors.blue,
                                          child: Icon(
                                            Icons.chat,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color: COLORS().primaryColor,
                                            size: 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 5,
                                            ),
                                            child: Text(
                                              chatController.chatList[index]
                                                              .name ==
                                                          "" ||
                                                      chatController
                                                              .chatList[index]
                                                              .name ==
                                                          null
                                                  ? "User"
                                                  : chatController
                                                      .chatList[index].name!,
                                              style: Get.theme.primaryTextTheme
                                                  .displaySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_month_outlined,
                                              color: COLORS().primaryColor,
                                              size: 20,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 5,
                                              ),
                                              child: Text(
                                                DateFormat('dd-MM-yyyy').format(
                                                  DateTime.parse(
                                                    chatController
                                                        .chatList[index]
                                                        .birthDate
                                                        .toString(),
                                                  ),
                                                ),
                                                style: Get
                                                    .theme
                                                    .primaryTextTheme
                                                    .titleSmall,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      chatController.chatList[index].birthTime!
                                              .isNotEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                top: 5,
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.schedule_outlined,
                                                    color:
                                                        COLORS().primaryColor,
                                                    size: 20,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 5,
                                                    ),
                                                    child: Text(
                                                      chatController
                                                          .chatList[index]
                                                          .birthTime!,
                                                      style: Get
                                                          .theme
                                                          .primaryTextTheme
                                                          .titleSmall,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : const SizedBox(),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.green[400]!,
                                            Colors.green[600]!
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.green.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                        onPressed: () {
                                          _handleacceptchat(index);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.phone,
                                                color: Colors.white, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              "Accept",
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ).tr(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Reject Button
                                    Container(
                                      width: 100,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: COLORS().errorColor),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: COLORS().errorColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                        onPressed: () async {
                                          _handleRejectCall(
                                              chatController.chatList[index]);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.call_end,
                                                color: COLORS().errorColor,
                                                size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              "Reject",
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ).tr(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void getchatlistdata() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(ConstantsKeys.ISCHATAVILABLE, false);
    debugPrint('started getchatlistdata');
    await chatController.getChatList(true);
  }

  void _handleacceptchat(int index) async {
    global.isDialogopend = false;
    Future.delayed(
      const Duration(milliseconds: 500),
    ).then((value) async {
      await localNotifications.cancelAll();
    });
    // global.showOnlyLoaderDialog();
    await chatController.storeChatId(
      chatController.chatList[index].id!,
      chatController.chatList[index].chatId!,
    );
    await chatController.acceptChatRequest(
        chatController.chatList[index].subscriptionid ?? "",
        chatController.chatList[index].chatId!,
        chatController.chatList[index].userId,
        chatController.chatList[index].name ?? 'user',
        chatController.chatList[index].profile ?? "",
        chatController.chatList[index].id!,
        chatController.chatList[index].fcmToken??"",
        chatController.chatList[index].chatDuration!,
        "chattab:- ${chatController.chatList[index].fcmToken!}");
    // await chatController.acceptChatRequest(
    //   chatController.chatList[index].subscriptionid ?? "",
    //   chatController.chatList[index].chatId!,
    //   chatController.chatList[index].userId,
    //   chatController.chatList[index].name ?? 'user',
    //   chatController.chatList[index].profile ?? "",
    //   chatController.chatList[index].userId!,
    //   chatController.chatList[index].fcmToken ?? "",
    //   chatController.chatList[index].chatDuration!,
    // );
  }

  Future<void> _handleRejectCall(ChatRequest call) async {
    await FlutterCallkitIncoming.endAllCalls();
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.message_rounded,
                  color: Colors.red[600],
                  size: 32,
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                "Reject Chat?",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ).tr(),

              const SizedBox(height: 8),

              // Message
              Text(
                "Are you sure you want to reject this Chat request?",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ).tr(),

              const SizedBox(height: 24),

              // Buttons Row
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.grey[700],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          global.isDialogopend = false;
                          Get.back();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ).tr(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Reject Button
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red[400]!, Colors.red[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Close notification
                          Future.delayed(const Duration(milliseconds: 300))
                              .then((value) async {
                            await localNotifications.cancelAll();
                          });

                          // Reject call
                          chatController.rejectChatRequest(call.chatId!);
                          chatController.update();
                          Get.back();
                        },
                        child: Text(
                          "Reject",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ).tr(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
