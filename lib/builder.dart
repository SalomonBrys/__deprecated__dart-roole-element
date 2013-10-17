library roole.builder;

import 'dart:io';
import 'dart:async';

import 'package:polymer/builder.dart';


List<String> _binDirs = ["/usr/bin/", "/usr/local/bin/", "/usr/local/share/npm/bin/"];

String _findBin(String bin) {
  for (String dir in _binDirs)
    if (new File(dir + bin).existsSync())
      return dir + bin;
  throw "Could not find " + bin;
}

Future build(String name, CommandLineOptions options) {
  String outFileName = 'web/' + name + '.roo.css';
  
  bool compile = false;
  
  if (options.full || options.clean || options.forceDeploy)
    compile = true;
  else {
    compile = !options.changedFiles.where((String file) => file.endsWith(".roo")).isEmpty;
  }

  if (!compile)
    return new Future.sync(() => null);
    
  String node = _findBin("node");
  String roole = _findBin("roole");

  var output = new File(outFileName).openWrite();
  
  return Process.start(node, [roole, '-s', 'web']).then((process) {
    return process.stdout.pipe(output).then((_) {
      return output.close();
    });
  });
}
