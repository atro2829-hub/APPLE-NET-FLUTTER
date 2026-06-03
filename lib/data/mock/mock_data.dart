import '../models/app_models.dart';

final mockUser = AppUser(uid: 'demo123', email: 'user@applenet.ye', displayName: 'أحمد محمد', phone: '777123456', role: 'user', balance: 15000, isActive: true);

final mockNetworks = [
  NetworkModel(id: 'net1', name: 'Apple Net', color: '#1B7A3D', emoji: '🍎', provinceName: 'عدن', district: 'المعلا', networkType: 'wifi', coverage: '2 كم', speed: '10 Mbps', ownerPhone: '777111111'),
  NetworkModel(id: 'net2', name: 'Al-Faris Net', color: '#FF9500', emoji: '⚡', provinceName: 'عدن', district: 'المنصورة', networkType: 'wifi', coverage: '1.5 كم', speed: '8 Mbps', ownerPhone: '777222222'),
  NetworkModel(id: 'net3', name: 'Hi-Net', color: '#007AFF', emoji: '🌐', provinceName: 'لحج', district: 'المفلحي', networkType: 'fiber', coverage: '3 كم', speed: '20 Mbps', ownerPhone: '777333333'),
  NetworkModel(id: 'net4', name: 'BASHIB NET', color: '#AF52DE', emoji: '🔥', provinceName: 'أبين', district: 'زنجبار', networkType: 'wifi', coverage: '1 كم', speed: '5 Mbps', ownerPhone: '777444444'),
  NetworkModel(id: 'net5', name: 'YemenNet', color: '#FF3B30', emoji: '📡', provinceName: 'تعز', district: 'المظفر', networkType: '4g_lte', coverage: '5 كم', speed: '15 Mbps', ownerPhone: '777555555'),
];

final mockTiers = [
  TierModel(id: 't1', tier: '200', price: 200, data: '2 جيجابايت', duration: 1, icon: '🟢', networkId: 'net1'),
  TierModel(id: 't2', tier: '500', price: 500, data: '5 جيجابايت', duration: 3, icon: '🔵', networkId: 'net1'),
  TierModel(id: 't3', tier: '1000', price: 1000, data: '10 جيجابايت', duration: 7, icon: '🟡', networkId: 'net1'),
  TierModel(id: 't4', tier: '200', price: 200, data: '2 جيجابايت', duration: 1, icon: '🟢', networkId: 'net2'),
  TierModel(id: 't5', tier: '500', price: 500, data: '5 جيجابايت', duration: 3, icon: '🔵', networkId: 'net2'),
  TierModel(id: 't6', tier: '1000', price: 1000, data: '10 جيجابايت', duration: 7, icon: '🟡', networkId: 'net2'),
  TierModel(id: 't7', tier: '500', price: 500, data: '5 جيجابايت', duration: 3, icon: '🔵', networkId: 'net3'),
  TierModel(id: 't8', tier: '2000', price: 2000, data: '20 جيجابايت', duration: 30, icon: '🟣', networkId: 'net3'),
  TierModel(id: 't9', tier: '200', price: 200, data: '2 جيجابايت', duration: 1, icon: '🟢', networkId: 'net4'),
  TierModel(id: 't10', tier: '500', price: 450, data: '5 جيجابايت', duration: 3, icon: '🔵', networkId: 'net4'),
  TierModel(id: 't11', tier: '300', price: 300, data: '3 جيجابايت', duration: 2, icon: '🟠', networkId: 'net5'),
  TierModel(id: 't12', tier: '1000', price: 900, data: '10 جيجابايت', duration: 7, icon: '🟡', networkId: 'net5'),
];

final mockPurchasedCards = [
  CardModel(id: 'c1', code: 'AP-XK7M2P-001', price: 200, data: '2 جيجابايت', duration: 1, isUsed: true, tier: '200', network: 'net1', networkName: 'Apple Net'),
  CardModel(id: 'c2', code: 'AP-QW4N8R-002', price: 500, data: '5 جيجابايت', duration: 3, isUsed: true, tier: '500', network: 'net2', networkName: 'Al-Faris Net'),
  CardModel(id: 'c3', code: 'AP-LK9J5T-003', price: 1000, data: '10 جيجابايت', duration: 7, isUsed: false, tier: '1000', network: 'net1', networkName: 'Apple Net'),
];

