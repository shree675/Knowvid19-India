import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Color(0xff4d4dff),
          elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(

                // color: Color(0xff454545),
                decoration: BoxDecoration(
                  color: Color(0xff4d4dff),
                  borderRadius: BorderRadius.vertical(

                    bottom: Radius.circular(50.0),        // 50 to 60
                  ),
                ),
                height: 250.0,                            // make it dynamic and responsive
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Choose your\nlocation below\nand you're\ngood to go!",
                            style: TextStyle(
                              fontSize: 24.0,
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              wordSpacing: 1.4,
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/location7.svg', height: 100,
                            width: 100,),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.0),
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 8.0),
                        height: 60.0,
                        alignment: Alignment.bottomCenter,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.0),
                            border: Border.all(color: Colors.greenAccent,)
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                          Icon(Icons.location_on_rounded,
                          color: Colors.greenAccent,),
                        ],
                        ),
                        ),

                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 0.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Last Updated: ',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            color: Colors.black87,
                          ),),

                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
