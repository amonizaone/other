import 'package:upgrader/upgrader.dart';

class ThaiMessages extends UpgraderMessages {
  /// Override the message function to provide custom language localization.
  @override
  String? message(UpgraderMessage messageKey) {
    if (languageCode == 'th') {
      switch (messageKey) {
        // A new version of {{appName}} is available! Version {{currentAppStoreVersion}} is now available-you have {{currentInstalledVersion}}.
        case UpgraderMessage.body:
          return 'มี {{appName}} เวอร์ชันใหม่แล้ว! เวอร์ชัน {{currentAppStoreVersion}} พร้อมใช้งานแล้ว - คุณมี {{currentInstalledVersion}}';
        case UpgraderMessage.buttonTitleIgnore:
          return 'ละเว้น';
        case UpgraderMessage.buttonTitleLater:
          return 'ภายหลัง';
        case UpgraderMessage.buttonTitleUpdate:
          return 'อัปเดตตอนนี้';
        case UpgraderMessage.prompt:
          return 'คุณต้องการอัปเดตตอนนี้หรือไม่';
        case UpgraderMessage.releaseNotes:
          return 'บันทึกประจำรุ่น';
        case UpgraderMessage.title:
          return 'อัปเดตแอป?';
      }
    }
    // Messages that are not provided above can still use the default values.
    return super.message(messageKey);
  }
}
