import 'package:door/services/api_client.dart';
import 'package:door/services/models/api_response.dart';
import 'package:door/services/models/pharmacy_models.dart';
import 'package:http/http.dart' as http;

class PharmacyProductService {
  final ApiClient _client = ApiClient();

  // GET /api/pharmacy/products
  Future<ApiResponse<ProductsResponse>> getProducts({
    String? search,
    String? category,
    bool? isPrescriptionRequired,
    double? minPrice,
    double? maxPrice,
    String? status,
    int page = 1,
    int limit = 20,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (isPrescriptionRequired != null) {
        queryParams['isPrescriptionRequired'] = isPrescriptionRequired.toString();
      }
      if (minPrice != null) {
        queryParams['minPrice'] = minPrice.toString();
      }
      if (maxPrice != null) {
        queryParams['maxPrice'] = maxPrice.toString();
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _client.get(
        '/pharmacy/products',
        queryParams: queryParams,
        includeAuth: false, // Public endpoint
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<ProductsResponse>(
          success: true,
          data: ProductsResponse.fromJson(data['data'] ?? {}),
        );
      } else {
        return ApiResponse<ProductsResponse>(
          success: false,
          message: data['message'] ?? 'Failed to fetch products',
        );
      }
    } catch (e) {
      return ApiResponse<ProductsResponse>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // GET /api/pharmacy/products/:productId
  Future<ApiResponse<PharmacyProduct>> getProductById(String productId) async {
    try {
      final response = await _client.get(
        '/pharmacy/products/$productId',
        includeAuth: false, // Public endpoint
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<PharmacyProduct>(
          success: true,
          data: PharmacyProduct.fromJson(data['data'] ?? {}),
        );
      } else {
        return ApiResponse<PharmacyProduct>(
          success: false,
          message: data['message'] ?? 'Failed to fetch product',
        );
      }
    } catch (e) {
      return ApiResponse<PharmacyProduct>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // POST /api/pharmacy/products (Admin only)
  Future<ApiResponse<PharmacyProduct>> createProduct({
    required String name,
    required double price,
    String? sku,
    String? description,
    String? category,
    String? brand,
    String? dosageForm,
    String? strength,
    List<String>? tags,
    double? mrp,
    double? discountPercent,
    int stock = 0,
    bool isPrescriptionRequired = false,
    List<http.MultipartFile>? images,
  }) async {
    try {
      final fields = <String, String>{
        'name': name,
        'price': price.toString(),
        'stock': stock.toString(),
        'isPrescriptionRequired': isPrescriptionRequired.toString(),
      };

      if (sku != null && sku.isNotEmpty) {
        fields['sku'] = sku;
      }
      if (description != null && description.isNotEmpty) {
        fields['description'] = description;
      }
      if (category != null && category.isNotEmpty) {
        fields['category'] = category;
      }
      if (brand != null && brand.isNotEmpty) {
        fields['brand'] = brand;
      }
      if (dosageForm != null && dosageForm.isNotEmpty) {
        fields['dosageForm'] = dosageForm;
      }
      if (strength != null && strength.isNotEmpty) {
        fields['strength'] = strength;
      }
      if (tags != null && tags.isNotEmpty) {
        fields['tags'] = tags.toString(); // Will be parsed on backend
      }
      if (mrp != null) {
        fields['mrp'] = mrp.toString();
      }
      if (discountPercent != null) {
        fields['discountPercent'] = discountPercent.toString();
      }

      final files = images != null ? {'images': images} : null;

      final response = await _client.postMultipart(
        '/pharmacy/products',
        fields: fields,
        files: files,
        includeAuth: true, // Admin only
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 201 && data['success'] == true) {
        return ApiResponse<PharmacyProduct>(
          success: true,
          message: data['message'],
          data: PharmacyProduct.fromJson(data['data'] ?? {}),
        );
      } else {
        return ApiResponse<PharmacyProduct>(
          success: false,
          message: data['message'] ?? 'Failed to create product',
          errors: data['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<PharmacyProduct>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // PUT /api/pharmacy/products/:productId (Admin only)
  Future<ApiResponse<PharmacyProduct>> updateProduct(
    String productId, {
    String? name,
    String? sku,
    String? description,
    String? category,
    String? brand,
    String? dosageForm,
    String? strength,
    List<String>? tags,
    double? price,
    double? mrp,
    double? discountPercent,
    int? stock,
    String? status,
    bool? isPrescriptionRequired,
    List<String>? removeImageFilenames,
    List<http.MultipartFile>? images,
  }) async {
    try {
      final fields = <String, String>{};

      if (name != null) fields['name'] = name;
      if (sku != null) fields['sku'] = sku;
      if (description != null) fields['description'] = description;
      if (category != null) fields['category'] = category;
      if (brand != null) fields['brand'] = brand;
      if (dosageForm != null) fields['dosageForm'] = dosageForm;
      if (strength != null) fields['strength'] = strength;
      if (tags != null) fields['tags'] = tags.toString();
      if (price != null) fields['price'] = price.toString();
      if (mrp != null) fields['mrp'] = mrp.toString();
      if (discountPercent != null) {
        fields['discountPercent'] = discountPercent.toString();
      }
      if (stock != null) fields['stock'] = stock.toString();
      if (status != null) fields['status'] = status;
      if (isPrescriptionRequired != null) {
        fields['isPrescriptionRequired'] = isPrescriptionRequired.toString();
      }
      if (removeImageFilenames != null && removeImageFilenames.isNotEmpty) {
        fields['removeImageFilenames'] = removeImageFilenames.toString();
      }

      final files = images != null ? {'images': images} : null;

      // Use multipart for PUT as well (backend expects form-data)
      // We need to use http package directly for PUT multipart
      final uri = Uri.parse('${_client.baseUrl}/pharmacy/products/$productId');
      final request = http.MultipartRequest('PUT', uri);

      // Add headers (get token manually)
      final token = await _client.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add fields
      request.fields.addAll(fields);

      // Add files
      if (files != null) {
        request.files.addAll(files.values.expand((fileList) => fileList));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<PharmacyProduct>(
          success: true,
          message: data['message'],
          data: PharmacyProduct.fromJson(data['data'] ?? {}),
        );
      } else {
        return ApiResponse<PharmacyProduct>(
          success: false,
          message: data['message'] ?? 'Failed to update product',
          errors: data['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<PharmacyProduct>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // DELETE /api/pharmacy/products/:productId (Admin only)
  Future<ApiResponse<void>> archiveProduct(String productId) async {
    try {
      final response = await _client.delete(
        '/pharmacy/products/$productId',
        includeAuth: true, // Admin only
      );

      final data = _client.parseResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<void>(
          success: true,
          message: data['message'],
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: data['message'] ?? 'Failed to archive product',
        );
      }
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: e.toString(),
      );
    }
  }
}

