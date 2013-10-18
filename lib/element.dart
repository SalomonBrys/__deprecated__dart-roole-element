
library roole.element;

import 'dart:html';
import 'dart:js' as djs;
import 'dart:async';

import 'package:custom_element/custom_element.dart';
import 'package:polymer/polymer.dart';
import 'package:js/js.dart' as js;

class _CachedStyle {
  StyleElement style;
  String text;
  _CachedStyle(this.style);
}

abstract class RooleElementMixin implements CustomElement {
  
  bool _needEncapsulation() {
    if (js.context == null) return false;
    
    var platform = djs.context['Platform'];
    if (platform == null) return false;

    var shadowCss = platform['ShadowCSS'];
    if (shadowCss == null) return false;

    var shimShadowDOMStyling2 = shadowCss['shimShadowDOMStyling2'];
    if (shimShadowDOMStyling2 == null) return false;
    
    if (js.context.window.ShadowDOMPolyfill != null)
      return true;
    
    return false;
  }
  
  Future<StyleElement> _compileRoole(String txt, bool encaps, [StyleElement style]) {
    var comp = new Completer();
    if (encaps)
      txt = this.tagName.toLowerCase() + ", [is=" + this.tagName.toLowerCase() + "] {\n" + txt + "\n}\n";
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
      style.text = css;
      shadowRoot.append(style);
      comp.complete(style);
    }));
    return comp.future;
  }

  Future<_CachedStyle> _compileRooleHTTP(Element e, bool encaps, [_CachedStyle cache]) {
    return HttpRequest.getString(e.attributes["src"]).then((String text) {
      StyleElement style = null;
      if (cache != null) {
        if (cache.text == text)
          return cache;
        window.console.info("Reloading " + e.attributes["src"]);
        style = cache.style;
      }
      return _compileRoole(text + "\n" + e.text, encaps, style).then((StyleElement el) {
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
  
  Future<dynamic> _compileRooleElement(Element e, bool encaps) {
    Future<_CachedStyle> ret = _compileRooleHTTP(e, encaps);
    
    if (e.attributes.containsKey("monitor")) {
      int period = int.parse(e.attributes["monitor"], onError: (_) => 0);
      if (period > 0)
        ret = ret.then((_CachedStyle cache) =>
            new Timer.periodic(new Duration(seconds: period), (_) => _compileRooleHTTP(e, encaps, cache))
        );
    }
    
    return ret;
  }
  
  void compileRoole() {
    bool encaps = _needEncapsulation();

    this.host.classes.add("roole-wait");
    
    List<Future> futures = new List();
    
    this.shadowRoot.queryAll('roole').forEach((Element e) {
      e.remove();
      Future fut;
      if (e.attributes.containsKey("src")) {
        fut = _compileRooleElement(e, encaps);
      }
      else {
        fut = _compileRoole(e.text, encaps);
      }
      futures.add(fut);
    });
    
    Future.wait(futures).then((e) {
      this.host.classes.remove("roole-wait");
    });
  }

}

class RooleElement extends PolymerElement with RooleElementMixin {
  
  void created() {
    super.created();
    compileRoole();
  }
  
}