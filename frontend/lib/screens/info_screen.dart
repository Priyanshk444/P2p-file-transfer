import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:p2p/screens/home_screen.dart';
import 'package:p2p/screens/socket_service.dart';
import 'dart:io';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 54, 54, 54),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Basic Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Center(
                child: FormContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FormContent extends StatefulWidget {
  const FormContent({super.key});

  @override
  State<FormContent> createState() => _FormContentState();
}

class _FormContentState extends State<FormContent> {
  final TextEditingController _shareFolderPath = TextEditingController();
  final TextEditingController _receiveFolderPath = TextEditingController();
  final TextEditingController _serverIP = TextEditingController();
  final TextEditingController _userName = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  SocketService socketService = SocketService();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
      child: SingleChildScrollView(
        child: SizedBox(
          height: 400,
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  ' Username',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  child: TextFormField(
                    controller: _userName,
                    decoration: InputDecoration(
                      hintText: "Enter Username",
                      hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 159, 159, 159)),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 45, 45, 45),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 24, 24, 24)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 220, 188, 255)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 201, 156, 153),
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 201, 156, 153),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username cannot be empty';
                      }
                      if (value.length < 3) {
                        return 'Username must be at least 3 characters long';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  ' Server IP',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  child: TextFormField(
                    controller: _serverIP,
                    decoration: InputDecoration(
                      hintText: "Enter Server IP",
                      hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 159, 159, 159)),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 45, 45, 45),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 24, 24, 24)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 220, 188, 255)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 201, 156, 153),
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 201, 156, 153),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an IP address';
                      }
                      final ipRegex = RegExp(
                          r'^((25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)$');
                      if (!ipRegex.hasMatch(value)) {
                        return 'Please enter a valid IP address';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  ' Share Folder Path',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: TextFormField(
                          controller: _shareFolderPath,
                          decoration: InputDecoration(
                            hintText: "Enter Share Folder Path",
                            hintStyle: const TextStyle(
                                color: Color.fromARGB(255, 159, 159, 159)),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 45, 45, 45),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 24, 24, 24)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 220, 188, 255),
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 201, 156, 153),
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 201, 156, 153),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Share folder path cannot be empty';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _selectFolder(_shareFolderPath);
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(100, 48),
                        backgroundColor: const Color.fromARGB(255, 54, 54, 54),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 32.0),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              color: Color.fromARGB(255, 24, 24, 24)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        "Open",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  ' Recieve Folder Path',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: TextFormField(
                          controller: _receiveFolderPath,
                          decoration: InputDecoration(
                            hintText: "Enter Receive Folder Path",
                            hintStyle: const TextStyle(
                                color: Color.fromARGB(255, 159, 159, 159)),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 45, 45, 45),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 24, 24, 24)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 220, 188, 255),
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 201, 156, 153),
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 201, 156, 153),
                              ),
                            ),
                          ),
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Receive folder path cannot be empty';
                          //   }
                          //   return null;
                          // },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _selectFolder(_receiveFolderPath);
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(100, 48),
                        backgroundColor: const Color.fromARGB(255, 54, 54, 54),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 32.0),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              color: Color.fromARGB(255, 24, 24, 24)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        "Open",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // socketService.connect();
                    // if (socketRef == null) {
                    //   print("socket not defined");
                    // }
                    // socketRef.emit("register", {
                    //   "username": _userName.text,
                    //   "fileList": getFolderContents(_shareFolderPath.text),
                    //   "ip": await getLocalIPAddress()
                    //   // "recieveFolder" : _receiveFolderPath.text,
                    // });
                    appWindow.size = const Size(1000, 800);
                    appWindow.minSize = const Size(1000, 800);
                    appWindow.alignment = Alignment.center;
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const HomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(400, 38),
                    backgroundColor: const Color.fromARGB(255, 54, 54, 54),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 32.0),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          color: Color.fromARGB(255, 24, 24, 24)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // void _submitForm() {
  //   final socket = IO.io('ws://192.168.66.45:9000', <String, dynamic>{
  //     'transports': ['websocket'],
  //     'autoConnect': true,
  //   });

  //   socket.on('connect', (_) {
  //     print('Connected to server with socket ID: ${socket.id}');
  //   });

  //   socket.on('connect_error', (err) {
  //     print('Connection error: ${err.toString()}');
  //   });

  //   socket.on('disconnect', (_) {
  //     print('Disconnected from server.');
  //   });
  // }

  Future<String> getLocalIPAddress() async {
    List<NetworkInterface> interfaces = await NetworkInterface.list();

    for (var interface in interfaces) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
          print(addr.address);
          return addr.address;
        }
      }
    }
    return "Unable to determine IP address";
  }

  List<Map<String, String>> getFolderContents(String folderPath) {
    List<Map<String, String>> results = [];

    try {
      Directory folder = Directory(folderPath);
      List<FileSystemEntity> entities = folder.listSync();

      for (var entity in entities) {
        FileStat stats = entity.statSync();
        String type =
            stats.type == FileSystemEntityType.directory ? "folder" : "file";

        results.add({
          "name": entity.uri.pathSegments.last,
          "path": entity.path,
          "type": type,
        });

        // If it's a folder, call recursively
        if (type == "folder") {
          results.addAll(getFolderContents(entity.path));
        }
      }
    } catch (e) {
      print("Error reading folder: $e");
    }

    return results;
  }

  Future<void> _selectFolder(TextEditingController controller) async {
    String? selectedFolder = await FilePicker.platform.getDirectoryPath();

    if (selectedFolder != null) {
      setState(() {
        controller.text = selectedFolder;
      });
    } else {
      print("No folder selected.");
    }
  }
}
