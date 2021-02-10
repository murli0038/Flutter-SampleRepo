import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage()
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final nameHolder = TextEditingController();

  String name;
  final DatabaseRef = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: nameHolder,
                        decoration: InputDecoration(
                          hintText: 'Enter your name',
                          fillColor: Colors.white70,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)),
                            borderSide: BorderSide(color: Color.fromRGBO(49, 171, 218, 1), width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)),
                            borderSide: BorderSide(color:Color.fromRGBO(49, 171, 218, 1)),
                          ),
                        ),
                        onChanged: (value){
                          name = value;
                        },
                      ),
                    ),
                    SizedBox(width: 10,),
                    RaisedButton(
                      onPressed: () async {
                        setState(() {
                          DatabaseRef.child("UserData").push().set({
                            'name': name,
                            'timestamp': DateTime.now().toString()
                          });
                          nameHolder.clear();
                          // currentFocus.unfocus();
                        });
                      },
                      child: Text('Add',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      ),
                      color: Color.fromRGBO(49, 171, 218, 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 450,
                    width: MediaQuery.of(context).size.width / 1.1,
                    child:  StreamBuilder(
                      stream: DatabaseRef.reference().child("UserData").orderByChild("timestamp").onValue,
                      builder: (context, snap) {
                        if (snap.hasData &&
                            !snap.hasError &&
                            snap.data.snapshot.value != null) {
                          Map<dynamic,dynamic> data = snap.data.snapshot.value;
                          List<dynamic> list = data.values.toList();
                          List<dynamic> key = data.keys.toList();

                          // var listA = data.entries.toList();
                          // listA.sort((a, b) => b.value["timestamp"].compareTo(a.value["timestamp"]));
                          // var listB = listA.map((a) => {a.key: a.value}).toList();

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 3,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(list[index]["name"].toString(), style: TextStyle(color: Color.fromRGBO(49, 171, 218, 1),fontSize: 18,fontFamily: "Popmed", fontWeight: FontWeight.w600),),
                                          Text(list[index]["timestamp"].toString())
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: (){
                                        DatabaseRef.reference().child("UserData").child(key[index]).remove();
                                      },
                                    )
                                  ],
                                ),
                              );
                            },
                          );
                        } else
                          return Center(child: Text("No data"));
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

