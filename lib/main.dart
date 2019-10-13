import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const url = "https://api.hgbrasil.com/finance?format=json&key=7ce39328";

void main() async {  

  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
        hintColor: Colors.amberAccent,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white30))
        ),
      ),
  ));
}

Future<Map> getData() async {
  var res = await http
    .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
  var data = json.decode(res.body);
  print(data["results"]["currencies"]["USD"]);
  return json.decode(res.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolarResponse = 0.0;
  double euroResponse = 0.0;

  void _resetFields(){
    setState(() {
      realController.text = "";
      dolarController.text = "";
      euroController.text = "";
    });
  }

  void _realChanged(String text){  
    if(text.isEmpty){
      _resetFields();
      return;
    }  
    double real = double.parse(text);
    dolarController.text = (real/dolarResponse).toStringAsFixed(2);
    euroController.text = (real/euroResponse).toStringAsFixed(2);
  }
  
  void _dolarChanged(String text){   
    if(text.isEmpty){
      _resetFields();
      return;
    }   
    double dolar = double.parse(text);
    realController.text = (dolar * dolarResponse).toStringAsFixed(2);
    euroController.text = (dolar * dolarResponse / euroResponse).toStringAsFixed(2);
  }

  void _euroChanged(String text){  
    if(text.isEmpty){
      _resetFields();
      return;
    }   
    double euro = double.parse(text);
    realController.text = (euro * euroResponse).toStringAsFixed(2);
    dolarController.text = (euro * euroResponse / dolarResponse).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(      
        titleSpacing: 20.0,
        toolbarOpacity: 0.8,
        backgroundColor: Colors.amberAccent,
        title: Text(
          "Cass Software - Conversor de moedas",
          style: TextStyle(fontSize: 17.0)
        ),  
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: _resetFields),          
        ],
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot){
          switch(snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados...",
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 25.0
                  )
                ),
              );    
            default:              
              if(snapshot.hasError){
                return Center(
                  child: Text(
                    "Erro ao carregar dados.... ${snapshot.error}",
                    style: TextStyle(color: Colors.amberAccent, fontSize: 25.0)
                  ),
                );
              } else {
                dolarResponse = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euroResponse = snapshot.data["results"]["currencies"]["EUR"]["buy"];               
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on, size: 150.0, color: Colors.amberAccent),
                      Divider(),                
                      buildTextField("Reais", "R\$ ", realController, _realChanged),
                      Divider(),
                      buildTextField("Dólares", "USD ", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField("Euros", "€ ", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          } 
          // switch
        },
      ),
    );
    
  }
}


// Função para gerar TextField
Widget buildTextField(String label, String prefix, TextEditingController controller, Function fn) {
  return TextField(
    controller: controller,
    onChanged: fn,
    keyboardType: TextInputType.number,                        
    decoration: InputDecoration(
      labelText: label,                          
      labelStyle: TextStyle(color: Colors.amberAccent),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(
      color: Colors.amberAccent, fontSize: 25.0
    ), 
  );
}
