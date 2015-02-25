import 'package:plugins/plugin.dart';
import 'dart:isolate';
import 'src/template_data.dart';

void main(List<String> args, SendPort port) {
  Receiver rec = new Receiver(port);
  rec.listen((Map<dynamic, dynamic> data) {
    Map pluginData = new Map();
    pluginData['info'] = "Polymer Contacts App";
    pluginData['description'] = "A full fledged polymer app template with layout, route and ajax support";
    pluginData['entrypoint'] = "web/index.html";
    pluginData['help'] = "to run your app, use 'pub serve'";
    pluginData['data'] = templateData;
    rec.send(pluginData);
  });
}
