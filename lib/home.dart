import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double balance = 10000.0;
  double currentPrice = 1.0850;
  double profitLoss = 0.0;
  bool isBuyOpen = false;
  double entryPrice = 0.0;
  List<double> chartData = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 50; i++) {
      chartData.add(1.0800 + Random().nextDouble() * 0.01);
    }
    startPriceUpdate();
  }

  void startPriceUpdate() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        double change = (Random().nextDouble() - 0.5) * 0.0005;
        currentPrice += change;
        chartData.removeAt(0);
        chartData.add(currentPrice);
        if (isBuyOpen) {
          profitLoss = (currentPrice - entryPrice) * 10000;
        }
      });
    });
  }

  void buyTrade() {
    setState(() {
      if (!isBuyOpen) {
        isBuyOpen = true;
        entryPrice = currentPrice;
        profitLoss = 0.0;
      } else {
        balance += profitLoss;
        isBuyOpen = false;
        profitLoss = 0.0;
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forex Trading Demo'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('DEMO ACCOUNT - NOT REAL MONEY', 
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(children: [
                  Text('Balance', style: TextStyle(color: Colors.grey)),
                  Text('\$${balance.toStringAsFixed(2)}', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ]),
                Column(children: [
                  Text('EUR/USD', style: TextStyle(color: Colors.grey)),
                  Text(currentPrice.toStringAsFixed(5), 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ]),
              ],
            ),
            SizedBox(height: 10),
            Text('P/L: \$${profitLoss.toStringAsFixed(2)}', 
              style: TextStyle(
                color: profitLoss >= 0? Colors.green : Colors.red,
                fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF161B22),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: ChartPainter(chartData),
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBuyOpen? Colors.red : Colors.green,
                ),
                onPressed: buyTrade,
                child: Text(isBuyOpen? 'CLOSE TRADE' : 'BUY EUR/USD',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 10),
            Text('This is a fake demo. No real money involved.', 
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<double> data;
  ChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    double min = data.reduce(min);
    double max = data.reduce(max);
    double range = max - min;
    if (range == 0) range = 1;

    Paint linePaint = Paint()
  ..color = Colors.green
  ..strokeWidth = 2
  ..style = PaintingStyle.stroke;

    Path path = Path();
    for (int i = 0; i < data.length; i++) {
      double x = i * size.width / (data.length - 1);
      double y = size.height - ((data[i] - min) / range * size.height);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
