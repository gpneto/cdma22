import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'checkbox_form_field.dart';
import 'client_model.dart';
import 'database.dart';

void main() => runApp(MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CDMA22 - Clientes"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              DBProvider.db.deleteAll();
              setState(() {});
            },
          )
        ],
      ),
      body: FutureBuilder<List<Cliente>>(
        future: DBProvider.db.getAllClientes(),
        builder: (BuildContext context, AsyncSnapshot<List<Cliente>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Cliente item = snapshot.data[index];
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) {
                    DBProvider.db.deleteCliente(item.id);
                  },
                  child: ListTile(
                    title: Text(item.nome + " " + item.sobrenome),
                    leading: Text(item.id.toString()),
                    trailing: Checkbox(
                      onChanged: (bool value) {
                        DBProvider.db.blockOrUnblock(item);
                        setState(() {});
                      },
                      value: item.marcado,
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: mostradialogo,
      ),
    );
  }

  mostradialogo() async{
    Cliente cliente =  Cliente();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      child: Icon(Icons.close),
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Nome',
                            contentPadding: EdgeInsets.all(15.0),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Digite o seu nome';
                            }
                            return null;
                          },
                          onSaved: (String value) {
                            cliente.nome = value;
                          },),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Sobrenome',
                            contentPadding: EdgeInsets.all(15.0),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Digite o seu Sobrenome';
                            }
                            return null;
                          },
                          onSaved: (String value) {
                            cliente.sobrenome = value;
                          },),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CheckboxFormField(title: Text("Marcado"),
                          onSaved: (bool value) {
                            cliente.marcado = value;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          child: Text("Salvar"),
                          onPressed: () async{
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              await DBProvider.db.newCliente(cliente);
                              setState(() {});
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });

  }
}
