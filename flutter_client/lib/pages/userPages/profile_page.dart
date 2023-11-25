import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:SpoTinder/api/server_api.dart';
import 'package:SpoTinder/models/User.dart';
import 'package:SpoTinder/models/requests/updateProfile_model.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants.dart';

//This file contains profile page and edit profile page
class ProfilePage extends StatefulWidget {
  final User user;
  bool initDone = false;

  ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    loadProfile();
    super.initState();
  }

  Future<void> loadProfile() async {
    //if the user updated his profile through EditPage
    if (widget.user.hasToBeUpdated) {
      GetProfileResponseModel response = await APIService.getProfile();
      updateLocalFields(response);
    }
  }

  void updateLocalFields(GetProfileResponseModel value) {
    if (value.status.errorMsg.contains("No profile created")) {
      //in case of first use (no profile) then user is redirected to EditPage
      widget.user.profileData = ProfileData.noArgs();
      widget.user.profileData!.images.add(SpotinderImage(0, defaultImageUrl));
      Navigator.pushNamed(context, "/EditProfilePage", arguments: widget.user);
    } else {
      widget.user.profileData = value.profileData;
      if (value.profileData.images.isNotEmpty) {
        widget.user.profileData!.images = value.profileData.images;
      } else {
        widget.user.profileData!.images.add(SpotinderImage(
            0, defaultImageUrl)); //default image if no image was uploaded
      }
      setState(() {
        widget.user.hasToBeUpdated = false;
        widget.initDone = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Stack(
          children: <Widget>[
            ListView(),
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: mainGradient,
              ),
              child: RefreshIndicator(
                onRefresh: loadProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        widget.initDone
                            ? Card(
                                elevation: 0,
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 375,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: primaryDarkColor,
                                          radius: 84,
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                widget.user.profileData!
                                                    .images[0].imageUrl,
                                                headers: {
                                                  'Authorization':
                                                      widget.user.token
                                                }),
                                            //NetworkImage
                                            radius: 80,
                                          ), //CircleAvatar
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),

                                        Text(
                                          widget.user.profileData!.surname,
                                          style:
                                              secondaryDarkTitleStyle, //Textstyle
                                        ), //Text
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        ElevatedButton(
                                            style: secondaryButtonStyle,
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pushNamed(
                                                    "/EditProfilePage",
                                                    arguments: widget.user)
                                                    .then(onGoBack),
                                            child: Text(
                                              'Edit Profile',
                                              style: tertiaryTitleStyle,
                                            )),
                                        const SizedBox(height: 10,),
                                        Expanded(
                                          child: Text(
                                            widget.user.profileData!.description,
                                            maxLines: 9,
                                            softWrap: false,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                tertiaryDarkTitleStyle, //Textstyle
                                          ),
                                        ),
                                        //SizedBox
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : const Text(""),
                        widget.initDone
                            ? GridView.builder(
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount:
                                    widget.user.profileData!.images.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              widget.user.profileData!
                                                  .images![index].imageUrl,
                                              headers: {
                                                "Authorization":
                                                    widget.user.token
                                              }),
                                          fit: BoxFit.cover),
                                    ),
                                  );
                                },
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 10.0,
                                  childAspectRatio: 600 / 900,
                                ),
                              )
                            : const Center(
                                heightFactor: 10.0,
                                child: CircularProgressIndicator(),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  FutureOr onGoBack(Object? value) {
    loadProfile();
    setState(() { widget.initDone = true;});
  }
}

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker imagePicker = ImagePicker();
  List<XFile> imageFileList = [];
  UpdateRequestModel updateRequestModel = UpdateRequestModel.noArgs();

  final countryPicker = const FlCountryCodePicker(showDialCode: false);
  bool isCompressing = false;

  void selectImages() async {
    final List<XFile> selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages!.isNotEmpty) {
      imageFileList!.addAll(selectedImages);
      setState(() => isCompressing = true);
      compute(compressAndLoadImagesInRequest, selectedImages).then((value) {
        //when done compressing
        updateRequestModel.images = value;
        setState(() => isCompressing = false);
      });
    }
  }

  @override
  void initState() {
    if (widget.user.profileData != null) {
      //setting fields one by one in order to not copy the reference => in case of a cancel, the actual data in User would be modified
      copyFields();
    } else {
      updateRequestModel.profileData.gender = 'M';
    }
    super.initState();
  }

  void copyFields() {
    updateRequestModel.profileData.surname = widget.user.profileData!.surname;
    updateRequestModel.profileData.description =
        widget.user.profileData!.description;
    updateRequestModel.profileData.birthDate =
        widget.user.profileData!.birthDate;
    updateRequestModel.profileData.gender = widget.user.profileData!.gender;
    updateRequestModel.profileData.localisation =
        widget.user.profileData!.localisation;
    updateRequestModel.profileData.images = widget.user.profileData!.images;
  }

  Widget buildSurnameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Surname",
          style: TextStyle(
              color: primaryWhiteColor,
              fontSize: 16,
              fontWeight: FontWeight.bold),
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
                    color: primaryShadowColor,
                    blurRadius: 6,
                    offset: Offset(0, 2))
              ]),
          height: 50,
          child: TextField(
            onChanged: (value) {
              setState(() {
                updateRequestModel.profileData.surname = value!;
              });
            },
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 14),
              hintText: widget.user.profileData == null
                  ? "John"
                  : widget.user.profileData!.surname,
              hintStyle: const TextStyle(color: Colors.black38),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Description",
          style: tertiaryTitleStyle,
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
                    color: primaryShadowColor,
                    blurRadius: 6,
                    offset: Offset(0, 2))
              ]),
          height: 50,
          child: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            onChanged: (value) {
              updateRequestModel.profileData.description = value!;
            },
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 14),
              hintText: widget.user.profileData == null
                  ? "I love apples"
                  : widget.user.profileData!.description,
              hintStyle: const TextStyle(color: Colors.black38),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentCountry;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
            decoration: const BoxDecoration(
              gradient: mainGradient,
            ),
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            child: ListView(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: primaryDarkColor,
                  radius: 84,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                        widget.user.profileData!
                            .images[0].imageUrl,
                        headers: {
                          'Authorization':
                          widget.user.token
                        }),
                    //NetworkImage
                    radius: 80,
                  ), //CircleAvatar
                ),
                const SizedBox(
                  height: 30,
                ),
                buildSurnameField(),
                const SizedBox(
                  height: 20,
                ),
                buildDescriptionField(),
                const SizedBox(
                  height: 20,
                ),
                Row(children: [
                  SizedBox(
                    width: 170,
                    child: ElevatedButton(
                      style: secondaryButtonStyle,
                      child: const Text('Pick your birth date'),
                      onPressed: () => showSelectedDate(context),
                    ),
                  ),
                  const SizedBox(
                    width: 100,
                  ),
                  Text(updateRequestModel.profileData.birthDate.isEmpty
                      ? widget.user.profileData!.birthDate
                      : updateRequestModel.profileData.birthDate),
                ]),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Pick your Gender',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                    children: <String>{'M', 'F'}.map((value) {
                  return Flexible(
                      child: RadioListTile(
                          value: value,
                          groupValue: updateRequestModel.profileData.gender,
                          title: Text(
                            value,
                          ),
                          onChanged: (value) {
                            setState(() {
                              updateRequestModel.profileData.gender = value!;
                            });
                          }));
                }).toList()),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final code =
                            await countryPicker.showPicker(context: context);
                        updateRequestModel.profileData.localisation =
                            code!.code;
                        setState(() {
                          currentCountry = code!.name;
                        });
                      },
                      style: secondaryButtonStyle,
                      child: const Text('Choose your country'),
                    ),
                    const SizedBox(width: 100),
                    Text(currentCountry ??
                        widget.user.profileData!.localisation),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      itemCount: imageFileList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Image.file(
                          File(imageFileList[index].path),
                          fit: BoxFit.cover,
                        );
                      },
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10.0,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_a_photo_sharp),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(30, 30),
                      maximumSize: const Size(30, 30),
                      backgroundColor: const Color(0x555ac18e)),
                  onPressed: () {
                    selectImages();
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: (() => uploadProfile()),
                      style: secondaryButtonStyle,
                      child: const Text('Save'),
                    ),
                    const SizedBox(
                      width: 200,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: secondaryButtonStyle,
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            )),
      ),
    );
  }

  Future<void> showSelectedDate(BuildContext context) async {
    DateTime dateTime = (await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now()
          .subtract(const Duration(days: 6575)), // 6575 days = 18 years
    ))!;
    setState(() {
      updateRequestModel.profileData.birthDate =
          "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    });
  }

  void uploadProfile() {
    //todo prefill fields, and for images?
    if (!updateRequestModel.profileData.isEmpty() && !isCompressing) {
      APIService.updateProfile(updateRequestModel)
          .then((value) => displayUpdateResultAndSetToBeUpdated(value));
    } else {
      String content = isCompressing
          ? "Images are being compressed, wait"
          : "Fields cannot be empty";
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(content)));
    }
  }

  void displayUpdateResultAndSetToBeUpdated(UpdateResponseModel value) {
    if (value.status.status == "success") {
      widget.user.hasToBeUpdated =
          true; // hasToBeUpdated == true triggers a GET /profile on api
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Updated successfully '),
        ),
      );
    }
  }
}

//out of class method because required for compute(). Allows for background work
List<String> compressAndLoadImagesInRequest(List<XFile> selectedImages) {
  List<String> images = [];
  for (var img in selectedImages) {
    var file = File(img.path);
    var imgBytes = file.readAsBytesSync();
    reduceImageQualityAndSize(imgBytes)
        .then((value) => images.add(base64Encode(value)));
  }
  return images;
}
