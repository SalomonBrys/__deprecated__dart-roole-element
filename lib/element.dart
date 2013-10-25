
library roole.element;

import 'dart:html';
import 'dart:js' as djs;
import 'dart:async';

import 'package:polymer/polymer.dart';
import 'package:js/js.dart' as js;

class _CachedStyle {
  StyleElement style;
  String text;
  _CachedStyle(this.style);
}

abstract class Roole implements Polymer {

  String _shimShadowDomStyling(String txt) {
    if (js.context == null) return txt;

    var platform = djs.context['Platform'];
    if (platform == null) return txt;

    var shadowCss = platform['ShadowCSS'];
    if (shadowCss == null) return txt;

    var shimShadowDOMStyling2 = shadowCss['shimShadowDOMStyling2'];
    if (shimShadowDOMStyling2 == null) return txt;

//    if (js.context.window.ShadowDOMPolyfill == null) return false;
//
//    return true;

    return shimShadowDOMStyling2.apply(shadowCss, [txt, localName]);
  }

  Future<StyleElement> _compileRoole(String txt, [StyleElement style]) {
    var comp = new Completer();
//    if (encaps)
//      txt = this.tagName.toLowerCase() + ", [is=" + this.tagName.toLowerCase() + "] {\n" + txt + "\n}\n";
    js.context.roole.compile(txt, js.map({'base': './'}), new js.Callback.once((error, [css]) {
      if (error != null) {
        window.console.log(error.toString());
      }
      if (css == null)
        return ;
      if (style == null)
        style = new StyleElement()
          ..type = "text/css"
        ;
      style.text = _shimShadowDomStyling(css);
      shadowRoot.append(style);
      comp.complete(style);
    }));
    return comp.future;
  }

  Future<_CachedStyle> _compileRooleHTTP(Element e, [_CachedStyle cache]) {
    return HttpRequest.getString(e.attributes["src"]).then((String text) {
      StyleElement style = null;
      if (cache != null) {
        if (cache.text == text)
          return cache;
        window.console.info("Reloading " + e.attributes["src"]);
        style = cache.style;
      }
      return _compileRoole(text + "\n" + e.text, style).then((StyleElement el) {
        if (cache == null)
          cache = new _CachedStyle(el);
        cache.text = text;
        return cache;
      });
    },
    onError: (err) {
      window.console.log("Could not load " + e.attributes["src"]);
    });
  }

  Future<dynamic> _compileRooleElement(Element e) {
    Future<_CachedStyle> ret = _compileRooleHTTP(e);

    if (e.attributes.containsKey("monitor")) {
      int period = int.parse(e.attributes["monitor"], onError: (_) => 0);
      if (period > 0)
        ret = ret.then((_CachedStyle cache) =>
            new Timer.periodic(new Duration(seconds: period), (_) => _compileRooleHTTP(e, cache))
        );
    }

    return ret;
  }

  void compileRoole() {
    this.classes.add("roole-wait");

    List<Future> futures = new List();

    this.shadowRoot.querySelectorAll('roole').forEach((Element e) {
      e.remove();
      Future fut;
      if (e.attributes.containsKey("src")) {
        fut = _compileRooleElement(e);
      }
      else {
        fut = _compileRoole(e.text);
      }
      futures.add(fut);
    });

    Future.wait(futures).then((e) {
//      this.classes.remove("roole-wait");
    });
  }

}

class RooleElement extends PolymerElement with Roole {

  RooleElement.created() : super.created() {}

  void shadowRootReady(ShadowRoot root, Element template) {
    super.shadowRootReady(root, template);
    compileRoole();
  }
}
