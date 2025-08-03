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
