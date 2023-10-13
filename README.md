<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

Pick color from image (assets/network/file) and get color hexcodes.

## Features

You can by this package add (asset/network/file) and know the basic colors that make up the image and know the color in the pixels that you want from the image.

## Getting started

First run flutter pub add extract_colors_from_image

Next Import it:
import 'package:extract_colors_from_image/extract_colors_from_image.dart';

Finally provide Image either by assets/network/file.

## Usage

Here there are three examples about how to use this package:

To use assete image:
    AssetImageBG(
        assetPath: 'images/space.jpg',
        backgroundColor: Color.fromARGB(255, 243, 229, 245),
    ),

To use network image:
    NetworkImageBG(
        networkpath:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQEBx9Wr0-Vrvo7-X_EwAXnCxBrBODj3sjPLE_6DZPA&s',
        backgroundColor: Color.fromARGB(255, 243, 229, 245),
    ),

To use File image:
   FileImageBG(
        backgroundColor: Color.fromARGB(255, 243, 229, 245),
    ),


