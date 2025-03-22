import 'package:flutter/material.dart';

class FileList extends StatefulWidget {
  const FileList({super.key, required this.fileList});
  final List<Map<String, dynamic>> fileList;

  @override
  State<FileList> createState() => _FileListState();
}

class _FileListState extends State<FileList> with TickerProviderStateMixin {
  late List<Map<String, dynamic>> fileStructure;

  @override
  void initState() {
    super.initState();
    fileStructure = convertToNestedStructure(widget.fileList);
  }

  List<Map<String, dynamic>> convertToNestedStructure(
      List<Map<String, dynamic>> fileList) {
    // Helper function to create nested folder structure recursively
    void addToNestedStructure(Map<String, dynamic> currentFolder,
        List<String> pathParts, String name, String type) {
      if (pathParts.isEmpty) return;

      String currentPart = pathParts.removeAt(0);

      bool isFile =
          currentPart.contains('.'); // Check if it's a file by extension

      if (pathParts.isEmpty && isFile) {
        (currentFolder['children'] ??= []).add({
          "name": currentPart,
          "fileType": "file",
        });
        return;
      }

      // Find or create folder in the current structure
      Map<String, dynamic> folder = currentFolder['children']?.firstWhere(
        (child) =>
            child['name'] == currentPart && child['fileType'] == "folder",
        orElse: () {
          Map<String, dynamic> newFolder = {
            "name": currentPart,
            "fileType": "folder",
            "isExpanded": false,
            "children": [],
          };
          (currentFolder['children'] ??= []).add(newFolder);
          return newFolder;
        },
      );

      addToNestedStructure(folder, pathParts, name, type);
    }

    List<Map<String, dynamic>> result = [];

    // Traverse the file list and build the nested structure
    for (var file in fileList) {
      List<String> pathParts =
          file['path'].split('\\'); // Split using backslash
      String name = file['name'];
      String type = file['fileType']; // Correct key for file type

      if (pathParts.length == 1) {
        // Top-level file or folder
        if (type == "file" || name.contains('.')) {
          result.add({"name": name, "fileType": "file"});
        } else {
          result.add({
            "name": name,
            "fileType": "folder",
            "isExpanded": false,
            "children": []
          });
        }
      } else {
        // Nested files or folders
        String rootFolder = pathParts.removeAt(0);
        Map<String, dynamic> folder = result.firstWhere(
          (item) => item['name'] == rootFolder && item['fileType'] == "folder",
          orElse: () {
            Map<String, dynamic> newFolder = {
              "name": rootFolder,
              "fileType": "folder",
              "isExpanded": false,
              "children": [],
            };
            result.add(newFolder);
            return newFolder;
          },
        );

        addToNestedStructure(folder, pathParts, name, type);
      }
    }

    return result;
  }

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
        bool isFolder = item["fileType"] == "folder"; // Use updated key

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
      scrollDirection: Axis.horizontal, // Allow horizontal scrolling
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical, // Allow vertical scrolling
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: buildFileTree(fileStructure),
        ),
      ),
    );
  }
}