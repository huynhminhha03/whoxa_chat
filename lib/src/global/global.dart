// ignore_for_file: must_be_immutable, constant_identifier_names, deprecated_member_use, avoid_print, use_key_in_widget_constructors, unused_local_variable, equal_keys_in_map

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

String baseUrl() {
  return 'http://62.72.36.245:3000/api/';
  //'https://meyaoo.theprimoapp.com/public/api/';
  //'http://192.168.0.11:8001/api/'
}

String socketBaseUrl() {
  return 'http://62.72.36.245:3000';
  // return 'http://62.72.36.245:3000';
  //'https://meyaoo.theprimoapp.com/public/api/';
  //'http://192.168.0.11:8001/api/'
}

String isOnline = 'Online';
bool isForward = false;
bool isStarred = false;

String agoraBaseUrl =
    "https://agora-token-service-production-4ef9.up.railway.app/";

/// Description: This file is used for declaring all global objects used in the Application.
///
/// @author Deval Joshi
///
List grpids = [];

class Person {
  //modal class for Person object
  String id, name, phone, dp;
  Person(
      {required this.id,
      required this.name,
      required this.phone,
      required this.dp});
}

String convertUTCTimeTo12HourFormat(String utcTimeString) {
  DateTime utcDate = DateTime.parse(utcTimeString);
  String formattedTime = DateFormat('h:mm a').format(utcDate.toLocal());
  return formattedTime;
}

bool isURL(String text) {
  // Simple check for HTTP or HTTPS URLs
  return text.startsWith('http://') || text.startsWith('https://');
}

List<Person> persons = [];

// List localcontname = [];

String appName = 'Chat App';
const Color backgroundblack = Color(0xFF414141);
const Color backgroundgrey = Color(0xFFf4f7f8);
const Color splashColor = Color(0xFF45bfec);
const Color appColorGreen = Color(0xFF1E3C72);
const Color appColorOrange = Color(0xffFFA97B);
const Color appColorBlack = Colors.black;
const Color appGreen = Color(0XFF1ea36d);
const Color appbarColor = Color(0XFFf5f1ec);
const Color iconColor = Color(0XFF9e7e5b);
const Color ratingBgColor = Color(0XFFffefe7);
const Color appColorWhite = Colors.white;
const Color appColorBlue = Color(0xFF00366D);
const Color appIconColor = Color(0xFF445E76);
const Color appColorYellow = Color(0XFFE7B12D);
const Color appOrange = Color(0xffF56A1F);
const Color chatownColor = Color(0xffFDC604);
Color chatStrokeColor = const Color.fromRGBO(255, 249, 226, 1);
const Color gradient1 = Color(0XffFF6056);
const Color gradient2 = Color(0XffFF934E);
const Color bg = Color(0xffFFFFFF);
const Color blackcolor = Color(0xff123456);
const Color IndigoColor = Color(0xFF1A237E);
const Color WhiteColor = Color(0xFFFFFFFF);
const Color chatColor = Color(0xff000000);
const Color bg1 = Color(0xffEEEEEE);
const Color appgrey = Color(0xffD9D9D9);
const Color appgrey2 = Color.fromARGB(255, 150, 150, 150);
const Color chatcolor2 = Color(0xFF393738);
Color chatLogoColor = const Color.fromRGBO(252, 198, 4, 1);
Color chatYColor = const Color.fromRGBO(252, 198, 4, 0.43);
Color yellow1Color = const Color.fromRGBO(255, 237, 171, 1);
Color yellow2Color = const Color.fromRGBO(252, 198, 4, 1);
Color grey1Color = const Color.fromRGBO(221, 221, 221, 1);
Color blurColor = const Color.fromRGBO(0, 0, 0, 0.56);
Color darkGreyColor = const Color.fromRGBO(58, 51, 51, 1);
Color linkColor = const Color.fromRGBO(2, 126, 181, 1);
Color blackColor = const Color.fromRGBO(158, 158, 158, 1);
Color black1Color = const Color.fromRGBO(27, 27, 27, 1);
List<String> likedPost = [];
List<String> likedComment = [];
var likedProduct = [];
var likedService = [];
// String chatid = " ";
String stripSecret = ' ';
String stripPublic = '';
String rozSecret = '';
String rozPublic = '';
String msgid = '';

class GlobalVariable {
  /// This global key is used in material app for navigation through firebase notifications.
  /// [navState] usage can be found in [notification_notifier.dart] file.
  static final GlobalKey<NavigatorState> navState = GlobalKey<NavigatorState>();
}

closekeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

List<String> addedBookmarks = [];
String googleKEY = "AIzaSyDGFi8AlKgBoR8LrLA--Y836vfH4zwfiRU";
String onchat = "0";
String serverKey =
    'AAAAqh1Nstg:APA91bFxv6IjIge1pGr_2qAP9SIqUIpxZ8_0aYS998ZeBfjVux-Mg07cHAMvabyCf3AUiLXNcsLDQ7_4YdYBfRf2bljzOGWZ-ID03EKb3RWNaZNlaOK9zX7kZcngMsex6BwIqlQL9lNH';

// Client client = Client();

closeKeyboard() {
  return SystemChannels.textInput.invokeMethod('TextInput.hide');
}

String readTimestamp(int timestamp) {
  var now = DateTime.now();
  var format = DateFormat('h:mma');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  var diff = now.difference(date);
  var time = '';

  if (diff.inSeconds <= 0 ||
      diff.inSeconds > 0 && diff.inMinutes == 0 ||
      diff.inMinutes > 0 && diff.inHours == 0 ||
      diff.inHours > 0 && diff.inDays == 0 && diff.inHours < 20) {
    time = format.format(date);
  } else if (diff.inHours >= 20 && diff.inDays < 7) {
    time = DateFormat('EEEE').format(date);
  } else {
    var format = DateFormat('dd/MM/yy');
    time = format.format(date);
  }

  return time;
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return text;
  }
  return text[0].toUpperCase() + text.substring(1);
}

dynamic safeQueries(BuildContext context) {
  return (MediaQuery.of(context).size.height >= 812.0 ||
      MediaQuery.of(context).size.height == 812.0 ||
      (MediaQuery.of(context).size.height >= 812.0 &&
          MediaQuery.of(context).size.height <= 896.0 &&
          Platform.isIOS));
}

