import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:number_display/number_display.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  RefreshController ref = RefreshController(initialRefresh: false);
  bool theme=false;

  load() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    theme = pref.getBool('theme') ?? false;
  }

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
      setState((){
        totReg=null;
        recReg=null;
        deReg=null;
        totInd=null;
        recInd=null;
        deInd=null;
        val="";
        highest=null;
        lowest=null;
        hig="";
        low="";
      });
      await load();
      if(theme) {
        showAlertDialog(context);
      }
      else{
        showAlertDialogLight(context);
      }
      print("Something went wrong");
      print(e);
    }
  }

  showAlertDialog(BuildContext context) {
    Widget button = Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0)
        ),
        child:FlatButton(
          color: Color(0xff343434),
          child: Text("OK",
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.amberAccent,
              fontWeight: FontWeight.bold,
            ),),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ));

    AlertDialog alert = AlertDialog(
      backgroundColor: Color(0xff343434),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: Text('Oops! Something went wrong.',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20.0,
            color: Colors.white
        ),),
      content: Text(
        'The backend server is temporarily taken down or there is no network available on your device. Please refresh or try again later.',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16.0,
          color: Colors.white70,
        ),
        textAlign: TextAlign.center,),
      actions: [
        button
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialogLight(BuildContext context) {
    Widget button = Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0)
        ),
        child:FlatButton(
          color: Colors.white,
          child: Text("OK",
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ));

    AlertDialog alertLight = AlertDialog(
      backgroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: Text('Oops! Something went wrong',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20.0,
            color: Colors.black
        ),),
      content: Text(
        'The backend server is temporarily taken down or there is no network available on your device. Please refresh or try again later.',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16.0,
          color: Colors.grey[700],
        ),
        textAlign: TextAlign.center,),
      actions: [
        button
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertLight;
      },
    );

  }

  final display = createDisplay(
    length: 5,
    units: const ['K','M','B','Z','P'],
    decimal: 0,
  );

  final display2 = createDisplay(
      length: 4,
      units: const ['K','M','B','Z','P'],
      decimal: 0
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ind=0;
    getData(ind);
    load();
  }

  @override
  Widget build(BuildContext context) {
    if (!theme) {
      return Scaffold(
        appBar: AppBar(
          title: Text(""),
          backgroundColor: Color(0xff4d4dff),
          elevation: 0.0,
        ),
        drawer: Drawer(
          child: Container(
            // height: 1000,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 200.0,
                  padding: EdgeInsets.all(10.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(0), bottom: Radius.circular(20.0)),
                    color: Colors.blueGrey,
                  ),
                  alignment: Alignment.center,
                  child: Text('Settings and Info',
                      style: TextStyle(
                        fontSize: 35.0,
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                      )),
                ),
                SizedBox(height: 10.0,),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Theme:',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),),
                      Row(
                        children: [
                          Text('Light ',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16.0,
                            ),),
                          FlutterSwitch(
                            width: 49.0,
                            height: 24.5,
                            padding: 0.0,
                            showOnOff: false,
                            value: theme,
                            inactiveToggleColor: Colors.yellow,
                            inactiveColor: Colors.lightBlueAccent,
                            activeColor: Colors.blueGrey,
                            onToggle: (val) async {
                              SharedPreferences prefs = await SharedPreferences
                                  .getInstance();
                              theme = prefs.getBool('theme') ?? false;
                              // print(theme);
                              setState(() {
                                if (!theme) {
                                  theme = true;
                                  prefs.setBool('theme', true);
                                }
                                else {
                                  theme = false;
                                  prefs.setBool('theme', false);
                                }
                              });
                              build(context);
                            },
                          ),
                          Text(' Dark',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16.0,
                            ),),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.0,),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text('Version:  1.0.0',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Montserrat',
                          color: Colors.black54,
                        ),),
                    ),
                    // SizedBox(height: 10.0,),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    // SizedBox(height: 10.0,),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'The statistics present here is updated once a day. You can refresh the app by swiping the screen down.',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          color: Colors.black54,
                        ),),
                    ),
                    // SizedBox(height: 10.0,),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    // SizedBox(height: 10.0,),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Please follow all COVID-19 guidelines. Visit the website below for more information.',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          color: Colors.black54,
                        ),),
                    ),
                    // SizedBox(height: 10.0,),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: new InkWell(
                        child: Text('Guidelines and protocols by WHO',
                          style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 16.0
                          ),),
                        onTap: () =>
                            launch(
                                'https://www.who.int/emergencies/diseases/novel-coronavirus-2019/advice-for-public'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: SmartRefresher(
          controller: ref,
          enablePullDown: true,
          enablePullUp: false,
          header: BezierCircleHeader(
            bezierColor: Color(0xff4d4dff),
            circleColor: Colors.greenAccent,
          ),
          footer: null,
          onRefresh: () async {
            regions.clear();
            await getData(ind);
            ref.refreshCompleted();
          },
          child: SingleChildScrollView(
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
                    height: 250.0, // make it dynamic and responsive
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
                            Text('Last Updated:  $lastUpdated',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                color: Colors.black87,
                              ),),
                            Text('Swipe down to refresh',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  color: Colors.black38
                              ),
                            )
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
                                    Text('${display2(totReg)}',
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
                                    Text('${display2(recReg)}',
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
                                    Text('${display2(deReg)}',
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
                                          Text('${display2(lowest)}',
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
                  SizedBox(height: 20.0,),
                ],
              ),
            ),
          ),
        ),
      );
    }


    else{
      return Scaffold(
        appBar: AppBar(
          title: Text(""),
          backgroundColor: Color(0xff4d4dff),
          elevation: 0.0,
          actions: [
            // IconButton(
            //   icon: Icon(Icons.menu_rounded),
            //   color: Colors.amberAccent,
            //   onPressed: () {},
            //   splashColor: Color(0xff4d4dff),
            // ),
          ],
        ),
        drawer: Drawer(
          child: Container(
            // height: 1000,
            color: Color(0xff343434),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 200.0,
                  padding: EdgeInsets.all(10.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(0), bottom: Radius.circular(20.0)),
                    color: Colors.blueGrey,
                  ),
                  alignment: Alignment.center,
                  child: Text('Settings and Info',
                      style: TextStyle(
                        fontSize: 35.0,
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                      )),
                ),
                SizedBox(height: 10.0,),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Theme:',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                        ),),
                      Row(
                        children: [
                          Text('Light ',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16.0,
                            ),),
                          FlutterSwitch(
                            width: 49.0,
                            height: 24.5,
                            padding: 0.0,
                            showOnOff: false,
                            value: theme,
                            activeToggleColor: Color(0xffcacaca),
                            // borderRadius: 10.0,
                            inactiveToggleColor: Colors.yellow,
                            inactiveColor: Colors.lightBlueAccent,
                            switchBorder: Border.all(
                              width: 1.0,
                              color: Colors.black,
                            ),
                            activeColor: Color(0xff2a2a92),               // 191970  3b3ba2
                            onToggle: (val) async {
                              SharedPreferences prefs = await SharedPreferences
                                  .getInstance();
                              theme = prefs.getBool('theme') ?? false;
                              // print(theme);
                              setState(() {
                                if (!theme) {
                                  theme = true;
                                  prefs.setBool('theme', true);
                                }
                                else {
                                  theme = false;
                                  prefs.setBool('theme', false);
                                }
                              });
                            },
                          ),
                          Text(' Dark',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16.0,
                            ),),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.0,),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text('Version:  1.0.0',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Montserrat',
                          color: Colors.white54,
                        ),),
                    ),
                    // SizedBox(height: 20.0,),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'The statistics present here is updated once a day. You can refresh the app by swiping the screen down.',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          color: Colors.white54,
                        ),),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text('Please follow all COVID-19 guidelines. Visit the website below for more information.',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          color: Colors.white54,
                        ),),
                    ),
                    // SizedBox(height: 10.0,),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: new InkWell(
                        child: Text('Guidelines and protocols by WHO',
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16.0
                          ),),
                        onTap: () => launch('https://www.who.int/emergencies/diseases/novel-coronavirus-2019/advice-for-public'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: SmartRefresher(
          controller: ref,
          enablePullDown: true,
          enablePullUp: false,
          header: BezierCircleHeader(
            bezierColor: Color(0xff4d4dff),
            circleColor: Colors.amberAccent,
          ),
          footer: null,
          onRefresh: () async {
            regions.clear();
            await getData(ind);
            ref.refreshCompleted();
          },
          child: SingleChildScrollView(
            child: Container(
              color: Color(0xff454545),
              child: Column(
                children: [
                  Container(
                      height: 250.0,
                      // width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xff4d4dff),
                        borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(50.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
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
                                    color: Colors.amber,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    wordSpacing: 1.4,
                                  ),
                                ),
                                SvgPicture.asset(
                                  'assets/location6.svg', height: 100,
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
                                  color: Color(0xff454545),
                                  borderRadius: BorderRadius.circular(30.0),
                                  border: Border.all(color: Colors.amber,)
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Icon(Icons.location_on_rounded,
                                    color: Colors.amber,),
                                  Expanded(
                                    child: DropdownButton(
                                      value: val,
                                      isExpanded: true,
                                      underline: SizedBox(height: 0,),
                                      dropdownColor: Color(0xff454545),
                                      focusColor: Colors.white,

                                      items: regions.map<
                                          DropdownMenuItem<String>>((
                                          String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value,
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 16.0,
                                                color: Colors.white
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
                            )
                          ],
                        ),
                      )
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
                            Text('Last Updated:  $lastUpdated',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  color: Colors.white60
                              ),),
                            Text('Swipe down to refresh',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  color: Colors.white30
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Card(
                    elevation: 7.0,
                    shadowColor: Colors.amber,
                    color: Colors.blueGrey,
                    margin: EdgeInsets.all(10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(10.0),
                      padding: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: Colors.blueGrey,
                          width: 2.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('${val.toUpperCase()}',
                            style: TextStyle(
                              color: Colors.white,
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
                              color: Colors.amberAccent,
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
                                          fontSize: 22.0, color: Colors.white),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('${display2(totReg)}',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white
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
                              color: Colors.lightGreenAccent,
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
                                          fontSize: 22.0, color: Colors.white),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('${display2(recReg)}',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.white,
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
                              color: Colors.redAccent,
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
                                          fontSize: 22.0, color: Colors.white),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('${display2(deReg)}',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white
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
                    elevation: 7.0,
                    shadowColor: Colors.amber,
                    color: Colors.blueGrey,
                    margin: EdgeInsets.all(10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(10.0),
                      padding: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: Colors.blueGrey,
                          width: 2.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('CASES IN INDIA',
                            style: TextStyle(
                              color: Colors.white,
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
                              color: Colors.amberAccent,
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
                                          fontSize: 22.0, color: Colors.white),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('${display(totInd)}',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white
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
                              color: Colors.lightGreenAccent,
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
                                          fontSize: 22.0, color: Colors.white),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('${display(recInd)}',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.white,
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
                              color: Colors.redAccent,
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
                                          fontSize: 22.0, color: Colors.white),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('${display(deInd)}',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.white,
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
                    elevation: 7.0,
                    shadowColor: Colors.amber,
                    color: Colors.blueGrey,
                    margin: EdgeInsets.all(10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Container(
                        margin: EdgeInsets.all(10.0),
                        padding: EdgeInsets.all(5.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: Colors.blueGrey,
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
                                  color: Colors.white,
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
                                color: Colors.lightBlueAccent,
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
                                      color: Colors.white70,
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
                                              color: Colors.white,
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
                                              color: Colors.white,
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
                                color: Colors.lightBlueAccent,
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
                                        color: Colors.white70
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
                                                color: Colors.white
                                            ),),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        children: [
                                          Text('${display2(lowest)}',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.white
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
                  SizedBox(height: 20.0,),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}