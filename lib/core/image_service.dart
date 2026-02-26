import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';

class ImageService {
  final CloudinaryService _cloudinaryService = CloudinaryService();

  /// Uploads an image to Cloudinary and returns the secure URL.
  Future<String?> uploadImage(XFile imageFile, String folder) async {
    return await _cloudinaryService.uploadImage(imageFile, folder: folder);
  }
}