// Future<Duration?> getVideoDuration(String filePath) async {
//   final result = await FFmpegKit.execute('-i $filePath -hide_banner');
//   final output = await result.getOutput();
//   final regex = RegExp(r'Duration: (\d+):(\d+):(\d+)\.(\d+)');
//   final match = regex.firstMatch(output!);
//   if (match != null) {
//     final hours = int.parse(match.group(1)!);
//     final minutes = int.parse(match.group(2)!);
//     final seconds = int.parse(match.group(3)!);
//     final milliseconds = int.parse(match.group(4)!);
//     return Duration(
//       hours: hours,
//       minutes: minutes,
//       seconds: seconds,
//       milliseconds: milliseconds,
//     );
//   }
//   return null;
// }

Widget load() {
  return Center(
    child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Container(
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: const Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(appColorOrange)),
              )),
        )),
  );
}

// CHECK CONNECTIVITY
// Future<bool> checkInternet(BuildContext context) async {
//   try {
//     var connectivityResult = await (Connectivity().checkConnectivity());
//     if (connectivityResult == ConnectivityResult.none) {
//       return false;
//     } else {
//       return true;
//     }
//   } catch (e) {
//     return false;
//   }
// }

//SHOW LOADER

Widget customLoader(BuildContext context) {
  return Center(
    child: Container(
        alignment: Alignment.center,
        height: 40,
        width: 40,
        decoration:
            const BoxDecoration(color: gradient1, shape: BoxShape.circle),
        child: const Padding(
          padding: EdgeInsets.all(7),
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: appColorWhite,
            ),
          ),
        )),
  );
}

checkForNull(var data) {
  if (data != null && data != '' && data.toString().isNotEmpty) {
    return data;
  } else {
    return null;
  }
}

Widget onScrrenLoader(BuildContext context) {
  return Container(
    color: Colors.black45,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Container(
              alignment: Alignment.center,
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(
                  color: appColorWhite,
                ),
              )),
        ),
      ],
    ),
  );
}

String? extractFilename(String url) {
  // Extract the full filename from the URL
  String fullFilename = url.split('/').last;

  // Use a regular expression to remove any leading characters before the actual filename
  RegExp regExp = RegExp(r'\d+\.\w+$');
  RegExpMatch? match = regExp.firstMatch(fullFilename);
  if (match != null) {
    return match.group(0);
  } else {
    return fullFilename; // Return full filename if regex match fails
  }
}

Widget getUrlWidget(String url) {
  if (url.endsWith('.mp4')) {
    // If URL ends with '.mp4', fetch its thumbnail
    return FutureBuilder<Uint8List?>(
      future: getThumbnail(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        } else {
          return Container(
            color: Colors.white,
            child: const Icon(
              Icons.image,
              size: 100,
            ),
          ); // Placeholder or loading indicator can be used here
        }
      },
    );
  } else {
    // Otherwise, it's an image URL, return Image.network
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
    );
  }
}

Future<Uint8List?> getThumbnail(String videoUrl) async {
  final thumbnail = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.PNG,
      quality: 100,
      maxHeight: 100,
      maxWidth: 100);
  return thumbnail;
}

Future<void> launchURL(String url) async {
  try {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  } on PlatformException catch (e) {
    print("Error launching URL: $e");
  } catch (e) {
    print("Unexpected error: $e");
  }
}

Widget timestpa(String messageseen, String timestamp, bool isstar) {
  return RichText(
      text: TextSpan(children: [
    isstar == false
        ? const WidgetSpan(child: SizedBox.shrink())
        : WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Image.asset("assets/images/starfill.png",
                color: Colors.grey.shade400, height: 8),
          ),
    const WidgetSpan(child: SizedBox(width: 5)),
    TextSpan(
      text: convertUTCTimeTo12HourFormat(timestamp),
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    ),
    const WidgetSpan(child: SizedBox(width: 5)),
    WidgetSpan(
      child: Icon(
        Icons.done_all,
        color: messageseen == "1" ? Colors.blue : Colors.grey.shade400,
        size: 15,
      ),
    )
  ]));
}

class CustomtextField extends StatefulWidget {
  final TextInputType? keyboardType;
  final Function()? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function()? onEditingComplate;
  final Function(String)? onSubmitted;
  final dynamic controller;
  final int? maxLines;
  final dynamic onChange;
  final String? errorText;
  final String? hintText;
  final String? labelText;
  bool obscureText = false;
  bool readOnly = false;
  bool autoFocus = false;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  CustomtextField({
    super.key,
    this.keyboardType,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplate,
    this.onSubmitted,
    this.controller,
    this.maxLines,
    this.onChange,
    this.errorText,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.readOnly = false,
    this.autoFocus = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomtextFieldState createState() => _CustomtextFieldState();
}

class _CustomtextFieldState extends State<CustomtextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      textInputAction: widget.textInputAction,
      onTap: widget.onTap,
      autofocus: widget.autoFocus,
      maxLines: widget.maxLines,
      onEditingComplete: widget.onEditingComplate,
      onSubmitted: widget.onSubmitted,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      controller: widget.controller,
      onChanged: widget.onChange,
      style: const TextStyle(color: Colors.black),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        filled: true,
        fillColor: appColorWhite,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        labelText: widget.labelText,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
        errorStyle: const TextStyle(color: Colors.black),
        errorText: widget.errorText,
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(20),
        ),
        hintText: widget.hintText,
        focusColor: Colors.black,
        labelStyle: const TextStyle(color: Colors.black, fontSize: 14),
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

void loginerrorDialog(BuildContext context, String message, {bool? button}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(height: 10.0),
            Text(message, textAlign: TextAlign.center),
            Container(height: 30.0),
            SizedBox(
              height: 45,
              width: MediaQuery.of(context).size.width - 100,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            )
          ],
        ),
      );
    },
  );
}

bool? checkEmailFormat(String? email) {
  bool? emailFormat;
  if (email != '') {
    emailFormat = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email!);
  }
  return emailFormat;
}

class Loader {
  void showIndicator(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Center(
            child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.black.withOpacity(0.7),
              ),
              const Center(
                child: CircularProgressIndicator(
                  color: appColorWhite,
                ),
              )
            ],
          ),
        ));
      },
    );
  }

  void hideIndicator(BuildContext context) {
    Navigator.pop(context);
  }
}

void bookDialog(BuildContext context, String message, {bool? button}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(height: 10.0),
            Text(message, textAlign: TextAlign.center),
            Container(height: 30.0),
            SizedBox(
              height: 45,
              width: MediaQuery.of(context).size.width - 100,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            )
          ],
        ),
      );
    },
  );
}

Widget loader(BuildContext context) {
  return Center(
    child: Container(
      height: 40,
      width: 40,
      decoration: const BoxDecoration(
        color: chatownColor,
        shape: BoxShape.circle,
      ),
      child: const Padding(
        padding: EdgeInsets.all(7.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(chatColor),
          strokeWidth: 3,
        ),
      ),
    ),
  );
}

