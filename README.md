# CIS535 Project - 1 : Sensors on Mobile Devices

This project is my submission towards my assignment in the 1st Term which had three requirements.

1. Upon opening the App you should see two buttons each pointing to different sensors.
2. One among them should be Accelerometer and another one could be anything (I choose Gyroscope).
3. On clicking either of the button should plot the values, mean, and variance on a graph.
   NOTE: The values, mean, variance should be plotted against time and with taking the values using this formula below.

```java
value = sqrt(pow(X,2)+pow(Y,2)+pow(Z,2))
```

I have specifically used flutter as I wanted to try learning since I got the chance too. I have used sensor_plus, fl_chart for reading the data and plotting on the graph.
