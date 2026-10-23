import 'package:flutter/widgets.dart';

class S {
  S(this.code);

  final String code;

  static S of(BuildContext context) =>
      S(Localizations.localeOf(context).languageCode);

  String _t(String th, String en) => code == 'en' ? en : th;

  // Common
  String get cancel => _t('ยกเลิก', 'Cancel');
  String get confirm => _t('ยืนยัน', 'Confirm');
  String get retry => _t('ลองอีกครั้ง', 'Try again');
  String get close => _t('ปิด', 'Close');

  // Status
  String get statusNotStarted => _t('ยังไม่เริ่ม', 'Not started');
  String get statusDoing => _t('กำลังทำ', 'In progress');
  String get statusDone => _t('เสร็จแล้ว', 'Done');
  String get statusOverdue => _t('เลยกำหนด', 'Overdue');
  String get statusInProgressLong => _t('กำลังดำเนินการ', 'In progress');
  String get all => _t('ทั้งหมด', 'All');

  // Navigation / titles
  String get navHome => _t('หน้าหลัก', 'Home');
  String get navTodo => _t('งาน', 'Todo');
  String get navCalendar => _t('ปฏิทิน', 'Calendar');
  String get navSettings => _t('ตั้งค่า', 'Settings');
  String get dashboard => _t('แดชบอร์ด', 'Dashboard');

  // Notification
  String get upcoming => _t('งานที่ใกล้ถึงกำหนด', 'Upcoming tasks');
  String notifBody(int n) => _t(
        'มีงานที่ยังไม่เสร็จและมีวันครบกำหนดตั้งแต่วันนี้ จำนวน $n งาน',
        'You have $n unfinished task(s) due today or later',
      );

  // Home
  String get dashboardSub =>
      _t('ภาพรวมงานทั้งหมดของคุณ', 'Overview of all your tasks');
  String get loadFailed =>
      _t('ไม่สามารถโหลดข้อมูล Todo ได้', 'Unable to load todos');
  String get totalTasks => _t('งานทั้งหมด', 'All tasks');
  String get progressTitle => _t('ความคืบหน้าของงาน', 'Progress');
  String get noTasks => _t('ยังไม่มีรายการงาน', 'No tasks yet');
  String doneOf(int c, int t) =>
      _t('เสร็จแล้ว $c จาก $t งาน', '$c of $t tasks done');
  String get noUpcoming =>
      _t('ไม่มีงานที่ใกล้ถึงกำหนด', 'No upcoming tasks');
  String dueOn(String d) => _t('กำหนดส่ง $d', 'Due $d');

  // Stats
  String get statistics => _t('สถิติ', 'Statistics');
  String get chartStatusTitle => _t('สัดส่วนตามสถานะ', 'By status');
  String get chartWeeklyTitle =>
      _t('งานที่เสร็จต่อสัปดาห์', 'Tasks done per week');
  String get noChartData => _t('ยังไม่มีข้อมูลสำหรับแสดงกราฟ', 'No data yet');

  // Calendar
  String get calendarSub =>
      _t('ปฏิทินกำหนดส่งงานของคุณ', 'Your task due dates');
  String get today => _t('วันนี้', 'Today');
  String tasksOn(String d) => _t('งานวันที่ $d', 'Tasks on $d');
  String get noTasksSelected =>
      _t('ไม่มีงานในวันที่เลือก', 'No tasks on this day');
  List<String> get weekdays => code == 'en'
      ? ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
      : ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส'];

  // Todo
  String get todoTitle => _t('รายการงาน', 'Todo list');
  String get noTodo => _t('ยังไม่มีงาน', 'No todos yet');
  String get search => _t('ค้นหางาน', 'Search tasks');
  String get sort => _t('เรียงลำดับ', 'Sort');
  String get sortDefault => _t('ค่าเริ่มต้น', 'Default');
  String get sortPriority => _t('Priority สูงไปต่ำ', 'Priority high to low');
  String get sortDue => _t('ใกล้ครบกำหนดก่อน', 'Due soonest first');
  String get noMatch => _t('ไม่พบงานที่ตรงกับเงื่อนไข', 'No matching tasks');
  String errorMsg(String m) => _t('เกิดข้อผิดพลาด: $m', 'Error: $m');
  String statusLabel(String st) => _t('สถานะ: $st', 'Status: $st');
  String get statusColon => _t('สถานะ:', 'Status:');
  String get noDueDate =>
      _t('ยังไม่ได้กำหนดวันครบกำหนด', 'No due date set');
  String get setDueDate => _t('กำหนดวันครบกำหนด', 'Set due date');
  String get pickDueDate => _t('เลือกวันครบกำหนด', 'Pick due date');
  String dueDateLabel(String d) => _t('ครบกำหนด $d', 'Due $d');
  String get changeStatus => _t('เปลี่ยนสถานะงาน', 'Change status');
  String get deleteTitle => _t('ยืนยันการลบ', 'Confirm delete');
  String get deleteConfirmBtn => _t('ยืนยันการลบ', 'Delete');
  String deleteConfirmMsg(String t) => _t(
        'ต้องการย้ายงาน "$t" ไปถังขยะหรือไม่?\nสามารถกู้คืนได้ภายหลัง',
        'Move task "$t" to trash?\nYou can restore it later.',
      );
  String get undo => _t('เลิกทำ', 'Undo');
  String get editTodo => _t('แก้ไข Todo', 'Edit todo');
  String get delete => _t('ลบ', 'Delete');