Widget ingenieriaTextfield(
    {Widget? prefixIcon,
    Function(String)? onChanged,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
    Function? onTap,
    TextEditingController? controller,
    int? maxLines,
    TextInputType? keyboardType}) {
  return TextField(
    controller: controller,
    onTap: () {},
    inputFormatters: inputFormatters,
    maxLines: maxLines,
    keyboardType: keyboardType,
    onChanged: onChanged,
    style: const TextStyle(color: Colors.black, fontSize: 15),
    decoration: InputDecoration(
      prefixIcon: prefixIcon,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
      filled: true,
      contentPadding: const EdgeInsets.only(top: 30.0, left: 10.0),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(0),
      ),
      fillColor: Colors.transparent,
    ),
  );
}

class ReviewtextField extends StatefulWidget {
  final TextInputType? keyboardType;
  final Function()? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function()? onEditingComplate;
  final Function()? onSubmitted;
  final dynamic controller;
  final int? maxLines;
  final dynamic onChange;
  final String? errorText;
  final String? hintText;
  final String? labelText;
  bool obscureText = false;
  bool readOnly = false;
  bool autoFocus = false;
  final Widget? suffixIcon;

  final Widget? prefixIcon;
  ReviewtextField({
    super.key,
    this.keyboardType,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplate,
    this.onSubmitted,
    this.controller,
    this.maxLines,
    this.onChange,
    this.errorText,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.readOnly = false,
    this.autoFocus = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ReviewtextFieldState createState() => _ReviewtextFieldState();
}

class _ReviewtextFieldState extends State<ReviewtextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      textInputAction: widget.textInputAction,
      onTap: widget.onTap,
      autofocus: widget.autoFocus,
      maxLines: widget.maxLines,
      onEditingComplete: widget.onEditingComplate,
      //onSubmitted: widget.onSubmitted!,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      controller: widget.controller,
      onChanged: widget.onChange,
      style: const TextStyle(color: Colors.black),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        labelText: widget.labelText,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
        errorStyle: const TextStyle(color: Colors.black),
        errorText: widget.errorText,
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        hintText: widget.hintText,
        labelStyle: const TextStyle(color: Color(0xFF106C6F)),
        hintStyle: const TextStyle(color: Colors.black),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 1.8),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class CapitalizedText extends StatelessWidget {
  final String text;
  TextStyle? textStyle;

  CapitalizedText(this.text, this.textStyle, {super.key});

  String capitalize(String s) {
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    // Split the text into individual words
    List<String> words = text.split(' ');

    // Capitalize the first letter of each word
    List<String> capitalizedWords =
        words.map((word) => capitalize(word)).toList();

    // Join the words back into a single string
    String capitalizedText = capitalizedWords.join(' ');

    return Text(
      capitalizedText,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textStyle,
    );
  }
}

// String formatLastSeen(String lastSeenString) {
//   DateTime lastSeen = DateTime.parse(lastSeenString).toLocal();

//   final now = DateTime.now();
//   final difference = now.difference(lastSeen);

//   // Use DateFormat to format the time part
//   String formattedTime = DateFormat("h:mm a").format(lastSeen);

//   if (difference.inDays >= 365) {
//     final years = (difference.inDays / 365).floor();
//     return 'Last seen $years ${years == 1 ? 'year' : 'years'} ago';
//   } else if (difference.inDays >= 30) {
//     final months = (difference.inDays / 30).floor();
//     return 'Last seen $months ${months == 1 ? 'month' : 'months'} ago';
//   } else if (difference.inDays >= 1) {
//     return 'Last seen ${difference.inDays == 1 ? 'yesterday at $formattedTime' : '${difference.inDays} days ago'}';
//   } else {
//     return 'Last seen today at $formattedTime';
//   }
// }

String formatLastSeen(String lastSeenString) {
  DateTime lastSeen = DateTime.parse(lastSeenString).toLocal();

  final now = DateTime.now();
  final difference = now.difference(lastSeen);

  // Use DateFormat to format the time part
  String formattedTime = DateFormat("h:mm a").format(lastSeen);

  if (difference.inDays >= 365) {
    final years = (difference.inDays / 365).floor();
    return 'Last seen $years ${years == 1 ? 'year' : 'years'} ago';
  } else if (difference.inDays >= 30) {
    final months = (difference.inDays / 30).floor();
    return 'Last seen $months ${months == 1 ? 'month' : 'months'} ago';
  } else if (difference.inDays >= 1) {
    if (difference.inDays == 1) {
      return 'Last seen yesterday at $formattedTime';
    } else if (difference.inDays == 0) {
      return 'Last seen today, ${DateFormat("d MMMM y").format(lastSeen)}, $formattedTime';
    } else {
      return 'Last seen ${DateFormat("d MMMM y").format(lastSeen)}';
    }
  } else {
    return 'Last seen today at $formattedTime';
  }
}

//=============================================================
// below function :today:- Format time as 4 : 54 PM
// below function :yesterday:- Format time as 4 : 54 PM
String formatDateTime(DateTime dateTime) {
  DateTime now = DateTime.now();
  bool isToday = dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day;

  if (isToday) {
    // Format time as 4 : 54 PM
    return DateFormat.jm().format(dateTime.toLocal());
  } else {
    // Format as 29 April, 4 : 54 PM
    return DateFormat('d MMMM, h:mm a').format(dateTime.toLocal());
  }
}

class CustomCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Color placeholderColor;
  final Icon errorWidgeticon;

  const CustomCachedNetworkImage(
      {required this.imageUrl,
      this.size = 50.0,
      this.placeholderColor = Colors.grey,
      required this.errorWidgeticon});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => SizedBox(
        width: size,
        height: size,
        child: Center(
          child: CircularProgressIndicator(
            color: placeholderColor,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: errorWidgeticon,
      ),
    );
  }
}

String formatDate(String dateString) {
  DateTime date = parseDate(dateString);
  DateTime now = DateTime.now();
  DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return 'Today';
  } else if (date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day) {
    return 'Yesterday';
  } else if (now.difference(date).inDays < 6) {
    return DateFormat('EEEE').format(date);
  } else {
    return DateFormat('dd MMM yyyy').format(date);
  }
}

DateTime parseDate(String dateString) {
  List<String> parts = dateString.split(' ');
  int day = int.parse(parts[0]);
  String monthName = parts[1];
  int year = int.parse(parts[2]);
  int month = DateFormat.MMM().parse(monthName).month;
  return DateTime(year, month, day);
}

