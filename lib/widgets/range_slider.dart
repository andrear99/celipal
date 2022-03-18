import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RangeSliderColorWidget extends StatefulWidget {
  var controller;
  var divisions;
  var min;
  var max;
  final tipo;
  RangeSliderColorWidget(this.controller, this.divisions, this.max, this.min, this.tipo);
  @override
  _RangeSliderColorWidgetState createState() => _RangeSliderColorWidgetState();
}

class _RangeSliderColorWidgetState extends State<RangeSliderColorWidget> {
  RangeValues values = RangeValues(1, 5);

  @override
  Widget build(BuildContext context) => SliderTheme(
        data: SliderThemeData(
          /// track color
          inactiveTrackColor: Colors.black12,

          /// ticks in between
          activeTickMarkColor: Colors.transparent,
          inactiveTickMarkColor: Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RangeSlider(
              values: values,
              min: double.parse(widget.min.toString()),
              max: double.parse(widget.max.toString()),
              divisions: widget.divisions,
              labels: RangeLabels(
                values.start.round().toString(),
                values.end.round().toString(),
              ),
              onChanged: (values){ 
                setState(() => this.values = values);
              },
            ),
            ElevatedButton(
              onPressed:() {
                widget.controller.stream.drain();
                Stream s;
                switch (widget.tipo) {
                  case "pro":
                    s = FirebaseFirestore.instance.collection('Producto').where('precio_estimado', isLessThanOrEqualTo: values.end, isGreaterThanOrEqualTo: values.start).snapshots();
                    s.forEach((element) {
                      widget.controller.add(element);
                    }
                    ); 
                    break;
                  case "res_pre": 
                    s = FirebaseFirestore.instance.collection('Restaurante').where('rango_precio', isLessThanOrEqualTo: values.end, isGreaterThanOrEqualTo: values.start).where('aprobado_admin', isEqualTo: true).snapshots();
                    s.forEach((element) {
                      widget.controller.add(element);
                    });

                    break;
                }
                setState(() {
                  Navigator.pop(context);
                });
              }, 
              child: Text("Filtrar"),
            )
          ],
        ),
      );
}