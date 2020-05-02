import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

Future<String> fetchPost({String testServerAddr: "10.42.0.1"}) async {
  var url = Uri(
      scheme: "http",
      host: testServerAddr ?? "10.42.0.1",
      port: int.parse("5000", radix: 10),
      path: "/images");
  final response =
  await http.get(url);

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    print("Get header" + response.headers.keys.join(","));
    return response.headers['x-total-count'];
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

Future<http.Response> fetchSummary({String testServerAddr: "10.42.0.1"}) async {
  var url = Uri(scheme: "http",
      host: testServerAddr ?? "10.42.0.1",
      port: int.parse("5000", radix: 10),
      path: "/images");
  final response =
  await http.get(url);

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    print("Get header" + response.headers.keys.join(","));
    return response;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

Future<http.Response> fetchList(String offset,String limit,{String testServerAddr: "10.42.0.1"}) async {
  var url = Uri(scheme: "http",
      host: testServerAddr ?? "10.42.0.1",
      port: int.parse("5000", radix: 10),
      path: "/images",
      queryParameters:{"offset":offset,"limit":limit});
  final response =
  await http.get(url);

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    print("Get header" + response.headers.keys.join(","));
    return response;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

Future<http.Response> fetchDetail(imageUUID,{String testServerAddr: "10.42.0.1"}) async {
  var url = Uri(scheme: "http",
      host: testServerAddr ?? "10.42.0.1",
      port: int.parse("5000", radix: 10),
      path: "/images/" + imageUUID);
  final response =
  await http.get(url);

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    print("Get header" + response.headers.keys.join(","));
    return response;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

Future<http.Response> confirmImageTag(imageUUID,{String testServerAddr: "10.42.0.1"}) async {
  var url = Uri(scheme: "http",
      host: testServerAddr ?? "10.42.0.1",
      port: int.parse("5000", radix: 10),
      path: "/images/" + imageUUID + "/tag_confirmed");
  var payload = {"confirmed": true};
  print(json.encode(payload));
  final response =
  await http.put(url,headers: {"Content-Type": "application/json"},body: json.encode(payload));

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    print("Get header" + response.headers.keys.join(","));
    return response;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

Future<http.Response> updateImageTags (String imageUUID, List<String> tags,{String testServerAddr: "10.42.0.1"}) async {
  print("Post update image tags");
  var url = Uri(scheme: "http",
      host: testServerAddr ?? "10.42.0.1",
      port: int.parse("5000", radix: 10),
      path: "/images/" + imageUUID + "/tags");
  var payload = {"tags": tags};
  print(json.encode(payload));
  final response =
  await http.put(url,headers: {"Content-Type": "application/json"},body: json.encode(payload));

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    print("Get header" + response.headers.keys.join(","));
    return response;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}


Future<http.Response> deleteImageTag (String imageUUID, String tagName,{String testServerAddr: "10.42.0.1"}) async {
  print("Delete image tag");
  var url = Uri(scheme: "http",
      host: testServerAddr ?? "10.42.0.1",
      port: int.parse("5000", radix: 10),
      path: "/images/" + imageUUID + "/tags/" + tagName);
 // var payload = {"tags": tags};
  //print(json.encode(payload));
  final response =
  await http.delete(url,headers: {"Content-Type": "application/json"});

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    print("Get header" + response.headers.keys.join(","));
    return response;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

Future<http.Response> addImageTag (String imageUUID, String tagName,{String testServerAddr: "10.42.0.1"}) async {
  print("Add image tag");
  var url = Uri(scheme: "http",
      host: testServerAddr ?? "10.42.0.1",
      port: int.parse("5000", radix: 10),
      path: "/images/" + imageUUID + "/tags/" + tagName);
  // var payload = {"tags": tags};
  //print(json.encode(payload));
  final response =
  await http.put(url,headers: {"Content-Type": "application/json"});

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    print("Get header" + response.headers.keys.join(","));
    return response;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed add image tag');
  }
}

Future<http.Response> fetchTags({String testServerAddr: "10.42.0.1"}) async {
  var url = Uri(scheme: "http",
      host: testServerAddr ?? "10.42.0.1",
      port: int.parse("5000", radix: 10),
      path: "/tags");
  final response =
  await http.get(url);

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    //print("Get header" + response.headers.keys.join(","));
    return response;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to fetch tags');
  }
}

Future<http.Response> fetchImagesByTag(String tag,String offset,String limit,{String testServerAddr: "10.42.0.1"}) async {
  var url = Uri(scheme: "http",
      host: testServerAddr ?? "10.42.0.1",
      port: int.parse("5000", radix: 10),
      path: "/images",
      queryParameters:{"tag":tag,"offset":offset,"limit":limit});
  final response =
  await http.get(url);

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    //print("Get header" + response.headers.keys.join(","));kjk
    return response;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to fetch tags');
  }
}