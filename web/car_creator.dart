import 'dart:html';
import 'dart:convert' show JSON;
import 'dart:async' show Future;
import 'dart:math' show Random;
SpanElement carCreateElement;
ButtonElement randomCarButton, createButton;
SelectElement carSelect;
void main() {
  carSelect = querySelector('#car_choices');
  createButton = querySelector('#create');
  createButton.onClick.listen(updateCar);
  randomCarButton = querySelector('#randomCarButton');
  randomCarButton.onClick.listen(generateCar);
  
  carCreateElement = querySelector('#your_car');
  
  Car.loadCars()
    .then((_) {
      //on success
      carSelect.disabled = false; //enable
      createButton.disabled = false; //enable
      randomCarButton.disabled = false;  //enable
    })
    .catchError((totaled) {
      print('Error initializing car data: $totaled');
      carCreateElement.text = "The thing's busted!";
    });
}
void updateCar(Event e) {
  String inputMake = carSelect.value;
  
  setCar(new Car(inputMake));
  randomCarButton..disabled = false
                 ..text = 'Generate!';
}
void setCar(Car newCar) {
  if (newCar == null) {
    return;
  }
  carCreateElement.text = "$newCar";
}
void generateCar(Event e) {
  var keys=Car.cars.keys;
  var makes=new List<String>();
  makes.addAll(keys);
  var index=Car.indexGen.nextInt(makes.length);
  setCar(new Car(makes[index]));
}

class Car {
  static final Random indexGen = new Random();
  static Map<String, List<Map<String, dynamic>>> cars={};
  String _make, _model;
  num _year;
  factory Car(String make) {
    print(cars[make].length);
    num ind= indexGen.nextInt(cars[make].length);
    Car forClient = new Car._internal(make, cars[make][ind]);
    return forClient;
  }
  
  String toString() => "Your car is the $_make $_model made in $_year!";
  
  
  static Future loadCars() {
    var path = 'cars.json';
    return HttpRequest.getString(path)
        .then(_parseCarsFromJSON);
  }
  
  static _parseCarsFromJSON(String jsonString) {
    Map makesToCars = JSON.decode(jsonString);
    for (var make in makesToCars.keys) {
      cars[make]=makesToCars[make];
    }
  }
  Car._internal(String make, Map<String, dynamic> car) {
    this._make=make;
    this._model=car["model"];
    this._year=car["year"];
  }
}