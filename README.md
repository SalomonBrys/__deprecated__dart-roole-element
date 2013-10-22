# Roole integration in dart

## Introduction

#### Roole

[Roole](http://roole.org) is a language that compiles to CSS.  
It drew many inspirations from other CSS preprocessing languages like Sass, LESS and Stylus.  
The most unique feature of Roole is that it has vendor prefixing built-in, so the language stays dead simple yet being able to prefix some extremely complex rules transparently. Since Roole is also a superset of CSS, you can use it directly as a CSS prefixer.

#### Roole_element

Roole_element is a dart library that enables :

 * Automatic compilation of *.roo roole files into one big CSS.
 * Integration of roole inside polymer.dart elements

It is made for polymer.dart projects and directly depends on it.


## Compiling *.roo files

#### What it does

***For now, this part only works on Linux and Mac OS X. A future update will make this work on Windows.***

It will take all the .roo files in your `web/` directory and compile them into one CSS file.  
That way, you can separate your styling semantics into different files and load only one CSS file at runtime.

This is **not required**. It is for performance improvement only.  
Roole.js can compile at runtime the roole style linked or embeded within your HTML page.

#### Install

*For this to work, you must have the roole command line installed with node's npm.*

First, install `node.js` and `npm`. Instructions for [Linux](https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager) and [Mac OS X](https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager#osx).

	npm install roole -g

#### build.dart

Modify your build.dart file:

	import 'dart:io';
	import 'package:polymer/builder.dart' as p;
	
	import 'web/polyroole/builder.dart' as r;
	
	main() {
	  p.CommandLineOptions options = p.parseOptions(new Options().arguments);
	  
	  r.build('my_project', options).then((dynamic e) {
	    p.build(entryPoints: ['web/chabine_ui.html'], options: options);
	  });
	}

#### HTML

In your `my_project.html` file, in the `head` section, add

	<link rel="stylesheet" href="my_project.roo.css">

Never edit `my_project.roo.css` as it is automatically generated and your modifications **will be deleted** at next file save.

#### Automatic style reloading

If you are using the dart editor along with Dartium in debug mode, the style will reload automatically as Dartium monitors CSS files and the dart editor will rebuild the `my_project.roo.css` file at every file save.


## Using roole inside polymer elements

#### roole.js

In your `my_project.html` file, in the `head` section, add

	<link rel="stylesheet" href="package:roole_element/roole_element.css">
	<script src="package:roole_element/roole.js"></script>

The first is a simple CSS that prevents [FOUC](http://wikipedia.org/wiki/FOUC).  
The second is the roole javascript processor file.

Please note that roole_element uses roole.js library via [js-interop](https://www.dartlang.org/articles/js-dart-interop/).  
Therefore, if you haven't already done this in your `my_project.html` file, you need to add this script in the `head` section to enable dart to interact with javascript :

	<script src="packages/browser/interop.js"></script>

#### Roole inside polymer-element

First, you need to make your element roole aware.

Two solutions :

1. Your element inherits from `RooleElement` instead of `PolymerElement`, example :

		@CustomTag('click-counter')
		class ClickCounter extends RooleElement with ObservableMixin {
		  @observable int count = 0;
		
		  bool get applyAuthorStyles => true;
		  
		  void increment() {
		    count++;
		  }
		}

2. Sometimes you need to be free to inherit what you want, in this case, you can use the `RooleElementMixin`. You then need to override `created()` like in this example :

		@CustomTag('click-counter')
		class ClickCounter extends PolymerElement with ObservableMixin, RooleElementMixin {
		  @observable int count = 0;
		
		  bool get applyAuthorStyles => true;
		  
		  void created() {
		    super.created();
		    compileRoole();
		  }
		  
		  void increment() {
		    count++;
		  }
		}

#### Embeded roole

Inside the HTML of your element, just after the `<template>` opening tag, put:

	<roole>
		// Here roole style
	</roole>

You need to use the `<roole>` tag instead of `<style type="text/roole">` because polymer does CSS processing on all `<style>` elements, regardless of their `type`.

#### Roole file reference

You can reference an external roole file.
This file's extension **must not be `.roo`** because if it is, it will be compiled in the big `.roo.css` file. We suggest to use the extensions `.rin` for "Roole INside".

Inside the HTML of your element, just after the `<template>` opening tag, put:

	<roole src="clickcounter.rin" monitor="1"></roole>

#### Automatic style reloading

You can ask roole_element to monitore your `.rin` file so, each time it is modified, the style of your element is dynamically reloaded.

For this, just add `monitor="1"` in your roole declaration.

	<roole src="clickcounter.rin" monitor="1"></roole>

You can only use monitoring for external files, not embeded roole.

Note that the parameter to `monitor` is actually the duration in seconds between each check.

**THIS IS INTENDED FOR DEVELOPMENT ONLY. USING THIS IN PRODUCTION WILL DAMAGE PERFORMANCES. DO NOT FORGET TO REMOVE THE `monitor` ARGUMENT ONCE YOU ARE DONE STYLING.**


