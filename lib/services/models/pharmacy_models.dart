class PharmacyProduct {
  final String id;
  final String name;
  final String? sku;
  final String? description;
  final String? category;
  final String? brand;
  final String? dosageForm;
  final String? strength;
  final List<String>? tags;
  final double price;
  final double? mrp;
  final double? discountPercent;
  final int stock;
  final List<ProductImage>? images;
  final bool isPrescriptionRequired;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PharmacyProduct({
    required this.id,
    required this.name,
    this.sku,
    this.description,
    this.category,
    this.brand,
    this.dosageForm,
    this.strength,
    this.tags,
    required this.price,
    this.mrp,
    this.discountPercent,
    required this.stock,
    this.images,
    required this.isPrescriptionRequired,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory PharmacyProduct.fromJson(Map<String, dynamic> json) {
    return PharmacyProduct(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      sku: json['sku'],
      description: json['description'],
      category: json['category'],
      brand: json['brand'],
      dosageForm: json['dosageForm'],
      strength: json['strength'],
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : null,
      price: (json['price'] ?? 0).toDouble(),
      mrp: json['mrp'] != null ? (json['mrp'] as num).toDouble() : null,
      discountPercent: json['discountPercent'] != null
          ? (json['discountPercent'] as num).toDouble()
          : null,
      stock: json['stock'] ?? 0,
      images: json['images'] != null
          ? (json['images'] as List)
              .map((img) => ProductImage.fromJson(img))
              .toList()
          : null,
      isPrescriptionRequired: json['isPrescriptionRequired'] ?? false,
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'sku': sku,
      'description': description,
      'category': category,
      'brand': brand,
      'dosageForm': dosageForm,
      'strength': strength,
      'tags': tags,
      'price': price,
      'mrp': mrp,
      'discountPercent': discountPercent,
      'stock': stock,
      'images': images?.map((img) => img.toJson()).toList(),
      'isPrescriptionRequired': isPrescriptionRequired,
      'status': status,
    };
  }

  String get imageUrl {
    if (images != null && images!.isNotEmpty) {
      final image = images!.first;
      // If it's a relative path, we'll need to prepend base URL in the UI
      return image.url;
    }
    return '';
  }

  double get effectivePrice {
    if (discountPercent != null && discountPercent! > 0) {
      return price * (1 - discountPercent! / 100);
    }
    return price;
  }
}

class ProductImage {
  final String url;
  final String filename;
  final String? mimetype;
  final int? size;

  ProductImage({
    required this.url,
    required this.filename,
    this.mimetype,
    this.size,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      url: json['url'] ?? '',
      filename: json['filename'] ?? '',
      mimetype: json['mimetype'],
      size: json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'filename': filename,
      'mimetype': mimetype,
      'size': size,
    };
  }
}

class ProductsResponse {
  final List<PharmacyProduct> items;
  final PaginationInfo pagination;

  ProductsResponse({
    required this.items,
    required this.pagination,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => PharmacyProduct.fromJson(item))
              .toList() ??
          [],
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
}

class PaginationInfo {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationInfo({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}

// Order Models
class PharmacyOrder {
  final String id;
  final String userId;
  final UserInfo? user;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final ShippingAddress shippingAddress;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PharmacyOrder({
    required this.id,
    required this.userId,
    this.user,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.shippingAddress,
    this.notes,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory PharmacyOrder.fromJson(Map<String, dynamic> json) {
    return PharmacyOrder(
      id: json['_id']?.toString() ?? '',
      userId: json['user']?.toString() ?? json['user']?['_id']?.toString() ?? '',
      user: json['user'] != null && json['user'] is Map
          ? UserInfo.fromJson(json['user'])
          : null,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'cod',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      status: json['status'] ?? 'pending',
      shippingAddress: ShippingAddress.fromJson(
          json['shippingAddress'] ?? {}),
      notes: json['notes'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}

class OrderItem {
  final String productId;
  final String name;
  final String? image;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.name,
    this.image,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product']?.toString() ?? '',
      name: json['name'] ?? '',
      image: json['image'],
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  double get lineTotal => price * quantity;
}

class ShippingAddress {
  final String fullName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  ShippingAddress({
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'India',
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? 'India',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
    };
  }
}

class UserInfo {
  final String id;
  final String userName;
  final String email;
  final String? phoneNumber;
  final String? role;

  UserInfo({
    required this.id,
    required this.userName,
    required this.email,
    this.phoneNumber,
    this.role,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      role: json['role'],
    );
  }
}

class CreateOrderRequest {
  final List<OrderItemRequest> items;
  final double discount;
  final String paymentMethod;
  final ShippingAddress shippingAddress;
  final String? notes;
  final Map<String, dynamic>? metadata;

  CreateOrderRequest({
    required this.items,
    this.discount = 0,
    this.paymentMethod = 'cod',
    required this.shippingAddress,
    this.notes,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'discount': discount,
      'paymentMethod': paymentMethod,
      'shippingAddress': shippingAddress.toJson(),
      if (notes != null) 'notes': notes,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

class OrderItemRequest {
  final String productId;
  final int quantity;

  OrderItemRequest({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}

class OrdersResponse {
  final List<PharmacyOrder> items;
  final PaginationInfo pagination;

  OrdersResponse({
    required this.items,
    required this.pagination,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => PharmacyOrder.fromJson(item))
              .toList() ??
          [],
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
}

class UpdateOrderStatusRequest {
  final String? status;
  final String? paymentStatus;

  UpdateOrderStatusRequest({
    this.status,
    this.paymentStatus,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (status != null) map['status'] = status;
    if (paymentStatus != null) map['paymentStatus'] = paymentStatus;
    return map;
  }
}



