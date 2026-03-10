// ignore_for_file: must_be_immutable, avoid_print, use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:astrowaypartner/controllers/Chattimercontroller.dart';
import 'package:astrowaypartner/controllers/HomeController/productController.dart';
import 'package:astrowaypartner/utils/constantskeys.dart';
import 'package:astrowaypartner/views/HomeScreen/chat/ChatSession.dart';
import 'package:astrowaypartner/views/HomeScreen/home_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/products/productScreen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:swipe_to/swipe_to.dart';
import '../../../constants/colorConst.dart';
import '../../../controllers/Authentication/signup_controller.dart';
import '../../../controllers/HomeController/call_controller.dart';
import '../../../controllers/HomeController/chat_controller.dart';
import '../../../controllers/HomeController/timer_controller.dart';
import '../../../controllers/HomeController/wallet_controller.dart';
import '../../../controllers/free_kundli_controller.dart';
import '../../../models/History/chat_history_model.dart';
import '../../../models/chat_message_model.dart';
import '../../../services/apiHelper.dart';
import '../../../widgets/chat_app_bar_widget.dart';
import 'pdfviewerpage.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

import 'zoomimagewidget.dart';

class ChatScreen extends StatefulWidget {
  int flagId;
  final String customerName;
  final int customerId;
  final String? fireBasechatId;
  int? fromrejoin;
  final String? chatId;
  int? astrologerId;
  final String? astrologerName;
  final String customerProfile;
  final String? fcmToken;
  final int? chatduration;
  final dynamic astrouserID;
  final dynamic subscriptionId;

