import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as IMG;
const themeColor = Color(0xff5ac18e);
const primaryDarkColor = CupertinoColors.darkBackgroundGray;
const primaryWhiteColor = CupertinoColors.white;
final secondaryButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: primaryDarkColor,
  foregroundColor: primaryWhiteColor,
  padding: const EdgeInsets.all(15),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
);
const defaultImageUrl = "https://i.pinimg.com/736x/b7/a3/0f/b7a30fd91a79edd33c3730c72e363f1e.jpg";
const mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x775ac18e),
      Color(0x995ac18e),
      Color(0xcc5ac18e),
      Color(0xff5ac18e),
    ]);

final cardsButtonStyle =  ElevatedButton.styleFrom(
elevation: 8,
primary: CupertinoColors.white,
shape:  const CircleBorder(),
minimumSize:  const Size.square(80),
);
const primaryShadowColor = Colors.black26;
const primaryTitleStyle = TextStyle(
    color: primaryWhiteColor, fontSize: 34, fontWeight: FontWeight.bold
);
const primaryDarkTitleStyle = TextStyle(
  fontSize: 30,
  color: Colors.black87,
  fontWeight: FontWeight.w500,
);
const secondaryDarkTitleStyle = TextStyle(
  fontSize: 18,
  color: Colors.black87,
  fontWeight: FontWeight.w500,
);
const secondaryTitleStyle = TextStyle(
    color: primaryWhiteColor, fontSize: 18, fontWeight: FontWeight.bold
);
const tertiaryTitleStyle = TextStyle(
    color: primaryWhiteColor, fontSize: 15, fontWeight: FontWeight.bold
);
const tertiaryDarkTitleStyle = TextStyle(
  fontSize: 15,
  color: Colors.black87,
  fontWeight: FontWeight.w500,
);
const normalBoldTextStyle = TextStyle(
    color: primaryWhiteColor, fontWeight: FontWeight.bold
);
class staticMethods {
  static Widget buildTextField(String label, String example, String field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
              color: primaryWhiteColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.only(left: 10),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
              ]),
          height: 50,
            child: TextField(
              onChanged: (value) {
                field = value!;

              },
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(top: 14),
                hintText: example,
                hintStyle: const TextStyle(color: Colors.black38),
            ),
          ),
        ),
      ],
    );
  }

}


//this function has to be out of a class. In fact, we use the "compute" feature that allows to do background work (threading)
//this feature requires a FUNCTION and not a METHOD
  Future<Uint8List> reduceImageQualityAndSize(Uint8List image) async {

  int maxInBytes = 500 * 1000;
  Uint8List resizedData = Uint8List.fromList(image);

  IMG.Image? img = IMG.decodeImage(image);
  int size = image.lengthInBytes;
  int quality = 100;

  print("size max: " + maxInBytes.toString());
  print("size before: " + size.toString() + " bytes");

  while (size > maxInBytes && quality > 10) {
    // reduce image size about 10% of image, until the size is less than the maximum limit
    quality = (quality - (quality * 0.1)).toInt();
    int width = img!.width - (img.width * 0.1).toInt();
    IMG.Image resized = IMG.copyResize(img, width: width);
    resizedData =
    Uint8List.fromList(IMG.encodeJpg(resized, quality: quality));
    size = resizedData.lengthInBytes;
    img = resized;
  }

  print("size after: " + size.toString() + " bytes");

  return resizedData;
}

