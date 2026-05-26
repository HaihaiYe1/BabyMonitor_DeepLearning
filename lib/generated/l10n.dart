// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Baby Monitor`
  String get baby_monitor {
    return Intl.message(
      'Baby Monitor',
      name: 'baby_monitor',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings_title {
    return Intl.message('Settings', name: 'settings_title', desc: '', args: []);
  }

  /// `Account Management`
  String get account_management {
    return Intl.message(
      'Account Management',
      name: 'account_management',
      desc: '',
      args: [],
    );
  }

  /// `Manage Account`
  String get manage_account {
    return Intl.message(
      'Manage Account',
      name: 'manage_account',
      desc: '',
      args: [],
    );
  }

  /// `Device Management`
  String get device_management {
    return Intl.message(
      'Device Management',
      name: 'device_management',
      desc: '',
      args: [],
    );
  }

  /// `Manage Devices`
  String get manage_devices {
    return Intl.message(
      'Manage Devices',
      name: 'manage_devices',
      desc: '',
      args: [],
    );
  }

  /// `Preferences`
  String get preferences {
    return Intl.message('Preferences', name: 'preferences', desc: '', args: []);
  }

  /// `Enable Notifications`
  String get enable_notifications {
    return Intl.message(
      'Enable Notifications',
      name: 'enable_notifications',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Appearance`
  String get appearance {
    return Intl.message('Appearance', name: 'appearance', desc: '', args: []);
  }

  /// `Dark Mode`
  String get dark_mode {
    return Intl.message('Dark Mode', name: 'dark_mode', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Chinese`
  String get chinese {
    return Intl.message('Chinese', name: 'chinese', desc: '', args: []);
  }

  /// `Support & Help`
  String get support_help {
    return Intl.message(
      'Support & Help',
      name: 'support_help',
      desc: '',
      args: [],
    );
  }

  /// `Customer Support`
  String get customer_support {
    return Intl.message(
      'Customer Support',
      name: 'customer_support',
      desc: '',
      args: [],
    );
  }

  /// `Frequently Asked Questions`
  String get faq {
    return Intl.message(
      'Frequently Asked Questions',
      name: 'faq',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `App Version`
  String get app_version {
    return Intl.message('App Version', name: 'app_version', desc: '', args: []);
  }

  /// `Monitor`
  String get monitor {
    return Intl.message('Monitor', name: 'monitor', desc: '', args: []);
  }

  /// `History`
  String get history {
    return Intl.message('History', name: 'history', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Alerts`
  String get alerts {
    return Intl.message('Alerts', name: 'alerts', desc: '', args: []);
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Live View`
  String get live_view {
    return Intl.message('Live View', name: 'live_view', desc: '', args: []);
  }

  /// `Statistics`
  String get statistics {
    return Intl.message('Statistics', name: 'statistics', desc: '', args: []);
  }

  /// `Arrange`
  String get arrange {
    return Intl.message('Arrange', name: 'arrange', desc: '', args: []);
  }

  /// `Milestones`
  String get milestones {
    return Intl.message('Milestones', name: 'milestones', desc: '', args: []);
  }

  /// `Guide`
  String get guide {
    return Intl.message('Guide', name: 'guide', desc: '', args: []);
  }

  /// `Sleep`
  String get sleep {
    return Intl.message('Sleep', name: 'sleep', desc: '', args: []);
  }

  /// `Welcome Back`
  String get welcome_back {
    return Intl.message(
      'Welcome Back',
      name: 'welcome_back',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Log In`
  String get log_in {
    return Intl.message('Log In', name: 'log_in', desc: '', args: []);
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `Email and password cannot be empty`
  String get error_empty_fields {
    return Intl.message(
      'Email and password cannot be empty',
      name: 'error_empty_fields',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email or password`
  String get error_invalid_credentials {
    return Intl.message(
      'Invalid email or password',
      name: 'error_invalid_credentials',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get create_account {
    return Intl.message(
      'Create Account',
      name: 'create_account',
      desc: '',
      args: [],
    );
  }

  /// `Username (default: User123)`
  String get username_hint {
    return Intl.message(
      'Username (default: User123)',
      name: 'username_hint',
      desc: '',
      args: [],
    );
  }

  /// `Registering...`
  String get registering {
    return Intl.message(
      'Registering...',
      name: 'registering',
      desc: '',
      args: [],
    );
  }

  /// `Registration failed`
  String get error_registration_failed {
    return Intl.message(
      'Registration failed',
      name: 'error_registration_failed',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account? Log In`
  String get already_have_account {
    return Intl.message(
      'Already have an account? Log In',
      name: 'already_have_account',
      desc: '',
      args: [],
    );
  }

  /// `Notification Deleted`
  String get notification_deleted {
    return Intl.message(
      'Notification Deleted',
      name: 'notification_deleted',
      desc: '',
      args: [],
    );
  }

  /// `Simulate Notification`
  String get simulate_notification {
    return Intl.message(
      'Simulate Notification',
      name: 'simulate_notification',
      desc: '',
      args: [],
    );
  }

  /// `Trash`
  String get trash {
    return Intl.message('Trash', name: 'trash', desc: '', args: []);
  }

  /// `Change Avatar`
  String get change_avatar {
    return Intl.message(
      'Change Avatar',
      name: 'change_avatar',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Change Password`
  String get change_password {
    return Intl.message(
      'Change Password',
      name: 'change_password',
      desc: '',
      args: [],
    );
  }

  /// `Change Username`
  String get change_username {
    return Intl.message(
      'Change Username',
      name: 'change_username',
      desc: '',
      args: [],
    );
  }

  /// `Enter new username`
  String get enter_new_username {
    return Intl.message(
      'Enter new username',
      name: 'enter_new_username',
      desc: '',
      args: [],
    );
  }

  /// `Username updated successfully`
  String get username_updated_successfully {
    return Intl.message(
      'Username updated successfully',
      name: 'username_updated_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update username`
  String get failed_update_username {
    return Intl.message(
      'Failed to update username',
      name: 'failed_update_username',
      desc: '',
      args: [],
    );
  }

  /// `Enter old password`
  String get enter_old_password {
    return Intl.message(
      'Enter old password',
      name: 'enter_old_password',
      desc: '',
      args: [],
    );
  }

  /// `Enter new password`
  String get enter_new_password {
    return Intl.message(
      'Enter new password',
      name: 'enter_new_password',
      desc: '',
      args: [],
    );
  }

  /// `Password changed successfully`
  String get password_changed_successfully {
    return Intl.message(
      'Password changed successfully',
      name: 'password_changed_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update password`
  String get failed_update_password {
    return Intl.message(
      'Failed to update password',
      name: 'failed_update_password',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Log Out`
  String get logout {
    return Intl.message('Log Out', name: 'logout', desc: '', args: []);
  }

  /// `Bind Device`
  String get bind_device {
    return Intl.message('Bind Device', name: 'bind_device', desc: '', args: []);
  }

  /// `Edit Device`
  String get edit_device {
    return Intl.message('Edit Device', name: 'edit_device', desc: '', args: []);
  }

  /// `Device Name`
  String get device_name {
    return Intl.message('Device Name', name: 'device_name', desc: '', args: []);
  }

  /// `Device IP Address`
  String get device_ip {
    return Intl.message(
      'Device IP Address',
      name: 'device_ip',
      desc: '',
      args: [],
    );
  }

  /// `Device Status`
  String get device_status {
    return Intl.message(
      'Device Status',
      name: 'device_status',
      desc: '',
      args: [],
    );
  }

  /// `RTSP Address`
  String get rtsp_address {
    return Intl.message(
      'RTSP Address',
      name: 'rtsp_address',
      desc: '',
      args: [],
    );
  }

  /// `Bind Email`
  String get bind_email {
    return Intl.message('Bind Email', name: 'bind_email', desc: '', args: []);
  }

  /// `Not Set`
  String get not_set {
    return Intl.message('Not Set', name: 'not_set', desc: '', args: []);
  }

  /// `Test RTSP Connection`
  String get test_rtsp_connection {
    return Intl.message(
      'Test RTSP Connection',
      name: 'test_rtsp_connection',
      desc: '',
      args: [],
    );
  }

  /// `Connection Successful`
  String get connection_success {
    return Intl.message(
      'Connection Successful',
      name: 'connection_success',
      desc: '',
      args: [],
    );
  }

  /// `Connection Failed`
  String get connection_failed {
    return Intl.message(
      'Connection Failed',
      name: 'connection_failed',
      desc: '',
      args: [],
    );
  }

  /// `RTSP connection successful!`
  String get rtsp_connection_success {
    return Intl.message(
      'RTSP connection successful!',
      name: 'rtsp_connection_success',
      desc: '',
      args: [],
    );
  }

  /// `RTSP connection failed, please check the network or address.`
  String get rtsp_connection_failed {
    return Intl.message(
      'RTSP connection failed, please check the network or address.',
      name: 'rtsp_connection_failed',
      desc: '',
      args: [],
    );
  }

  /// `Update Device`
  String get update_device {
    return Intl.message(
      'Update Device',
      name: 'update_device',
      desc: '',
      args: [],
    );
  }

  /// `Enter Device Name`
  String get input_device_name {
    return Intl.message(
      'Enter Device Name',
      name: 'input_device_name',
      desc: '',
      args: [],
    );
  }

  /// `Enter Device IP Address`
  String get input_device_ip {
    return Intl.message(
      'Enter Device IP Address',
      name: 'input_device_ip',
      desc: '',
      args: [],
    );
  }

  /// `Enter Device Status`
  String get input_device_status {
    return Intl.message(
      'Enter Device Status',
      name: 'input_device_status',
      desc: '',
      args: [],
    );
  }

  /// `Enter RTSP Address`
  String get input_rtsp_address {
    return Intl.message(
      'Enter RTSP Address',
      name: 'input_rtsp_address',
      desc: '',
      args: [],
    );
  }

  /// `Enter Bind Email`
  String get input_bind_email {
    return Intl.message(
      'Enter Bind Email',
      name: 'input_bind_email',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Please enter {title}`
  String enter_text(Object title) {
    return Intl.message(
      'Please enter $title',
      name: 'enter_text',
      desc: '',
      args: [title],
    );
  }

  /// `Loading Devices...`
  String get loading_devices {
    return Intl.message(
      'Loading Devices...',
      name: 'loading_devices',
      desc: '',
      args: [],
    );
  }

  /// `Add Device`
  String get add_device {
    return Intl.message('Add Device', name: 'add_device', desc: '', args: []);
  }

  /// `Customer Support & Help`
  String get support_page_title {
    return Intl.message(
      'Customer Support & Help',
      name: 'support_page_title',
      desc: '',
      args: [],
    );
  }

  /// `Frequently Asked Questions`
  String get faq_tab_title {
    return Intl.message(
      'Frequently Asked Questions',
      name: 'faq_tab_title',
      desc: '',
      args: [],
    );
  }

  /// `Contact Customer Support`
  String get contact_tab_title {
    return Intl.message(
      'Contact Customer Support',
      name: 'contact_tab_title',
      desc: '',
      args: [],
    );
  }

  /// `How to bind the camera?`
  String get faq_question_1 {
    return Intl.message(
      'How to bind the camera?',
      name: 'faq_question_1',
      desc: '',
      args: [],
    );
  }

  /// `You can bind the camera by entering the RTSP address in the bind device section under settings.`
  String get faq_answer_1 {
    return Intl.message(
      'You can bind the camera by entering the RTSP address in the bind device section under settings.',
      name: 'faq_answer_1',
      desc: '',
      args: [],
    );
  }

  /// `What to do if the device cannot connect?`
  String get faq_question_2 {
    return Intl.message(
      'What to do if the device cannot connect?',
      name: 'faq_question_2',
      desc: '',
      args: [],
    );
  }

  /// `Please ensure the device is connected to the network, or restart the device and check the device status.`
  String get faq_answer_2 {
    return Intl.message(
      'Please ensure the device is connected to the network, or restart the device and check the device status.',
      name: 'faq_answer_2',
      desc: '',
      args: [],
    );
  }

  /// `How to fix video stuttering?`
  String get faq_question_3 {
    return Intl.message(
      'How to fix video stuttering?',
      name: 'faq_question_3',
      desc: '',
      args: [],
    );
  }

  /// `You can check the network bandwidth or try restarting the camera and router.`
  String get faq_answer_3 {
    return Intl.message(
      'You can check the network bandwidth or try restarting the camera and router.',
      name: 'faq_answer_3',
      desc: '',
      args: [],
    );
  }

  /// `Phone Support`
  String get contact_phone_title {
    return Intl.message(
      'Phone Support',
      name: 'contact_phone_title',
      desc: '',
      args: [],
    );
  }

  /// `Call customer support for real-time assistance.`
  String get contact_phone_description {
    return Intl.message(
      'Call customer support for real-time assistance.',
      name: 'contact_phone_description',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get contact_email_title {
    return Intl.message(
      'Email',
      name: 'contact_email_title',
      desc: '',
      args: [],
    );
  }

  /// `Send an email and customer support will reply as soon as possible.`
  String get contact_email_description {
    return Intl.message(
      'Send an email and customer support will reply as soon as possible.',
      name: 'contact_email_description',
      desc: '',
      args: [],
    );
  }

  /// `Online Chat`
  String get contact_chat_title {
    return Intl.message(
      'Online Chat',
      name: 'contact_chat_title',
      desc: '',
      args: [],
    );
  }

  /// `Communicate with customer support via online chat.`
  String get contact_chat_description {
    return Intl.message(
      'Communicate with customer support via online chat.',
      name: 'contact_chat_description',
      desc: '',
      args: [],
    );
  }

  /// `Sleep White Noise`
  String get sleepWhiteNoise {
    return Intl.message(
      'Sleep White Noise',
      name: 'sleepWhiteNoise',
      desc: '',
      args: [],
    );
  }

  /// `Suitable for 0-6 months`
  String get suitableFor0To6Months {
    return Intl.message(
      'Suitable for 0-6 months',
      name: 'suitableFor0To6Months',
      desc: '',
      args: [],
    );
  }

  /// `Suitable for 6-18 months`
  String get suitableFor6To18Months {
    return Intl.message(
      'Suitable for 6-18 months',
      name: 'suitableFor6To18Months',
      desc: '',
      args: [],
    );
  }

  /// `Above 18 months`
  String get above18Months {
    return Intl.message(
      'Above 18 months',
      name: 'above18Months',
      desc: '',
      args: [],
    );
  }

  /// `Fetal Environment`
  String get soundFetal {
    return Intl.message(
      'Fetal Environment',
      name: 'soundFetal',
      desc: '',
      args: [],
    );
  }

  /// `Shhh`
  String get soundShhh {
    return Intl.message('Shhh', name: 'soundShhh', desc: '', args: []);
  }

  /// `Vacuum Cleaner`
  String get soundVacuum {
    return Intl.message(
      'Vacuum Cleaner',
      name: 'soundVacuum',
      desc: '',
      args: [],
    );
  }

  /// `Car Sound`
  String get soundCar {
    return Intl.message('Car Sound', name: 'soundCar', desc: '', args: []);
  }

  /// `Fan`
  String get soundFan {
    return Intl.message('Fan', name: 'soundFan', desc: '', args: []);
  }

  /// `Stream`
  String get soundStream {
    return Intl.message('Stream', name: 'soundStream', desc: '', args: []);
  }

  /// `Rain`
  String get soundRain {
    return Intl.message('Rain', name: 'soundRain', desc: '', args: []);
  }

  /// `Market`
  String get soundMarket {
    return Intl.message('Market', name: 'soundMarket', desc: '', args: []);
  }

  /// `Ocean`
  String get soundOcean {
    return Intl.message('Ocean', name: 'soundOcean', desc: '', args: []);
  }

  /// `Pond`
  String get soundPond {
    return Intl.message('Pond', name: 'soundPond', desc: '', args: []);
  }

  /// `Beach`
  String get soundBeach {
    return Intl.message('Beach', name: 'soundBeach', desc: '', args: []);
  }

  /// `Ocean Waves`
  String get soundOceanWaves {
    return Intl.message(
      'Ocean Waves',
      name: 'soundOceanWaves',
      desc: '',
      args: [],
    );
  }

  /// `Mother's Heartbeat`
  String get soundHeartbeat {
    return Intl.message(
      'Mother\'s Heartbeat',
      name: 'soundHeartbeat',
      desc: '',
      args: [],
    );
  }

  /// `Lullaby`
  String get soundLullaby {
    return Intl.message('Lullaby', name: 'soundLullaby', desc: '', args: []);
  }

  /// `Bird Chirping`
  String get soundBird {
    return Intl.message('Bird Chirping', name: 'soundBird', desc: '', args: []);
  }

  /// `Cat Meowing`
  String get soundCat {
    return Intl.message('Cat Meowing', name: 'soundCat', desc: '', args: []);
  }

  /// `Data Analysis`
  String get titleDataAnalysis {
    return Intl.message(
      'Data Analysis',
      name: 'titleDataAnalysis',
      desc: '',
      args: [],
    );
  }

  /// `📊 Hourly Alert Distribution`
  String get labelHourlyAlert {
    return Intl.message(
      '📊 Hourly Alert Distribution',
      name: 'labelHourlyAlert',
      desc: '',
      args: [],
    );
  }

  /// `📈 Danger Trend Over Time`
  String get labelDangerTrend {
    return Intl.message(
      '📈 Danger Trend Over Time',
      name: 'labelDangerTrend',
      desc: '',
      args: [],
    );
  }

  /// `Danger`
  String get levelDanger {
    return Intl.message('Danger', name: 'levelDanger', desc: '', args: []);
  }

  /// `Warning`
  String get levelWarning {
    return Intl.message('Warning', name: 'levelWarning', desc: '', args: []);
  }

  /// `Safe`
  String get levelSafe {
    return Intl.message('Safe', name: 'levelSafe', desc: '', args: []);
  }

  /// `Failed to load notifications`
  String get errorLoadNotification {
    return Intl.message(
      'Failed to load notifications',
      name: 'errorLoadNotification',
      desc: '',
      args: [],
    );
  }

  /// `Failed to fetch notifications`
  String get errorFetchNotification {
    return Intl.message(
      'Failed to fetch notifications',
      name: 'errorFetchNotification',
      desc: '',
      args: [],
    );
  }

  /// `Development Milestones`
  String get pageTitle {
    return Intl.message(
      'Development Milestones',
      name: 'pageTitle',
      desc: '',
      args: [],
    );
  }

  /// `🍼 Baby Growth Records`
  String get growthTitle {
    return Intl.message(
      '🍼 Baby Growth Records',
      name: 'growthTitle',
      desc: '',
      args: [],
    );
  }

  /// `Month`
  String get monthLabel {
    return Intl.message('Month', name: 'monthLabel', desc: '', args: []);
  }

  /// `Weight (kg)`
  String get weightLabel {
    return Intl.message('Weight (kg)', name: 'weightLabel', desc: '', args: []);
  }

  /// `Height (cm)`
  String get heightLabel {
    return Intl.message('Height (cm)', name: 'heightLabel', desc: '', args: []);
  }

  /// `Head Circumference (cm)`
  String get headCircLabel {
    return Intl.message(
      'Head Circumference (cm)',
      name: 'headCircLabel',
      desc: '',
      args: [],
    );
  }

  /// `Required`
  String get requiredField {
    return Intl.message('Required', name: 'requiredField', desc: '', args: []);
  }

  /// `Add Record`
  String get addRecord {
    return Intl.message('Add Record', name: 'addRecord', desc: '', args: []);
  }

  /// `📈 Weight Trend`
  String get weightTrend {
    return Intl.message(
      '📈 Weight Trend',
      name: 'weightTrend',
      desc: '',
      args: [],
    );
  }

  /// `📏 Height Trend`
  String get heightTrend {
    return Intl.message(
      '📏 Height Trend',
      name: 'heightTrend',
      desc: '',
      args: [],
    );
  }

  /// `🎯 Milestone Tips`
  String get milestoneTitle {
    return Intl.message(
      '🎯 Milestone Tips',
      name: 'milestoneTitle',
      desc: '',
      args: [],
    );
  }

  /// `{month} month baby suggestion:`
  String milestonePrefix(Object month) {
    return Intl.message(
      '$month month baby suggestion:',
      name: 'milestonePrefix',
      desc: '',
      args: [month],
    );
  }

  /// `👶 1 month: Baby starts to look at your face and respond to sounds.`
  String get tip1 {
    return Intl.message(
      '👶 1 month: Baby starts to look at your face and respond to sounds.',
      name: 'tip1',
      desc: '',
      args: [],
    );
  }

  /// `✅ 2 months: Baby can lift their head and likes bright light or sounds.`
  String get tip2 {
    return Intl.message(
      '✅ 2 months: Baby can lift their head and likes bright light or sounds.',
      name: 'tip2',
      desc: '',
      args: [],
    );
  }

  /// `✅ 3 months: Baby begins hand coordination and can grasp objects.`
  String get tip3 {
    return Intl.message(
      '✅ 3 months: Baby begins hand coordination and can grasp objects.',
      name: 'tip3',
      desc: '',
      args: [],
    );
  }

  /// `✅ 4 months: Baby starts to roll over, with better hand-foot coordination.`
  String get tip4 {
    return Intl.message(
      '✅ 4 months: Baby starts to roll over, with better hand-foot coordination.',
      name: 'tip4',
      desc: '',
      args: [],
    );
  }

  /// `✅ 5 months: Baby can sit steadily, supporting themselves with hands.`
  String get tip5 {
    return Intl.message(
      '✅ 5 months: Baby can sit steadily, supporting themselves with hands.',
      name: 'tip5',
      desc: '',
      args: [],
    );
  }

  /// `✅ 6 months: Baby learns to grab and play with things.`
  String get tip6 {
    return Intl.message(
      '✅ 6 months: Baby learns to grab and play with things.',
      name: 'tip6',
      desc: '',
      args: [],
    );
  }

  /// `✅ 7 months: Baby may start crawling and explore more.`
  String get tip7 {
    return Intl.message(
      '✅ 7 months: Baby may start crawling and explore more.',
      name: 'tip7',
      desc: '',
      args: [],
    );
  }

  /// `✅ 8 months: Baby tries to stand and walk holding furniture.`
  String get tip8 {
    return Intl.message(
      '✅ 8 months: Baby tries to stand and walk holding furniture.',
      name: 'tip8',
      desc: '',
      args: [],
    );
  }

  /// `✅ 9 months: Baby likely crawls and can stand briefly.`
  String get tip9 {
    return Intl.message(
      '✅ 9 months: Baby likely crawls and can stand briefly.',
      name: 'tip9',
      desc: '',
      args: [],
    );
  }

  /// `✅ 10 months: Baby imitates sounds and simple actions.`
  String get tip10 {
    return Intl.message(
      '✅ 10 months: Baby imitates sounds and simple actions.',
      name: 'tip10',
      desc: '',
      args: [],
    );
  }

  /// `✅ 11 months: Baby stands stably and tries a few steps.`
  String get tip11 {
    return Intl.message(
      '✅ 11 months: Baby stands stably and tries a few steps.',
      name: 'tip11',
      desc: '',
      args: [],
    );
  }

  /// `✅ 12 months: Baby may say 'mama' or 'dada' and walk a bit.`
  String get tip12 {
    return Intl.message(
      '✅ 12 months: Baby may say \'mama\' or \'dada\' and walk a bit.',
      name: 'tip12',
      desc: '',
      args: [],
    );
  }

  /// `✅ 15 months: Baby can walk independently and understand simple commands.`
  String get tip15 {
    return Intl.message(
      '✅ 15 months: Baby can walk independently and understand simple commands.',
      name: 'tip15',
      desc: '',
      args: [],
    );
  }

  /// `✅ 18 months: Baby expresses needs clearly with steady steps.`
  String get tip18 {
    return Intl.message(
      '✅ 18 months: Baby expresses needs clearly with steady steps.',
      name: 'tip18',
      desc: '',
      args: [],
    );
  }

  /// `✅ 24 months: Baby can express emotions and thoughts with improved language.`
  String get tip24 {
    return Intl.message(
      '✅ 24 months: Baby can express emotions and thoughts with improved language.',
      name: 'tip24',
      desc: '',
      args: [],
    );
  }

  /// `AI Agent Chat`
  String get agent_chat {
    return Intl.message('AI Agent Chat', name: 'agent_chat', desc: '', args: []);
  }

  /// `Parenting Advice`
  String get parenting_advice {
    return Intl.message('Parenting Advice', name: 'parenting_advice', desc: '', args: []);
  }

  /// `Smart Home Control`
  String get smart_home {
    return Intl.message('Smart Home Control', name: 'smart_home', desc: '', args: []);
  }

  /// `Monitoring Dashboard`
  String get monitoring_dashboard {
    return Intl.message('Monitoring Dashboard', name: 'monitoring_dashboard', desc: '', args: []);
  }

  /// `Refresh Status`
  String get refresh_status {
    return Intl.message('Refresh Status', name: 'refresh_status', desc: '', args: []);
  }

  /// `Initialize Agent`
  String get initialize_agent {
    return Intl.message('Initialize Agent', name: 'initialize_agent', desc: '', args: []);
  }

  /// `Send Message`
  String get send_message {
    return Intl.message('Send Message', name: 'send_message', desc: '', args: []);
  }

  /// `Enter message...`
  String get input_message {
    return Intl.message('Enter message...', name: 'input_message', desc: '', args: []);
  }

  /// `Agent Status`
  String get agent_status {
    return Intl.message('Agent Status', name: 'agent_status', desc: '', args: []);
  }

  /// `Ready`
  String get agent_ready {
    return Intl.message('Ready', name: 'agent_ready', desc: '', args: []);
  }

  /// `Not Initialized`
  String get agent_not_initialized {
    return Intl.message('Not Initialized', name: 'agent_not_initialized', desc: '', args: []);
  }

  /// `Initializing...`
  String get agent_initializing {
    return Intl.message('Initializing...', name: 'agent_initializing', desc: '', args: []);
  }

  /// `Chat with AI Agent`
  String get chat_with_agent {
    return Intl.message('Chat with AI Agent', name: 'chat_with_agent', desc: '', args: []);
  }

  /// `Ask parenting questions or request help`
  String get ask_parenting_question {
    return Intl.message('Ask parenting questions or request help', name: 'ask_parenting_question', desc: '', args: []);
  }

  /// `Situation Description`
  String get situation_description {
    return Intl.message('Situation Description', name: 'situation_description', desc: '', args: []);
  }

  /// `Baby Age (months, optional)`
  String get baby_age_months {
    return Intl.message('Baby Age (months, optional)', name: 'baby_age_months', desc: '', args: []);
  }

  /// `Not Specified`
  String get not_specified {
    return Intl.message('Not Specified', name: 'not_specified', desc: '', args: []);
  }

  /// `Get Advice`
  String get get_advice {
    return Intl.message('Get Advice', name: 'get_advice', desc: '', args: []);
  }

  /// `Search Knowledge Base`
  String get search_knowledge {
    return Intl.message('Search Knowledge Base', name: 'search_knowledge', desc: '', args: []);
  }

  /// `Search Content`
  String get search_content {
    return Intl.message('Search Content', name: 'search_content', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Parenting Advice`
  String get advice_result {
    return Intl.message('Parenting Advice', name: 'advice_result', desc: '', args: []);
  }

  /// `Reference Knowledge`
  String get reference_knowledge {
    return Intl.message('Reference Knowledge', name: 'reference_knowledge', desc: '', args: []);
  }

  /// `Search Results`
  String get search_results {
    return Intl.message('Search Results', name: 'search_results', desc: '', args: []);
  }

  /// `No advice yet`
  String get no_advice {
    return Intl.message('No advice yet', name: 'no_advice', desc: '', args: []);
  }

  /// `Please enter situation description`
  String get please_enter_situation {
    return Intl.message('Please enter situation description', name: 'please_enter_situation', desc: '', args: []);
  }

  /// `Please enter search content`
  String get please_enter_search {
    return Intl.message('Please enter search content', name: 'please_enter_search', desc: '', args: []);
  }

  /// `Quick Actions`
  String get quick_actions {
    return Intl.message('Quick Actions', name: 'quick_actions', desc: '', args: []);
  }

  /// `Sleep Mode`
  String get sleep_mode {
    return Intl.message('Sleep Mode', name: 'sleep_mode', desc: '', args: []);
  }

  /// `Comfort Mode`
  String get comfort_mode {
    return Intl.message('Comfort Mode', name: 'comfort_mode', desc: '', args: []);
  }

  /// `Alert Mode`
  String get alert_mode {
    return Intl.message('Alert Mode', name: 'alert_mode', desc: '', args: []);
  }

  /// `Scene Modes`
  String get scene_modes {
    return Intl.message('Scene Modes', name: 'scene_modes', desc: '', args: []);
  }

  /// `Smart Speaker`
  String get smart_speaker {
    return Intl.message('Smart Speaker', name: 'smart_speaker', desc: '', args: []);
  }

  /// `Play Content`
  String get play_content {
    return Intl.message('Play Content', name: 'play_content', desc: '', args: []);
  }

  /// `Play`
  String get play {
    return Intl.message('Play', name: 'play', desc: '', args: []);
  }

  /// `Stop`
  String get stop {
    return Intl.message('Stop', name: 'stop', desc: '', args: []);
  }

  /// `Smart Light`
  String get smart_light {
    return Intl.message('Smart Light', name: 'smart_light', desc: '', args: []);
  }

  /// `Light Color`
  String get light_color {
    return Intl.message('Light Color', name: 'light_color', desc: '', args: []);
  }

  /// `Light Mode`
  String get light_mode {
    return Intl.message('Light Mode', name: 'light_mode', desc: '', args: []);
  }

  /// `Turn On`
  String get turn_on {
    return Intl.message('Turn On', name: 'turn_on', desc: '', args: []);
  }

  /// `Turn Off`
  String get turn_off {
    return Intl.message('Turn Off', name: 'turn_off', desc: '', args: []);
  }

  /// `Apply`
  String get apply {
    return Intl.message('Apply', name: 'apply', desc: '', args: []);
  }

  /// `System Status`
  String get system_status {
    return Intl.message('System Status', name: 'system_status', desc: '', args: []);
  }

  /// `MQTT Connection`
  String get mqtt_connection {
    return Intl.message('MQTT Connection', name: 'mqtt_connection', desc: '', args: []);
  }

  /// `Connected`
  String get connected {
    return Intl.message('Connected', name: 'connected', desc: '', args: []);
  }

  /// `Disconnected`
  String get disconnected {
    return Intl.message('Disconnected', name: 'disconnected', desc: '', args: []);
  }

  /// `Speaker Tool`
  String get speaker_tool {
    return Intl.message('Speaker Tool', name: 'speaker_tool', desc: '', args: []);
  }

  /// `Light Tool`
  String get light_tool {
    return Intl.message('Light Tool', name: 'light_tool', desc: '', args: []);
  }

  /// `Scene Tool`
  String get scene_tool {
    return Intl.message('Scene Tool', name: 'scene_tool', desc: '', args: []);
  }

  /// `Brightness`
  String get brightness {
    return Intl.message('Brightness', name: 'brightness', desc: '', args: []);
  }

  /// `Volume`
  String get volume {
    return Intl.message('Volume', name: 'volume', desc: '', args: []);
  }

  /// `Active Connections`
  String get active_connections {
    return Intl.message('Active Connections', name: 'active_connections', desc: '', args: []);
  }

  /// `Messages Sent`
  String get messages_sent {
    return Intl.message('Messages Sent', name: 'messages_sent', desc: '', args: []);
  }

  /// `Messages Received`
  String get messages_received {
    return Intl.message('Messages Received', name: 'messages_received', desc: '', args: []);
  }

  /// `Audio Devices`
  String get audio_devices {
    return Intl.message('Audio Devices', name: 'audio_devices', desc: '', args: []);
  }

  /// `Message Traffic`
  String get message_traffic {
    return Intl.message('Message Traffic', name: 'message_traffic', desc: '', args: []);
  }

  /// `Connection Count`
  String get connection_count {
    return Intl.message('Connection Count', name: 'connection_count', desc: '', args: []);
  }

  /// `Latency`
  String get latency {
    return Intl.message('Latency', name: 'latency', desc: '', args: []);
  }

  /// `No Data`
  String get no_data {
    return Intl.message('No Data', name: 'no_data', desc: '', args: []);
  }

  /// `No Active Connections`
  String get no_active_connections {
    return Intl.message('No Active Connections', name: 'no_active_connections', desc: '', args: []);
  }

  /// `Audio Statistics`
  String get audio_statistics {
    return Intl.message('Audio Statistics', name: 'audio_statistics', desc: '', args: []);
  }

  /// `Active Devices`
  String get active_device_count {
    return Intl.message('Active Devices', name: 'active_device_count', desc: '', args: []);
  }

  /// `Streaming Devices`
  String get streaming_device_count {
    return Intl.message('Streaming Devices', name: 'streaming_device_count', desc: '', args: []);
  }

  /// `Buffer Status`
  String get buffer_status {
    return Intl.message('Buffer Status', name: 'buffer_status', desc: '', args: []);
  }

  /// `Refresh Data`
  String get refresh_data {
    return Intl.message('Refresh Data', name: 'refresh_data', desc: '', args: []);
  }

  /// `Video Stream`
  String get video_stream {
    return Intl.message('Video Stream', name: 'video_stream', desc: '', args: []);
  }

  /// `Audio Stream`
  String get audio_stream {
    return Intl.message('Audio Stream', name: 'audio_stream', desc: '', args: []);
  }

  /// `Two-way Intercom`
  String get intercom {
    return Intl.message('Two-way Intercom', name: 'intercom', desc: '', args: []);
  }

  /// `Reconnect`
  String get reconnect {
    return Intl.message('Reconnect', name: 'reconnect', desc: '', args: []);
  }

  /// `In Call`
  String get in_call {
    return Intl.message('In Call', name: 'in_call', desc: '', args: []);
  }

  /// `Speaker`
  String get speaker {
    return Intl.message('Speaker', name: 'speaker', desc: '', args: []);
  }

  /// `Listener`
  String get listener {
    return Intl.message('Listener', name: 'listener', desc: '', args: []);
  }

  /// `Hang Up`
  String get hang_up {
    return Intl.message('Hang Up', name: 'hang_up', desc: '', args: []);
  }

  /// `Start Intercom`
  String get start_intercom {
    return Intl.message('Start Intercom', name: 'start_intercom', desc: '', args: []);
  }

  /// `Mute`
  String get mute {
    return Intl.message('Mute', name: 'mute', desc: '', args: []);
  }

  /// `Unmute`
  String get unmute {
    return Intl.message('Unmute', name: 'unmute', desc: '', args: []);
  }

  /// `Connection Statistics`
  String get connection_statistics {
    return Intl.message('Connection Statistics', name: 'connection_statistics', desc: '', args: []);
  }

  /// `Video Connection`
  String get video_connection {
    return Intl.message('Video Connection', name: 'video_connection', desc: '', args: []);
  }

  /// `Audio Connection`
  String get audio_connection {
    return Intl.message('Audio Connection', name: 'audio_connection', desc: '', args: []);
  }

  /// `Intercom Connection`
  String get intercom_connection {
    return Intl.message('Intercom Connection', name: 'intercom_connection', desc: '', args: []);
  }

  /// `Frames Received`
  String get frames_received {
    return Intl.message('Frames Received', name: 'frames_received', desc: '', args: []);
  }

  /// `Audio Chunks Received`
  String get audio_chunks_received {
    return Intl.message('Audio Chunks Received', name: 'audio_chunks_received', desc: '', args: []);
  }

  /// `Normal`
  String get normal {
    return Intl.message('Normal', name: 'normal', desc: '', args: []);
  }

  /// `Disconnected`
  String get abnormal {
    return Intl.message('Disconnected', name: 'abnormal', desc: '', args: []);
  }

  /// `Detection Time Test`
  String get detection_time_test {
    return Intl.message('Detection Time Test', name: 'detection_time_test', desc: '', args: []);
  }

  /// `Notifications Enabled`
  String get notifications_enabled {
    return Intl.message('Notifications Enabled', name: 'notifications_enabled', desc: '', args: []);
  }

  /// `You will receive app notifications!`
  String get notifications_enabled_body {
    return Intl.message('You will receive app notifications!', name: 'notifications_enabled_body', desc: '', args: []);
  }

  /// `Select Device`
  String get select_device {
    return Intl.message('Select Device', name: 'select_device', desc: '', args: []);
  }

  /// `Enable Video Detection`
  String get enable_video_detection {
    return Intl.message('Enable Video Detection', name: 'enable_video_detection', desc: '', args: []);
  }

  /// `Prompt`
  String get prompt {
    return Intl.message('Prompt', name: 'prompt', desc: '', args: []);
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Operation Successful`
  String get operation_success {
    return Intl.message('Operation Successful', name: 'operation_success', desc: '', args: []);
  }

  /// `Operation Failed`
  String get operation_failed {
    return Intl.message('Operation Failed', name: 'operation_failed', desc: '', args: []);
  }

  /// `Unknown Operation`
  String get unknown_operation {
    return Intl.message('Unknown Operation', name: 'unknown_operation', desc: '', args: []);
  }

  /// `Camera address not found, please check device connection.`
  String get no_camera_address {
    return Intl.message('Camera address not found, please check device connection.', name: 'no_camera_address', desc: '', args: []);
  }

  /// `White Noise`
  String get whitenoise {
    return Intl.message('White Noise', name: 'whitenoise', desc: '', args: []);
  }

  /// `Lullaby`
  String get lullaby {
    return Intl.message('Lullaby', name: 'lullaby', desc: '', args: []);
  }

  /// `Ocean Waves`
  String get ocean {
    return Intl.message('Ocean Waves', name: 'ocean', desc: '', args: []);
  }

  /// `Rain`
  String get rain {
    return Intl.message('Rain', name: 'rain', desc: '', args: []);
  }

  /// `Heartbeat`
  String get heartbeat {
    return Intl.message('Heartbeat', name: 'heartbeat', desc: '', args: []);
  }

  /// `Bird Chirping`
  String get bird {
    return Intl.message('Bird Chirping', name: 'bird', desc: '', args: []);
  }

  /// `Warm Light`
  String get warm_light {
    return Intl.message('Warm Light', name: 'warm_light', desc: '', args: []);
  }

  /// `Cool Light`
  String get cool_light {
    return Intl.message('Cool Light', name: 'cool_light', desc: '', args: []);
  }

  /// `Night Light`
  String get night_light {
    return Intl.message('Night Light', name: 'night_light', desc: '', args: []);
  }

  /// `Soft Light`
  String get soft_light {
    return Intl.message('Soft Light', name: 'soft_light', desc: '', args: []);
  }

  /// `Normal Mode`
  String get normal_mode {
    return Intl.message('Normal Mode', name: 'normal_mode', desc: '', args: []);
  }

  /// `Night Mode`
  String get night_mode {
    return Intl.message('Night Mode', name: 'night_mode', desc: '', args: []);
  }

  /// `Reading Mode`
  String get reading_mode {
    return Intl.message('Reading Mode', name: 'reading_mode', desc: '', args: []);
  }

  /// `Sleep Mode`
  String get sleep_mode_light {
    return Intl.message('Sleep Mode', name: 'sleep_mode_light', desc: '', args: []);
  }

  /// `General`
  String get general {
    return Intl.message('General', name: 'general', desc: '', args: []);
  }

  /// `Feeding`
  String get feeding {
    return Intl.message('Feeding', name: 'feeding', desc: '', args: []);
  }

  /// `Safety`
  String get safety {
    return Intl.message('Safety', name: 'safety', desc: '', args: []);
  }

  /// `Health`
  String get health {
    return Intl.message('Health', name: 'health', desc: '', args: []);
  }

  /// `Development`
  String get development {
    return Intl.message('Development', name: 'development', desc: '', args: []);
  }

  /// `ms`
  String get ms_unit {
    return Intl.message('ms', name: 'ms_unit', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
