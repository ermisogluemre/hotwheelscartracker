import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'db.dart';


class SaveScreen extends StatelessWidget {
  @override
  Widget build (BuildContext ctxt) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Add New Car to Collection"),
      ),
      body: new MyCustomForm(),
    );
  }
}

// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}



// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
// Create a global key that uniquely identifies the Form widget
// and allows validation of the form.
//
// Note: This is a GlobalKey<FormState>,
// not a GlobalKey<MyCustomFormState>.
final _formKey = GlobalKey<FormState>();
final _barcodeController = TextEditingController();
final _nameControlller = TextEditingController();
String barcode = "";


@override
void dispose() {
  // other dispose methods
  _barcodeController.dispose();
  _nameControlller.dispose();
  super.dispose();
}

Future barcodeScanning() async {

  try {
    var barcode = await BarcodeScanner.scan();
    setState(() => _barcodeController.text = barcode.toString());
  } on PlatformException catch (e) {
    this.barcode = 'Can not capture the barcode';
  } on FormatException {
    setState(() => this.barcode =
    'Nothing captured.');
  } catch (e) {
    setState(() => this.barcode = 'Unknown error: $e');
  }
}

void saveCar() async{
    if(_barcodeController.text.length == 0){
        final snackBar = SnackBar(
          content: Text('Missing Barcode'),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );

        // Find the Scaffold in the widget tree and use
        // it to show a SnackBar.
        Scaffold.of(context).showSnackBar(snackBar);
        return;
    }

    if(_nameControlller.text.length == 0){
      final snackBar = SnackBar(
        content: Text('Missing CAR Name'),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );

      // Find the Scaffold in the widget tree and use
      // it to show a SnackBar.
      Scaffold.of(context).showSnackBar(snackBar);
    }

    var selectedCar = await SQLiteDbProvider.db.getCarByBarcode(_barcodeController.text);
    if(selectedCar == null){
      Car newCar = new Car();
      newCar.name = _nameControlller.text;
      newCar.barcode = _barcodeController.text;
      //newCar.create_time = new DateTime.now();
      SQLiteDbProvider.db.insertCar(newCar);
      Navigator.pop(context);
    }else{
      var car = await selectedCar;
      final snackBar = SnackBar(
        content: Text(car.name+' exists!'),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );

      // Find the Scaffold in the widget tree and use
      // it to show a SnackBar.
      Scaffold.of(context).showSnackBar(snackBar);
    }
}

@override
Widget build(BuildContext context) {
// Build a Form widget using the _formKey created above.
return Form(
  key: _formKey,
  child: Column(
        children: <Widget>[
          new ListTile(
            leading: const Icon(Icons.car_rental),
            title: new TextField(
              decoration: new InputDecoration(
                hintText: "CAR Name",
              ),
              controller: _nameControlller,
            ),
          ),
          new ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: new TextField(
              decoration: new InputDecoration(
                hintText: "Barcode Number",
              ),
              onTap: barcodeScanning,
              controller: _barcodeController,
            ),
          ),
          Container(
            child: RaisedButton(
              onPressed: saveCar,
              child: Text("Add to Collection",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              color: Colors.green,
            ),
            padding: const EdgeInsets.all(10.0),
            margin: EdgeInsets.all(10),
          )
        ],
      ),
    );
  }
}