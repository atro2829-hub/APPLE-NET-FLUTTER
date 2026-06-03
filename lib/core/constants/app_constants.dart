class AppConstants {
  static const String appName = 'Apple.NET';
  static const String appNameAr = 'أبل نت';
  static const String appTagline = 'إدارة الهوت سبوت';
  static const String developerName = 'QTBM DEV';
  static const String developerEmail = 'qtbm.dev@gmail.com';
  static const String version = '2.1.0';

  // Owner info
  static const String ownerName = 'عبدالعليم اليافعي';
  static const String ownerPhone = '967774146432';
  static const String ownerEmail = 'applenet.ye@gmail.com';
  static const String ownerPhotoAsset = 'assets/images/owner_photo.jpg';

  // Admin WhatsApp (from original project)
  static const String adminWhatsApp = '967774146432';

  // Firebase paths
  static const String fbUsers = 'users';
  static const String fbCards = 'cards';
  static const String fbOrders = 'orders';
  static const String fbBanks = 'bankDetails';
  static const String fbAds = 'advertisements';
  static const String fbSims = 'simCards';
  static const String fbDeposits = 'depositRequests';
  static const String fbRedeemCodes = 'redeemCodes';
  static const String fbSharedCodes = 'sharedRedeemCodes';
  static const String fbNetworks = 'networks';
  static const String fbTiers = 'tiers';
  static const String fbNetworkTiers = 'networkTiers';
  static const String fbCredit = 'credit';
  static const String fbNotifications = 'notifications';
  static const String fbBulkNotifications = 'bulkNotifications';
  static const String fbSubscriptionPlans = 'subscriptionPlans';
  static const String fbUserSubscriptions = 'userSubscriptions';
  static const String fbStarlinkProducts = 'starlinkProducts';
  static const String fbStarlinkOrders = 'starlinkOrders';
  static const String fbCommissionSettings = 'commissionSettings';
  static const String fbCommissionEntries = 'commissionEntries';
  static const String fbMonthlyPayouts = 'monthlyPayouts';
  static const String fbSettings = 'settings';
  static const String fbAppContent = 'appContent';
  static const String fbHomeBanners = 'homeBanners';
  static const String fbNetworkSubmissions = 'networkSubmissions';
  static const String fbCardSaleLocations = 'cardSaleLocations';

  // Roles
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';
  static const String roleNetworkManager = 'network_manager';

  // Default values
  static const double defaultMaxBalance = 50000;
  static const double minDeposit = 500;

  // Default networks (from original project)
  static const List<Map<String, String>> defaultNetworks = [
    {'id': 'apple-net', 'name': 'Apple Net', 'color': '#1B7A3D', 'bgColor': '#E8F5E9', 'emoji': '🍎'},
    {'id': 'al-faris-net', 'name': 'Al-Faris Net', 'color': '#FF9500', 'bgColor': '#FFF3E0', 'emoji': '⚔️'},
    {'id': 'hi-net', 'name': 'Hi-Net', 'color': '#007AFF', 'bgColor': '#E3F2FD', 'emoji': '📡'},
    {'id': 'bashib-net', 'name': 'BASHIB NET', 'color': '#AF52DE', 'bgColor': '#F3E5F5', 'emoji': '🔥'},
  ];

  // Default card tiers (from original project)
  static const List<Map<String, dynamic>> defaultTiers = [
    {'tier': '200', 'price': 200, 'data': '800 ميجابايت', 'duration': 2, 'icon': '🟢'},
    {'tier': '300', 'price': 300, 'data': '1 جيجابايت', 'duration': 3, 'icon': '🔵'},
    {'tier': '500', 'price': 500, 'data': '2 جيجابايت', 'duration': 5, 'icon': '🟡'},
    {'tier': '1000', 'price': 1000, 'data': '4 جيجابايت', 'duration': 10, 'icon': '🔴'},
    {'tier': '2000', 'price': 2000, 'data': '8 جيجابايت', 'duration': 15, 'icon': '🟣'},
  ];

  // ========== PROVINCES & DISTRICTS (from original project only) ==========
  static const List<Map<String, dynamic>> provinces = [
    {
      'id': 'aden',
      'name': 'العاصمة المؤقتة عدن',
      'nameEn': 'Aden (Capital)',
      'isCapital': true,
      'districts': ['صيرة (كريتر)', 'المعلا', 'التواهي', 'خور مكسر', 'المنصورة', 'الشيخ عثمان', 'دار سعد', 'البريقة'],
    },
    {
      'id': 'lahj',
      'name': 'لحج',
      'nameEn': 'Lahj',
      'districts': ['الحوطة', 'تبن', 'المقاطرة', 'القبيطة', 'طور الباحة', 'المضاربة ورأس العارة', 'المفلحي', 'يهر', 'لبعوس', 'الحد', 'الملاح', 'المسيمير', 'حبيل جبر', 'ردفان (الحبيلين)'],
    },
    {
      'id': 'abyan',
      'name': 'أبين',
      'nameEn': 'Abyan',
      'districts': ['زنجبار', 'خنفر (جعار)', 'لودر', 'مودية', 'الوضيع', 'أحور', 'المحفد', 'جيشان', 'سباح', 'رصد', 'سرار'],
    },
    {
      'id': 'aldhale',
      'name': 'الضالع',
      'nameEn': 'Al Dhale',
      'districts': ['الضالع', 'قعطبة', 'دمت', 'الأزارق', 'جحاف', 'الحشاء', 'الشعيب', 'الحصين', 'جبن'],
    },
    {
      'id': 'shabwah',
      'name': 'شبوة',
      'nameEn': 'Shabwah',
      'districts': ['عتق', 'بيحان', 'عسيلان', 'عين', 'مرخة العليا', 'مرخة السفلى', 'نصاب', 'حطيب', 'الصعيد', 'الروضة', 'حبان', 'ميفعة', 'الرضوم', 'دعر', 'جردان', 'الطلح', 'عرماء'],
    },
    {
      'id': 'hadramout',
      'name': 'حضرموت',
      'nameEn': 'Hadhramaut',
      'districts': ['المكلا', 'أرياف المكلا', 'الشحر', 'غيل باوزير', 'غيل بن يمين', 'الدين', 'حجر', 'بروم وميفع', 'الريدة وقصيعر', 'قصيعر', 'سيئون', 'تريم', 'شبام', 'القطن', 'وادي العين', 'حورة', 'حريضة', 'عمد', 'رخية', 'السوم', 'ثمود', 'رماه', 'القف', 'زمخ ومنوخ', 'ساه', 'دوعن', 'الضليعة', 'يبعث', 'حجر الصيعر', 'العبر'],
    },
    {
      'id': 'almahrah',
      'name': 'المهرة',
      'nameEn': 'Al Mahrah',
      'districts': ['الغيضة', 'شحن', 'حات', 'حوف', 'سيحوت', 'المسيلة', 'قشن', 'حصوين', 'منعر'],
    },
    {
      'id': 'socotra',
      'name': 'أرخبيل سقطرى',
      'nameEn': 'Socotra',
      'districts': ['حديبو', 'قلنسية وعبد الكوري'],
    },
    {
      'id': 'marib',
      'name': 'مأرب',
      'nameEn': "Ma'rib",
      'districts': ['مدينة مأرب', 'مأرب (المديرية)', 'الوادي', 'صرواح', 'مجزر', 'مدغل الجدعان', 'رغوان', 'حريب', 'العبدية', 'ماهلية', 'رحبة', 'الجوبة', 'جبل مراد', 'حريب القراميش'],
    },
    {
      'id': 'taiz',
      'name': 'تعز',
      'nameEn': 'Taiz',
      'districts': ['القاهرة', 'المظفر', 'صالة', 'التعزية', 'صبر الموادم', 'المشرعة والحدنان', 'المعافر', 'الشمايتين (التربة)', 'المواسط', 'الصلو', 'حيفان', 'المسراخ', 'جبل حبشي', 'مقبنة', 'شرعب الرونة', 'شرعب السلام', 'موزع', 'الوازعية', 'ذوباب (باب المندب)', 'المخا', 'الخوخة', 'السياني', 'سامع'],
    },
  ];

  static List<String> getDistricts(String provinceId) {
    final province = provinces.firstWhere(
      (p) => p['id'] == provinceId,
      orElse: () => {'districts': <String>[]},
    );
    return List<String>.from(province['districts'] as List);
  }

  static String getProvinceName(String provinceId) {
    final province = provinces.firstWhere(
      (p) => p['id'] == provinceId,
      orElse: () => {'name': ''},
    );
    return province['name'] as String;
  }
}
