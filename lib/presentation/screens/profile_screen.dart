import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/user_provider.dart';
import 'package:gap/gap.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final notifier = ref.read(userProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: colorScheme.surfaceContainer,
                  backgroundImage: user.imagePath != null
                      ? FileImage(File(user.imagePath!))
                      : null,
                  child: user.imagePath == null
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton.filled(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        notifier.updateImage(image.path);
                      }
                    },
                    icon: const Icon(Icons.camera_alt),
                  ),
                ),
              ],
            ),
          ),
          const Gap(24),
          ListTile(
            title: const Text('Display Name'),
            subtitle: Text(user.name, style: const TextStyle(fontSize: 18)),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final controller = TextEditingController(text: user.name);
                final newName = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Edit Name'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, controller.text),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );
                if (newName != null && newName.isNotEmpty) {
                  notifier.updateName(newName);
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Preferred Calculator Mode'),
            subtitle: Text(user.preferredMode),
            trailing: DropdownButton<String>(
              value: user.preferredMode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'Standard', child: Text('Standard')),
                DropdownMenuItem(
                  value: 'Scientific',
                  child: Text('Scientific'),
                ),
              ],
              onChanged: (val) {
                if (val != null) notifier.updatePreferredMode(val);
              },
            ),
          ),
        ],
      ),
    );
  }
}
