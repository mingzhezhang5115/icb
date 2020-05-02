import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
//import 'dart:ffi';
//import 'dart:js';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/local_detail_page.dart';
import 'package:flutter_app/actions.dart';
import 'package:flutter_app/app_state.dart';
import 'package:flutter_app/nav_key.dart';
import 'package:flutter_app/reducers.dart';
import 'package:flutter_app/bottom_nav_bar.dart';
import 'package:flutter_app/remote_images_state.dart';
import 'package:flutter_app/remote_sum_screen.dart';
import 'package:flutter_app/middleware.dart';
import 'package:flutter_app/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';


import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:extended_image/extended_image.dart';

part 'local_image_detail.g.dart';

@JsonSerializable(nullable: false)
class LocalImageDetail {
  final String imageUri;
  final List<int> imageData;

  LocalImageDetail({
    this.imageUri,
    this.imageData,
  });

  factory LocalImageDetail.fromJson(Map<String, dynamic> json) =>
      _$LocalImageDetailFromJson(json);

  Map<String, dynamic> toJson() => _$LocalImageDetailToJson(this);

}