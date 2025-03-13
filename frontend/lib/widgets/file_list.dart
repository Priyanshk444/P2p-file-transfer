import 'package:flutter/material.dart';

class FileList extends StatefulWidget {
  const FileList({super.key});

  @override
  State<FileList> createState() => _FileListState();
}

class _FileListState extends State<FileList>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> fileStructure = [
    {"name": "notes.txt", "type": "file"},
    {"name": "blueprint.sketch", "type": "file"},
    {"name": "manual.pdf", "type": "file"},
    {
      "name": "Work",
      "type": "folder",
      "isExpanded": false,
      "children": [
        {"name": "task_list.docx", "type": "file"},
        {"name": "summary.pdf", "type": "file"},
        {
          "name": "Meetings",
          "type": "folder",
          "isExpanded": false,
          "children": [
            {"name": "agenda_q1.doc", "type": "file"},
            {"name": "minutes_q2.doc", "type": "file"},
          ],
        },
      ],
    },
    {
      "name": "Development",
      "type": "folder",
      "isExpanded": false,
      "children": [
        {
          "name": "Flutter Project",
          "type": "folder",
          "isExpanded": false,
          "children": [
            {"name": "home.dart", "type": "file"},
            {"name": "config.yaml", "type": "file"},
            {
              "name": "Flutter ",
              "type": "folder",
              "isExpanded": false,
              "children": [
                {"name": "home.dart", "type": "file"},
                {"name": "config.yaml", "type": "file"},
                {
                  "name": " Project",
                  "type": "folder",
                  "isExpanded": false,
                  "children": [
                    {"name": "home.dart", "type": "file"},
                    {"name": "config.yaml", "type": "file"},
                    {
                      "name": "Flutter Proj",
                      "type": "folder",
                      "isExpanded": false,
                      "children": [
                        {"name": "home.dart", "type": "file"},
                        {"name": "config.yaml", "type": "file"},
                        {
                          "name": "Flutter ject",
                          "type": "folder",
                          "isExpanded": false,
                          "children": [
                            {"name": "home.dart", "type": "file"},
                            {"name": "config.yaml", "type": "file"},
                          ],
                        },
                      ],
                    },
                  ],
                },
              ],
            },
          ],
        },
        {"name": "server.py", "type": "file"},
      ],
    },
    {
      "name": "Media",
      "type": "folder",
      "isExpanded": false,
      "children": [
        {"name": "track1.mp3", "type": "file"},
        {"name": "track2.mp3", "type": "file"},
      ],
    },
  ];

  String? _selectedItem;

  void toggleFolder(Map<String, dynamic> folder) {
    setState(() {
      folder["isExpanded"] = !(folder["isExpanded"] ?? false);
    });
  }

  Widget buildFileTree(List<Map<String, dynamic>> items, {int level = 0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        bool isSelected = _selectedItem == item["name"];
        bool isFolder = item["type"] == "folder";

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedItem = item["name"];
                  if (isFolder) {
                    toggleFolder(item);
                  }
                });
              },
              child: Container(
                margin: EdgeInsets.only(left: level * 25),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.teal.withOpacity(0.7)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    if (isFolder)
                      Icon(
                        item["isExpanded"]
                            ? Icons.arrow_drop_down
                            : Icons.arrow_right,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                    Icon(
                      isFolder
                          ? (item['isExpanded']
                              ? Icons.folder_open
                              : Icons.folder)
                          : Icons.insert_drive_file,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item["name"] + (isFolder ? "/" : ""),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade300,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isFolder)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topLeft,
                child: item["isExpanded"]
                    ? buildFileTree(
                        List<Map<String, dynamic>>.from(item["children"] ?? []),
                        level: level + 1,
                      )
                    : const SizedBox.shrink(),
              ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: buildFileTree(fileStructure),
      ),
    );
  }
}
