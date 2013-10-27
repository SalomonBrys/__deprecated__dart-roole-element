# Roole integration in polymer.dart

## Introduction

#### Roole

[Roole](http://roole.org) is a language that compiles to CSS.  
It drew many inspirations from other CSS preprocessing languages like Sass, LESS and Stylus.  
The most unique feature of Roole is that it has vendor prefixing built-in, so the language stays dead simple yet being able to prefix some extremely complex rules transparently. Since Roole is also a superset of CSS, you can use it directly as a CSS prefixer.

#### Roole_element

Roole_element is a dart library that enables :

 * **Integration of roole css processing inside polymer.dart elements**
 * Automatic compilation by the editor of *.roo roole files into one big CSS.

It is made for polymer.dart projects and directly depends on it.

## Using roole inside polymer elements

#### roole.js

In your `my_project.html` file, in the `head` section, add

	<script src="packages/roole_element/roole.js"></script>

This is the roole javascript processor file.

Please note that roole_element uses roole.js library via [js-interop](https://www.dartlang.org/articles/js-dart-interop/).  
Therefore, if you haven't already done this in your `my_project.html` file, you need to add this script in the `head` section to enable dart to interact with javascript :

	<script src="packages/browser/interop.js"></script>

#### Roole inside polymer-element

First, you need to make your element roole aware.

There are different ways of activating roole in your element:

1. If your element extends `PolymerElement`, make it extends `RooleElement` instead.

		import 'package:roole_element/element.dart';
		
		@CustomTag('my-element')
		class MyElement extends RooleElement {
		  ClickCounter.created : super.created();
		}

2. If your element extends a custom subclass of `PolymerElement`, use the `StyleProcessor` and `Roole` mixins. You then need to override `shadowRootReady(ShadowRoot, Element)` to add `compileStyle()`.

		import 'package:roole_element/element.dart';
		import 'package:styleproc_element/element.dart';
		
		@CustomTag('my-element')
		class MyElement extends MyCustomPolymerElement with StyleProcessor, Roole {
		  ClickCounter.created : super.created();
		
		  void shadowRootReady(ShadowRoot root, Element template) {
		    super.shadowRootReady(root, template);
		    compileStyle();
		  }
		}

3. If you are extending an element in your markup, for instance: `<polymer-element name="my-element" extends="div">`. Then your Dart class must match, and must include a call to `polymerCreated()` in the created constructor. In this case, you should also use the `StyleProcessor` and `Roole` mixins and override `shadowRootReady(ShadowRoot, Element)` to add `compileStyle()`.

		import 'package:roole_element/element.dart';
		import 'package:styleproc_element/element.dart';
		
		@CustomTag('my-element')
		class MyElement extends DivElement with Polymer, Observable, StyleProcessor, Roole {
		  ClickCounter.created : super.created() { polymerCreated(); }
		
		  void shadowRootReady(ShadowRoot root, Element template) {
		    super.shadowRootReady(root, template);
		    compileStyle();
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
This file's extension **must not be `.roo`** because if it is, it will be compiled in the big `.roo.css` file (see below). We suggest to use the extensions `.rin` for "Roole INside".

Inside the HTML of your element, just after the `<template>` opening tag, put:

	<roole src="clickcounter.rin"></roole>

#### Automatic style reloading

You can ask roole_element to monitore your `.rin` file so, each time it is modified, the style of your element is dynamically reloaded.

For this, just add `monitor="1"` in your roole declaration.

	<roole src="clickcounter.rin" monitor="1"></roole>

You can only use monitoring for external files, not embeded roole.

Note that the parameter to `monitor` is actually the duration in seconds between each check.

**THIS IS INTENDED FOR DEVELOPMENT ONLY. USING THIS IN PRODUCTION WILL DAMAGE PERFORMANCES. DO NOT FORGET TO REMOVE THE `monitor` ARGUMENT ONCE YOU ARE DONE STYLING.**


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
	    p.build(entryPoints: ['web/my_project.html'], options: options);
	  });
	}

#### HTML

In your `my_project.html` file, in the `head` section, add

	<link rel="stylesheet" href="my_project.roo.css">

Never edit `my_project.roo.css` as it is automatically generated and your modifications **will be deleted** at next file save.

#### Automatic style reloading

If you are using the dart editor along with Dartium in debug mode, the style will reload automatically as Dartium monitors CSS files and the dart editor will rebuild the `my_project.roo.css` file at every file save.




