import 'package:flutter/material.dart';
import 'package:mboathoscope/models/User.dart';
import 'package:mboathoscope/views/ProfilePage.dart';
import 'package:mboathoscope/views/widgets/DoctorListScreen.dart';
import 'package:mboathoscope/views/widgets/RecordingList.dart';
import 'package:mboathoscope/views/widgets/HomePage_headerHalf.dart';
import 'package:mboathoscope/views/widgets/alert_dialog_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/Doctor.dart';
import '../record_implementation/recorder_main.dart';

class HomePage extends StatefulWidget {
  final CustomUser user;
  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ///index user has clicked/active navigation button
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    ///for navigation page except settings
    if (index < 3) {
      setState(() {
        _selectedIndex = index;
      });
    }

    ///for settings page
    if (index == 3) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  ///
  List<Widget> widgetList() {
    return [
      ///navigation bottom 0
      Container(
        child:  headerHalf(
          onPredictionComplete: (result,outputPath) {
            // Handle the prediction result, you can pass it to DialogUtils or navigate to Result page here
            // For example:
            DialogUtils.showCustomDialog(
              context,
              title: 'title',
              path: outputPath,
              predictionResult: result,
            );
            //Navigator.of(context).pop();
          },
        ),
      ),
      // MyRecorderApp(),

      ///navigation bottom 1
      Container(
        child: const RecordingList(),
      ),

      ///navigation bottom 2
      Container(
        height: MediaQuery.of(context).size.height, // Set a fixed height
        child: FutureBuilder<List<Doctor>>(
          future: fetchDataAndNavigate(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                // Check if data is not null before showing DoctorListScreen
                if (snapshot.data != null) {
                  return DoctorListScreen(doctors: snapshot.data!);
                } else {
                  // Handle case where data is null
                  return Text('No data available');
                }
              }
            }
          },
        ),
      ),


      ///navigation bottom 3
      ProfilePage(
        user: widget.user,
      )
    ];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F7FF),
      body: SingleChildScrollView(
        child: widgetList()[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        //backgroundColor: const Color(0xffF3F7FF),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Color(0xffF3F7FF),
            icon: ImageIcon(
              AssetImage("assets/images/img_profile.png"),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/images/img_explore.png"),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/images/img_recordings.png"),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/images/img_setting.png"),
            ),
            label: '',
          ),
        ],
        selectedItemColor: const Color(0xff3D79FD),
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }

  Future<List<Doctor>> fetchDataAndNavigate(BuildContext context) async {
    try {
      CollectionReference<Map<String, dynamic>> doctorsCollection =
      FirebaseFirestore.instance.collection('Doctors');
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await doctorsCollection.get();

      List<Doctor> doctors = snapshot.docs
          .map((doc) => Doctor.fromMap(doc.id, doc.data()!))
          .toList();

      // Log a message indicating successful data retrieval
      debugPrint('Successfully fetched ${doctors.length} doctors from Firebase');

      return doctors;
    } catch (e) {
      // Log the error
      debugPrint('Error fetching doctors: $e');
      print('Error fetching doctors: $e'); // Also print to console for visibility

      throw e; // Rethrow the error to be handled by the caller
    }
  }





}