final mockStarlinkProducts = [
  StarlinkProduct(id: 'sl1', name: 'Starlink Standard', description: 'جهاز إنترنت فضائي قياسي', priceUSD: 349, specs: {'سرعة التحميل': '50-200 Mbps', 'سرعة الرفع': '10-20 Mbps', 'الاستجابة': '20-40ms', 'التغطية': 'داخل المنزل'}),
  StarlinkProduct(id: 'sl2', name: 'Starlink Mini', description: 'جهاز محمول صغير', priceUSD: 599, specs: {'سرعة التحميل': '50-150 Mbps', 'سرعة الرفع': '10-15 Mbps', 'الاستجابة': '25-50ms', 'التغطية': 'محمول'}),
  StarlinkProduct(id: 'sl3', name: 'Starlink High Performance', description: 'جهاز عالي الأداء', priceUSD: 2500, specs: {'سرعة التحميل': '100-350 Mbps', 'سرعة الرفع': '20-40 Mbps', 'الاستجابة': '15-30ms', 'التغطية': 'شاملة'}),
];

final mockBanks = [
  BankDetail(id: 'b1', bankName: 'البنك الأهلي اليمني', accountName: 'عبدالعليم اليافعي', accountNumber: '0012345678'),
  BankDetail(id: 'b2', bankName: 'بنك الكريمي', accountName: 'عبدالعليم اليافعي', accountNumber: '9876543210'),
  BankDetail(id: 'b3', bankName: 'بنك سبأ الإسلامي', accountName: 'عبدالعليم اليافعي', accountNumber: '5551234567'),
];

final mockCreditHistory = [
  CreditHistory(id: 'h1', type: 'deposit', amount: 10000, description: 'إيداع - البنك الأهلي', date: DateTime.now().subtract(const Duration(days: 5))),
  CreditHistory(id: 'h2', type: 'purchase', amount: -500, description: 'شراء كرت - Apple Net', date: DateTime.now().subtract(const Duration(days: 3))),
  CreditHistory(id: 'h3', type: 'gift', amount: 2000, description: 'هدية من الإدارة', date: DateTime.now().subtract(const Duration(days: 2))),
  CreditHistory(id: 'h4', type: 'purchase', amount: -200, description: 'شراء كرت - Al-Faris Net', date: DateTime.now().subtract(const Duration(days: 1))),
  CreditHistory(id: 'h5', type: 'redeem', amount: 5000, description: 'تحصيل كود شحن', date: DateTime.now()),
];

final mockNotifications = [
  AppNotification(id: 'n1', type: 'deposit_approved', title: 'تم قبول إيداعك', message: 'تم إضافة 10,000 ر.ي لرصيدك', isRead: false, createdAt: DateTime.now().subtract(const Duration(hours: 2))),
  AppNotification(id: 'n2', type: 'purchase', title: 'شراء ناجح', message: 'تم شراء كرت Apple Net - 5 جيجابايت', isRead: false, createdAt: DateTime.now().subtract(const Duration(hours: 5))),
  AppNotification(id: 'n3', type: 'gift_received', title: 'هدية من الإدارة', message: 'تم إضافة 2,000 ر.ي كهدية لرصيدك', isRead: true, createdAt: DateTime.now().subtract(const Duration(days: 1))),
  AppNotification(id: 'n4', type: 'general', title: 'تحديث جديد', message: 'تم إضافة شبكات جديدة في منطقتك', isRead: true, createdAt: DateTime.now().subtract(const Duration(days: 2))),
];

final mockAds = [
  Advertisement(id: 'ad1', title: 'عروض الصيف', description: 'احصل على كروت بأسعار مخفضة هذا الصيف!'),
  Advertisement(id: 'ad2', title: 'Starlink متاح الآن', description: 'إنترنت فضائي عالي السرعة في كل مكان'),
  Advertisement(id: 'ad3', title: 'شريحة Apple.NET', description: 'قريباً - شريحة إنترنت خاصة بـ Apple.NET'),
];

final mockSubscriptions = [
  SubscriptionPlan(id: 'sp1', name: 'باقة أسبوعية', price: 1500, description: 'إنترنت غير محدود لمدة أسبوع', durationDays: 7),
  SubscriptionPlan(id: 'sp2', name: 'باقة شهرية', price: 5000, description: 'إنترنت غير محدود لمدة شهر', durationDays: 30),
  SubscriptionPlan(id: 'sp3', name: 'باقة 3 أشهر', price: 12000, description: 'إنترنت غير محدود لمدة 3 أشهر', durationDays: 90),
];

const double mockMaxBalance = 50000;
