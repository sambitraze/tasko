import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:tasko/models/task.dart';
import 'package:tasko/services/base_service.dart';

class TaskService {
  static Future<Task?> addMyTasks(paylaod) async {
    final response = await BaseService.makeAuthenticatedRequest(
      '${BaseService.BASE_URL}/items/task',
      body: jsonEncode(paylaod),
      method: 'POST',
    );
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      try {
        return Task.fromJson(responseJson['data']);
      } catch (error) {
        throw Exception('Failed to load myTasks: $error');
      }
    } else {
      print(response.reasonPhrase);
      return null;
    }
  }

  static Future<bool> deleteMyTasks(id) async {
    final response = await BaseService.makeAuthenticatedRequest(
      '${BaseService.BASE_URL}/items/task/$id',
      method: 'DELETE',
    );
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Task deleted successfully");
      return true;
    } else {
      Fluttertoast.showToast(msg: "Task not deleted");
      return false;
    }
  }

  static Future<bool> updateMyTasks(id, payload) async {
    final response = await BaseService.makeAuthenticatedRequest(
      '${BaseService.BASE_URL}/items/task/$id',
      body: jsonEncode(payload),
      method: 'PATCH',
    );
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Task updated successfully");
      return true;
    } else {
      Fluttertoast.showToast(msg: "Task not updated");
      return false;
    }
  }

  static Future<List<Task>> getMyDoneTasks() async {
    final response = await BaseService.makeAuthenticatedRequest(
      '${BaseService.BASE_URL}/items/task?filter[status][_eq]=true&sort=-date_updated',
      method: 'GET',
    );
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      try {
        // communityPosts map
        List<Task> myTasks = [];
        for (int i = 0; i < responseJson['data'].length; i++) {
          myTasks.add(Task.fromJson(responseJson['data'][i]));
        }
        return myTasks;
      } catch (error) {
        throw Exception('Failed to load myTasks: $error');
      }
    } else {
      return [];
    }
  }

  static Future<List<Task>> getMyUnDoneTasks() async {
    final response = await BaseService.makeAuthenticatedRequest(
      '${BaseService.BASE_URL}/items/task?filter[status][_eq]=false&sort=-date_created',
      method: 'GET',
    );
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      try {
        // communityPosts map
        List<Task> myTasks = [];
        for (int i = 0; i < responseJson['data'].length; i++) {
          myTasks.add(Task.fromJson(responseJson['data'][i]));
        }
        return myTasks;
      } catch (error) {
        throw Exception('Failed to load myTasks: $error');
      }
    } else {
      return [];
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
