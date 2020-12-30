import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'db.dart';

class ListScreen extends StatelessWidget {
  @override
  Widget build (BuildContext ctxt) {


    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Available Cars in the Collection"),
      ),
      body: new CarList(),
    );
  }
}


class CarList extends StatefulWidget {
  @override
  CarListState createState() {
    return CarListState();
  }
}

class CarListState extends State<CarList> {
  @override
  Widget build(BuildContext context) {
        return FutureBuilder<List>(
            future: SQLiteDbProvider.db.listCars(),
            initialData: List(),
            builder: (context, snapshot) {
              return snapshot.hasData ?
              new ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: snapshot.data.length,
                itemBuilder: (context, i) {
                  return _buildRow(snapshot.data[i]);
                },
              )
                  : Center(
                child: CircularProgressIndicator(),
              );
            },
        );
  }

  Widget _buildRow(Car car) {
    return new ListTile(
      title: new Text(car.name),
    );
  }
}