import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AccelerometerScreen()),
                );
              },
              child: Text('Accelerometer'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GyroscopeScreen()),
                );
              },
              child: Text('Gyroscope'),
            ),
          ],
        ),
      ),
    );
  }
}

class AccelerometerScreen extends StatefulWidget {
  @override
  _AccelerometerScreenState createState() => _AccelerometerScreenState();
}

class _AccelerometerScreenState extends State<AccelerometerScreen> {
  List<FlSpot> dataPoints = [];
  List<FlSpot> meanPoints = [];
  List<FlSpot> variancePoints = [];
  AccelerometerEvent _accelerometerEvent = AccelerometerEvent(0, 0, 0);
  late List<double> mainValues;
  List<AccelerometerEvent> _accelerometerEvents = [];
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  double _accelerometerMainValueEvent(AccelerometerEvent event) {
    double value = sqrt(
        event.x * event.x + event.y * event.y * event.y + event.z + event.z);
    dataPoints.add(FlSpot(dataPoints.length.toDouble(), value));
    return value;
  }

  double _accelerometerMeanValueEvent(List<AccelerometerEvent> events) {
    double sumX = 0.0, sumY = 0.0, sumZ = 0.0;
    for (var event in events) {
      sumX += event.x;
      sumY += event.y;
      sumZ += event.z;
    }
    double meanX = sumX / events.length;
    double meanY = sumY / events.length;
    double meanZ = sumZ / events.length;

    double mean = sqrt(meanX * meanX + meanY * meanY + meanZ * meanZ);
    meanPoints.add(FlSpot(meanPoints.length.toDouble(), mean));
    return mean;
  }

  double _accelerometerVarianceValueEvent(
      AccelerometerEvent mainEvent, List<AccelerometerEvent> events) {
    double sumSqDiffX = 0.0;
    double sumSqDiffY = 0.0;
    double sumSqDiffZ = 0.0;

    double meanEventsX = 0;
    double meanEventsY = 0;
    double meanEventsZ = 0;

    for (var event in events) {
      meanEventsX += event.x;
      meanEventsY += event.y;
      meanEventsZ += event.z;
    }
    meanEventsX /= events.length;
    meanEventsY /= events.length;
    meanEventsZ /= events.length;

    for (var event in events) {
      sumSqDiffX += pow((event.x - meanEventsX), 2);
      sumSqDiffY += pow((event.y - meanEventsY), 2);
      sumSqDiffZ += pow((event.z - meanEventsZ), 2);
    }

    double varianceX = sumSqDiffX / events.length;
    double varianceY = sumSqDiffY / events.length;
    double varianceZ = sumSqDiffZ / events.length;

    double variance = sqrt(
        varianceX * varianceX + varianceY * varianceY + varianceZ * varianceZ);
    variancePoints.add(FlSpot(variancePoints.length.toDouble(), variance));
    return variance;
  }

  @override
  void initState() {
    super.initState();
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      setState(() {
        Timer.periodic(Duration(milliseconds: 100), (timer) {
          _accelerometerEvent = event;
          _accelerometerEvents.add(event);
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _accelerometerSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accelerometer Screen'),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                  color: Colors.white,
                  height: 400,
                  width: 300,
                  child: LineChart(LineChartData(
                      minX: 0,
                      maxX: dataPoints.length.toDouble(),
                      minY: 0,
                      titlesData: const FlTitlesData(
                          leftTitles: AxisTitles(
                              axisNameWidget: Text('Values ->'),
                              sideTitles: SideTitles(showTitles: true)),
                          bottomTitles: AxisTitles(
                              axisNameWidget: Text('Time ->'),
                              sideTitles: SideTitles(showTitles: true))),
                      lineBarsData: [
                        // LineChartBarData(
                        //     spots: dataPoints,
                        //     isCurved: false,
                        //     color: Colors.red,
                        //     dotData: FlDotData(show: true)),
                        LineChartBarData(
                            spots: meanPoints,
                            isCurved: false,
                            color: Colors.orange,
                            dotData: FlDotData(show: true)),
                        // LineChartBarData(
                        //     spots: variancePoints,
                        //     isCurved: true,
                        //     color: Colors.blue,
                        //     dotData: FlDotData(show: true))
                      ]))),
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                        'Accelerometer Values:  X=> ${_accelerometerEvent.x.toStringAsFixed(2)}, Y=> ${_accelerometerEvent.y.toStringAsFixed(2)}, Z=> ${_accelerometerEvent.z.toStringAsFixed(2)}'),
                    Text(
                        'Square Value : ${_accelerometerMainValueEvent(_accelerometerEvent).toStringAsFixed(2)}'),
                    Text(
                        'Mean Square Value : ${_accelerometerMeanValueEvent(_accelerometerEvents).toStringAsFixed(2)}'),
                    Text(
                        'Variance value : ${_accelerometerVarianceValueEvent(_accelerometerEvent, _accelerometerEvents).toStringAsFixed(2)}')
                  ])
            ]),
      ),
    );
  }
}

// class AccelerometerScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Accelerometer Screen'),
//       ),
//       body: Center(
//         child: Text('Accelerometer data will be displayed here'),
//       ),
//     );
//   }
// }

class GyroscopeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gyroscope Screen'),
      ),
      body: Center(
        child: Text('Gyroscope data will be displayed here'),
      ),
    );
  }
}