//=========================================================
DateTime parsedate(String dateString) {
  return DateTime.parse(dateString);
}

String date(String dateString) {
  DateTime date = parseDate(dateString);
  return DateFormat('dd-MM-yyyy').format(date);
}

String convertToLocalDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return "";
  final DateTime dateTime = DateTime.parse(dateString);
  final DateFormat formatter = DateFormat('dd MMMM yyyy');
  return formatter.format(dateTime);
}

//================================================================= GET ALL CONTACT =========================================================
List<Map<String, String>> mobileContacts = [];
//var mobileContacts = [];
List<Contact> allcontacts = [];

Future getContactsFromGloble() async {
  var getContacts = [];

  var contacts = (await FlutterContacts.getContacts(
    withProperties: true,
    withPhoto: true,
  ))
      .toList();

  allcontacts = contacts.toList();

  // for (int i = 0; i < allcontacts.length; i++) {
  //   Contact c = allcontacts.elementAt(i);
  //   if (c.phones.isNotEmpty) {
  //     getContacts.add(c.phones.map((e) => getMobile(e.number)));
  //   }
  // }
  String cleanNumber(String number) {
    return getMobile(number);
  }

  for (Contact c in allcontacts) {
    if (c.phones.isNotEmpty) {
      // Get the cleaned phone numbers
      List<String> cleanedNumbers =
          c.phones.map((e) => cleanNumber(e.number)).toList();
      for (String number in cleanedNumbers) {
        // Add contact with display name and cleaned number
        mobileContacts.add({'name': c.displayName, 'number': number});
      }
    }
  }
}

