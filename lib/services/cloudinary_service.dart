import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class CloudinaryService {
  // Replace these with your actual Cloudinary credentials
  static const String _cloudName = 'dui8suv1b';
  static const String _uploadPreset = 'edushare_preset';

  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    _cloudName,
    _uploadPreset,
    cache: false,
  );

  /// Uploads an image file to Cloudinary and returns the secure URL.
  ///
  /// [file] is the XFile (from image_picker) to upload.
  /// [folder] is an optional folder name on Cloudinary.
  Future<String?> uploadImage(XFile file, {String? folder}) async {
    try {
      CloudinaryResponse response;

      if (kIsWeb) {
        // On Web, use bytes
        final bytes = await file.readAsBytes();
        response = await _cloudinary.uploadFile(
          CloudinaryFile.fromByteData(
            ByteData.view(
              bytes.buffer,
              bytes.offsetInBytes,
              bytes.lengthInBytes,
            ),
            identifier: file.name,
            resourceType: CloudinaryResourceType.Image,
            folder: folder,
          ),
        );
      } else {
        // On Mobile, path works
        response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            file.path,
            resourceType: CloudinaryResourceType.Image,
            folder: folder,
          ),
        );
      }

      return response.secureUrl;
    } on CloudinaryException catch (e) {
      if (kDebugMode) {
        print('Cloudinary Error: ${e.message}');
        print('Request: ${e.request}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Upload Error: $e');
        // Try to print more details if it's a DioException (though cloudinary_public abstracts it)
      }
      return null;
    }
  }
}
