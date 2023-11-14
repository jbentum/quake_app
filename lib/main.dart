import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Map _data = {}; // Initialize _data with an empty Map

void main() async {
  _data =
      await getQuakes(); // Assign to the global variable without redeclaring it
  debugPrint(_data["features"][0]["properties"].toString());

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Quakes App",
      home: Quakes(),
    ),
  );
}

class Quakes extends StatelessWidget {
  const Quakes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quakes"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: ListView.builder(
            itemCount: _data["features"].length,
            padding: const EdgeInsets.all(15.0),
            itemBuilder: (BuildContext context, int index) {
              // Accessing each earthquake data based on the index
              // ignore: unused_local_variable
              var place = _data["features"][index]["properties"]["mag"];

              if (index.isOdd) return const Divider();
              // ignore: unused_local_variable
              final position = index ~/ 2;
              // we are dividing index by 2 and returning an integer result
              var properties = _data["features"][index]["properties"];
              var mag = properties["mag"];
              var formattedMag = double.tryParse(mag.toString());

              if (formattedMag != null) {
                formattedMag = double.parse(formattedMag.toStringAsFixed(2));
              } else {
                formattedMag = 0.0;
              }

              var time = DateTime.fromMillisecondsSinceEpoch(
                  properties["time"] * 1000);
              // ignore: unused_local_variable
              var formattedTime = "${time.hour}:${time.minute}:${time.second}";

              var formattedDate =
                  DateFormat('MMMM dd, yyyy h:mm a').format(time);
              return ListTile(
                title: Text(
                  "At $formattedDate",
                  style: const TextStyle(
                    fontSize: 19.5,
                    fontWeight: FontWeight.normal,
                    color: Colors.orange,
                  ),
                ),
                subtitle: Text(
                  "${properties["place"]}",
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    formattedMag.toString(),
                    style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontStyle: FontStyle.normal),
                  ), // Corrected this line
                ),
                onTap: () {
                  _showAlertMessages(context,
                      "${_data["features"][index]["properties"]["title"]}");
                },
              );
            }),
      ),
    );
  }

  void _showAlertMessages(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Quakes"),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

Future<Map> getQuakes() async {
  String apiUrl =
      "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson";
  http.Response response = await http.get(Uri.parse(apiUrl));
  return json.decode(response.body);
}
