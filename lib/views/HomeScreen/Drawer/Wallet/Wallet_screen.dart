// ignore_for_file: file_names, must_be_immutable, avoid_print, prefer_interpolation_to_compose_strings, deprecated_member_use

import 'dart:developer';
import 'package:astrowaypartner/constants/messageConst.dart';
import 'package:astrowaypartner/controllers/Authentication/signup_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/wallet_controller.dart';
import 'package:astrowaypartner/views/HomeScreen/Drawer/Wallet/add_amount_screen.dart';
import 'package:astrowaypartner/widgets/common_textfield_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:sizer/sizer.dart';
import '../../../../models/wallet_model.dart';
import '../../FloatingButton/KundliMatching/payment/AddmoneyToWallet.dart';

class WalletScreen extends StatelessWidget {
  WalletScreen({super.key});
  final walletController = Get.find<WalletController>();
  final signupController = Get.find<SignupController>();
  final Color _secondaryAccent = const Color(0xFF64B5F6);
  final Color _successColor = const Color(0xFF66BB6A);
  final Color _pendingColor = const Color(0xFFFFA726);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: GetBuilder<WalletController>(
          builder: (walletController) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildCosmicHeader(walletController),
                  SizedBox(height: 4.h),
                  _buildStatsGrid(walletController),
                  SizedBox(height: 4.h),
                  SizedBox(height: 4.h),
                  _buildHistorySection(walletController),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      title: Text(
        "Wallet",
        style: Get.theme.textTheme.bodyMedium!.copyWith(
          fontSize: 15.sp,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ).tr(),
      centerTitle: false,
      actions: [
        InkWell(
          onTap: () async {
            await walletController.getAmount();
            Get.to(() => AddmoneyToWallet());
          },
          child: Container(
            margin: EdgeInsets.all(4.w),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.black],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 16.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(WalletController walletController) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Pending Withdraw',
              '${walletController.withdraw.totalPending ?? "0"}',
              global.isCoinWallet()
                  ? CachedNetworkImage(
                      imageUrl: global.getSystemFlagValue(
                        global.systemFlagNameList.coinIcon,
                      ),
                      height: 8.w,
                      width: 8.w,
                    )
                  : Center(
                      child: Text(
                        global.getSystemFlagValue(
                            global.systemFlagNameList.currency),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              const [Color(0xFFFF6B6B), Color(0xFFEE5A52)], // Red gradient
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: _buildStatCard(
              'Withdraw Amount',
              '${walletController.withdraw.withdrawAmount ?? "0"}',
              global.isCoinWallet()
                  ? CachedNetworkImage(
                      imageUrl: global.getSystemFlagValue(
                        global.systemFlagNameList.coinIcon,
                      ),
                      height: 8.w,
                      width: 8.w,
                    )
                  : Center(
                      child: Text(
                        global.getSystemFlagValue(
                            global.systemFlagNameList.currency),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              const [Color(0xFF4ECDC4), Color(0xFF44A08D)], // Teal gradient
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: _buildStatCard(
              'Total\nEarning',
              '${walletController.withdraw.totalEarning ?? "0"}',
              global.isCoinWallet()
                  ? CachedNetworkImage(
                      imageUrl: global.getSystemFlagValue(
                        global.systemFlagNameList.coinIcon,
                      ),
                      height: 8.w,
                      width: 8.w,
                    )
                  : Center(
                      child: Text(
                        global.getSystemFlagValue(
                            global.systemFlagNameList.currency),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              const [Color(0xFFA166AB), Color(0xFF764BA2)], // Purple gradient
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String amount, Widget icon, List<Color> gradientColors) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 3),

              // Icon
              Center(
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: icon,
                ),
              ),

              const SizedBox(height: 3),

              // Amount
              Center(
                child: Text(
                  double.tryParse(amount.toString())?.toStringAsFixed(0) ?? "0",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCosmicHeader(WalletController walletController) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Stack(
        children: [
          // Background with shadow
          Container(
            height: 22.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Get.theme.primaryColor,
                  Get.theme.primaryColor.withOpacity(0.8),
                  Get.theme.primaryColor.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Get.theme.primaryColor.withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),

          // Main content
          Container(
            padding: EdgeInsets.all(4.w),
            height: 22.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Wallet Icon
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(Icons.account_balance_wallet_rounded,
                            color: Colors.white, size: 8.w),
                      ),
                      SizedBox(width: 4.w),

                      // Balance Info
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Balance',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ).tr(),
                            SizedBox(height: 1.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    if (global.isCoinWallet())
                                      WidgetSpan(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 6.0),
                                          child: global.buildCoinIcon(),
                                        ),
                                      )
                                    else
                                      TextSpan(
                                        text:
                                            '${global.getSystemFlagValue(global.systemFlagNameList.currency)} ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    TextSpan(
                                      text: walletController
                                                  .withdraw.walletAmount !=
                                              null
                                          ? walletController
                                              .withdraw.walletAmount
                                              .toString()
                                              .split(".")
                                              .first
                                          : "0",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Withdraw Button
                      if (walletController.withdraw.walletAmount != null)
                        InkWell(
                          onTap: () async {
                            walletController.updateAmountId = null;
                            walletController.clearAmount();
                            await walletController.withdrawWalletAmount();
                            Get.to(() => AddAmountScreen());
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 1.5.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.white.withOpacity(0.9),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_upward_rounded,
                                    color: Get.theme.primaryColor, size: 14.sp),
                                SizedBox(width: 1.w),
                                Text(
                                  'Withdraw',
                                  style: TextStyle(
                                    color: Get.theme.primaryColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ).tr(),
                              ],
                            ),
                          ).marginOnly(top: 2.h),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(WalletController walletController) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // Modern Tab Bar
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: TabBar(
                      dividerColor: Colors.transparent,
                      indicatorColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      labelStyle: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      indicator: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF667EEA),
                            Color(0xFF764BA2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667EEA).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(tr('Withdraw History')),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(tr('Wallet History')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Tab Content
                  Container(
                    height: Get.height * 0.50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TabBarView(
                      children: [
                        // Add some subtle animation or shimmer to content
                        _buildWithdrawHistory(walletController),
                        _buildWalletHistory(walletController),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawHistory(WalletController walletController) {
    if (walletController.withdraw.walletModel == null ||
        walletController.withdraw.walletModel!.isEmpty) {
      return _buildEmptyState(Icons.history, "No withdraw history yet");
    }

    return RefreshIndicator(
      onRefresh: () async {
        await walletController.getAmountList();
        walletController.update();
      },
      child: ListView.builder(
        itemCount: walletController.withdraw.walletModel!.length,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemBuilder: (context, index) {
          final transaction = walletController.withdraw.walletModel![index];
          return _buildTransactionItem(
            amount: transaction.withdrawAmount.toString(),
            time: DateFormat('hh:mm a')
                .format(DateTime.parse(transaction.createdAt.toString())),
            date: DateFormat('dd-MM-yyyy')
                .format(DateTime.parse(transaction.createdAt.toString())),
            status: transaction.status!,
            isPending: transaction.status == 'Pending',
            onUpdate: () {
              walletController.fillAmount(transaction);
              walletController.updateAmountId = transaction.id;
              Get.to(() => AddAmountScreen());
              walletController.update();
            },
          );
        },
      ),
    );
  }

  Widget _buildWalletHistory(WalletController walletController) {
    if (walletController.withdraw.walletTransactionModel == null ||
        walletController.withdraw.walletTransactionModel!.isEmpty) {
      return _buildEmptyState(
          Icons.account_balance_wallet, "No transaction history yet");
    }

    return RefreshIndicator(
      onRefresh: () async {
        await walletController.getAmountList();
        walletController.update();
      },
      child: ListView.builder(
        itemCount: walletController.withdraw.walletTransactionModel!.length,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemBuilder: (context, index) {
          final transaction =
              walletController.withdraw.walletTransactionModel![index];
          return _buildWalletTransactionItem(transaction);
        },
      ),
    );
  }

  Widget _buildTransactionItem({
    required String amount,
    required String time,
    required String date,
    required String status,
    required bool isPending,
    required VoidCallback onUpdate,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: isPending
                  ? _pendingColor.withOpacity(0.2)
                  : _successColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPending ? Icons.pending : Icons.check_circle,
              color: isPending ? _pendingColor : _successColor,
              size: 6.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (global.isCoinWallet())
                      global.buildCoinIcon().paddingOnly(right: 4.0)
                    else
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Text(
                          global.getSystemFlagValue(
                              global.systemFlagNameList.currency),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Text(
                      amount,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Icon(Icons.schedule,
                        size: 4.w, color: Colors.black.withOpacity(0.6)),
                    SizedBox(width: 1.w),
                    Text(time,
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 10.sp)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(date,
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.7), fontSize: 10.sp)),
              SizedBox(height: 0.5.h),
              Text(
                status,
                style: TextStyle(
                  color: status == 'Released' ? _successColor : _pendingColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isPending) SizedBox(height: 0.5.h),
              if (isPending)
                GestureDetector(
                  onTap: onUpdate,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _pendingColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Update',
                            style:
                                TextStyle(color: Colors.black, fontSize: 10.sp))
                        .tr(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletTransactionItem(WalletTransactionModel transaction) {
    final icon = _getTransactionIcon(transaction.transactionType.toString());

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Get.theme.primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: icon,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (global.isCoinWallet())
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: global.buildCoinIcon(),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Text(
                          global.getSystemFlagValue(
                              global.systemFlagNameList.currency),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Text(
                      double.tryParse(transaction.amount.toString())
                              ?.toStringAsFixed(1) ??
                          '0.0',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '${transaction.transactionType}'.toUpperCase(),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('dd-MM-yyyy')
                    .format(DateTime.parse(transaction.createdAt.toString())),
                style: TextStyle(
                    color: Colors.black.withOpacity(0.7), fontSize: 10.sp),
              ),
              SizedBox(height: 0.5.h),
              Text(
                transaction.paymentStatus?.toUpperCase() ?? '',
                style: TextStyle(
                  color: transaction.paymentStatus == 'success'
                      ? _successColor
                      : _pendingColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getTransactionIcon(String transactionType) {
    log("Transaction Type: $transactionType");
    switch (transactionType) {
      case 'recharge':
        return Icon(CupertinoIcons.bolt, color: _successColor, size: 6.w);
      case 'Gift':
        return Icon(CupertinoIcons.gift, color: _successColor, size: 6.w);
      case 'VideoCall' || 'video Live Streaming':
        return Icon(CupertinoIcons.video_camera_solid,
            color: Get.theme.primaryColor, size: 6.w);
      case 'audio Live Streaming':
        return Icon(CupertinoIcons.speaker_3_fill,
            color: Get.theme.primaryColor, size: 6.w);
      case 'Call':
        return Icon(CupertinoIcons.phone, color: _secondaryAccent, size: 6.w);
      case 'Chat':
        return Icon(CupertinoIcons.chat_bubble_2,
            color: _secondaryAccent, size: 6.w);
      default:
        return Icon(Icons.receipt, color: Get.theme.primaryColor, size: 6.w);
    }
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.3), size: 20.w),
          SizedBox(height: 2.h),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14.sp,
            ),
          ).tr(),
        ],
      ),
    );
  }

  //Withdraw amount
  void withdrawAmount({int? index}) {
    try {
      Get.defaultDialog(
        title: walletController.updateAmountId != null
            ? tr('UPDATE AN AMOUNT')
            : tr('ADD AN AMOUNT'),
        titleStyle: Get.theme.textTheme.titleSmall,
        content: Column(
          children: [
            Icon(
              Icons.account_balance_outlined,
              size: 50,
              color: Get.theme.primaryColor,
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: CommonTextFieldWidget(
                textEditingController: walletController.cWithdrawAmount,
                hintText: "Add Amount",
                keyboardType: TextInputType.number,
                formatter: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 10,
                counterText: '',
                prefix: Icon(
                  Icons.currency_rupee_outlined,
                  color: Get.theme.primaryColor,
                  size: 25,
                ),
              ),
            )
          ],
        ),
        confirm: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.primaryColor,
            ),
            onPressed: () {
              log("Withdraw Amount :" +
                  walletController.cWithdrawAmount.text.toString());
              if (walletController.updateAmountId != null) {
                if (double.parse(walletController.cWithdrawAmount.text) <=
                    double.parse(
                        walletController.withdraw.walletAmount.toString())) {
                  walletController.updateAmount(
                      walletController.withdraw.walletModel![index!].id!);
                } else {
                  global.showToast(message: tr("Please enter a valid amount"));
                }
              } else {
                if (double.parse(walletController.cWithdrawAmount.text) <=
                    double.parse(
                        walletController.withdraw.walletAmount.toString())) {
                  walletController.addAmount();
                } else {
                  global.showToast(message: tr("Please enter a valid amount"));
                }
              }
              walletController.getAmountList();
              walletController.update();
            },
            child: const Text(MessageConstants.WITHDRAW,
                    style: TextStyle(color: Colors.white))
                .tr(),
          ),
        ),
      );
      walletController.update();
    } catch (e) {
      print('Exception :  Wallet_screen - withdrawAmount() :' + e.toString());
    }
  }
}
