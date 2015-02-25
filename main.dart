import 'package:plugins/plugin.dart';
import 'dart:isolate';
import 'src/template_data.dart';

void main(List<String> args, SendPort port) {
  Receiver rec = new Receiver(port);
  rec.listen((Map<dynamic, dynamic> data) {
    Map stagehandTemplateData = new Map();
    stagehandTemplateData['info'] = "Polymer Contacts App";
    stagehandTemplateData['description'] = "A full fledged polymer app template with layout, route and ajax support";
    stagehandTemplateData['entrypoint'] = "web/index.html";
    stagehandTemplateData['help'] = "to run your app, use 'pub serve'";
    stagehandTemplateData['data'] = templateData;
    rec.send(stagehandTemplateData);
  });
}
