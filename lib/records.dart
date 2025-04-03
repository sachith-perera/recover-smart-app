import 'package:flutter/material.dart';
import './components/sidebar.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'dart:io';

class Records extends StatefulWidget {
  const Records({super.key});

  @override
  State<Records> createState() => _RecordsState();
}

class _RecordsState extends State<Records> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    final picker = image_picker.ImagePicker();
    final pickedFile = await picker.pickImage(
      source: image_picker.ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 181, 207, 232),
      appBar: AppBar(title: Text("Records")),
      drawer: Sidebar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(
                    // color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This is a dummy paragraph. It contains some placeholder text to represent the description of the medication.',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Upload records',
                  style: TextStyle(
                    // color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      // color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _selectedFile == null
                            ? 'Tap to upload records'
                            : 'File selected',
                        style: const TextStyle(
                          // color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Accepted formats: docs, pdf, images, jpgs',
                  // style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Upload action
                    },
                    child: const Text('Upload'),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Write notes here...',
                    // filled: true,
                    // fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Submit action
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
