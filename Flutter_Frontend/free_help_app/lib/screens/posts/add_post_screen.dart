import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/api_service.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  String postType = "food";
  int radius = 2;

  final ImagePicker _picker = ImagePicker();
  List<File> selectedImages = [];

  bool isActive = true;
  DateTime? eventTime;

  bool isSubmitting = false;

  // -------------------------------
  // 📷 PICK IMAGES (MAX 3)
  // -------------------------------
  Future<void> pickImages() async {
    if (selectedImages.length >= 3) return;

    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles == null) return;

    setState(() {
      selectedImages.addAll(
        pickedFiles.take(3 - selectedImages.length).map((e) => File(e.path)),
      );
    });
  }

  // -------------------------------
  // ⏰ EVENT TIME PICKER
  // -------------------------------
  Future<void> pickEventTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    setState(() {
      eventTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  // -------------------------------
  // 🚀 SUBMIT POST
  // -------------------------------
  Future<void> submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    if (!isActive && eventTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select event time for scheduled post"),
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await ApiService.createPost(
        postType: postType,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        latitude: 0.0, // will be replaced by LocationService
        longitude: 0.0,
        radius: radius,
        images: selectedImages,
        isActive: isActive,
        eventTime: eventTime,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // -------------------------------
  // 🧱 UI
  // -------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: postType,
                decoration: const InputDecoration(labelText: "Post Type"),
                items: const [
                  DropdownMenuItem(value: "food", child: Text("Food")),
                  DropdownMenuItem(value: "help", child: Text("Help")),
                  DropdownMenuItem(value: "event", child: Text("Event")),
                ],
                onChanged: (value) => setState(() => postType = value!),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Title required" : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? "Description required"
                    : null,
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: pickImages,
                icon: const Icon(Icons.image),
                label: Text("Add Images (${selectedImages.length}/3)"),
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                children: selectedImages.map((img) {
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(img, width: 90, height: 90, fit: BoxFit.cover),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          setState(() => selectedImages.remove(img));
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              SwitchListTile(
                title: const Text("Post is active now"),
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    isActive = value;
                    if (isActive) eventTime = null;
                  });
                },
              ),

              if (!isActive)
                ListTile(
                  title: Text(
                    eventTime == null
                        ? "Select Event Time"
                        : "Event Time: ${eventTime!.day}/${eventTime!.month}/${eventTime!.year} "
                              "${eventTime!.hour}:${eventTime!.minute.toString().padLeft(2, '0')}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: pickEventTime,
                ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isSubmitting ? null : submitPost,
                child: isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text("Create Post"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
