import 'package:flutter/material.dart';

class SearchFileDialog extends StatefulWidget {
  const SearchFileDialog({super.key});

  @override
  State<SearchFileDialog> createState() => _SearchFileDialogState();
}

class _SearchFileDialogState extends State<SearchFileDialog> {
  final TextEditingController _searchController = TextEditingController();
  String selectedFileName = "";
  List<Map<String, dynamic>> allFiles = [
    {
      'name': 'JetBrainsMono-2.242.zip',
      'type': 'file',
      'owner': 'harsh',
      'size': '3.91 MB'
    },
    {
      'name': 'FlutterGuide.pdf',
      'type': 'file',
      'owner': 'john',
      'size': '1.2 MB'
    },
    {
      'name': 'NodeJS_Tutorial.docx',
      'type': 'file',
      'owner': 'mark',
      'size': '3.5 MB'
    },
    {
      'name': 'React_Code.zip',
      'type': 'file',
      'owner': 'alice',
      'size': '5.0 MB'
    },
    {
      'name': 'Database_Design.pptx',
      'type': 'file',
      'owner': 'harsh',
      'size': '8.1 MB'
    },
    {
      'name': 'DesignPatternsBook.epub',
      'type': 'file',
      'owner': 'mike',
      'size': '2.4 MB'
    },
    {
      'name': 'DockerEssentials.pdf',
      'type': 'file',
      'owner': 'harsh',
      'size': '4.8 MB'
    },
    {
      'name': 'Networking_Tools.zip',
      'type': 'file',
      'owner': 'anna',
      'size': '6.2 MB'
    },
    {
      'name': 'JetBrainsMono-2.242_1.zip',
      'type': 'file',
      'owner': 'harsh',
      'size': '3.91 MB'
    },
    {
      'name': 'System_Architecture.ppt',
      'type': 'file',
      'owner': 'emma',
      'size': '7.4 MB'
    },
    {
      'name': 'Guide_to_Linux.pdf',
      'type': 'file',
      'owner': 'chris',
      'size': '3.0 MB'
    },
    {
      'name': 'GraphQL_Tutorial.docx',
      'type': 'file',
      'owner': 'kate',
      'size': '5.5 MB'
    },
    {
      'name': 'Kotlin_Coding_Tips.zip',
      'type': 'file',
      'owner': 'max',
      'size': '4.1 MB'
    },
  ];

  List<Map<String, dynamic>> filteredFiles = []; // For filtered search results

  @override
  void initState() {
    super.initState();
    filteredFiles;
  }

  void _filterFiles() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredFiles = allFiles.where((file) {
        return file['name'].toLowerCase().contains(query) ||
            file['owner'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 54, 54, 54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 35,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 32, 32, 32),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(5), topLeft: Radius.circular(5)),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Global Search",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 15,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search for files among your peers',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 35,
                          child: TextFormField(
                            controller: _searchController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color.fromARGB(255, 45, 45, 45),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    const BorderSide(color: Colors.black),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    const BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      _button('Search', _filterFiles),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
                    height: 400,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: IntrinsicWidth(
                          child: DataTable(
                            headingRowHeight: 30,
                            columnSpacing: 30,
                            dataRowMinHeight: 30,
                            dataRowMaxHeight: 30,
                            border: TableBorder.symmetric(
                              inside: const BorderSide(
                                  color: Colors.black, width: 1),
                              outside: const BorderSide(
                                  color: Colors.black, width: 1),
                            ),
                            columns: const [
                              DataColumn(
                                label: SizedBox(
                                  width: 300,
                                  child: Text('Item',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: 50,
                                  child: Text('Type',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: 50,
                                  child: Text('Owner',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: 60,
                                  child: Text('Size',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                            rows: filteredFiles.map((file) {
                              final isSelected =
                                  selectedFileName == file['name'];
                              return DataRow(
                                selected: isSelected,
                                color: WidgetStateProperty.resolveWith<Color?>(
                                  (states) {
                                    if (isSelected) {
                                      return Colors.teal.withAlpha((0.6 * 255)
                                          .toInt()); // Selected color
                                    }
                                    return null; // Default color
                                  },
                                ),
                                onSelectChanged: (data) {
                                  setState(() {
                                    selectedFileName = file['name'];
                                  });
                                },
                                cells: [
                                  DataCell(
                                    Text(
                                      file['name'],
                                      style: const TextStyle(
                                          color: Colors.white),
                                    ),
                                  ),
                                  DataCell(
                                    Text(file['type'],
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ),
                                  DataCell(
                                    Text(file['owner'],
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ),
                                  DataCell(
                                    Text(file['size'],
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _button('Download', () {}),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _button(String title, VoidCallback? onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 54, 54, 54),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color.fromARGB(255, 24, 24, 24)),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Text(title, style: const TextStyle(color: Colors.white)),
    );
  }
}
