// ============================================================
// Apple.NET — Complete Data Models
// ============================================================

// --------------------- 1. AppUser ---------------------

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String phone;
  final String role; // user / admin / network_manager
  final String? managedNetwork;
  final double balance;
  final DateTime? createdAt;
  final bool isActive;
  final String? photoUrl;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phone = '',
    this.role = 'user',
    this.managedNetwork,
    this.balance = 0,
    this.createdAt,
    this.isActive = true,
    this.photoUrl,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      role: map['role'] as String? ?? 'user',
      managedNetwork: map['managedNetwork'] as String?,
      balance: (map['balance'] as num?)?.toDouble() ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      isActive: map['isActive'] as bool? ?? true,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phone': phone,
      'role': role,
      'balance': balance,
      'isActive': isActive,
    };
    if (managedNetwork != null) m['managedNetwork'] = managedNetwork;
    if (createdAt != null) m['createdAt'] = createdAt!.toIso8601String();
    if (photoUrl != null) m['photoUrl'] = photoUrl;
    return m;
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phone,
    String? role,
    String? managedNetwork,
    double? balance,
    DateTime? createdAt,
    bool? isActive,
    String? photoUrl,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      managedNetwork: managedNetwork ?? this.managedNetwork,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

// --------------------- 2. NetworkModel ---------------------

class NetworkModel {
  final String id;
  final String name;
  final String color;
  final String bgColor;
  final String emoji;
  final String ownerId;
  final String ownerName;
  final String? ownerPhone;
  final String? location;
  final String? provinceId;
  final String? provinceName;
  final String? district;
  final String? exactLocation;
  final String? connectionIP;
  final String? imageBase64;
  final String? networkType;
  final String? coverage;
  final String? speed;
  final DateTime? createdAt;

  const NetworkModel({
    required this.id,
    required this.name,
    required this.color,
    this.bgColor = '#E8F5E9',
    this.emoji = '📡',
    this.ownerId = '',
    this.ownerName = '',
    this.ownerPhone,
    this.location,
    this.provinceId,
    this.provinceName,
    this.district,
    this.exactLocation,
    this.connectionIP,
    this.imageBase64,
    this.networkType,
    this.coverage,
    this.speed,
    this.createdAt,
  });

  factory NetworkModel.fromMap(Map<String, dynamic> map) {
    return NetworkModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      color: map['color'] as String? ?? '',
      bgColor: map['bgColor'] as String? ?? '#E8F5E9',
      emoji: map['emoji'] as String? ?? '📡',
      ownerId: map['ownerId'] as String? ?? '',
      ownerName: map['ownerName'] as String? ?? '',
      ownerPhone: map['ownerPhone'] as String?,
      location: map['location'] as String?,
      provinceId: map['provinceId'] as String?,
      provinceName: map['provinceName'] as String?,
      district: map['district'] as String?,
      exactLocation: map['exactLocation'] as String?,
      connectionIP: map['connectionIP'] as String?,
      imageBase64: map['imageBase64'] as String?,
      networkType: map['networkType'] as String?,
      coverage: map['coverage'] as String?,
      speed: map['speed'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'name': name,
      'color': color,
      'bgColor': bgColor,
      'emoji': emoji,
      'ownerId': ownerId,
      'ownerName': ownerName,
    };
    if (ownerPhone != null) m['ownerPhone'] = ownerPhone;
    if (location != null) m['location'] = location;
    if (provinceId != null) m['provinceId'] = provinceId;
    if (provinceName != null) m['provinceName'] = provinceName;
    if (district != null) m['district'] = district;
    if (exactLocation != null) m['exactLocation'] = exactLocation;
    if (connectionIP != null) m['connectionIP'] = connectionIP;
    if (imageBase64 != null) m['imageBase64'] = imageBase64;
    if (networkType != null) m['networkType'] = networkType;
    if (coverage != null) m['coverage'] = coverage;
    if (speed != null) m['speed'] = speed;
    if (createdAt != null) m['createdAt'] = createdAt!.toIso8601String();
    return m;
  }

