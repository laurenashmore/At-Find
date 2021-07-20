import 'package:flutter/widgets.dart';
import 'package:atfind/atlocation/map_content/flutter_map/src/layer/marker_layer.dart';

// In a separate file so it can be exported individually in extension_api.dart
typedef PopupBuilder = Widget Function(BuildContext, Marker?);
