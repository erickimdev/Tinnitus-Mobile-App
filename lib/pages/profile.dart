import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // final AuthService _auth = AuthService();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 69, 151, 1),

      appBar: AppBar(
        title: Text('Profile Page'),
        centerTitle: true,
        backgroundColor: Colors.black12,
        elevation: 5,
      ),

      body: Center(
        child: Column(
          children: <Widget>[
            // PROFILE ICON
            SizedBox(height: 30.0),
            Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 80,
            ),
            SizedBox(height: 15.0),
            Text(
              'My Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 70.0),

            // EMAIL ADDRESS FORM
            Container(
              width: 350,
              child: TextFormField(
                textAlign: TextAlign.center,
                onChanged: (i) {
                  setState(() => email = i);
                },
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: "Email Address",
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                  fillColor: Colors.white70,
                  enabledBorder:OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400], width: 2.0),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),

            // PASSWORD FORM
            SizedBox(height: 10.0),
            Container(
              width: 350,
              child: TextFormField(
                textAlign: TextAlign.center,
                obscureText: true,
                onChanged: (i) {
                  setState(() => password = i);
                },
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                  fillColor: Colors.white70,
                  enabledBorder:OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400], width: 2.0),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),

            // REGISTER BUTTON
            SizedBox(height: 30.0),
            TextButton.icon(
              // onPressed: () async {
              //   dynamic result = await _auth.signInAnon();
              //   print("result: " + result.toString());
              // },
              onPressed: ()  {
                print("email: " + email);
                print("password: " + password);
              },
              icon: Icon(
                Icons.check,
                color: Colors.white70,
                size: 30,
              ),
              label: Text(
                "Login",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 21,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
//
// class ProfilePage extends StatefulWidget {
//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   int _counter = 0;
//   void _incrementCounter() => setState(() {
//     _counter++;
//   });
//   void _decrementCounter() => setState(() {
//     _counter--;
//   });
//
//   Widget quoteTemplate(quote) {
//     return Card(
//       margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               quote.text,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold
//               ),
//             ),
//             Text(
//               "- " + quote.author.toString(),
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 20,
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//   List<Quote> quotes = [
//     Quote(text: "sample quote", author: "alex"),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Profile Page'),
//         centerTitle: true,
//         backgroundColor: Colors.grey[900],
//         elevation: 5,
//       ),
//
//       body: Column(
//         children: <Widget>[
//           SizedBox(height: 40.0),
//           Icon(
//             Icons.account_circle,
//             color: Colors.grey[800],
//             size: 80,
//           ),
//           Text(
//             'My Profile',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 20.0,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 30.0),
//           TextButton.icon(
//             onPressed: () {print("hi");},
//             icon: Icon(
//               Icons.email_sharp,
//               color: Colors.black,
//               size: 30,
//             ),
//             label: Text(
//               'asdf@gmail.com',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 21,
//               ),
//             ),
//           ),
//           Column(children: quotes.map((i) {return quoteTemplate(i);}).toList()),
//           SizedBox(height: 30.0),
//           Text(
//             'You have pushed the button\nthis many times:',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 20.0,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 10.0),
//           Text(
//             '$_counter',
//             style: Theme.of(context).textTheme.headline4,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               FloatingActionButton(
//                 heroTag: "btn1",
//                 onPressed: _decrementCounter,
//                 child: Icon(Icons.remove),
//                 backgroundColor: Colors.grey[500],
//                 elevation: 0,
//               ),
//               FloatingActionButton(
//                 heroTag: "btn2",
//                 onPressed: _incrementCounter,
//                 child: Icon(Icons.add),
//                 backgroundColor: Colors.grey[500],
//                 elevation: 0,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );  }
// }
//
// class Quote {
//   String author;
//   String text;
//
//   Quote({
//     this.text,
//     this.author
//   });
// }