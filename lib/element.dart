
library roole.element;

import 'dart:async';
import 'dart:mirrors';

import 'package:styleproc_element/element.dart';
import 'package:js/js.dart' as js;

class RooleVarProperty {
  const RooleVarProperty();
}

const RooleVarProperty rooleVar = const RooleVarProperty();

class Roole {

  String get styleElementName => "roole";

  Future<String> compileStyleText(String txt, String classScope) {
    Map variables = computeVariables();
    Completer<String> comp = new Completer<String>();
    js.context.roole.compile(".$classScope { $txt }", js.map({'base': './', 'global': variables}), (error, [css]) {
      if (error != null) {
        comp.completeError(error);
        return ;
      }
      if (css == null) {
        comp.completeError("Unknown Roole error");
        return ;
      }
      comp.complete(css);
    });
    return comp.future;
  }

  Map<String, dynamic> computeVariables() {
    Map<String, dynamic> map = {};
    InstanceMirror instance = reflect(this);
    instance.type.declarations.values
      .where((DeclarationMirror d) => d is VariableMirror || (d is MethodMirror && d.isGetter))
      .forEach((DeclarationMirror declaration) {
        declaration.metadata
          .where((InstanceMirror m) => m.reflectee is RooleVarProperty)
          .forEach((InstanceMirror metadata) {
            var value = instance.getField(declaration.simpleName).reflectee;
            String name = MirrorSystem.getName(declaration.simpleName);
            map[name] = value;
          });
      });
    return map;
  }
}

class RooleElement extends StyleProcessorElement with Roole {
  RooleElement.created() : super.created() {}
}