  ChatHistoryModel? chatHistoryData;
  ChatScreen({
    super.key,
    this.fromrejoin = 0,
    required this.flagId,
    required this.customerName,
    required this.customerProfile,
    required this.customerId,
    required this.chatduration,
    this.fireBasechatId,
    this.chatId,
    this.astrologerId,
    this.astrologerName,
    this.chatHistoryData,
    this.fcmToken,
    this.astrouserID,
    this.subscriptionId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final chatController = Get.find<ChatController>();
  final callController = Get.find<CallController>();
  final timecontroller = Get.find<TimerController>();
  final messageController = TextEditingController();
  final walletController = Get.put(WalletController());
  final productController = Get.find<Productcontroller>();
  final chattimerController = Get.find<ChattimerController>();
  bool isuertyping = true;
  ChatMessageModel? message;
  final apiHelper = APIHelper();
  final sendtextfocusnode = FocusNode();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? userLeftChat;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatController.isReading = true;
      _showprints();
      if (widget.flagId != 2) {
        _updateOnlineStatus();
      }

      if (widget.fromrejoin == 1) {
        _initializeCountdownController();
      } else {
        global.isChatTimerStarted = false;
        print("NOT FROM REJOIN");
      }
      chatController.chatLeft = false;
      chatController.update();
      // ---- LISTENER FOR CUSTOMER LEAVING CHAT ----
      userLeftChat = chatController
          .getUserOnlineStatus(
        userID: widget.customerId.toString(),
        firebasid: widget.fireBasechatId,
      )
          .listen((snapshot) {
        if (!mounted) return;

        bool isInChat = snapshot.data()?['isInChat'] ?? false;

        print("isInChat- $isInChat");
        print("global.isChatTimerStarted- ${global.isChatTimerStarted}");

        if (isInChat == false && global.isChatTimerStarted == true) {
          /// Avoid repeating exit logic
          if (!chatController.chatLeft) {
            chatController.chatLeft = true;
            Get.back();

            backpress(eddedfrom: "firebase stream");
          }
        }
      });
    });
  }

  void _showprints() {
    debugPrint('customerName: ${widget.customerName}');
    debugPrint('customerId: ${widget.customerId}');
    debugPrint('fireBasechatId: ${widget.fireBasechatId}');
    debugPrint('chatId: ${widget.chatId}');
    debugPrint('astrologerId: ${widget.astrologerId}');
    debugPrint('astrologerName: ${widget.astrologerName}');
    debugPrint('customerProfile: ${widget.customerProfile}');
    debugPrint('fcmToken: ${widget.fcmToken}');
    debugPrint('chatduration: ${widget.chatduration}');
    debugPrint('astrouserID: ${widget.astrouserID}');
    debugPrint('subscriptionId: ${widget.subscriptionId}');
  }

  void _updateOnlineStatus() {
    apiHelper.setAstrologerOnOffBusyline("Busy");
    global.inChatscreen(true);
    global.firebaseChatId = widget.fireBasechatId;
    global.isCallOrChat = 1;
    chatController.setOnlineStatus(
        true, widget.fireBasechatId.toString(), '${global.currentUserId}',
        extiform: "from init for User");
    chatController.setOnlineStatus(
        true, widget.fireBasechatId.toString(), '${widget.astrologerId}',
        extiform: "from init for astrologer");
  }

  void _initializeCountdownController() {
    final endTime = DateTime.now().millisecondsSinceEpoch +
        1000 * int.parse(widget.chatduration.toString());
    chattimerController.endTime = endTime;
    chattimerController.update();
    debugPrint("New time After Update $endTime");
  }

  void _updateChatSession() {
    final session = ChatSession(
        sessionId: '${widget.customerId}_${widget.astrologerId}',
        customerId: widget.customerId,
        astrologerId: widget.astrologerId!,
        fireBasechatId: widget.fireBasechatId ?? chatController.firebaseChatId,
        customerName: widget.customerName,
        customerProfile: widget.customerProfile,
        chatduration: (chattimerController.totalDuration ~/ 1000).toString(),
        astrouserID: widget.astrouserID,
        userFcm: widget.fcmToken,
        subscriptionId: widget.subscriptionId,
        lastSaved: global.getStorage.read('chatStartedAt').toString());
    print(
        "last saved used ${global.getStorage.read('chatStartedAt').toString()}");
    Get.find<ChatController>().addSession(session); //add session
    Get.to(() => HomeScreen());
  }

  @override
  void dispose() {
    log('chat screen ondispose online ');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          log('sending chatstarted time is 0 ${global.chatStartedAt}');
          if (widget.flagId == 2) {
            Get.back();
          } else {
            chatController.isReading = false;
            log('else ${chatController.isReading}');
            _updateChatSession();
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: ChatAppBar(
          firebasechatid: widget.fireBasechatId,
          flagid: widget.flagId,
          customerid: widget.customerId,
          counterduration: widget.chatduration,
          profile: widget.customerProfile,
          customername: widget.customerName,
          height: 80,
          backgroundColor: COLORS().primaryColor,
          leading: InkWell(
            onTap: () async {
              if (widget.flagId == 2) {
                Get.back();
                log('isnde flagid 2');
              } else {
                log('sending chatstarted time is 3 ${global.chatStartedAt}');
                _updateChatSession();
              }
            },
            child:  Icon(Icons.arrow_back, color: COLORS().textColor),
          ),
          actions: [
            InkWell(
                onTap: () async {
                  global.showOnlyLoaderDialog();
                  await Get.find<KundliController>()
                      .getBasicDetailChart(widget.customerId, false);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      border: Border.all(color: COLORS().textColor),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    'Kundli',
                    style: TextStyle(
                        color:COLORS().textColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500),
                  ),
                )),
            SizedBox(width: 1.w),
            widget.flagId == 2
                ? const SizedBox()
                : GetBuilder<KundliController>(
                    builder: (kundliController) {
                      return InkWell(
                          onTap: () {
                            //exit
                            print(
                                "chatleft from button- ${chatController.chatLeft}");
                            chatController.chatLeft
                                ? null
                                : backpress(eddedfrom: "from Exit Btn");
                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                  color: Get.theme.primaryColor,
                                  border: Border.all(color: COLORS().textColor),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                "Exit",
                                style: TextStyle(
                                  color: COLORS().textColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11.sp,
                                ),
                              )));
                    },
                  ),
            SizedBox(width: 1.w),
          ],
        ),
        body: SafeArea(
          child: KeyboardVisibilityBuilder(
            builder: (p0, isKeyboardVisible) {
              if (isKeyboardVisible) {
                log('keyboard is visible');
                chatController.updateTypingStatus(widget.customerId.toString(),
                    widget.astrologerId.toString(), true);
              } else {
                log('keyboard is invisible');
                chatController.updateTypingStatus(widget.customerId.toString(),
                    widget.astrologerId.toString(), false);
              }
              return Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/chat_background.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    GetBuilder<ChatController>(builder: (chatController) {
                      return Column(
                        children: [
                          Expanded(
                            child: StreamBuilder<
                                    QuerySnapshot<Map<String, dynamic>>>(
                                stream: chatController.getChatMessages(
                                    widget.fireBasechatId == null
                                        ? chatController.firebaseChatId
                                        : widget.fireBasechatId!,
                                    widget.astrologerId),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text(
                                        'snapShotError :- ${snapshot.error}');
                                  } else {
                                    List<ChatMessageModel> messageList = [];

                                    if (snapshot.hasData) {
                                      for (var res in snapshot.data!.docs) {
                                        messageList.add(
                                            ChatMessageModel.fromJson(
                                                res.data()));
                                      }
                                    } else {
                                      messageList = [];
                                      log('no data for msg');
                                    }

                                    chatController.isReading == true
                                        ? chatController.markMessagesAsRead(
                                            widget.fireBasechatId == null
                                                ? chatController.firebaseChatId
                                                : widget.fireBasechatId!,
                                            widget.customerId)
                                        : null;

                                    // Play sound when a new message is received
                                    if (messageList.isNotEmpty &&
                                        snapshot.hasData) {
                                      debugPrint(
                                          'first msage is ${messageList.first.message} ');

                                      if (messageList.first.isEndMessage ==
                                          true) {
                                      } else {
                                        // Ensure this only plays on new messages
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          chatController.audioPlayer.play(
                                            AssetSource(
                                                'sounds/message_sound.mp3'),
                                          );
                                        });
                                      }
                                    }

                                    return ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        padding: EdgeInsets.only(bottom: 10.h),
                                        itemCount: messageList.length,
                                        shrinkWrap: true,
                                        reverse: true,
                                        itemBuilder: (context, index) {
                                          ChatMessageModel message =
                                              messageList[index];
                                          chatController.isMe =
                                              message.userId1 ==
                                                  '${global.currentUserId}';
                                          print(
                                              'isread index- $index - ${messageList[index].isRead}');
                                          return messageList[index]
                                                      .isEndMessage ==
                                                  true
                                              ? Container(
                                                  color: const Color.fromARGB(
                                                      255, 247, 244, 211),
                                                  margin: const EdgeInsets.only(
                                                      bottom: 10),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    messageList[index].message!,
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                              : Row(
                                                  mainAxisAlignment:
                                                      chatController.isMe
                                                          ? MainAxisAlignment
                                                              .end
                                                          : MainAxisAlignment
                                                              .start,
                                                  crossAxisAlignment:
                                                      chatController.isMe
                                                          ? CrossAxisAlignment
                                                              .end
                                                          : CrossAxisAlignment
                                                              .start,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: chatController
                                                                .isMe
                                                            ? messageList[index]
                                                                        .attachementPath ==
                                                                    ""
                                                                ? const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    247,
                                                                    244,
                                                                    211)
                                                                : Colors.white
                                                            : messageList[index]
                                                                        .attachementPath ==
                                                                    ""
                                                                ? Colors.grey
                                                                    .shade100
                                                                : Colors.white,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft: const Radius
                                                              .circular(12),
                                                          topRight: const Radius
                                                              .circular(12),
                                                          bottomLeft:
                                                              chatController
                                                                      .isMe
                                                                  ? const Radius
                                                                      .circular(
                                                                      0)
                                                                  : const Radius
                                                                      .circular(
                                                                      12),
                                                          bottomRight:
                                                              chatController
                                                                      .isMe
                                                                  ? const Radius
                                                                      .circular(
                                                                      0)
                                                                  : const Radius
                                                                      .circular(
                                                                      12),
                                                        ),
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10,
                                                          horizontal: 16),
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 16,
                                                          horizontal: 8),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            chatController.isMe
                                                                ? CrossAxisAlignment
                                                                    .end
                                                                : CrossAxisAlignment
                                                                    .start,
                                                        children: [
                                                          GetBuilder<
                                                              ChatController>(
                                                            builder:
                                                                (ccontroller) =>
                                                                    SwipeTo(
                                                              key: UniqueKey(),
                                                              iconOnLeftSwipe: Icons
                                                                  .arrow_forward,
                                                              iconOnRightSwipe:
                                                                  Icons.reply,
                                                              onRightSwipe:
                                                                  (details) {
                                                                dev.log(
                                                                    "\n Left Swipe Data --> $details");
                                                                sendtextfocusnode
                                                                    .requestFocus();
                                                                ccontroller
                                                                        .replymessage =
                                                                    messageList[
                                                                        index];
                                                                ccontroller
                                                                    .update();
                                                                dev.log(
                                                                    " Swipe details --> ${ccontroller.replymessage!.toJson()}");
                                                              },
                                                              swipeSensitivity:
                                                                  5,
                                                              child: messageList[index]
                                                                              .replymsg !=
                                                                          null &&
                                                                      messageList[index]
                                                                              .replymsg !=
                                                                          ""
                                                                  ? Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        IntrinsicHeight(
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              Container(
                                                                                color: Colors.green,
                                                                                width: 1.w,
                                                                              ),
                                                                              SizedBox(width: 3.w),
                                                                              messageList[index].replymsg != null && messageList[index].replymsg!.contains('.png') || messageList[index].replymsg != null && messageList[index].replymsg!.contains('.jpg') || messageList[index].replymsg != null && messageList[index].replymsg!.contains('.jpeg')
                                                                                  ? Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        CachedNetworkImage(
                                                                                          height: 10.h,
                                                                                          width: 30.w,
                                                                                          imageUrl: messageList[index].replymsg!,
                                                                                          imageBuilder: (context, imageProvider) => Image.network(
                                                                                            messageList[index].replymsg!,
                                                                                            width: MediaQuery.of(context).size.width,
                                                                                            fit: BoxFit.fill,
                                                                                          ),
                                                                                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                                          errorWidget: (context, url, error) => Image.asset(
                                                                                            'assets/images/close.png',
                                                                                            height: 10.h,
                                                                                            width: 30.w,
                                                                                            fit: BoxFit.fill,
                                                                                          ),
                                                                                        ),
                                                                                        Text(DateFormat().add_jm().format(messageList[index].createdAt!),
                                                                                            style: const TextStyle(
                                                                                              color: Colors.grey,
                                                                                              fontSize: 9.5,
                                                                                            )),
                                                                                      ],
                                                                                    )
                                                                                  : messageList[index].replymsg!.contains('.pdf')
                                                                                      ? SizedBox(
                                                                                          height: 9.h,
                                                                                          width: 9.h,
                                                                                          child: const Image(image: AssetImage('assets/images/pdf.png')),
                                                                                        )
                                                                                      : messageList[index].replymsg != "" || messageList[index].replymsg != null
                                                                                          ? SizedBox(
                                                                                              width: 70.w,
                                                                                              child: Text(
                                                                                                '${messageList[index].replymsg}',
                                                                                                style: TextStyle(
                                                                                                  color: Colors.grey,
                                                                                                  fontSize: 12.sp,
                                                                                                ),
                                                                                              ))
                                                                                          : SizedBox(
                                                                                              width: 70.w,
                                                                                              child: Text(
                                                                                                '${messageList[index].message}',
                                                                                                style: TextStyle(
                                                                                                  color: Colors.grey,
                                                                                                  fontSize: 12.sp,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              70.w,
                                                                          child:
                                                                              Text(
                                                                            '${messageList[index].message}',
                                                                            style:
                                                                                TextStyle(color: Colors.black, fontSize: 12.sp),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : messageList[index]
                                                                              .attachementPath !=
                                                                          ""
                                                                      ? messageList[index]
                                                                              .attachementPath!
                                                                              .toLowerCase()
                                                                              .contains('.pdf')
                                                                          ? InkWell(
                                                                              onTap: () {
                                                                                debugPrint('pdf onclicked');
                                                                                Get.to(() => PdfViewerPage(url: messageList[index].attachementPath!));
                                                                              },
                                                                              child: SizedBox(
                                                                                height: 9.h,
                                                                                width: 9.h,
                                                                                child: const Image(image: AssetImage('assets/images/pdf.png')),
                                                                              ),
                                                                            )
                                                                          : messageList[index].attachementPath!.toLowerCase().contains('.png') || messageList[index].attachementPath!.toLowerCase().contains('.jpg') || messageList[index].attachementPath!.toLowerCase().contains('.jpeg')
                                                                              ? InkWell(
                                                                                  onTap: () {
                                                                                    Get.to(() => zoomImageWidget(url: messageList[index].attachementPath!));
                                                                                  },
                                                                                  child: Column(
                                                                                    children: [
                                                                                      CachedNetworkImage(
                                                                                        height: 10.h,
                                                                                        width: 30.w,
                                                                                        imageUrl: messageList[index].attachementPath!,
                                                                                        imageBuilder: (context, imageProvider) => Image.network(
                                                                                          messageList[index].attachementPath!,
                                                                                          width: MediaQuery.of(context).size.width,
                                                                                          fit: BoxFit.fill,
                                                                                        ),
                                                                                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                                        errorWidget: (context, url, error) => Image.asset(
                                                                                          'assets/images/close.png',
                                                                                          height: 10.h,
                                                                                          width: 30.w,
                                                                                          fit: BoxFit.fill,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              : const SizedBox(
                                                                                  child: Icon(Icons.not_interested_outlined),
                                                                                )
                                                                      : Container(
                                                                          constraints:
                                                                              BoxConstraints(maxWidth: Get.width - 100),
                                                                          child:
                                                                              Text(
                                                                            messageList[index].message!,
                                                                            style:
                                                                                TextStyle(
                                                                              color: chatController.isMe ? Colors.black : Colors.black,
                                                                            ),
                                                                            textAlign: chatController.isMe
                                                                                ? TextAlign.start
                                                                                : TextAlign.start,
                                                                          ),
                                                                        ),
                                                            ),
                                                          ),
                                                          messageList[index]
                                                                      .createdAt !=
                                                                  null
                                                              ? Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Text(
                                                                        DateFormat()
                                                                            .add_jm()
                                                                            .format(messageList[index]
                                                                                .createdAt!),
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              Colors.grey,
                                                                          fontSize:
                                                                              9.5,
                                                                        )),
                                                                    Icon(
                                                                      chatController
                                                                              .isMe
                                                                          ? messageList[index].isRead == true
                                                                              ? Icons.done_all
                                                                              : Icons.done
                                                                          : null,
                                                                      color: messageList[index].isRead ==
                                                                              true
                                                                          ? Colors
                                                                              .blue
                                                                          : Colors
                                                                              .grey,
                                                                      size: 15,
                                                                    )
                                                                  ],
                                                                )
                                                              : const SizedBox()
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                        });
                                  }
                                }),
                          ),
                        ],
                      );
                    }),

                    StreamBuilder<DocumentSnapshot>(
                      stream: chatController
                          .getTypingStatusStream(widget.customerId.toString()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox();
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Container();
                        }
                        // Get the typing status
                        bool isTyping = snapshot.data!['isusertyping'] ?? false;

                        return Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: 100.w,
                            height: 4.h,
                            alignment: Alignment.topCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (isTyping) // Only show if typing is true
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 3.w, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(3.w)),
                                    ),
                                    child: Text(
                                      'typing...',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              color: Colors.white,
                                              fontSize: 10.sp),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    //   key: ValueKey(widget.customerId),
                    //   stream: chatController.getUserOnlineStatus(
                    //     userID: widget.customerId.toString(),
                    //     firebasid: widget.fireBasechatId,
                    //   ),
                    //   builder: (context, snapshot) {
                    //     if (snapshot.hasData) {
                    //       bool isInChat =
                    //           snapshot.data?.data()?['isInChat'] ?? false;
                    //       print("isInChat- ${isInChat}");
                    //       print("global.isChatTimerStarted- ${global.isChatTimerStarted}");
                    //       if (isInChat == false && global.isChatTimerStarted==true) {
                    //         // Cancel any existing timer (to avoid stacking)
                    //        if(chatController.chatLeft) {
                    //          null;
                    //        } else
                    //        {
                    //            Get.back();
                    //              backpress(
                    //                  eddedfrom:
                    //                  "firebase strxeam");
                    //            }
                    //        // Exit or go back
                    //       }
                    //
                    //       // If user comes back to chat, cancel the timer
                    //       // if (previousIsInChat == false && isInChat == true) {
                    //       //   leaveTimer?.cancel();
                    //       // }
                    //
                    //       // previousIsInChat = isInChat;
                    //     }
                    //
                    //     if (snapshot.hasError) {
                    //       log('snapShotError :- ${snapshot.error}');
                    //       return const SizedBox();
                    //     }
                    //
                    //     return const SizedBox();
                    //   },
                    // ),

                    //SEND MSG
                    widget.flagId == 2
                        ? const SizedBox()
                        : GetBuilder<ChatController>(
                            builder: (ccontroller) => Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (ccontroller.replymessage?.message
                                                ?.isNotEmpty ==
                                            true ||
                                        ccontroller.replymessage
                                                ?.attachementPath?.isNotEmpty ==
                                            true)
                                    ? _replywidget()
                                    : const SizedBox.shrink(),
                                Container(
                                  padding: EdgeInsets.only(left: 2.w),
                                  margin: EdgeInsets.only(bottom: 1.h),
                                  child: GetBuilder<ChatController>(
                                      builder: (chatController) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(2.w),
                                                  bottomRight:
                                                      Radius.circular(2.w),
                                                )),
                                            // height: 7.h,
                                            child: TextFormField(
                                              focusNode: sendtextfocusnode,
                                              controller: messageController,
                                              maxLines: 6,
                                              minLines: 1,
                                              onChanged: (value) {},
                                              cursorColor: Colors.black,
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              decoration: InputDecoration(
                                                hintText: 'Enter message here',
                                                hintStyle: TextStyle(
                                                    color:
                                                        Colors.grey.shade600),
                                                contentPadding:
                                                    EdgeInsets.only(left: 2.w),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(2.w),
                                                    bottomRight:
                                                        Radius.circular(2.w),
                                                  ),
                                                  borderSide: const BorderSide(
                                                      color: Colors.grey),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  2.w),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  2.w)),
                                                  borderSide: const BorderSide(
                                                      color: Colors.grey),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(bottom: 1.h),
                                          padding:
                                              const EdgeInsets.only(left: 3.0),
                                          child: Material(
                                            elevation: 3,
                                            color: Colors.transparent,
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(100),
                                            ),
                                            child: Container(
                                                height: 6.h,
                                                width: 6.h,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade700,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                child: InkWell(
                                                  onTap: () async {
                                                    //! Attachement work
                                                    String? filepicked =
                                                        await chatController
                                                            .pickFiles();
                                                    log('onclick file is $filepicked');
                                                    chatController
                                                        .sendFiletoFirebase(
                                                      widget.fireBasechatId ==
                                                              null
                                                          ? chatController
                                                              .firebaseChatId
                                                          : widget
                                                              .fireBasechatId!,
                                                      widget.customerId,
                                                      File(filepicked!),
                                                      context,
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5.0),
                                                    child: Icon(
                                                      Icons.file_copy_sharp,
                                                      size: 18.sp,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(bottom: 1.h),
                                          padding:
                                              const EdgeInsets.only(left: 1.0),
                                          child: Material(
                                            elevation: 3,
                                            color: Colors.transparent,
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(100),
                                            ),
                                            child: Container(
                                              height: 6.h,
                                              width: 6.h,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade700,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              child: InkWell(
                                                onTap: () async {
                                                  log('clicked first');

                                                  // Refine and filter the message
                                                  String refinedMessage =
                                                      chatController
                                                          .addBlockKeywordInList(
                                                              messageController
                                                                  .text);
                                                  String filtertext = chatController
                                                      .filterBlockedWordsForSending(
                                                          refinedMessage);
                                                  log('filtered message: $filtertext');
                                                  if (chatController
                                                      .tempBlockedKeywords
                                                      .isNotEmpty) {
                                                    // log('tempBlockedKeywords is not empty try to send to api for store');
                                                    await chatController
                                                        .storedefaultmessage(
                                                            messageController
                                                                .text,
                                                            widget.astrouserID,
                                                            widget.customerId);
                                                  } else {
                                                    //
                                                    log('no blocked content go ahead');
                                                  }

                                                  // Clear temporary blocked keywords
                                                  chatController
                                                      .tempBlockedKeywords
                                                      .clear();

                                                  // Check if replying or sending a new message
                                                  if (ccontroller
                                                              .replymessage!
                                                              .message
                                                              ?.isNotEmpty ==
                                                          true ||
                                                      ccontroller
                                                              .replymessage!
                                                              .attachementPath
                                                              ?.isNotEmpty ==
                                                          true) {
                                                    log('clicked sec');

                                                    // Send reply message
                                                    chatController
                                                        .sendReplyMessage(
                                                      filtertext,
                                                      widget.customerId,
                                                      false,
                                                      ccontroller
                                                                  .replymessage!
                                                                  .attachementPath
                                                                  ?.isNotEmpty ==
                                                              true
                                                          ? ccontroller
                                                              .replymessage!
                                                              .attachementPath!
                                                          : ccontroller
                                                                  .replymessage!
                                                                  .message ??
                                                              'N/A',
                                                    );
                                                  } else if (messageController
                                                      .text.isNotEmpty) {
                                                    // Send normal message
                                                    chatController.sendMessage(
                                                        filtertext,
                                                        widget.customerId,
                                                        false,
                                                        "normalMessage");
                                                  }

                                                  // Clear input and reply field
                                                  messageController.clear();
                                                  ccontroller.replymessage!
                                                      .reset();
                                                  ccontroller.update();
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5.0),
                                                  child: Icon(
                                                    Icons.send,
                                                    size: 18.sp,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ],
                            ),
                          )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _replywidget() {
    return Container(
      width: 73.w, //87.w
      height: 30.h,
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2.w),
            topRight: Radius.circular(2.w),
          )),
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      child: SingleChildScrollView(
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.green,
                    width: 1.w,
                  ),
                  SizedBox(width: 1.w),
                  GetBuilder<ChatController>(
                    builder: (controller) => Stack(
                      children: [
                        Container(
                            width: 67.w,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(2.w),
                                topRight: Radius.circular(2.w),
                              ),
                            ),
                            //CHECKC WHAT IS YOU SWIPING
                            child: controller.replymessage!.message != "" &&
                                    controller.replymessage!.message != null
                                ? Text(
                                    '${controller.replymessage!.message}',
                                    style: TextStyle(
                                        fontSize: 12.sp, color: Colors.black),
                                  )
                                : controller.replymessage?.attachementPath != null &&
                                        controller.replymessage!.attachementPath!
                                            .contains('pdf')
                                    ? SizedBox(
                                        height: 9.h,
                                        width: 9.h,
                                        child: const Image(
                                            image: AssetImage(
                                                'assets/images/pdf.png')),
                                      )
                                    : controller.replymessage?.attachementPath != null &&
                                                controller.replymessage!
                                                    .attachementPath!
                                                    .toLowerCase()
                                                    .contains('.png') ||
                                            controller.replymessage?.attachementPath !=
                                                    null &&
                                                controller.replymessage!
                                                    .attachementPath!
                                                    .toLowerCase()
                                                    .contains('.jpg') ||
                                            controller.replymessage?.attachementPath !=
                                                    null &&
                                                controller.replymessage!
                                                    .attachementPath!
                                                    .toLowerCase()
                                                    .contains('.jpeg')
                                        ? CachedNetworkImage(
                                            height: 10.h,
                                            width: 30.w,
                                            imageUrl: controller
                                                .replymessage!.attachementPath!,
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Image.network(
                                              controller.replymessage!
                                                  .attachementPath!,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              fit: BoxFit.fill,
                                            ),
                                            placeholder: (context, url) =>
                                                const Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                              'assets/images/close.png',
                                              height: 10.h,
                                              width: 30.w,
                                              fit: BoxFit.fill,
                                            ),
                                          )
                                        : const SizedBox.shrink()),
                        Positioned(
                          top: 1,
                          right: 1,
                          child: GestureDetector(
                            onTap: () {
                              controller.replymessage!.reset();
                              controller.update();
                            },
                            child: const Icon(Icons.close),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  final signupController = Get.find<SignupController>();
  void backpress({String eddedfrom = ""}) async {
    debugPrint("Chat Ended on click of $eddedfrom");
    userLeftChat!.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ConstantsKeys.ISACCEPTED, false);
    await prefs.setString(ConstantsKeys.ISACCEPTEDDATA, '');
    await prefs.setBool(ConstantsKeys.ISREJECTED, false);
    global.isChatTimerStarted = false;
    callController.newIsStartTimer = false;
    chattimerController.isTimerStarted = false;
    chattimerController.update();
    callController.update();
    chattimerController.resetTimer();
    global.chatStartedAt = null;

    if (chatController.activeSessions.values.isNotEmpty) {
      final session = chatController.activeSessions.values.first;
      log('removed session is $session');
      Get.find<ChatController>().removeSession(session.sessionId,
          firebasechatId: widget.fireBasechatId);
    } else {
      log('No active audio call sessions found');
    }
    chatController.chatLeft = true;
    chatController.update();
    if (widget.flagId == 1) {
      global.inChatscreen(false);
      global.sendNotification(
          title: "Astro left chat", fcmToken: widget.fcmToken);
      chatController.sendMessage('${global.user.name} -> ended chat',
          widget.customerId, true, "chat_screen_backpress");

      bool success = await apiHelper.setAstrologerOnOffBusyline("Online");

      if (success) {
        log('Astrologer status set to Online successfully');
        signupController.oflinestatus = true;
        signupController.update();
        Get.back();
        chatController.isInChatScreen = false;
        global.getStorage.write('chatStartedAt', 0);
        await global.getStorage.save();
        print("exit time:- ${global.getStorage.read('chatStartedAt')}");
        chatController.update();
      } else {
        log('Failed to set Astrologer status to Online');
      }
      Future.wait([
        Get.find<SignupController>().astrologerProfileById(false),
      ]);
      chatController.setOnlineStatus(
          false, widget.fireBasechatId.toString(), '${global.currentUserId}',
          extiform: "form back press");

      showDialog<void>(
        context: context,
        barrierDismissible: false, 
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 8),
              height: 12.h,
              decoration: const BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(15),
                child: Container(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/interrogation-mark.png',
                    height: 7.h,
                  ),
                ),
              ),
            ),
            actions: [
              Text(
                'Do you want to Recommend a Product ?',
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 3.w),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Yes'),
                    onPressed: () {
                      Get.back();
                      productController.getProductList();
                      Get.to(() => Productscreen(astroId: widget.customerId));
                    },
                  ),
                ],
              ),
            ],
          );
        },
      );
    
    
    }
  }
}