//   for (int i = 0; i < getContacts.length; i++) {
//     mobileContacts.add(getContacts[i]
//         .toString()
//         .trim()
//         .replaceAll(' ', '')
//         .replaceAll(' ', '')
//         .replaceAll('  ', '')
//         .replaceAll("(", "")
//         .replaceAll(")", "")
//         .replaceAll("+93", "")
//         .replaceAll("+358", "")
//         .replaceAll("+355", "")
//         .replaceAll("+213", "")
//         .replaceAll("+1", "")
//         .replaceAll("+376", "")
//         .replaceAll("+244", "")
//         .replaceAll("+1", "")
//         .replaceAll("+1", "")
//         .replaceAll("+54", "")
//         .replaceAll("+374", "")
//         .replaceAll("+297", "")
//         .replaceAll("+247", "")
//         .replaceAll("+61", "")
//         .replaceAll("+672", "")
//         .replaceAll("+43", "")
//         .replaceAll("+994", "")
//         .replaceAll("+1", "")
//         .replaceAll("+973", "")
//         .replaceAll("+880", "")
//         .replaceAll("+1", "")
//         .replaceAll("+375", "")
//         .replaceAll("+32", "")
//         .replaceAll("+501", "")
//         .replaceAll("+229", "")
//         .replaceAll("+93", "")
//         .replaceAll("+355", "")
//         .replaceAll("+213", "")
//         .replaceAll("+1-684", "")
//         .replaceAll("+376", "")
//         .replaceAll("+244", "")
//         .replaceAll("+1-264", "")
//         .replaceAll("+672", "")
//         .replaceAll("+1-268", "")
//         .replaceAll("+54", "")
//         .replaceAll("+374", "")
//         .replaceAll("+297", "")
//         .replaceAll("+61", "")
//         .replaceAll("+43", "")
//         .replaceAll("+994", "")
//         .replaceAll("+1-242", "")
//         .replaceAll("+973", "")
//         .replaceAll("+880", "")
//         .replaceAll("+1-246", "")
//         .replaceAll("+375", "")
//         .replaceAll("+32", "")
//         .replaceAll("+501", "")
//         .replaceAll("+229", "")
//         .replaceAll("+1-441", "")
//         .replaceAll("+975", "")
//         .replaceAll("+591", "")
//         .replaceAll("+387", "")
//         .replaceAll("+267", "")
//         .replaceAll("+55", "")
//         .replaceAll("+246", "")
//         .replaceAll("+1-284", "")
//         .replaceAll("+673", "")
//         .replaceAll("+359", "")
//         .replaceAll("+226", "")
//         .replaceAll("+257", "")
//         .replaceAll("+855", "")
//         .replaceAll("+237", "")
//         .replaceAll("+1", "")
//         .replaceAll("+238", "")
//         .replaceAll("+1-345", "")
//         .replaceAll("+236", "")
//         .replaceAll("+235", "")
//         .replaceAll("+56", "")
//         .replaceAll("+86", "")
//         .replaceAll("+61", "")
//         .replaceAll("+61", "")
//         .replaceAll("+57", "")
//         .replaceAll("+269", "")
//         .replaceAll("+682", "")
//         .replaceAll("+506", "")
//         .replaceAll("+385", "")
//         .replaceAll("+53", "")
//         .replaceAll("+599", "")
//         .replaceAll("+357", "")
//         .replaceAll("+420", "")
//         .replaceAll("+243", "")
//         .replaceAll("+45", "")
//         .replaceAll("+253", "")
//         .replaceAll("+1-767", "")
//         .replaceAll("+1-809", "")
//         .replaceAll("+1-829", "")
//         .replaceAll("+1-849", "")
//         .replaceAll("+670", "")
//         .replaceAll("+593", "")
//         .replaceAll("+20", "")
//         .replaceAll("+503", "")
//         .replaceAll("+240", "")
//         .replaceAll("+291", "")
//         .replaceAll("+372", "")
//         .replaceAll("+251", "")
//         .replaceAll("+500", "")
//         .replaceAll("+298", "")
//         .replaceAll("+679", "")
//         .replaceAll("+358", "")
//         .replaceAll("+33", "")
//         .replaceAll("+689", "")
//         .replaceAll("+241", "")
//         .replaceAll("+220", "")
//         .replaceAll("+995", "")
//         .replaceAll("+49", "")
//         .replaceAll("+233", "")
//         .replaceAll("+350", "")
//         .replaceAll("+30", "")
//         .replaceAll("+299", "")
//         .replaceAll("+1-473", "")
//         .replaceAll("+1-671", "")
//         .replaceAll("+502", "")
//         .replaceAll("+44-1481", "")
//         .replaceAll("+224", "")
//         .replaceAll("+245", "")
//         .replaceAll("+592", "")
//         .replaceAll("+509", "")
//         .replaceAll("+504", "")
//         .replaceAll("+852", "")
//         .replaceAll("+36", "")
//         .replaceAll("+354", "")
//         .replaceAll("+91", "")
//         .replaceAll("+62", "")
//         .replaceAll("+98", "")
//         .replaceAll("+964", "")
//         .replaceAll("+353", "")
//         .replaceAll("+44-1624", "")
//         .replaceAll("+972", "")
//         .replaceAll("+39", "")
//         .replaceAll("+225", "")
//         .replaceAll("+1-876", "")
//         .replaceAll("+81", "")
//         .replaceAll("+44-1534", "")
//         .replaceAll("+962", "")
//         .replaceAll("+7", "")
//         .replaceAll("+254", "")
//         .replaceAll("+686", "")
//         .replaceAll("+383", "")
//         .replaceAll("+965", "")
//         .replaceAll("+996", "")
//         .replaceAll("+856", "")
//         .replaceAll("+371", "")
//         .replaceAll("+961", "")
//         .replaceAll("+266", "")
//         .replaceAll("+231", "")
//         .replaceAll("+218", "")
//         .replaceAll("+423", "")
//         .replaceAll("+370", "")
//         .replaceAll("+352", "")
//         .replaceAll("+853", "")
//         .replaceAll("+389", "")
//         .replaceAll("+261", "")
//         .replaceAll("+265", "")
//         .replaceAll("+60", "")
//         .replaceAll("+960", "")
//         .replaceAll("+223", "")
//         .replaceAll("+356", "")
//         .replaceAll("+692", "")
//         .replaceAll("+222", "")
//         .replaceAll("+230", "")
//         .replaceAll("+262", "")
//         .replaceAll("+52", "")
//         .replaceAll("+691", "")
//         .replaceAll("+373", "")
//         .replaceAll("+377", "")
//         .replaceAll("+976", "")
//         .replaceAll("+382", "")
//         .replaceAll("+1-664", "")
//         .replaceAll("+212", "")
//         .replaceAll("+258", "")
//         .replaceAll("+95", "")
//         .replaceAll("+264", "")
//         .replaceAll("+674", "")
//         .replaceAll("+977", "")
//         .replaceAll("+31", "")
//         .replaceAll("+599", "")
//         .replaceAll("+687", "")
//         .replaceAll("+64", "")
//         .replaceAll("+505", "")
//         .replaceAll("+227", "")
//         .replaceAll("+234", "")
//         .replaceAll("+683", "")
//         .replaceAll("+850", "")
//         .replaceAll("+1-670", "")
//         .replaceAll("+47", "")
//         .replaceAll("+968", "")
//         .replaceAll("+92", "")
//         .replaceAll("+680", "")
//         .replaceAll("+970", "")
//         .replaceAll("+507", "")
//         .replaceAll("+675", "")
//         .replaceAll("+595", "")
//         .replaceAll("+51", "")
//         .replaceAll("+63", "")
//         .replaceAll("+64", "")
//         .replaceAll("+48", "")
//         .replaceAll("+351", "")
//         .replaceAll("+1-787", "")
//         .replaceAll("+1-939", "")
//         .replaceAll("+974", "")
//         .replaceAll("+242", "")
//         .replaceAll("+262", "")
//         .replaceAll("+40", "")
//         .replaceAll("+7", "")
//         .replaceAll("+250", "")
//         .replaceAll("+590", "")
//         .replaceAll("+290", "")
//         .replaceAll("+1-869", "")
//         .replaceAll("+1-758", "")
//         .replaceAll("+590", "")
//         .replaceAll("+508", "")
//         .replaceAll("+1-784", "")
//         .replaceAll("+685", "")
//         .replaceAll("+378", "")
//         .replaceAll("+239", "")
//         .replaceAll("+966", "")
//         .replaceAll("+221", "")
//         .replaceAll("+381", "")
//         .replaceAll("+248", "")
//         .replaceAll("+232", "")
//         .replaceAll("+65", "")
//         .replaceAll("+1-721", "")
//         .replaceAll("+421", "")
//         .replaceAll("+386", "")
//         .replaceAll("+677", "")
//         .replaceAll("+252", "")
//         .replaceAll("+27", "")
//         .replaceAll("+82", "")
//         .replaceAll("+211", "")
//         .replaceAll("+34", "")
//         .replaceAll("+94", "")
//         .replaceAll("+249", "")
//         .replaceAll("+597", "")
//         .replaceAll("+47", "")
//         .replaceAll("+268", "")
//         .replaceAll("+46", "")
//         .replaceAll("+41", "")
//         .replaceAll("+963", "")
//         .replaceAll("+886", "")
//         .replaceAll("+992", "")
//         .replaceAll("+255", "")
//         .replaceAll("+66", "")
//         .replaceAll("+228", "")
//         .replaceAll("+690", "")
//         .replaceAll("+676", "")
//         .replaceAll("+1-868", "")
//         .replaceAll("+216", "")
//         .replaceAll("+90", "")
//         .replaceAll("+993", "")
//         .replaceAll("+1-649", "")
//         .replaceAll("+688", "")
//         .replaceAll("+1-340", "")
//         .replaceAll("+256", "")
//         .replaceAll("+380", "")
//         .replaceAll("+971", "")
//         .replaceAll("+44", "")
//         .replaceAll("+1", "")
//         .replaceAll("+598", "")
//         .replaceAll("+998", "")
//         .replaceAll("+678", "")
//         .replaceAll("+379", "")
//         .replaceAll("+58", "")
//         .replaceAll("+84", "")
//         .replaceAll("+681", "")
//         .replaceAll("+212", "")
//         .replaceAll("+967", "")
//         .replaceAll("+260", "")
//         .replaceAll("+263", "")
//         .replaceAll("+92", "")
//         .replaceAll(RegExp(r'^0+(?=.)'), '')
//         .replaceFirst(RegExp(r'^0+'), '')
//         .replaceAll("-", "")
//         .replaceAll(" ", "")
//         .replaceAll(".", "")
//         .replaceAll('  ', "")
//         .replaceAll("+91", "")
//         .trim());
//   }

//   return mobileContacts;
// }

String getContactName(mobile) {
  if (mobile != null) {
    var name = mobile;
    for (var i = 0; i < allcontacts.length; i++) {
      if (allcontacts[i]
          .phones
          .map((e) => e.number)
          .toString()
          .replaceAll(RegExp(r"\s+\b|\b\s"), "")
          .contains(mobile)) {
        name = allcontacts[i].displayName;
      }
    }
    return name;
  } else {
    return mobile;
  }
}

