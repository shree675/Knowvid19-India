import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:number_display/number_display.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String res="";
  String val="";
  Map data;
  List<String> regions = new List();
  int ind, length;
  String lastUpdated="";
  int totInd,deInd,recInd;
  int totReg,deReg,recReg;
  int highest,lowest;
  String hig="",low="";

  getData(int j) async {
    try {
      http.Response response = await http.get(
          Uri.encodeFull("https://api.rootnet.in/covid19-in/stats/latest"),
          headers: {
            "Accept": "application/json",
          });
      setState(() {
        res = response.body;
        data = jsonDecode(response.body);
        length=data["data"]["regional"].length;
        // print(length);
        if(regions.length==0) {
          highest=0;
          lowest = 2000000;
          for (int i = 0; i < length; i++) {
            regions.add(data["data"]["regional"][i]["loc"]);
            if(highest<data["data"]["regional"][i]["totalConfirmed"]){
              highest = data["data"]["regional"][i]["totalConfirmed"];
              hig = data["data"]["regional"][i]["loc"];
            }
            if(lowest>data["data"]["regional"][i]["totalConfirmed"]){
              lowest = data["data"]["regional"][i]["totalConfirmed"];
              low = data["data"]["regional"][i]["loc"];
            }
          }
        }
        val = data["data"]["regional"][ind]["loc"];
        DateFormat formatter = DateFormat('dd-MM-yyyy');
        lastUpdated = formatter.format(DateTime.parse(data["lastRefreshed"]));
        totInd = data["data"]["summary"]["total"];
        recInd = data["data"]["summary"]["discharged"];
        deInd = data["data"]["summary"]["deaths"];
        totReg = data["data"]["regional"][ind]["totalConfirmed"];
        deReg = data["data"]["regional"][ind]["deaths"];
        recReg = data["data"]["regional"][ind]["discharged"];
      });
    }
    catch (e) {
      setState(() {
        res = "Something went wrong";
      });
      print("Something went wrong");
      print(e);
    }
  }

  final display = createDisplay(
    length: 5,
    units: const ['K','M','B','Z','P'],
    decimal: 0,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ind=0;
    getData(ind);
  }

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

                    bottom: Radius.circular(50.0),
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
                            Expanded(
                              child: DropdownButton(
                                value: val,
                                isExpanded: true,
                                underline: SizedBox(height: 0,),
                                dropdownColor: Colors.white,
                                focusColor: Colors.black,
                                items: regions.map<
                                    DropdownMenuItem<String>>((
                                    String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value,
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 16.0,
                                          color: Colors.black
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    ind = regions.indexOf(newValue);
                                    val = newValue;
                                    getData(ind);
                                    // res=newValue;
                                  });
                                },
                              ),
                            ),
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
                        Text('Last Updated: $lastUpdated',
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
              Card(
                color: Colors.white,
                elevation: 5.0,
                shadowColor: Colors.grey,
                margin: EdgeInsets.all(10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(10.0),
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('${val.toUpperCase()}',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          wordSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5.0,),
                      Text('Total Infections:',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.amber,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),),
                      Container(
                        margin: EdgeInsets.all(5.0),
                        padding: EdgeInsets.all(5.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  'assets/cautionyellow.svg', height: 30.0,
                                  width: 30.0,),
                                SizedBox(width: 10.0,),
                                Text('${totReg == null
                                    ? 'Please wait...'
                                    : totReg}',
                                  style: TextStyle(
                                      fontSize: 22.0, color: Colors.black),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${display(totReg)}',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black
                                  ),),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5.0,),
                      Text('Total Recovered:',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.green,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),),
                      Container(
                        margin: EdgeInsets.all(5.0),
                        padding: EdgeInsets.all(5.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  'assets/cautiongreen1.svg', height: 30.0,
                                  width: 30.0,),
                                SizedBox(width: 10.0,),
                                Text('${recReg == null
                                    ? 'Please wait...'
                                    : recReg}',
                                  style: TextStyle(
                                      fontSize: 22.0, color: Colors.black),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${display(recReg)}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5.0,),
                      Text('Total Deaths:',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.red,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),),
                      Container(
                        margin: EdgeInsets.all(5.0),
                        padding: EdgeInsets.all(5.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  'assets/cautionred1.svg', height: 30.0,
                                  width: 30.0,),
                                SizedBox(width: 10.0,),
                                Text('${deReg == null
                                    ? 'Please wait...'
                                    : deReg}',
                                  style: TextStyle(
                                      fontSize: 22.0, color: Colors.black),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${display(deReg)}',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black
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
              Card(
                color: Colors.white,
                elevation: 5.0,
                shadowColor: Colors.grey,
                margin: EdgeInsets.all(10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(10.0),
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('CASES IN INDIA',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5.0,),
                      Text('Total Infections:',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.amber,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),),
                      Container(
                        margin: EdgeInsets.all(5.0),
                        padding: EdgeInsets.all(5.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  'assets/cautionyellow.svg', height: 30.0,
                                  width: 30.0,),
                                SizedBox(width: 10.0,),
                                Text('${totInd == null
                                    ? 'Please wait...'
                                    : totInd}',
                                  style: TextStyle(
                                      fontSize: 22.0, color: Colors.black),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${display(totInd)}',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black
                                  ),),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5.0,),
                      Text('Total Recovered:',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.green,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),),
                      Container(
                        margin: EdgeInsets.all(5.0),
                        padding: EdgeInsets.all(5.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  'assets/cautiongreen1.svg', height: 30.0,
                                  width: 30.0,),
                                SizedBox(width: 10.0,),
                                Text('${recInd == null
                                    ? 'Please wait...'
                                    : recInd}',
                                  style: TextStyle(
                                      fontSize: 22.0, color: Colors.black),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${display(recInd)}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5.0,),
                      Text('Total Deaths:',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.red,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),),
                      Container(
                        margin: EdgeInsets.all(5.0),
                        padding: EdgeInsets.all(5.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  'assets/cautionred1.svg', height: 30.0,
                                  width: 30.0,),
                                SizedBox(width: 10.0,),
                                Text('${deInd == null
                                    ? 'Please wait...'
                                    : deInd}',
                                  style: TextStyle(
                                      fontSize: 22.0, color: Colors.black),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${display(deInd)}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
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
              Card(
                elevation: 5.0,
                shadowColor: Colors.grey,
                color: Colors.white,
                margin: EdgeInsets.all(10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Container(
                    margin: EdgeInsets.all(10.0),
                    padding: EdgeInsets.all(5.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('MAX AND MIN',
                          style: TextStyle(
                              fontSize: 22.0,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              wordSpacing: 1.5
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5.0,),
                        Text('Highest number of cases:',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        SizedBox(height: 5.0,),
                        Container(
                          padding: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(hig,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: 'Montserrat',
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 2.0,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .start,
                                    children: [
                                      Text('${highest == null
                                          ? 'Please wait...'
                                          : highest}',
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.black,
                                        ),),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .start,
                                    children: [
                                      Text('${display(highest)}',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black,
                                        ),)
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 5.0,),
                        Text('Lowest number of cases:',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        SizedBox(height: 5.0,),
                        Container(
                          padding: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(low,
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontFamily: 'Montserrat',
                                    color: Colors.grey[600]
                                ),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 2.0,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .start,
                                    children: [
                                      Text('${lowest == null
                                          ? 'Please wait...'
                                          : lowest}',
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.black
                                        ),),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .start,
                                    children: [
                                      Text('${display(lowest)}',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black
                                        ),)
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.0,),
                      ],
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