  // Priority
  String get priority => _t('ความสำคัญ', 'Priority');
  String get priorityHigh => _t('สูง', 'High');
  String get priorityMedium => _t('กลาง', 'Medium');
  String get priorityLow => _t('ต่ำ', 'Low');
  String get allPriorities => _t('ทุกระดับ', 'Any priority');

  // Swipe
  String completedMsg(String t) =>
      _t('ทำงาน "$t" เสร็จแล้ว', 'Completed "$t"');
  String reopenedMsg(String t) =>
      _t('เปิดงาน "$t" อีกครั้ง', 'Reopened "$t"');
  String movedToTrashMsg(String t) =>
      _t('ย้าย "$t" ไปถังขยะแล้ว', 'Moved "$t" to trash');

  // Trash
  String get trash => _t('ถังขยะ', 'Trash');
  String get trashSub => _t('กู้คืนงานที่ลบไว้', 'Restore deleted tasks');
  String get trashEmpty => _t('ถังขยะว่างเปล่า', 'Trash is empty');
  String trashHint(int d) => _t(
        'งานในถังขยะจะถูกลบถาวรหลัง $d วัน',
        'Items are deleted permanently after $d days',
      );
  String daysLeft(int n) => _t('เหลือ $n วัน', '$n day(s) left');
  String get restore => _t('กู้คืน', 'Restore');
  String get deleteForever => _t('ลบถาวร', 'Delete forever');
  String get emptyTrash => _t('ล้างถังขยะ', 'Empty trash');
  String emptyTrashConfirm(int n) => _t(
        'ลบงาน $n รายการออกถาวร? ย้อนกลับไม่ได้',
        'Permanently delete $n task(s)? This cannot be undone.',
      );
  String get deleteForeverConfirm =>
      _t('ลบงานนี้ถาวร? ย้อนกลับไม่ได้', 'Delete this task permanently?');

  // Edit dialog
  String get editName => _t('ชื่อ Todo', 'Todo name');
  String get editNameHint =>
      _t('กรอกชื่ออย่างน้อย 6 ตัวอักษร', 'Enter at least 6 characters');
  String get editContent => _t('รายละเอียด', 'Details');
  String get editContentHint => _t('กรอกรายละเอียดงาน', 'Enter task details');
  String dueDateColon(String d) => _t('วันครบกำหนด: $d', 'Due date: $d');
  String get noDateYet => _t('ยังไม่ได้กำหนดวัน', 'Not set');
  String get clearDueDate => _t('ล้างวันครบกำหนด', 'Clear due date');
  String get save => _t('บันทึก', 'Save');
  String get titleLengthError => _t(
        'ชื่อ Todo ต้องมีความยาว 6–32 ตัวอักษร',
        'Todo name must be 6–32 characters',
      );
  String get contentRequired =>
      _t('กรุณากรอกรายละเอียด Todo', 'Please enter the todo details');

  // Setting
  String get settingsSub =>
      _t('ตั้งค่าและเครื่องมือของแอป', 'App settings and tools');
  String get general => _t('ทั่วไป', 'General');
  String get tools => _t('เครื่องมือ', 'Tools');
  String get language => _t('ภาษา', 'Language');
  String get chooseLanguage => _t('เลือกภาษา', 'Choose language');
  String get checkIp => _t('ตรวจสอบ IP Address', 'Check IP address');
  String get checkIpSub => _t(
        'ดู IP ที่แอปใช้เชื่อมต่ออินเทอร์เน็ต',
        'View the IP the app uses to connect',
      );
  String get ipFailed => _t('ไม่สามารถตรวจสอบ IP ได้', 'Unable to check IP');
  String get theme => _t('ธีม', 'Theme');
  String get chooseTheme => _t('เลือกธีม', 'Choose theme');
  String get themeSystem => _t('ตามระบบ', 'System');
  String get themeLight => _t('สว่าง', 'Light');
  String get themeDark => _t('มืด', 'Dark');
}