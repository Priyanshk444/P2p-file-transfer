import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:p2p/screens/socket_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:p2p/widgets/message_bubble.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  late TabController _tabController;
  List<dynamic> messages = [];
  // SocketService socketService = SocketService();
  String selectedFolder = "";
  String selectedFile = "";

  @override
  void initState() {
    super.initState();
    // fetchMessages();
    _getUsers();
    // _getUserFiles();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SocketService>(context, listen: false).connect();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 54, 54, 54),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'P2P / Mahil',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                _button("Global Search", () {}),
                SizedBox(width: 10),
                _button("Import Files", () {
                  _pickFile();
                }),
                SizedBox(width: 10),
                _button("Import Folders", () {
                  _selectFolder();
                }),
                SizedBox(width: 10),
                _button("Settings", () {}),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Browse Files',
                                style: TextStyle(color: Colors.white)),
                            SizedBox(width: 9),
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 54, 54, 54),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: Color.fromARGB(255, 24, 24, 24)),
                              ),
                              child: Icon(Icons.refresh,
                                  size: 16, color: Colors.white),
                            )
                          ],
                        ),
                        SizedBox(height: 10),
                        _infoContainer('No user selected', height: 26),
                        SizedBox(height: 10),
                        Expanded(child: _infoContainer('', height: null)),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                                child: Text('No file or folder selected',
                                    style: TextStyle(color: Colors.white))),
                            _button("Info", () {}),
                            SizedBox(width: 10),
                            _button("Download", () {}),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Users', style: TextStyle(color: Colors.white)),
                        SizedBox(height: 10),
                        _infoContainer('', height: size.height * 0.2),
                        SizedBox(height: 10),
                        DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 45, 45, 45),
                                  border: Border.all(
                                      color: Color.fromARGB(255, 24, 24, 24)),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  labelColor: Colors.white,
                                  unselectedLabelColor:
                                      Color.fromARGB(255, 159, 159, 159),
                                  indicatorColor: Colors.blue,
                                  tabs: [
                                    Tab(text: "Group Chat"),
                                    Tab(text: "Private Chat"),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(),
                                height: size.height * 0.26,
                                child: TabBarView(
                                  children: [
                                    Container(
                                      height: size.height * 0.26,
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(255, 45, 45, 45),
                                        border: Border.all(
                                          color:
                                              Color.fromARGB(255, 24, 24, 24),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                              padding: EdgeInsets.all(8),
                                              itemCount:
                                                  socketService.messages.length,
                                              itemBuilder: (context, index) {
                                                final message = socketService
                                                    .messages[index];
                                                bool isMe = message['sender'] ==
                                                    'Mahil';
                                                return Align(
                                                  alignment: isMe
                                                      ? Alignment.centerRight
                                                      : Alignment.centerLeft,
                                                  child: MessageBubble(
                                                    username: 'Mahil',
                                                    message:
                                                        message['message']!,
                                                    isMe: isMe,
                                                    time: TimeOfDay.now(),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _infoContainer(
                                      '',
                                      height: size.height * 0.2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 80,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 45, 45, 45),
                                  border: Border.all(
                                    color: Color.fromARGB(255, 24, 24, 24),
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                alignment: Alignment.topRight,
                                child: TextField(
                                  style: const TextStyle(color: Colors.white),
                                  controller: _messageController,
                                  autocorrect: true,
                                  enableSuggestions: true,
                                  minLines: 1,
                                  maxLines: 3,
                                  textAlign: TextAlign.left,
                                  textAlignVertical: TextAlignVertical.top,
                                  decoration: InputDecoration(
                                    hintText: 'Send a message',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Column(
                              children: [
                                _button(
                                  "Send Message",
                                  () {
                                    if (_messageController.text
                                        .trim()
                                        .isEmpty) {
                                      return;
                                    }
                                    setState(() {
                                      socketService.messages.add({
                                        'sender': 'Mahil',
                                        'message':
                                            _messageController.text.trim(),
                                        'isMe': true,
                                        'time': TimeOfDay.now(),
                                      });
                                    });
                                    socketService
                                        .sendMessage(_messageController.text);
                                    _messageController.clear();
                                  },
                                ),
                                SizedBox(height: 10),
                                _button("    Send File    ", () {},
                                    tabIndex: _tabController.index),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text('Downloading :', style: TextStyle(color: Colors.white)),
            SizedBox(height: 5),
            _infoContainer('', height: 115),
          ],
        ),
      ),
    );
  }

  // Function to fetch messages
  // Future<void> _fetchMessages() async {
  //   const String url = 'http://192.168.66.59:9000/api/users/groupMessages/';

  //   try {
  //     final response = await http.get(Uri.parse(url));

  //     if (response.statusCode == 200) {
  //       setState(() {
  //         messages = json.decode(response.body);
  //       });
  //     } else {
  //       throw Exception('Failed to load messages');
  //     }
  //   } catch (e) {
  //     print('Error fetching messages: $e');
  //   }
  // }

  Future<void> _selectFolder() async {
    String? result = await FilePicker.platform.getDirectoryPath();

    if (result != null) {
      setState(() {
        selectedFolder = result;
      });
    } else {
      print("No folder selected.");
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      selectedFile = result.files.single.path!;
    } else {
      print("No file selected.");
    }
  }

  Widget _button(String title, VoidCallback? onTap, {int? tabIndex}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 54, 54, 54),
        overlayColor: title == "    Send File    " && tabIndex == 0
            ? Colors.transparent
            : Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color.fromARGB(255, 24, 24, 24)),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: title == "    Send File    " && tabIndex == 0
              ? Color.fromARGB(255, 159, 159, 159)
              : Colors.white,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _infoContainer(String text, {double? height}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 45, 45, 45),
        border: Border.all(color: Color.fromARGB(255, 24, 24, 24)),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: 10, vertical: height == null ? 10 : 0),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(color: Color.fromARGB(255, 159, 159, 159)),
      ),
    );
  }

  void _getUsers() async {
    final url = Uri.parse('http://192.168.67.93:9000/api/users/users'); 
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Data: $data');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void _getUserFiles() async {
    final url = Uri.parse('http://192.168.67.93:9000/api/users/files'); 
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Data: $data');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }
}
