// ignore_for_file: deprecated_member_use, must_be_immutable, file_names, avoid_print, non_constant_identifier_names

import 'dart:developer';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lecle_flutter_link_preview/lecle_flutter_link_preview.dart';
import 'package:meyaoo_new/controller/single_chat_media_controller.dart';
import 'package:meyaoo_new/model/chat_profile_model.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:meyaoo_new/src/screens/chat/FileView.dart';
import 'package:meyaoo_new/src/screens/chat/chatvideo.dart';
import 'package:meyaoo_new/src/screens/chat/imageView.dart';
import 'package:page_transition/page_transition.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Media extends StatefulWidget {
  String? peeid;
  String? peername;
  Media({super.key, this.peeid, this.peername});

  @override
  State<Media> createState() => _MediaState();
}

class _MediaState extends State<Media> {
  ChatProfileController chatProfileController = Get.find();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatProfileController.getProfileDATA(widget.peeid!);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: chatownColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child:
              const Icon(Icons.arrow_back_ios, size: 23, color: Colors.black),
        ),
        centerTitle: true,
        title: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              const SizedBox(width: 10),
              Text(
                capitalizeFirstLetter(widget.peername.toString()),
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: chatColor),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        return SafeArea(
            child: Container(
          color: Colors.transparent,
          height: MediaQuery.of(context).size.height,
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                ButtonsTabBar(
                  borderWidth: 1,
                  unselectedBorderColor: chatownColor,
                  borderColor: chatownColor,
                  backgroundColor: chatownColor,
                  unselectedBackgroundColor: Colors.transparent,
                  unselectedLabelStyle: const TextStyle(color: Colors.black),
                  labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14),
                  tabs: const [
                    Tab(
                      text: '      Media        ',
                    ),
                    Tab(
                      text: "      Links       ",
                    ),
                    Tab(
                      text: "      Docs        ",
                    ),
                  ],
                ),
                chatProfileController.isLoading.value &&
                        chatProfileController
                            .profileModel.value!.mediaData!.isEmpty &&
                        chatProfileController
                            .profileModel.value!.documentData!.isEmpty &&
                        chatProfileController
                            .profileModel.value!.linkData!.isEmpty
                    ? Center(
                        child: Column(
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.4),
                            loader(context),
                          ],
                        ),
                      )
                    : chatProfileController.profileModel.value == null
                        ? const SizedBox()
                        : Expanded(
                            child: TabBarView(
                              children: <Widget>[
                                chatProfileController
                                        .profileModel.value!.mediaData!.isEmpty
                                    ? Center(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.3,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15),
                                              child: Container(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        0.90,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      15.0),
                                                  child: Text(
                                                    "You haven't share any media with ${widget.peername}",
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color: chatColor,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w300),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.3,
                                            )
                                          ],
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: GridView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              mainAxisExtent: 110,
                                              mainAxisSpacing: 10.0,
                                            ),
                                            itemCount: chatProfileController
                                                .profileModel
                                                .value!
                                                .mediaData!
                                                .length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Media1(
                                                  chatProfileController
                                                      .profileModel
                                                      .value!
                                                      .mediaData![index],
                                                  index);
                                            },
                                          ),
                                        ),
                                      ),
                                //_____________________________ LINS TABBAR ______________________________________
                                Column(
                                  children: [
                                    Center(
                                      child: chatProfileController.profileModel
                                              .value!.linkData!.isEmpty
                                          ? Center(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.3,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 15),
                                                    child: Container(
                                                      width: MediaQuery.sizeOf(
                                                                  context)
                                                              .width *
                                                          0.90,
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .grey.shade200,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15.0),
                                                        child: Text(
                                                          "You haven't share any link with ${widget.peername}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: const TextStyle(
                                                              color: chatColor,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.3,
                                                  )
                                                ],
                                              ),
                                            )
                                          : Container(
                                              // height: MediaQuery.of(context)
                                              //         .size
                                              //         .height *
                                              //     0.77,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              color: Colors.transparent,
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 20, 0, 0),
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    primary: false,
                                                    padding: EdgeInsets.zero,
                                                    itemCount:
                                                        chatProfileController
                                                            .profileModel
                                                            .value!
                                                            .linkData!
                                                            .length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return links(
                                                          chatProfileController
                                                              .profileModel
                                                              .value!
                                                              .linkData![index],
                                                          index);
                                                    },
                                                  )),
                                            ),
                                    )
                                  ],
                                ),
                                //__________________________DOC TABBAR_____________________________________
                                Container(
                                  child: chatProfileController.profileModel
                                          .value!.documentData!.isEmpty
                                      ? Center(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15),
                                                child: Container(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          0.90,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade200,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: Text(
                                                      "You haven't share any doc with ${widget.peername}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color: chatColor,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w300),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                              )
                                            ],
                                          ),
                                        )
                                      : Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.transparent,
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 20, 0, 0),
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                padding: EdgeInsets.zero,
                                                itemCount: chatProfileController
                                                    .profileModel
                                                    .value!
                                                    .documentData!
                                                    .length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return docs(
                                                      chatProfileController
                                                          .profileModel
                                                          .value!
                                                          .documentData![index],
                                                      index);
                                                },
                                              )),
                                        ),
                                ),
                              ],
                            ),
                          ),
              ],
            ),
          ),
        ));
      }),
    );
  }