String getMobile(String number) {
  return number
      .toString()
      .trim()
      .replaceAll(' ', '')
      .replaceAll(' ', '')
      .replaceAll('  ', '')
      .replaceAll("(", "")
      .replaceAll(")", "")
      .replaceAll("+93", "")
      .replaceAll("+358", "")
      .replaceAll("+355", "")
      .replaceAll("+213", "")
      .replaceAll("+1", "")
      .replaceAll("+376", "")
      .replaceAll("+244", "")
      .replaceAll("+1", "")
      .replaceAll("+1", "")
      .replaceAll("+54", "")
      .replaceAll("+374", "")
      .replaceAll("+297", "")
      .replaceAll("+247", "")
      .replaceAll("+61", "")
      .replaceAll("+672", "")
      .replaceAll("+43", "")
      .replaceAll("+994", "")
      .replaceAll("+1", "")
      .replaceAll("+973", "")
      .replaceAll("+880", "")
      .replaceAll("+1", "")
      .replaceAll("+375", "")
      .replaceAll("+32", "")
      .replaceAll("+501", "")
      .replaceAll("+229", "")
      .replaceAll("+93", "")
      .replaceAll("+355", "")
      .replaceAll("+213", "")
      .replaceAll("+1-684", "")
      .replaceAll("+376", "")
      .replaceAll("+244", "")
      .replaceAll("+1-264", "")
      .replaceAll("+672", "")
      .replaceAll("+1-268", "")
      .replaceAll("+54", "")
      .replaceAll("+374", "")
      .replaceAll("+297", "")
      .replaceAll("+61", "")
      .replaceAll("+43", "")
      .replaceAll("+994", "")
      .replaceAll("+1-242", "")
      .replaceAll("+973", "")
      .replaceAll("+880", "")
      .replaceAll("+1-246", "")
      .replaceAll("+375", "")
      .replaceAll("+32", "")
      .replaceAll("+501", "")
      .replaceAll("+229", "")
      .replaceAll("+1-441", "")
      .replaceAll("+975", "")
      .replaceAll("+591", "")
      .replaceAll("+387", "")
      .replaceAll("+267", "")
      .replaceAll("+55", "")
      .replaceAll("+246", "")
      .replaceAll("+1-284", "")
      .replaceAll("+673", "")
      .replaceAll("+359", "")
      .replaceAll("+226", "")
      .replaceAll("+257", "")
      .replaceAll("+855", "")
      .replaceAll("+237", "")
      .replaceAll("+1", "")
      .replaceAll("+238", "")
      .replaceAll("+1-345", "")
      .replaceAll("+236", "")
      .replaceAll("+235", "")
      .replaceAll("+56", "")
      .replaceAll("+86", "")
      .replaceAll("+61", "")
      .replaceAll("+61", "")
      .replaceAll("+57", "")
      .replaceAll("+269", "")
      .replaceAll("+682", "")
      .replaceAll("+506", "")
      .replaceAll("+385", "")
      .replaceAll("+53", "")
      .replaceAll("+599", "")
      .replaceAll("+357", "")
      .replaceAll("+420", "")
      .replaceAll("+243", "")
      .replaceAll("+45", "")
      .replaceAll("+253", "")
      .replaceAll("+1-767", "")
      .replaceAll("+1-809", "")
      .replaceAll("+1-829", "")
      .replaceAll("+1-849", "")
      .replaceAll("+670", "")
      .replaceAll("+593", "")
      .replaceAll("+20", "")
      .replaceAll("+503", "")
      .replaceAll("+240", "")
      .replaceAll("+291", "")
      .replaceAll("+372", "")
      .replaceAll("+251", "")
      .replaceAll("+500", "")
      .replaceAll("+298", "")
      .replaceAll("+679", "")
      .replaceAll("+358", "")
      .replaceAll("+33", "")
      .replaceAll("+689", "")
      .replaceAll("+241", "")
      .replaceAll("+220", "")
      .replaceAll("+995", "")
      .replaceAll("+49", "")
      .replaceAll("+233", "")
      .replaceAll("+350", "")
      .replaceAll("+30", "")
      .replaceAll("+299", "")
      .replaceAll("+1-473", "")
      .replaceAll("+1-671", "")
      .replaceAll("+502", "")
      .replaceAll("+44-1481", "")
      .replaceAll("+224", "")
      .replaceAll("+245", "")
      .replaceAll("+592", "")
      .replaceAll("+509", "")
      .replaceAll("+504", "")
      .replaceAll("+852", "")
      .replaceAll("+36", "")
      .replaceAll("+354", "")
      .replaceAll("+91", "")
      .replaceAll("+62", "")
      .replaceAll("+98", "")
      .replaceAll("+964", "")
      .replaceAll("+353", "")
      .replaceAll("+44-1624", "")
      .replaceAll("+972", "")
      .replaceAll("+39", "")
      .replaceAll("+225", "")
      .replaceAll("+1-876", "")
      .replaceAll("+81", "")
      .replaceAll("+44-1534", "")
      .replaceAll("+962", "")
      .replaceAll("+7", "")
      .replaceAll("+254", "")
      .replaceAll("+686", "")
      .replaceAll("+383", "")
      .replaceAll("+965", "")
      .replaceAll("+996", "")
      .replaceAll("+856", "")
      .replaceAll("+371", "")
      .replaceAll("+961", "")
      .replaceAll("+266", "")
      .replaceAll("+231", "")
      .replaceAll("+218", "")
      .replaceAll("+423", "")
      .replaceAll("+370", "")
      .replaceAll("+352", "")
      .replaceAll("+853", "")
      .replaceAll("+389", "")
      .replaceAll("+261", "")
      .replaceAll("+265", "")
      .replaceAll("+60", "")
      .replaceAll("+960", "")
      .replaceAll("+223", "")
      .replaceAll("+356", "")
      .replaceAll("+692", "")
      .replaceAll("+222", "")
      .replaceAll("+230", "")
      .replaceAll("+262", "")
      .replaceAll("+52", "")
      .replaceAll("+691", "")
      .replaceAll("+373", "")
      .replaceAll("+377", "")
      .replaceAll("+976", "")
      .replaceAll("+382", "")
      .replaceAll("+1-664", "")
      .replaceAll("+212", "")
      .replaceAll("+258", "")
      .replaceAll("+95", "")
      .replaceAll("+264", "")
      .replaceAll("+674", "")
      .replaceAll("+977", "")
      .replaceAll("+31", "")
      .replaceAll("+599", "")
      .replaceAll("+687", "")
      .replaceAll("+64", "")
      .replaceAll("+505", "")
      .replaceAll("+227", "")
      .replaceAll("+234", "")
      .replaceAll("+683", "")
      .replaceAll("+850", "")
      .replaceAll("+1-670", "")
      .replaceAll("+47", "")
      .replaceAll("+968", "")
      .replaceAll("+92", "")
      .replaceAll("+680", "")
      .replaceAll("+970", "")
      .replaceAll("+507", "")
      .replaceAll("+675", "")
      .replaceAll("+595", "")
      .replaceAll("+51", "")
      .replaceAll("+63", "")
      .replaceAll("+64", "")
      .replaceAll("+48", "")
      .replaceAll("+351", "")
      .replaceAll("+1-787", "")
      .replaceAll("+1-939", "")
      .replaceAll("+974", "")
      .replaceAll("+242", "")
      .replaceAll("+262", "")
      .replaceAll("+40", "")
      .replaceAll("+7", "")
      .replaceAll("+250", "")
      .replaceAll("+590", "")
      .replaceAll("+290", "")
      .replaceAll("+1-869", "")
      .replaceAll("+1-758", "")
      .replaceAll("+590", "")
      .replaceAll("+508", "")
      .replaceAll("+1-784", "")
      .replaceAll("+685", "")
      .replaceAll("+378", "")
      .replaceAll("+239", "")
      .replaceAll("+966", "")
      .replaceAll("+221", "")
      .replaceAll("+381", "")
      .replaceAll("+248", "")
      .replaceAll("+232", "")
      .replaceAll("+65", "")
      .replaceAll("+1-721", "")
      .replaceAll("+421", "")
      .replaceAll("+386", "")
      .replaceAll("+677", "")
      .replaceAll("+252", "")
      .replaceAll("+27", "")
      .replaceAll("+82", "")
      .replaceAll("+211", "")
      .replaceAll("+34", "")
      .replaceAll("+94", "")
      .replaceAll("+249", "")
      .replaceAll("+597", "")
      .replaceAll("+47", "")
      .replaceAll("+268", "")
      .replaceAll("+46", "")
      .replaceAll("+41", "")
      .replaceAll("+963", "")
      .replaceAll("+886", "")
      .replaceAll("+992", "")
      .replaceAll("+255", "")
      .replaceAll("+66", "")
      .replaceAll("+228", "")
      .replaceAll("+690", "")
      .replaceAll("+676", "")
      .replaceAll("+1-868", "")
      .replaceAll("+216", "")
      .replaceAll("+90", "")
      .replaceAll("+993", "")
      .replaceAll("+1-649", "")
      .replaceAll("+688", "")
      .replaceAll("+1-340", "")
      .replaceAll("+256", "")
      .replaceAll("+380", "")
      .replaceAll("+971", "")
      .replaceAll("+44", "")
      .replaceAll("+1", "")
      .replaceAll("+598", "")
      .replaceAll("+998", "")
      .replaceAll("+678", "")
      .replaceAll("+379", "")
      .replaceAll("+58", "")
      .replaceAll("+84", "")
      .replaceAll("+681", "")
      .replaceAll("+212", "")
      .replaceAll("+967", "")
      .replaceAll("+260", "")
      .replaceAll("+263", "")
      .replaceAll("+92", "")
      .replaceAll(RegExp(r'^0+(?=.)'), '')
      .replaceFirst(RegExp(r'^0+'), '')
      .replaceAll("-", "")
      .replaceAll(" ", "")
      .replaceAll(".", "")
      .replaceAll('  ', "")
      .replaceAll("+91", "")
      .trim();
}