  NetworkModel copyWith({
    String? id,
    String? name,
    String? color,
    String? bgColor,
    String? emoji,
    String? ownerId,
    String? ownerName,
    String? ownerPhone,
    String? location,
    String? provinceId,
    String? provinceName,
    String? district,
    String? exactLocation,
    String? connectionIP,
    String? imageBase64,
    String? networkType,
    String? coverage,
    String? speed,
    DateTime? createdAt,
  }) {
    return NetworkModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      bgColor: bgColor ?? this.bgColor,
      emoji: emoji ?? this.emoji,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      location: location ?? this.location,
      provinceId: provinceId ?? this.provinceId,
      provinceName: provinceName ?? this.provinceName,
      district: district ?? this.district,
      exactLocation: exactLocation ?? this.exactLocation,
      connectionIP: connectionIP ?? this.connectionIP,
      imageBase64: imageBase64 ?? this.imageBase64,
      networkType: networkType ?? this.networkType,
      coverage: coverage ?? this.coverage,
      speed: speed ?? this.speed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// --------------------- 3. TierModel ---------------------

class TierModel {
  final String id;
  final String tier;
  final double price;
  final String data;
  final int duration;
  final String icon;
  final String? networkId;
  final DateTime? createdAt;

  const TierModel({
    required this.id,
    required this.tier,
    required this.price,
    required this.data,
    required this.duration,
    this.icon = '📶',
    this.networkId,
    this.createdAt,
  });

  factory TierModel.fromMap(Map<String, dynamic> map) {
    return TierModel(
      id: map['id'] as String? ?? '',
      tier: map['tier'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      data: map['data'] as String? ?? '',
      duration: map['duration'] as int? ?? 0,
      icon: map['icon'] as String? ?? '📶',
      networkId: map['networkId'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'tier': tier,
      'price': price,
      'data': data,
      'duration': duration,
      'icon': icon,
    };
    if (networkId != null) m['networkId'] = networkId;
    if (createdAt != null) m['createdAt'] = createdAt!.toIso8601String();
    return m;
  }

  TierModel copyWith({
    String? id,
    String? tier,
    double? price,
    String? data,
    int? duration,
    String? icon,
    String? networkId,
    DateTime? createdAt,
  }) {
    return TierModel(
      id: id ?? this.id,
      tier: tier ?? this.tier,
      price: price ?? this.price,
      data: data ?? this.data,
      duration: duration ?? this.duration,
      icon: icon ?? this.icon,
      networkId: networkId ?? this.networkId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// --------------------- 4. CardModel ---------------------

class CardModel {
  final String id;
  final String code;
  final double price;
  final String data;
  final int duration;
  final bool isUsed;
  final String? usedBy;
  final DateTime? usedAt;
  final String tier;
  final String network;
  final String networkName;
  final DateTime? createdAt;

  const CardModel({
    required this.id,
    required this.code,
    required this.price,
    required this.data,
    required this.duration,
    this.isUsed = false,
    this.usedBy,
    this.usedAt,
    required this.tier,
    required this.network,
    required this.networkName,
    this.createdAt,
  });

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'] as String? ?? '',
      code: map['code'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      data: map['data'] as String? ?? '',
      duration: map['duration'] as int? ?? 0,
      isUsed: map['isUsed'] as bool? ?? false,
      usedBy: map['usedBy'] as String?,
      usedAt: map['usedAt'] != null
          ? DateTime.tryParse(map['usedAt'].toString())
          : null,
      tier: map['tier'] as String? ?? '',
      network: map['network'] as String? ?? '',
      networkName: map['networkName'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'code': code,
      'price': price,
      'data': data,
      'duration': duration,
      'isUsed': isUsed,
      'tier': tier,
      'network': network,
      'networkName': networkName,
    };
    if (usedBy != null) m['usedBy'] = usedBy;
    if (usedAt != null) m['usedAt'] = usedAt!.toIso8601String();
    if (createdAt != null) m['createdAt'] = createdAt!.toIso8601String();
    return m;
  }

  CardModel copyWith({
    String? id,
    String? code,
    double? price,
    String? data,
    int? duration,
    bool? isUsed,
    String? usedBy,
    DateTime? usedAt,
    String? tier,
    String? network,
    String? networkName,
    DateTime? createdAt,
  }) {
    return CardModel(
      id: id ?? this.id,
      code: code ?? this.code,
      price: price ?? this.price,
      data: data ?? this.data,
      duration: duration ?? this.duration,
      isUsed: isUsed ?? this.isUsed,
      usedBy: usedBy ?? this.usedBy,
      usedAt: usedAt ?? this.usedAt,
      tier: tier ?? this.tier,
      network: network ?? this.network,
      networkName: networkName ?? this.networkName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// --------------------- 5. StarlinkProduct ---------------------

class StarlinkProduct {
  final String id;
  final String name;
  final String description;
  final double priceUSD;
  final int quantity;
  final String? imageBase64;
  final Map<String, String> specs;
  final bool isActive;
  final DateTime? createdAt;

  const StarlinkProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.priceUSD,
    this.quantity = 0,
    this.imageBase64,
    this.specs = const {},
    this.isActive = true,
    this.createdAt,
  });

  factory StarlinkProduct.fromMap(Map<String, dynamic> map) {
    return StarlinkProduct(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      priceUSD: (map['priceUSD'] as num?)?.toDouble() ?? 0,
      quantity: map['quantity'] as int? ?? 0,
      imageBase64: map['imageBase64'] as String?,
      specs: map['specs'] != null
          ? Map<String, String>.from(
              (map['specs'] as Map).map((k, v) => MapEntry(k.toString(), v.toString())))
          : const {},
      isActive: map['isActive'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'priceUSD': priceUSD,
      'quantity': quantity,
      'specs': specs,
      'isActive': isActive,
    };
    if (imageBase64 != null) m['imageBase64'] = imageBase64;
    if (createdAt != null) m['createdAt'] = createdAt!.toIso8601String();
    return m;
  }

  StarlinkProduct copyWith({
    String? id,
    String? name,
    String? description,
    double? priceUSD,
    int? quantity,
    String? imageBase64,
    Map<String, String>? specs,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return StarlinkProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      priceUSD: priceUSD ?? this.priceUSD,
      quantity: quantity ?? this.quantity,
      imageBase64: imageBase64 ?? this.imageBase64,
      specs: specs ?? this.specs,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// --------------------- 6. StarlinkOrder ---------------------

class StarlinkOrder {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final String productId;
  final String productName;
  final double priceUSD;
  final String status; // pending / confirmed / shipped / delivered / cancelled
  final DateTime? createdAt;

  const StarlinkOrder({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    required this.productId,
    required this.productName,
    required this.priceUSD,
    this.status = 'pending',
    this.createdAt,
  });

  factory StarlinkOrder.fromMap(Map<String, dynamic> map) {
    return StarlinkOrder(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      userEmail: map['userEmail'] as String? ?? '',
      userPhone: map['userPhone'] as String?,
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      priceUSD: (map['priceUSD'] as num?)?.toDouble() ?? 0,
      status: map['status'] as String? ?? 'pending',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'productId': productId,
      'productName': productName,
      'priceUSD': priceUSD,
      'status': status,
    };
    if (userPhone != null) m['userPhone'] = userPhone;
    if (createdAt != null) m['createdAt'] = createdAt!.toIso8601String();
    return m;
  }

  StarlinkOrder copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? productId,
    String? productName,
    double? priceUSD,
    String? status,
    DateTime? createdAt,
  }) {
    return StarlinkOrder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      priceUSD: priceUSD ?? this.priceUSD,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// --------------------- 7. BankDetail ---------------------

class BankDetail {
  final String id;
  final String bankName;
  final String accountName;
  final String accountNumber;
  final bool isActive;

  const BankDetail({
    required this.id,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    this.isActive = true,
  });

  factory BankDetail.fromMap(Map<String, dynamic> map) {
    return BankDetail(
      id: map['id'] as String? ?? '',
      bankName: map['bankName'] as String? ?? '',
      accountName: map['accountName'] as String? ?? '',
      accountNumber: map['accountNumber'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bankName': bankName,
      'accountName': accountName,
      'accountNumber': accountNumber,
      'isActive': isActive,
    };
  }

  BankDetail copyWith({
    String? id,
    String? bankName,
    String? accountName,
    String? accountNumber,
    bool? isActive,
  }) {
    return BankDetail(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      isActive: isActive ?? this.isActive,
    );
  }
}

// --------------------- 8. CreditHistory ---------------------

class CreditHistory {
  final String id;
  final String type; // deposit / purchase / gift / redeem / commission / refund
  final double amount;
  final String description;
  final DateTime? date;

  const CreditHistory({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    this.date,
  });

  factory CreditHistory.fromMap(Map<String, dynamic> map) {
    return CreditHistory(
      id: map['id'] as String? ?? '',
      type: map['type'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      description: map['description'] as String? ?? '',
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
    };
    if (date != null) m['date'] = date!.toIso8601String();
    return m;
  }

  CreditHistory copyWith({
    String? id,
    String? type,
    double? amount,
    String? description,
    DateTime? date,
  }) {
    return CreditHistory(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }
}

// --------------------- 9. AppNotification ---------------------

class AppNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;
  final String? relatedId;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.isRead = false,
    this.createdAt,
    this.relatedId,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String? ?? '',
      type: map['type'] as String? ?? '',
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      isRead: map['isRead'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      relatedId: map['relatedId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'isRead': isRead,
    };
    if (createdAt != null) m['createdAt'] = createdAt!.toIso8601String();
    if (relatedId != null) m['relatedId'] = relatedId;
    return m;
  }

  AppNotification copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    String? relatedId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      relatedId: relatedId ?? this.relatedId,
    );
  }
}

// --------------------- 10. DepositRequest ---------------------

class DepositRequest {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? bankId;
  final String bankName;
  final double amount;
  final String referenceNumber;
  final String status; // pending / approved / rejected
  final DateTime? createdAt;
  final String? rejectionReason;
  final String? imageBase64;

  const DepositRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.bankId,
    required this.bankName,
    required this.amount,
    required this.referenceNumber,
    this.status = 'pending',
    this.createdAt,
    this.rejectionReason,
    this.imageBase64,
  });

  factory DepositRequest.fromMap(Map<String, dynamic> map) {
    return DepositRequest(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      userEmail: map['userEmail'] as String? ?? '',
      bankId: map['bankId'] as String?,
      bankName: map['bankName'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      referenceNumber: map['referenceNumber'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      rejectionReason: map['rejectionReason'] as String?,
      imageBase64: map['imageBase64'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'bankName': bankName,
      'amount': amount,
      'referenceNumber': referenceNumber,
      'status': status,
    };
    if (bankId != null) m['bankId'] = bankId;
    if (createdAt != null) m['createdAt'] = createdAt!.toIso8601String();
    if (rejectionReason != null) m['rejectionReason'] = rejectionReason;
    if (imageBase64 != null) m['imageBase64'] = imageBase64;
    return m;
  }

  DepositRequest copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? bankId,
    String? bankName,
    double? amount,
    String? referenceNumber,
    String? status,
    DateTime? createdAt,
    String? rejectionReason,
    String? imageBase64,
  }) {
    return DepositRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      bankId: bankId ?? this.bankId,
      bankName: bankName ?? this.bankName,
      amount: amount ?? this.amount,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      imageBase64: imageBase64 ?? this.imageBase64,
    );
  }
}

// --------------------- 11. Advertisement ---------------------

class Advertisement {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? imageBase64;
  final bool isActive;

  const Advertisement({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.imageBase64,
    this.isActive = true,
  });

  factory Advertisement.fromMap(Map<String, dynamic> map) {
    return Advertisement(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      imageBase64: map['imageBase64'] as String?,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'isActive': isActive,
    };
    if (imageUrl != null) m['imageUrl'] = imageUrl;
    if (imageBase64 != null) m['imageBase64'] = imageBase64;
    return m;
  }

  Advertisement copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? imageBase64,
    bool? isActive,
  }) {
    return Advertisement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBase64: imageBase64 ?? this.imageBase64,
      isActive: isActive ?? this.isActive,
    );
  }
}

// --------------------- 12. RedeemCode ---------------------

class RedeemCode {
  final String id;
  final String code;
  final double amount;
  final bool isUsed;
  final String? usedBy;
  final String? usedByName;
  final DateTime? usedAt;
  final DateTime? createdAt;
  final String? createdBy;

  const RedeemCode({
    required this.id,
    required this.code,
    required this.amount,
    this.isUsed = false,
    this.usedBy,
    this.usedByName,
    this.usedAt,
    this.createdAt,
    this.createdBy,
  });

  factory RedeemCode.fromMap(Map<String, dynamic> map) {
    return RedeemCode(
      id: map['id'] as String? ?? '',
      code: map['code'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      isUsed: map['isUsed'] as bool? ?? false,
      usedBy: map['usedBy'] as String?,
      usedByName: map['usedByName'] as String?,
      usedAt: map['usedAt'] != null
          ? DateTime.tryParse(map['usedAt'].toString())
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      createdBy: map['createdBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'code': code,
      'amount': amount,
      'isUsed': isUsed,
    };
    if (usedBy != null) m['usedBy'] = usedBy;
    if (usedByName != null) m['usedByName'] = usedByName;
    if (usedAt != null) m['usedAt'] = usedAt!.toIso8601String();
    if (createdAt != null) m['createdAt'] = createdAt!.toIso8601String();
    if (createdBy != null) m['createdBy'] = createdBy;
    return m;
  }

  RedeemCode copyWith({
    String? id,
    String? code,
    double? amount,
    bool? isUsed,
    String? usedBy,
    String? usedByName,
    DateTime? usedAt,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return RedeemCode(
      id: id ?? this.id,
      code: code ?? this.code,
      amount: amount ?? this.amount,
      isUsed: isUsed ?? this.isUsed,
      usedBy: usedBy ?? this.usedBy,
      usedByName: usedByName ?? this.usedByName,
      usedAt: usedAt ?? this.usedAt,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

// --------------------- 13. SharedRedeemCode ---------------------

class SharedRedeemCode {
  final String id;
  final String code;
  final double amount;
  final int maxRedemptions;
  final int currentRedemptions;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final String? createdBy;

  const SharedRedeemCode({
    required this.id,
    required this.code,
    required this.amount,
    required this.maxRedemptions,
    this.currentRedemptions = 0,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.createdBy,
  });

  factory SharedRedeemCode.fromMap(Map<String, dynamic> map) {
    return SharedRedeemCode(
      id: map['id'] as String? ?? '',
      code: map['code'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      maxRedemptions: map['maxRedemptions'] as int? ?? 1,
      currentRedemptions: map['currentRedemptions'] as int? ?? 0,
      description: map['description'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      createdBy: map['createdBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'code': code,
      'amount': amount,
      'maxRedemptions': maxRedemptions,
      'currentRedemptions': currentRedemptions,
      'isActive': isActive,
    };
    if (description != null) m['description'] = description;
    if (createdAt != null) m['createdAt'] = createdAt!.toIso8601String();
    if (createdBy != null) m['createdBy'] = createdBy;
    return m;
  }

  SharedRedeemCode copyWith({
    String? id,
    String? code,
    double? amount,
    int? maxRedemptions,
    int? currentRedemptions,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return SharedRedeemCode(
      id: id ?? this.id,
      code: code ?? this.code,
      amount: amount ?? this.amount,
      maxRedemptions: maxRedemptions ?? this.maxRedemptions,
      currentRedemptions: currentRedemptions ?? this.currentRedemptions,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

// --------------------- 14. SubscriptionPlan ---------------------

class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final String description;
  final int durationDays;
  final bool isActive;
  final DateTime? createdAt;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.durationDays,
    this.isActive = true,
    this.createdAt,
  });

  factory SubscriptionPlan.fromMap(Map<String, dynamic> map) {
    return SubscriptionPlan(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      description: map['description'] as String? ?? '',
      durationDays: map['durationDays'] as int? ?? 0,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'durationDays': durationDays,
      'isActive': isActive,
    };
    if (createdAt != null) m['createdAt'] = createdAt!.toIso8601String();
    return m;
  }

  SubscriptionPlan copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    int? durationDays,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return SubscriptionPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      durationDays: durationDays ?? this.durationDays,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// --------------------- 15. UserSubscription ---------------------

class UserSubscription {
  final String id;
  final String planId;
  final String planName;
  final DateTime? activatedAt;
  final DateTime? expiresAt;
  final bool isActive;
  final bool autoRenew;
  final String uid;

  const UserSubscription({
    required this.id,
    required this.planId,
    required this.planName,
    this.activatedAt,
    this.expiresAt,
    this.isActive = true,
    this.autoRenew = false,
    required this.uid,
  });

  factory UserSubscription.fromMap(Map<String, dynamic> map) {
    return UserSubscription(
      id: map['id'] as String? ?? '',
      planId: map['planId'] as String? ?? '',
      planName: map['planName'] as String? ?? '',
      activatedAt: map['activatedAt'] != null
          ? DateTime.tryParse(map['activatedAt'].toString())
          : null,
      expiresAt: map['expiresAt'] != null
          ? DateTime.tryParse(map['expiresAt'].toString())
          : null,
      isActive: map['isActive'] as bool? ?? true,
      autoRenew: map['autoRenew'] as bool? ?? false,
      uid: map['uid'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'planId': planId,
      'planName': planName,
      'isActive': isActive,
      'autoRenew': autoRenew,
      'uid': uid,
    };
    if (activatedAt != null) m['activatedAt'] = activatedAt!.toIso8601String();
    if (expiresAt != null) m['expiresAt'] = expiresAt!.toIso8601String();
    return m;
  }

  UserSubscription copyWith({
    String? id,
    String? planId,
    String? planName,
    DateTime? activatedAt,
    DateTime? expiresAt,
    bool? isActive,
    bool? autoRenew,
    String? uid,
  }) {
    return UserSubscription(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      activatedAt: activatedAt ?? this.activatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      autoRenew: autoRenew ?? this.autoRenew,
      uid: uid ?? this.uid,
    );
  }
}

// --------------------- 16. BulkNotification ---------------------

class BulkNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final int targetCount;
  final DateTime? sentAt;
  final String? sentBy;

  const BulkNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.targetCount = 0,
    this.sentAt,
    this.sentBy,
  });

  factory BulkNotification.fromMap(Map<String, dynamic> map) {
    return BulkNotification(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      type: map['type'] as String? ?? '',
      targetCount: map['targetCount'] as int? ?? 0,
      sentAt: map['sentAt'] != null
          ? DateTime.tryParse(map['sentAt'].toString())
          : null,
      sentBy: map['sentBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'targetCount': targetCount,
    };
    if (sentAt != null) m['sentAt'] = sentAt!.toIso8601String();
    if (sentBy != null) m['sentBy'] = sentBy;
    return m;
  }

  BulkNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    int? targetCount,
    DateTime? sentAt,
    String? sentBy,
  }) {
    return BulkNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      targetCount: targetCount ?? this.targetCount,
      sentAt: sentAt ?? this.sentAt,
      sentBy: sentBy ?? this.sentBy,
    );
  }
}

// --------------------- 17. CommissionSetting ---------------------

class CommissionSetting {
  final String id;
  final String managerUid;
  final String managerName;
  final String networkId;
  final String networkName;
  final double defaultRate;
  final Map<String, double> provinceRates;
  final Map<String, double> districtRates;
  final Map<String, double> tierRates;
  final DateTime? updatedAt;

  const CommissionSetting({
    required this.id,
    required this.managerUid,
    required this.managerName,
    required this.networkId,
    required this.networkName,
    this.defaultRate = 0,
    this.provinceRates = const {},
    this.districtRates = const {},
    this.tierRates = const {},
    this.updatedAt,
  });

  factory CommissionSetting.fromMap(Map<String, dynamic> map) {
    return CommissionSetting(
      id: map['id'] as String? ?? '',
      managerUid: map['managerUid'] as String? ?? '',
      managerName: map['managerName'] as String? ?? '',
      networkId: map['networkId'] as String? ?? '',
      networkName: map['networkName'] as String? ?? '',
      defaultRate: (map['defaultRate'] as num?)?.toDouble() ?? 0,
      provinceRates: map['provinceRates'] != null
          ? Map<String, double>.from(
              (map['provinceRates'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toDouble())))
          : const {},
      districtRates: map['districtRates'] != null
          ? Map<String, double>.from(
              (map['districtRates'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toDouble())))
          : const {},
      tierRates: map['tierRates'] != null
          ? Map<String, double>.from(
              (map['tierRates'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toDouble())))
          : const {},
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'managerUid': managerUid,
      'managerName': managerName,
      'networkId': networkId,
      'networkName': networkName,
      'defaultRate': defaultRate,
      'provinceRates': provinceRates,
      'districtRates': districtRates,
      'tierRates': tierRates,
    };
    if (updatedAt != null) m['updatedAt'] = updatedAt!.toIso8601String();
    return m;
  }

  CommissionSetting copyWith({
    String? id,
    String? managerUid,
    String? managerName,
    String? networkId,
    String? networkName,
    double? defaultRate,
    Map<String, double>? provinceRates,
    Map<String, double>? districtRates,
    Map<String, double>? tierRates,
    DateTime? updatedAt,
  }) {
    return CommissionSetting(
      id: id ?? this.id,
      managerUid: managerUid ?? this.managerUid,
      managerName: managerName ?? this.managerName,
      networkId: networkId ?? this.networkId,
      networkName: networkName ?? this.networkName,
      defaultRate: defaultRate ?? this.defaultRate,
      provinceRates: provinceRates ?? this.provinceRates,
      districtRates: districtRates ?? this.districtRates,
      tierRates: tierRates ?? this.tierRates,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// --------------------- 18. CommissionEntry ---------------------

class CommissionEntry {
  final String id;
  final String managerUid;
  final String managerName;
  final String networkId;
  final String networkName;
  final String? cardId;
  final String? cardTier;
  final double cardPrice;
  final double commissionRate;
  final double commissionAmount;
  final String? provinceId;
  final String? provinceName;
  final String? district;
  final DateTime? soldAt;
  final String? month;
  final bool isPaid;
  final DateTime? paidAt;

  const CommissionEntry({
    required this.id,
    required this.managerUid,
    required this.managerName,
    required this.networkId,
    required this.networkName,
    this.cardId,
    this.cardTier,
    this.cardPrice = 0,
    this.commissionRate = 0,
    this.commissionAmount = 0,
    this.provinceId,
    this.provinceName,
    this.district,
    this.soldAt,
    this.month,
    this.isPaid = false,
    this.paidAt,
  });

  factory CommissionEntry.fromMap(Map<String, dynamic> map) {
    return CommissionEntry(
      id: map['id'] as String? ?? '',
      managerUid: map['managerUid'] as String? ?? '',
      managerName: map['managerName'] as String? ?? '',
      networkId: map['networkId'] as String? ?? '',
      networkName: map['networkName'] as String? ?? '',
      cardId: map['cardId'] as String?,
      cardTier: map['cardTier'] as String?,
      cardPrice: (map['cardPrice'] as num?)?.toDouble() ?? 0,
      commissionRate: (map['commissionRate'] as num?)?.toDouble() ?? 0,
      commissionAmount: (map['commissionAmount'] as num?)?.toDouble() ?? 0,
      provinceId: map['provinceId'] as String?,
      provinceName: map['provinceName'] as String?,
      district: map['district'] as String?,
      soldAt: map['soldAt'] != null
          ? DateTime.tryParse(map['soldAt'].toString())
          : null,
      month: map['month'] as String?,
      isPaid: map['isPaid'] as bool? ?? false,
      paidAt: map['paidAt'] != null
          ? DateTime.tryParse(map['paidAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'managerUid': managerUid,
      'managerName': managerName,
      'networkId': networkId,
      'networkName': networkName,
      'cardPrice': cardPrice,
      'commissionRate': commissionRate,
      'commissionAmount': commissionAmount,
      'isPaid': isPaid,
    };
    if (cardId != null) m['cardId'] = cardId;
    if (cardTier != null) m['cardTier'] = cardTier;
    if (provinceId != null) m['provinceId'] = provinceId;
    if (provinceName != null) m['provinceName'] = provinceName;
    if (district != null) m['district'] = district;
    if (soldAt != null) m['soldAt'] = soldAt!.toIso8601String();
    if (month != null) m['month'] = month;
    if (paidAt != null) m['paidAt'] = paidAt!.toIso8601String();
    return m;
  }

  CommissionEntry copyWith({
    String? id,
    String? managerUid,
    String? managerName,
    String? networkId,
    String? networkName,
    String? cardId,
    String? cardTier,
    double? cardPrice,
    double? commissionRate,
    double? commissionAmount,
    String? provinceId,
    String? provinceName,
    String? district,
    DateTime? soldAt,
    String? month,
    bool? isPaid,
    DateTime? paidAt,
  }) {
    return CommissionEntry(
      id: id ?? this.id,
      managerUid: managerUid ?? this.managerUid,
      managerName: managerName ?? this.managerName,
      networkId: networkId ?? this.networkId,
      networkName: networkName ?? this.networkName,
      cardId: cardId ?? this.cardId,
      cardTier: cardTier ?? this.cardTier,
      cardPrice: cardPrice ?? this.cardPrice,
      commissionRate: commissionRate ?? this.commissionRate,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      provinceId: provinceId ?? this.provinceId,
      provinceName: provinceName ?? this.provinceName,
      district: district ?? this.district,
      soldAt: soldAt ?? this.soldAt,
      month: month ?? this.month,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}

// --------------------- 19. MonthlyPayout ---------------------

class MonthlyPayout {
  final String id;
  final String month;
  final String managerUid;
  final String managerName;
  final String networkId;
  final String networkName;
  final double totalCommission;
  final int totalCards;
  final String? bankName;
  final String? bankAccount;
  final String status; // pending / processing / paid / failed
  final DateTime? paidAt;
  final DateTime? createdAt;

  const MonthlyPayout({
    required this.id,
    required this.month,
    required this.managerUid,
    required this.managerName,
    required this.networkId,
    required this.networkName,
    this.totalCommission = 0,
    this.totalCards = 0,
    this.bankName,
    this.bankAccount,
    this.status = 'pending',
    this.paidAt,
    this.createdAt,
  });

  factory MonthlyPayout.fromMap(Map<String, dynamic> map) {
    return MonthlyPayout(
      id: map['id'] as String? ?? '',
      month: map['month'] as String? ?? '',
      managerUid: map['managerUid'] as String? ?? '',
      managerName: map['managerName'] as String? ?? '',
      networkId: map['networkId'] as String? ?? '',
      networkName: map['networkName'] as String? ?? '',
      totalCommission: (map['totalCommission'] as num?)?.toDouble() ?? 0,
      totalCards: map['totalCards'] as int? ?? 0,
      bankName: map['bankName'] as String?,
      bankAccount: map['bankAccount'] as String?,
      status: map['status'] as String? ?? 'pending',
      paidAt: map['paidAt'] != null
          ? DateTime.tryParse(map['paidAt'].toString())
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'month': month,
      'managerUid': managerUid,
      'managerName': managerName,
      'networkId': networkId,
      'networkName': networkName,
      'totalCommission': totalCommission,
      'totalCards': totalCards,
      'status': status,
    };
    if (bankName != null) m['bankName'] = bankName;
    if (bankAccount != null) m['bankAccount'] = bankAccount;
    if (paidAt != null) m['paidAt'] = paidAt!.toIso8601String();
    if (createdAt != null) m['createdAt'] = createdAt!.toIso8601String();
    return m;
  }

  MonthlyPayout copyWith({
    String? id,
    String? month,
    String? managerUid,
    String? managerName,
    String? networkId,
    String? networkName,
    double? totalCommission,
    int? totalCards,
    String? bankName,
    String? bankAccount,
    String? status,
    DateTime? paidAt,
    DateTime? createdAt,
  }) {
    return MonthlyPayout(
      id: id ?? this.id,
      month: month ?? this.month,
      managerUid: managerUid ?? this.managerUid,
      managerName: managerName ?? this.managerName,
      networkId: networkId ?? this.networkId,
      networkName: networkName ?? this.networkName,
      totalCommission: totalCommission ?? this.totalCommission,
      totalCards: totalCards ?? this.totalCards,
      bankName: bankName ?? this.bankName,
      bankAccount: bankAccount ?? this.bankAccount,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// --------------------- 20. NetworkSubmission ---------------------

class NetworkSubmission {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final String networkName;
  final String? provinceId;
  final String? provinceName;
  final String? district;
  final String? exactLocation;
  final String? networkType;
  final String? description;
  final String? coverage;
  final String? speed;
  final String status; // pending / approved / rejected
  final DateTime? createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;
  final String? assignedNetworkId;
  final String? imageBase64;

  const NetworkSubmission({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    required this.networkName,
    this.provinceId,
    this.provinceName,
    this.district,
    this.exactLocation,
    this.networkType,
    this.description,
    this.coverage,
    this.speed,
    this.status = 'pending',
    this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
    this.assignedNetworkId,
    this.imageBase64,
  });

  factory NetworkSubmission.fromMap(Map<String, dynamic> map) {
    return NetworkSubmission(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      userEmail: map['userEmail'] as String? ?? '',
      userPhone: map['userPhone'] as String?,
      networkName: map['networkName'] as String? ?? '',
      provinceId: map['provinceId'] as String?,
      provinceName: map['provinceName'] as String?,
      district: map['district'] as String?,
      exactLocation: map['exactLocation'] as String?,
      networkType: map['networkType'] as String?,
      description: map['description'] as String?,
      coverage: map['coverage'] as String?,
      speed: map['speed'] as String?,
      status: map['status'] as String? ?? 'pending',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      reviewedAt: map['reviewedAt'] != null
          ? DateTime.tryParse(map['reviewedAt'].toString())
          : null,
      reviewedBy: map['reviewedBy'] as String?,
      rejectionReason: map['rejectionReason'] as String?,
      assignedNetworkId: map['assignedNetworkId'] as String?,
      imageBase64: map['imageBase64'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'networkName': networkName,
      'status': status,
    };
    if (userPhone != null) m['userPhone'] = userPhone;
    if (provinceId != null) m['provinceId'] = provinceId;
    if (provinceName != null) m['provinceName'] = provinceName;
    if (district != null) m['district'] = district;
    if (exactLocation != null) m['exactLocation'] = exactLocation;
    if (networkType != null) m['networkType'] = networkType;
    if (description != null) m['description'] = description;
    if (coverage != null) m['coverage'] = coverage;
    if (speed != null) m['speed'] = speed;
    if (createdAt != null) m['createdAt'] = createdAt!.toIso8601String();
    if (reviewedAt != null) m['reviewedAt'] = reviewedAt!.toIso8601String();
    if (reviewedBy != null) m['reviewedBy'] = reviewedBy;
    if (rejectionReason != null) m['rejectionReason'] = rejectionReason;
    if (assignedNetworkId != null) m['assignedNetworkId'] = assignedNetworkId;
    if (imageBase64 != null) m['imageBase64'] = imageBase64;
    return m;
  }

  NetworkSubmission copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? networkName,
    String? provinceId,
    String? provinceName,
    String? district,
    String? exactLocation,
    String? networkType,
    String? description,
    String? coverage,
    String? speed,
    String? status,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? rejectionReason,
    String? assignedNetworkId,
    String? imageBase64,
  }) {
    return NetworkSubmission(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      networkName: networkName ?? this.networkName,
      provinceId: provinceId ?? this.provinceId,
      provinceName: provinceName ?? this.provinceName,
      district: district ?? this.district,
      exactLocation: exactLocation ?? this.exactLocation,
      networkType: networkType ?? this.networkType,
      description: description ?? this.description,
      coverage: coverage ?? this.coverage,
      speed: speed ?? this.speed,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      assignedNetworkId: assignedNetworkId ?? this.assignedNetworkId,
      imageBase64: imageBase64 ?? this.imageBase64,
    );
  }
}

// --------------------- 21. CardSaleLocation ---------------------

class CardSaleLocation {
  final String id;
  final String networkId;
  final String networkName;
  final String name;
  final String? provinceId;
  final String? provinceName;
  final String? district;
  final String? exactLocation;
  final String? phone;
  final bool isActive;
  final DateTime? createdAt;

  const CardSaleLocation({
    required this.id,
    required this.networkId,
    required this.networkName,
    required this.name,
    this.provinceId,
    this.provinceName,
    this.district,
    this.exactLocation,
    this.phone,
    this.isActive = true,
    this.createdAt,
  });

  factory CardSaleLocation.fromMap(Map<String, dynamic> map) {
    return CardSaleLocation(
      id: map['id'] as String? ?? '',
      networkId: map['networkId'] as String? ?? '',
      networkName: map['networkName'] as String? ?? '',
      name: map['name'] as String? ?? '',
      provinceId: map['provinceId'] as String?,
      provinceName: map['provinceName'] as String?,
      district: map['district'] as String?,
      exactLocation: map['exactLocation'] as String?,
      phone: map['phone'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'networkId': networkId,
      'networkName': networkName,
      'name': name,
      'isActive': isActive,
    };
    if (provinceId != null) m['provinceId'] = provinceId;
    if (provinceName != null) m['provinceName'] = provinceName;
    if (district != null) m['district'] = district;
    if (exactLocation != null) m['exactLocation'] = exactLocation;
    if (phone != null) m['phone'] = phone;
    if (createdAt != null) m['createdAt'] = createdAt!.toIso8601String();
    return m;
  }

  CardSaleLocation copyWith({
    String? id,
    String? networkId,
    String? networkName,
    String? name,
    String? provinceId,
    String? provinceName,
    String? district,
    String? exactLocation,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return CardSaleLocation(
      id: id ?? this.id,
      networkId: networkId ?? this.networkId,
      networkName: networkName ?? this.networkName,
      name: name ?? this.name,
      provinceId: provinceId ?? this.provinceId,
      provinceName: provinceName ?? this.provinceName,
      district: district ?? this.district,
      exactLocation: exactLocation ?? this.exactLocation,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// --------------------- 22. SimCard ---------------------

class SimCard {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final String? imageBase64;
  final bool isAvailable;

  const SimCard({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    this.imageBase64,
    this.isAvailable = true,
  });

  factory SimCard.fromMap(Map<String, dynamic> map) {
    return SimCard(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      description: map['description'] as String?,
      imageUrl: map['imageUrl'] as String?,
      imageBase64: map['imageBase64'] as String?,
      isAvailable: map['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'name': name,
      'price': price,
      'isAvailable': isAvailable,
    };
    if (description != null) m['description'] = description;
    if (imageUrl != null) m['imageUrl'] = imageUrl;
    if (imageBase64 != null) m['imageBase64'] = imageBase64;
    return m;
  }

  SimCard copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    String? imageBase64,
    bool? isAvailable,
  }) {
    return SimCard(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBase64: imageBase64 ?? this.imageBase64,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

// --------------------- 23. HomeBanner ---------------------

class HomeBanner {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? linkUrl;
  final bool isActive;
  final int order;
  final DateTime? createdAt;

  const HomeBanner({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.linkUrl,
    this.isActive = true,
    this.order = 0,
    this.createdAt,
  });

  factory HomeBanner.fromMap(Map<String, dynamic> map) {
    return HomeBanner(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      imageUrl: map['imageUrl'] as String?,
      linkUrl: map['linkUrl'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      order: map['order'] as int? ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'title': title,
      'isActive': isActive,
      'order': order,
    };
    if (description != null) m['description'] = description;
    if (imageUrl != null) m['imageUrl'] = imageUrl;
    if (linkUrl != null) m['linkUrl'] = linkUrl;
    if (createdAt != null) m['createdAt'] = createdAt!.toIso8601String();
    return m;
  }

  HomeBanner copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? linkUrl,
    bool? isActive,
    int? order,
    DateTime? createdAt,
  }) {
    return HomeBanner(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      linkUrl: linkUrl ?? this.linkUrl,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// --------------------- 24. AppSettings ---------------------

class AppSettings {
  final String? adminWhatsApp;
  final double? maxBalance;
  final bool maintenanceMode;
  final String? appDownloadUrl;
  final String? latestAppVersion;
  final String? updateMessage;
  final Map<String, bool> hiddenSections;

  const AppSettings({
    this.adminWhatsApp,
    this.maxBalance,
    this.maintenanceMode = false,
    this.appDownloadUrl,
    this.latestAppVersion,
    this.updateMessage,
    this.hiddenSections = const {},
  });

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      adminWhatsApp: map['adminWhatsApp'] as String?,
      maxBalance: (map['maxBalance'] as num?)?.toDouble(),
      maintenanceMode: map['maintenanceMode'] as bool? ?? false,
      appDownloadUrl: map['appDownloadUrl'] as String?,
      latestAppVersion: map['latestAppVersion'] as String?,
      updateMessage: map['updateMessage'] as String?,
      hiddenSections: map['hiddenSections'] != null
          ? Map<String, bool>.from(
              (map['hiddenSections'] as Map).map((k, v) => MapEntry(k.toString(), v as bool)))
          : const {},
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'maintenanceMode': maintenanceMode,
    };
    if (adminWhatsApp != null) m['adminWhatsApp'] = adminWhatsApp;
    if (maxBalance != null) m['maxBalance'] = maxBalance;
    if (appDownloadUrl != null) m['appDownloadUrl'] = appDownloadUrl;
    if (latestAppVersion != null) m['latestAppVersion'] = latestAppVersion;
    if (updateMessage != null) m['updateMessage'] = updateMessage;
    if (hiddenSections.isNotEmpty) m['hiddenSections'] = hiddenSections;
    return m;
  }

  AppSettings copyWith({
    String? adminWhatsApp,
    double? maxBalance,
    bool? maintenanceMode,
    String? appDownloadUrl,
    String? latestAppVersion,
    String? updateMessage,
    Map<String, bool>? hiddenSections,
  }) {
    return AppSettings(
      adminWhatsApp: adminWhatsApp ?? this.adminWhatsApp,
      maxBalance: maxBalance ?? this.maxBalance,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      appDownloadUrl: appDownloadUrl ?? this.appDownloadUrl,
      latestAppVersion: latestAppVersion ?? this.latestAppVersion,
      updateMessage: updateMessage ?? this.updateMessage,
      hiddenSections: hiddenSections ?? this.hiddenSections,
    );
  }
}
