import 'dart:convert';

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/login_response_model.dart';
import 'package:flutter_application_1/pages/login_page.dart';

class SharedService {
  // If you read this file, you should learn about how's cache work on android flatform.
  // We work with APICacheManager method:
  // - addCacheData
  // - isAPICacheKeyExist
  // - getCacheData
  // - deleteCache

  // Save user's information to cache having name: "login_details".
  static Future<void> setLoginDetails(
    model,
  ) async {
    APICacheDBModel cacheDBManager = APICacheDBModel(
      key: "login_details",
      syncData: jsonEncode(model.toJson()),
    );
    await APICacheManager().addCacheData(cacheDBManager);
  }

  // Check user login. If not, return false.
  static Future<bool> isLoggedIn() async {
    var isCacheKeyExist =
        await APICacheManager().isAPICacheKeyExist("login_details");
    return isCacheKeyExist;
  }

  // Get "login_details" cache, convert to json and store at LoginResponseModel.
  static Future<LoginResponseModel?> loginDetails() async {
    var isKeyExist =
        await APICacheManager().isAPICacheKeyExist("login_details");
    if (isKeyExist) {
      var cacheData = await APICacheManager().getCacheData("login_details");
      return loginResponseJson(cacheData.syncData);
    }
    return null;
  }

  // Delete "login_details" from the cache.
  static Future<void> logOut(context) async {
    await APICacheManager().deleteCache("login_details");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  static Future<void> updateUser(LoginResponseModel updatedModel) async {
    var isKeyExist =
        await APICacheManager().isAPICacheKeyExist("login_details");

    if (isKeyExist) {
      var cacheData = await APICacheManager().getCacheData("login_details");

      // Parse dữ liệu cache thành đối tượng LoginResponseModel
      LoginResponseModel currentModel = loginResponseJson(cacheData.syncData);

      // Cập nhật thông tin mới vào đối tượng LoginResponseModel
      currentModel.fullname = updatedModel.fullname;
      currentModel.email = updatedModel.email;
      currentModel.location = updatedModel.location;
      currentModel.phone = updatedModel.phone;

      // Cập nhật cache với thông tin mới
      String updatedData = jsonEncode(currentModel.toJson());
      APICacheDBModel updatedCache = APICacheDBModel(
        key: "login_details",
        syncData: updatedData,
      );
      await APICacheManager().addCacheData(updatedCache);
    }
  }
}