String getContact1(mobile, name1) {
  if (mobile != null) {
    var name = mobile;
    bool found = false;
    for (var i = 0; i < allcontacts.length; i++) {
      if (allcontacts[i]
          .phones
          .map((e) => e.number)
          .toString()
          .replaceAll(RegExp(r"\s+\b|\b\s"), "")
          .contains(mobile)) {
        name = allcontacts[i].displayName;
        found = true;
        break; // Once found, no need to continue searching
      }
    }
    if (!found) {
      return name1; // Return username if contact not found
    }
    return name;
  } else {
    return mobile;
  }
}

String addPublicToUrl(String url) {
  Uri uri = Uri.parse(url);

  // Construct the new URL with '/public'
  Uri newUri = Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.port,
    path: '/public${uri.path}',
  );

  return newUri.toString();
}

void showCustomToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT, // or Toast.LENGTH_LONG
      gravity: ToastGravity.BOTTOM, // or ToastGravity.TOP / ToastGravity.CENTER
      timeInSecForIosWeb: 2,
      backgroundColor:
          Colors.black, // Change this to your desired background color
      textColor: Colors.white, // Change this to your desired text color
      fontSize: 13.0 // Change this to your desired font size
      );
}

final Map<String, int> countryMobileLengths = {
  '+91': 10, // India
  '+93': 9, // Afghanistan
  '+355': 9, // Albania
  '+213': 9, // Algeria
  '+376': 6, // Andorra
  '+244': 9, // Angola
  '+54': 10, // Argentina
  '+374': 8, // Armenia
  '+61': 9, // Australia
  '+43': 10, // Austria
  '+994': 9, // Azerbaijan
  '+973': 8, // Bahrain
  '+880': 10, // Bangladesh
  '+375': 9, // Belarus
  '+32': 9, // Belgium
  '+501': 7, // Belize
  '+229': 8, // Benin
  '+975': 8, // Bhutan
  '+591': 8, // Bolivia
  '+387': 8, // Bosnia and Herzegovina
  '+267': 8, // Botswana
  '+55': 11, // Brazil
  '+673': 7, // Brunei
  '+359': 9, // Bulgaria
  '+226': 8, // Burkina Faso
  '+257': 8, // Burundi
  '+855': 9, // Cambodia
  '+237': 9, // Cameroon
  '+1': 10, // Canada
  '+238': 7, // Cape Verde
  '+236': 8, // Central African Republic
  '+235': 8, // Chad
  '+56': 9, // Chile
  '+86': 11, // China
  '+57': 10, // Colombia
  '+269': 7, // Comoros
  '+242': 9, // Congo
  '+243': 9, // Congo (DRC)
  '+682': 5, // Cook Islands
  '+506': 8, // Costa Rica
  '+225': 10, // Côte d'Ivoire
  '+385': 9, // Croatia
  '+53': 8, // Cuba
  '+357': 8, // Cyprus
  '+420': 9, // Czech Republic
  '+45': 8, // Denmark
  '+253': 8, // Djibouti
  '+670': 8, // East Timor
  '+593': 9, // Ecuador
  '+20': 10, // Egypt
  '+503': 8, // El Salvador
  '+240': 9, // Equatorial Guinea
  '+291': 7, // Eritrea
  '+372': 7, // Estonia
  '+268': 8, // Eswatini
  '+251': 9, // Ethiopia
  '+679': 7, // Fiji
  '+358': 10, // Finland
  '+33': 9, // France
  '+241': 7, // Gabon
  '+220': 7, // Gambia
  '+995': 9, // Georgia
  '+49': 11, // Germany
  '+233': 9, // Ghana
  '+30': 10, // Greece
  '+299': 6, // Greenland
  '+502': 8, // Guatemala
  '+224': 9, // Guinea
  '+245': 7, // Guinea-Bissau
  '+592': 7, // Guyana
  '+509': 8, // Haiti
  '+504': 8, // Honduras
  '+852': 8, // Hong Kong
  '+36': 9, // Hungary
  '+354': 7, // Iceland
  '+62': 11, // Indonesia
  '+98': 10, // Iran
  '+964': 10, // Iraq
  '+353': 9, // Ireland
  '+972': 10, // Israel
  '+39': 10, // Italy
  '+81': 10, // Japan
  '+962': 9, // Jordan
  '+7': 10, // Kazakhstan
  '+254': 10, // Kenya
  '+686': 8, // Kiribati
  '+965': 8, // Kuwait
  '+996': 9, // Kyrgyzstan
  '+856': 9, // Laos
  '+371': 8, // Latvia
  '+961': 8, // Lebanon
  '+266': 8, // Lesotho
  '+231': 7, // Liberia
  '+218': 9, // Libya
  '+423': 7, // Liechtenstein
  '+370': 8, // Lithuania
  '+352': 9, // Luxembourg
  '+853': 8, // Macau
  '+261': 9, // Madagascar
  '+265': 9, // Malawi
  '+60': 10, // Malaysia
  '+960': 7, // Maldives
  '+223': 8, // Mali
  '+356': 8, // Malta
  '+692': 7, // Marshall Islands
  '+222': 8, // Mauritania
  '+230': 8, // Mauritius
  '+52': 10, // Mexico
  '+691': 7, // Micronesia
  '+373': 8, // Moldova
  '+377': 8, // Monaco
  '+976': 8, // Mongolia
  '+382': 9, // Montenegro
  '+212': 9, // Morocco
  '+258': 9, // Mozambique
  '+264': 9, // Namibia
  '+674': 7, // Nauru
  '+977': 10, // Nepal
  '+31': 9, // Netherlands
  '+687': 6, // New Caledonia
  '+64': 9, // New Zealand
  '+505': 8, // Nicaragua
  '+227': 8, // Niger
  '+234': 10, // Nigeria
  '+47': 8, // Norway
  '+968': 8, // Oman
  '+92': 10, // Pakistan
  '+680': 7, // Palau
  '+507': 8, // Panama
  '+675': 9, // Papua New Guinea
  '+595': 9, // Paraguay
  '+51': 9, // Peru
  '+63': 10, // Philippines
  '+48': 9, // Poland
  '+351': 9, // Portugal
  '+974': 8, // Qatar
  '+40': 10, // Romania
  '+7': 10, // Russia
  '+250': 9, // Rwanda
  '+685': 7, // Samoa
  '+378': 10, // San Marino
  '+239': 7, // São Tomé and Príncipe
  '+966': 9, // Saudi Arabia
  '+221': 9, // Senegal
  '+381': 9, // Serbia
  '+248': 7, // Seychelles
  '+232': 8, // Sierra Leone
  '+65': 8, // Singapore
  '+421': 9, // Slovakia
  '+386': 9, // Slovenia
  '+677': 7, // Solomon Islands
  '+252': 8, // Somalia
  '+27': 9, // South Africa
  '+82': 10, // South Korea
  '+211': 9, // South Sudan
  '+34': 9, // Spain
  '+94': 9, // Sri Lanka
  '+249': 9, // Sudan
  '+597': 7, // Suriname
  '+268': 8, // Eswatini
  '+46': 9, // Sweden
  '+41': 9, // Switzerland
  '+963': 9, // Syria
  '+886': 9, // Taiwan
  '+992': 9, // Tajikistan
  '+255': 9, // Tanzania
  '+66': 9, // Thailand
  '+228': 8, // Togo
  '+676': 7, // Tonga
  '+216': 8, // Tunisia
  '+90': 10, // Turkey
  '+993': 8, // Turkmenistan
  '+688': 6, // Tuvalu
  '+256': 9, // Uganda
  '+380': 9, // Ukraine
  '+971': 9, // United Arab Emirates
  '+44': 10, // United Kingdom
  '+1': 10, // United States
  '+598': 9, // Uruguay
  '+998': 9, // Uzbekistan
  '+678': 7, // Vanuatu
  '+379': 9, // Vatican City
  '+58': 10, // Venezuela
  '+84': 9, // Vietnam
  '+967': 9, // Yemen
  '+260': 9, // Zambia
  '+263': 9, // Zimbabwe
};

