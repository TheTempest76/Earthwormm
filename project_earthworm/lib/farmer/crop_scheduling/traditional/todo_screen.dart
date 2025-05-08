// // task_management.dart
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:collection/collection.dart';
// import 'crop_schedule.dart';
// import '../task_completion_slider.dart';

// // Task Screen
// class TaskScreen extends StatelessWidget {
//   final String crop;
//   final DateTime date;

//   const TaskScreen({
//     Key? key,
//     required this.crop,
//     required this.date,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       return const Center(child: Text('Please login to view tasks'));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$crop Tasks'),
//         backgroundColor: Colors.green[700],
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('completed_todo')
//             .doc(user.uid)
//             .snapshots(),
//         builder: (context, completedSnapshot) {
//           if (completedSnapshot.hasError) {
//             return Center(child: Text('Error: ${completedSnapshot.error}'));
//           }

//           final completedTasks = (completedSnapshot.data?.data()
//                       as Map<String, dynamic>?)?['completed_tasks']
//                   as List<dynamic>? ??
//               [];

//           final tasks = CropSchedulerHelper.getScheduleForCrop(crop, date, '');

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: tasks.length,
//             itemBuilder: (context, index) {
//               final task = tasks[index];
//               final taskId = '${crop}_${task['task']}_${task['date']}'
//                   .replaceAll(' ', '_');

//               if (completedTasks.contains(taskId)) {
//                 return const SizedBox.shrink();
//               }

//               return TaskCard(
//                 task: task,
//                 taskId: taskId,
//                 cropName: crop,
//               );
//             },
//           );
//         },
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => DetailedTaskScreen(
//                   crop: crop,
//                   date: date,
//                 ),
//               ),
//             );
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.green[700],
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           child: const Text(
//             'View Detailed Tasks',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Detailed Task Screen
// class DetailedTaskScreen extends StatelessWidget {
//   final String crop;
//   final DateTime date;

//   const DetailedTaskScreen({
//     Key? key,
//     required this.crop,
//     required this.date,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       return const Scaffold(
//         body: Center(child: Text('Please login to view tasks')),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$crop Task Details'),
//         backgroundColor: Colors.green[700],
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('completed_todo')
//             .doc(user.uid)
//             .snapshots(),
//         builder: (context, completedSnapshot) {
//           if (completedSnapshot.hasError) {
//             return Center(child: Text('Error: ${completedSnapshot.error}'));
//           }

//           final completedTasks = (completedSnapshot.data?.data()
//                       as Map<String, dynamic>?)?['completed_tasks']
//                   as List<dynamic>? ??
//               [];

//           final tasks = CropScheduleHelper.getScheduleForCrop(crop, date, '');

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: tasks.length,
//             itemBuilder: (context, index) {
//               final task = tasks[index];
//               final taskId = '${crop}_${task['task']}_${task['date']}'
//                   .replaceAll(' ', '_');

//               return AnimatedTaskCard(
//                 task: task,
//                 taskId: taskId,
//                 cropName: crop,
//                 isCompleted: completedTasks.contains(taskId),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// // Task Card
// class TaskCard extends StatelessWidget {
//   final Map<String, String> task;
//   final String taskId;
//   final String cropName;

//   const TaskCard({
//     Key? key,
//     required this.task,
//     required this.taskId,
//     required this.cropName,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               task['date']!,
//               style: TextStyle(
//                 color: Colors.green[700],
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               task['task']!,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Animated Task Card
// class AnimatedTaskCard extends StatefulWidget {
//   final Map<String, String> task;
//   final String taskId;
//   final String cropName;
//   final bool isCompleted;

//   const AnimatedTaskCard({
//     Key? key,
//     required this.task,
//     required this.taskId,
//     required this.cropName,
//     required this.isCompleted,
//   }) : super(key: key);

//   @override
//   State<AnimatedTaskCard> createState() => _AnimatedTaskCardState();
// }

// class _AnimatedTaskCardState extends State<AnimatedTaskCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//   bool _isVisible = true;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _animation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOut,
//     );

//     if (widget.isCompleted) {
//       _isVisible = false;
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _completeTask() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;

//       final userDocRef =
//           FirebaseFirestore.instance.collection('completed_todo').doc(user.uid);

//       final docSnapshot = await userDocRef.get();

//       if (docSnapshot.exists) {
//         await userDocRef.update({
//           'completed_tasks': FieldValue.arrayUnion([widget.taskId]),
//           'last_updated': FieldValue.serverTimestamp(),
//         });
//       } else {
//         await userDocRef.set({
//           'uid': user.uid,
//           'completed_tasks': [widget.taskId],
//           'last_updated': FieldValue.serverTimestamp(),
//         });
//       }

//       _controller.forward().then((_) {
//         setState(() => _isVisible = false);
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error completing task: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isVisible) return const SizedBox.shrink();

//     return FadeTransition(
//       opacity: ReverseAnimation(_animation),
//       child: SizeTransition(
//         sizeFactor: ReverseAnimation(_animation),
//         child: Card(
//           margin: const EdgeInsets.only(bottom: 16),
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.task['date']!,
//                   style: TextStyle(
//                     color: Colors.green[700],
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   widget.task['task']!,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TaskCompletionSlider(
//                   onComplete: _completeTask,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
