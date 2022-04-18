import 'package:flutter/material.dart';

class TableKim extends StatelessWidget {
  final String val;
  const TableKim({@required this.val}) ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DataTable(
          columns: <DataColumn>[
            DataColumn(
              label: Text(
                '',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                '',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            // DataColumn(
            //   label: Text(
            //     'Role',
            //     style: TextStyle(fontStyle: FontStyle.italic),
            //   ),
            // ),
          ],
          rows: <DataRow>[
            DataRow(
              cells: <DataCell>[
                DataCell(Text('Ravi')),
                DataCell(Text(val)),
                //DataCell(Text('Student')),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text('Jane')),
                DataCell(Text('43')),
                //DataCell(Text('Professor')),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text('William')),
                DataCell(Text('27')),
                //DataCell(Text('Professor')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
