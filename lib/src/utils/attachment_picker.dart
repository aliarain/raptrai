import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raptrai/src/providers/provider_types.dart';
import 'package:raptrai/src/theme/raptrai_colors.dart';

/// Utility class for picking attachments (images, files) on mobile.
///
/// Provides a bottom sheet UI with options to take a photo, pick from gallery,
/// or select a file.
class RaptrAIAttachmentPicker {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Show a bottom sheet with attachment options.
  ///
  /// Returns the selected [RaptrAIAttachment] or null if cancelled.
  static Future<RaptrAIAttachment?> showPicker(BuildContext context) async {
    return showModalBottomSheet<RaptrAIAttachment>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AttachmentPickerSheet(),
    );
  }

  /// Pick an image from the gallery.
  static Future<RaptrAIAttachment?> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return null;
      return _xFileToAttachment(image, RaptrAIAttachmentType.image);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Take a photo with the camera.
  static Future<RaptrAIAttachment?> takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image == null) return null;
      return _xFileToAttachment(image, RaptrAIAttachmentType.image);
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  /// Pick a file (PDF, documents, etc).
  static Future<RaptrAIAttachment?> pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'csv', 'json'],
      );
      if (result == null || result.files.isEmpty) return null;
      return _platformFileToAttachment(result.files.first);
    } catch (e) {
      debugPrint('Error picking file: $e');
      return null;
    }
  }

  /// Convert XFile to RaptrAIAttachment with base64 data.
  static Future<RaptrAIAttachment> _xFileToAttachment(
    XFile file,
    RaptrAIAttachmentType type,
  ) async {
    final bytes = await file.readAsBytes();
    final base64Data = base64Encode(bytes);
    final mimeType = _getMimeType(file.path);

    return RaptrAIAttachment(
      type: type,
      base64Data: base64Data,
      mimeType: mimeType,
      name: file.name,
      size: bytes.length,
    );
  }

  /// Convert PlatformFile to RaptrAIAttachment with base64 data.
  static Future<RaptrAIAttachment> _platformFileToAttachment(
    PlatformFile file,
  ) async {
    final path = file.path;
    if (path == null) {
      throw Exception('File path is null');
    }

    final bytes = await File(path).readAsBytes();
    final base64Data = base64Encode(bytes);
    final mimeType = _getMimeType(path);
    final type = _getAttachmentType(file.extension ?? '');

    return RaptrAIAttachment(
      type: type,
      base64Data: base64Data,
      mimeType: mimeType,
      name: file.name,
      size: bytes.length,
    );
  }

  /// Get MIME type from file path.
  static String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      case 'csv':
        return 'text/csv';
      case 'json':
        return 'application/json';
      default:
        return 'application/octet-stream';
    }
  }

  /// Get attachment type from file extension.
  static RaptrAIAttachmentType _getAttachmentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return RaptrAIAttachmentType.image;
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'txt':
      case 'csv':
        return RaptrAIAttachmentType.document;
      case 'mp3':
      case 'wav':
      case 'm4a':
        return RaptrAIAttachmentType.audio;
      case 'mp4':
      case 'mov':
      case 'avi':
        return RaptrAIAttachmentType.video;
      default:
        return RaptrAIAttachmentType.file;
    }
  }
}

/// Bottom sheet widget for attachment picker.
class _AttachmentPickerSheet extends StatelessWidget {
  const _AttachmentPickerSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? RaptrAIColors.zinc900 : Colors.white;
    final textColor = isDark ? RaptrAIColors.zinc100 : RaptrAIColors.zinc900;
    final subtitleColor = isDark ? RaptrAIColors.zinc400 : RaptrAIColors.zinc600;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? RaptrAIColors.zinc700 : RaptrAIColors.zinc300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Add Attachment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            // Options
            _PickerOption(
              icon: Icons.camera_alt_outlined,
              label: 'Camera',
              subtitle: 'Take a photo',
              onTap: () async {
                final attachment = await RaptrAIAttachmentPicker.takePhoto();
                if (context.mounted) {
                  Navigator.of(context).pop(attachment);
                }
              },
            ),
            _PickerOption(
              icon: Icons.photo_library_outlined,
              label: 'Photo Library',
              subtitle: 'Choose from gallery',
              onTap: () async {
                final attachment = await RaptrAIAttachmentPicker.pickImage();
                if (context.mounted) {
                  Navigator.of(context).pop(attachment);
                }
              },
            ),
            _PickerOption(
              icon: Icons.insert_drive_file_outlined,
              label: 'File',
              subtitle: 'PDF, documents, and more',
              onTap: () async {
                final attachment = await RaptrAIAttachmentPicker.pickFile();
                if (context.mounted) {
                  Navigator.of(context).pop(attachment);
                }
              },
            ),
            const SizedBox(height: 8),
            // Cancel button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: subtitleColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? RaptrAIColors.zinc100 : RaptrAIColors.zinc900;
    final subtitleColor = isDark ? RaptrAIColors.zinc400 : RaptrAIColors.zinc600;
    final iconBgColor = isDark ? RaptrAIColors.zinc800 : RaptrAIColors.zinc100;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: RaptrAIColors.accent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: subtitleColor,
            ),
          ],
        ),
      ),
    );
  }
}