class CustomButtom extends StatelessWidget {
  final String? title;
  final Function()? onPressed;
  const CustomButtom({
    super.key,
    this.title,
    this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding: const EdgeInsets.all(0.0),
        ),
        onPressed: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(colors: [
              Color.fromRGBO(252, 198, 4, 0.5),
              Color.fromRGBO(252, 198, 4, 1)
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 370.0, minHeight: 50.0),
            alignment: Alignment.center,
            child: Text(title!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                )),
          ),
        ),
      ),
    );
  }
}

Widget messageSelector({
  required Function() onTap,
  required List chatID,
  required int messageid,
}) {
  return InkWell(
      onTap: onTap,
      child: chatID.isEmpty
          ? const SizedBox()
          : Transform.scale(
              scale: 1.1,
              child: Container(
                  width: 20.0,
                  height: 20.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                          color: chatID.contains(messageid.toString())
                              ? Colors.transparent
                              : black1Color),
                      color: chatID.contains(messageid.toString()) ? bg1 : bg1,
                      gradient: chatID.contains(messageid.toString())
                          ? LinearGradient(
                              colors: [blackColor, black1Color],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomCenter)
                          : null),
                  child: chatID.contains(messageid.toString())
                      ? Image.asset("assets/images/right.png").paddingAll(4)
                      : const SizedBox(
                          height: 10,
                        ))));
}

Widget containerProfileDesign(
    {required Function() onTap,
    required String image,
    required String title,
    String? about}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 46,
      width: Get.width * 90,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(image, height: 16),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600),
              )
            ],
          ),
          Row(
            children: [
              Text(
                about!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          )
        ],
      ).paddingSymmetric(horizontal: 10),
    ),
  );
}
