import 'package:at_commons/at_commons.dart';
import 'package:atfind/atlocation/map_content/flutter_map/src/layer/marker_layer.dart';
import 'package:atfind/atlocation/location_modal/hybrid_model.dart';
import 'package:atfind/atlocation/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import '../../service.dart';
import 'circle_marker_painter.dart';
import 'contacts_initial.dart';
import 'custom_circle_avatar.dart';
import 'marker_custom_painter.dart';
import 'package:atfind/screens/Profile.dart';

  Marker buildMarker(HybridModel user,
      {
        bool singleMarker = false,
        Widget? marker
      }) {
    return Marker(
        anchorPos: AnchorPos.align(AnchorAlign.center),
        height: 75,
        width: 50,
        point: user.latLng!,
        // ignore: prefer_if_null_operators
        builder: (ctx) =>
        marker != null
            ? marker
            : (singleMarker
            ? Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 25,
              child: SizedBox(
                width: 40,
                height: 40,
                child: CustomPaint(
                  painter: CircleMarkerPainter(
                      color: AllColors().WHITE,
                      paintingStyle: PaintingStyle.fill),
                ),
              ),
            ),
            Positioned(
              top: 10,
              child: Icon(
                Icons.circle,
                size: 40,
                color: AllColors().LIGHT_RED,
              ),
            ),
            Positioned(

              /// Press on button to get activity status!:
              top: 8,
              child: TextButton(
                onPressed: () {
                  showDialog(
                    context: ctx,
                    builder: (BuildContext ctx) {
                      return AlertDialog(
                        content: Stack(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Text(
                                      'Your activity status: '
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: RotationTransition(
                  turns: AlwaysStoppedAnimation(90 / 360),
                  child: Text(
                    ': )',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
            : Stack(alignment: Alignment.center, children: [
          Positioned(
            bottom: 25,
            child: CustomPaint(
              size: Size(40, (40 * 1.137455469677715).toDouble()),
              painter: RPSCustomPainter(),
            ),
          ),
          Positioned(
            top: 10,
            child: CircleAvatar(
              radius: 15,
              backgroundColor: AllColors().LIGHT_RED,
              child: user.image != null
                  ? CustomCircleAvatar(
                  byteImage: user.image, nonAsset: true, size: 30)
                  : ContactInitial(
                initials: user.displayName,
                size: 30,
                backgroundColor: AllColors().LIGHT_RED,
              ),
            ),
          ),
        ])));
  }


