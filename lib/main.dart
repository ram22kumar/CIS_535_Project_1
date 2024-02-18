import 'dart:async';
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
  double maxVal = -99;
  late List<double> mainValues;
  List<AccelerometerEvent> _accelerometerEvents = [];
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  double _accelerometerMainValueEvent(AccelerometerEvent event) {
    double value = sqrt(
        event.x * event.x + event.y * event.y * event.y + event.z + event.z);
    if (value > (maxVal / 2)) {
      maxVal = value * 2;
    }
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
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      setState(() {
        Future.delayed(const Duration(milliseconds: 100), () {
          // Timer.periodic(Duration(milliseconds: 100), (timer) {
          if (!event.x.isNaN || !event.y.isNaN || !event.z.isNaN) {
            _accelerometerEvents.add(event);
            _accelerometerMainValueEvent(event);
            _accelerometerMeanValueEvent(_accelerometerEvents);
            _accelerometerVarianceValueEvent(event, _accelerometerEvents);
          }
        });
      });
    });
    // _accelerometerSubscription = accelerometerEvents.listen((event) {
    // });
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
      body: Column(children: [
        Expanded(
          child: Container(
              padding: const EdgeInsets.all(15),
              child: LineChart(LineChartData(
                  minX: 0,
                  maxX: dataPoints.length.toDouble() + 10,
                  minY: 0,
                  maxY: maxVal + 10,
                  titlesData: const FlTitlesData(
                      leftTitles: AxisTitles(
                          axisNameWidget: Text('Values ->'),
                          sideTitles: SideTitles(showTitles: true)),
                      bottomTitles: AxisTitles(
                          axisNameWidget: Text('Time ->'),
                          sideTitles: SideTitles(showTitles: true))),
                  lineBarsData: [
                    LineChartBarData(
                        spots: dataPoints,
                        isCurved: true,
                        color: Colors.red,
                        dotData: const FlDotData(show: true)),
                    LineChartBarData(
                        spots: meanPoints,
                        isCurved: true,
                        color: Colors.orange,
                        dotData: const FlDotData(show: true)),
                    LineChartBarData(
                        spots: variancePoints,
                        isCurved: true,
                        color: Colors.blue,
                        dotData: const FlDotData(show: true))
                  ]))),
        ),
        Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                  'x=> ${_accelerometerEvents.last.x.toStringAsFixed(2)}, y=> ${_accelerometerEvents.last.y.toStringAsFixed(2)}, z=> ${_accelerometerEvents.last.z.toStringAsFixed(2)}'),
              Text(
                  'Main Value : ${dataPoints.isNotEmpty ? dataPoints.last.y.toStringAsFixed(2) : 'N/A'}',
                  style: const TextStyle(color: Colors.red)),
              Text(
                  'Mean Value : ${meanPoints.isNotEmpty ? meanPoints.last.y.toStringAsFixed(2) : 'N/A'}',
                  style: const TextStyle(color: Colors.orange)),
              Text(
                  'Variance Value : ${variancePoints.isNotEmpty ? variancePoints.last.y.toStringAsFixed(2) : 'N/A'}',
                  style: const TextStyle(color: Colors.blue)),
            ],
          ),
        )
      ]),
    );
  }
}

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
