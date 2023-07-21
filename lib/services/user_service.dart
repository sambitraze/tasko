import 'dart:convert';

import 'package:tasko/models/user_model.dart';
import 'package:tasko/services/base_service.dart';

class UserService {
  static Future<UserModel?> getUserByEmail(String email) async {
    final response = await BaseService.makeUnauthenticatedRequest(
      '${BaseService.BASE_URL}/users?filter[email][_eq]=$email',
      method: 'GET',
    );
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      try {
        // communityPosts map
        if (responseJson['data'].length > 0) {
          return UserModel.fromJson(responseJson['data'][0]);
        }else{
          return null;
        }
      } catch (error) {
        throw Exception('Failed to load communityPosts');
      }
    } else {
      throw Exception('Failed to load communityPosts');
    }
  }

  // static Future<CommunityPost?> createCommunityPost(
  //     String post, String userId) async {
  //   final response = await BaseService.makeUnauthenticatedRequest(
  //     '${BaseService.BASE_URL}/community/posts',
  //     method: 'POST',
  //     body: json.encode({'post': post, "user_id": userId}),
  //   );

  //   final responseJson = json.decode(response.body);
  //   if (response.statusCode == 200) {
  //     try {
  //       return CommunityPost.fromJson(responseJson);
  //     } catch (error) {
  //       throw Exception('Failed to create communityPost');
  //     }
  //   } else {
  //     throw Exception('Failed to create communityPost');
  //   }
  // }
}
