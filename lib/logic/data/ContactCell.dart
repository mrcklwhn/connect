import 'package:connect/screens/checkup/authentication/AuthenticationPage.dart';
import 'package:connect/screens/data/Models.dart';
import 'package:date_format/date_format.dart';

import 'LocalData.dart';

class ContactCell {
  static getLastOnline(String lastOnline) {
    String currentDate =
    formatDate(DateTime.now().toLocal(), [dd, '.', mm, '.', yy]);
    var date = lastOnline.split(" ");

    if (lastOnline.startsWith(currentDate)) {
      return date[1].trim();
    } else {
      return date[0].trim();
    }
  }

  static void deleteUser(ContactUser user) async {
    List<ContactUser> users =
    ContactUser.decode(LocalData.getString("contact_list"));
    users.removeWhere((item) => item.id == user.id);

    final String encodedData = ContactUser.encode(users);

    LocalData.putString("contact_list", encodedData);
  }
}