//==================================================== IMAGE, VIDEO ===================================================================================================
  Widget Media1(MediaData data, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: data.url.toString().contains(".mp4")
          ? InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoViewFix(
                          username: capitalizeFirstLetter(widget.peername!),
                          url: data.url!,
                          play: true,
                          mute: false),
                    ));
              },
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade200,
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      getUrlWidget(data.url!),
                      Positioned(
                          top: 47,
                          child: Image.asset("assets/images/play1.png",
                              height: 22, color: chatColor))
                    ],
                  ),
                ),
              ),
            )
          : InkWell(
              onTap: () {
                log(data.url!);
                Navigator.push(
                  context,
                  PageTransition(
                      curve: Curves.linear,
                      type: PageTransitionType.rightToLeft,
                      child: ImageView(
                        image: data.url!,
                        userimg: "",
                      )),
                );
              },
              child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: data.url!,
                      fit: BoxFit.cover,
                    ),
                  )),
            ),
    );
  }

//=================================================================== Links ============================================================================
  Widget links(LinkData data, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      child: Container(
        decoration: BoxDecoration(
            color: const Color(0xffFCFCFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(width: 1, color: const Color(0xffE8E8E8))),
        // height: 90,
        width: MediaQuery.of(context).size.width * 0.90,
        child: Padding(
            padding: const EdgeInsets.all(15),
            child: FlutterLinkPreview(
              url: data.message!,
              builder: (info) {
                if (info is WebInfo) {
                  return info.title == null && info.description == null
                      ? Text(
                          data.message!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (info.image != null)
                              Image.network(info.image!, fit: BoxFit.cover),
                            if (info.title != null)
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(7)),
                                child: Text(
                                  info.title!,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ).paddingAll(2),
                              ).paddingOnly(top: 5),
                            if (info.description != null)
                              Text(
                                info.description!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                          ],
                        );
                }
                return const CircularProgressIndicator();
              },
              titleStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            )),
      ),
    );
  }

//=================================================================== Documenet ========================================================================
  Widget docs(DocumentData data, int index) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
              curve: Curves.linear,
              type: PageTransitionType.rightToLeft,
              child: FileView(file: data.url!),
            ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
        child: Container(
          decoration: BoxDecoration(
              color: const Color(0xffFCFCFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(width: 1, color: const Color(0xffE8E8E8))),
          height: 70,
          width: MediaQuery.of(context).size.width * 0.90,
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xffCCCCCC),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Image(
                      image: AssetImage('assets/images/doc.png'),
                    ),
                  )),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.65,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.url.toString().split('/').last,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

//=======================================================
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
              fit: BoxFit.fill,
            );
          } else {
            return Container(); // Placeholder or loading indicator can be used here
          }
        },
      );
    } else {
      // Otherwise, it's an image URL, return Image.network
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.fill,
      );
    }
  }

  Future<Uint8List?> getThumbnail(String videoUrl) async {
    final thumbnail = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.JPEG,
        quality: 100,
        maxHeight: 100,
        maxWidth: 100);
    return thumbnail;
  }
}
