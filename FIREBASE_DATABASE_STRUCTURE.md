# Apple.NET — Firebase Realtime Database Structure
## Complete & Secure Database Schema v2.1.0
### Developed by QTBM DEV | Contact: qtbm.dev@gmail.com

---

## Security Rules (firebase-rules.json)

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "auth != null && (auth.uid == $uid || root.child('users').child(auth.uid).child('role').val() == 'admin')",
        ".write": "auth != null && (auth.uid == $uid || root.child('users').child(auth.uid).child('role').val() == 'admin')"
      }
    },
    "networks": {
      ".read": "auth != null",
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
    },
    "tiers": {
      ".read": "auth != null",
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
    },
    "cards": {
      ".read": "auth != null",
      ".write": "auth != null && (root.child('users').child(auth.uid).child('role').val() == 'admin' || root.child('users').child(auth.uid).child('role').val() == 'network_manager')"
    },
    "orders": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "bankDetails": {
      ".read": "auth != null",
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
    },
    "advertisements": {
      ".read": true,
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
    },
    "simCards": {
      ".read": "auth != null",
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
    },
    "depositRequests": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "redeemCodes": {
      ".read": "auth != null",
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
    },
    "sharedRedeemCodes": {
      ".read": "auth != null",
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
    },
    "notifications": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && (auth.uid == $uid || root.child('users').child(auth.uid).child('role').val() == 'admin')"
      }
    },
    "bulkNotifications": {
      ".read": "auth != null",
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
    },
    "subscriptionPlans": {
      ".read": "auth != null",
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
    },
    "userSubscriptions": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "starlinkProducts": {
      ".read": true,
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
    },
    "starlinkOrders": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "commissionSettings": {
      ".read": "auth != null",
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
    },
    "commissionEntries": {
      ".read": "auth != null",
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
    },
    "monthlyPayouts": {
      ".read": "auth != null",
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
    },
    "settings": {
      ".read": true,
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
    },
    "appContent": {
      ".read": true,
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
    },
    "homeBanners": {
      ".read": true,
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
    },
    "networkSubmissions": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "cardSaleLocations": {
      ".read": "auth != null",
      ".write": "auth != null && (root.child('users').child(auth.uid).child('role').val() == 'admin' || root.child('users').child(auth.uid).child('role').val() == 'network_manager')"
    },
    "credit": {
      "$uid": {
        ".read": "auth != null && (auth.uid == $uid || root.child('users').child(auth.uid).child('role').val() == 'admin')",
        ".write": "auth != null && (auth.uid == $uid || root.child('users').child(auth.uid).child('role').val() == 'admin')"
      }
    },
    "networkTiers": {
      ".read": "auth != null",
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
    }
  }
}
```

---

## Database Nodes & Schema

### 1. `users/{uid}`
Stores user profile information. Key = Firebase Auth UID.

```json
{
  "uid": "string — Firebase Auth UID",
  "email": "string — User email address",
  "displayName": "string — Full display name",
  "phone": "string — Phone number (Yemen format 967XXXXXXXX)",
  "role": "string — One of: 'user' | 'admin' | 'network_manager'",
  "balance": "number — Current balance in RYR (default: 0)",
  "isActive": "boolean — Account active status (default: true)",
  "managedNetwork": "string? — Network ID for network_manager role",
  "photoUrl": "string? — Profile photo URL",
  "createdAt": "string — ISO 8601 date",
  "fcmToken": "string? — Firebase Cloud Messaging token",
  "lastLoginAt": "string? — ISO 8601 date of last login"
}
```

### 2. `networks/{networkId}`
Stores network (hotspot) information.

```json
{
  "id": "string — Unique network ID (e.g., 'apple-net')",
  "name": "string — Network display name",
  "color": "string — Hex color code (e.g., '#1B7A3D')",
  "bgColor": "string — Background hex color (e.g., '#E8F5E9')",
  "emoji": "string — Emoji icon (e.g., '🍎')",
  "ownerId": "string — User UID of network owner",
  "ownerName": "string — Owner display name",
  "ownerPhone": "string? — Owner phone number",
  "location": "string? — General location description",
  "provinceId": "string? — Province ID (from app_constants.dart)",
  "provinceName": "string? — Province Arabic name",
  "district": "string? — District name",
  "exactLocation": "string? — Precise location/address",
  "connectionIP": "string? — Network connection IP",
  "imageBase64": "string? — Base64 encoded network image",
  "networkType": "string? — Type (e.g., 'hotspot', 'fiber')",
  "coverage": "string? — Coverage description",
  "speed": "string? — Speed description",
  "isActive": "boolean — Whether network is active",
  "createdAt": "string — ISO 8601 date"
}
```

### 3. `tiers/{tierId}`
Card tier/price categories.

```json
{
  "id": "string — Unique tier ID",
  "tier": "string — Tier label (e.g., '200', '300', '500', '1000', '2000')",
  "price": "number — Price in RYR",
  "data": "string — Data allowance description (e.g., '2 جيجابايت')",
  "duration": "number — Duration in days",
  "icon": "string — Emoji icon (e.g., '🟡')",
  "networkId": "string? — Associated network ID (null = global)",
  "isActive": "boolean — Whether tier is active",
  "createdAt": "string — ISO 8601 date"
}
```

### 4. `cards/{cardId}`
Individual internet cards.

```json
{
  "id": "string — Unique card ID (auto-generated)",
  "code": "string — Card redemption code (encrypted/Base64 safe)",
  "price": "number — Card price in RYR",
  "data": "string — Data allowance",
  "duration": "number — Duration in days",
  "isUsed": "boolean — Whether card has been used",
  "usedBy": "string? — UID of user who used the card",
  "usedAt": "string? — ISO 8601 date when card was used",
  "tier": "string — Tier label (e.g., '500')",
  "network": "string — Network ID",
  "networkName": "string — Network display name",
  "addedBy": "string? — UID of admin/manager who added the card",
  "createdAt": "string — ISO 8601 date"
}
```

### 5. `orders/{orderId}`
Card purchase order records.

```json
{
  "id": "string — Unique order ID",
  "userId": "string — Buyer UID",
  "userName": "string — Buyer display name",
  "userEmail": "string — Buyer email",
  "cardId": "string — Purchased card ID",
  "cardCode": "string — Card code (shown after purchase)",
  "networkId": "string — Network ID",
  "networkName": "string — Network display name",
  "tier": "string — Tier label",
  "price": "number — Price in RYR",
  "status": "string — 'completed' | 'refunded'",
  "purchasedAt": "string — ISO 8601 date"
}
```

### 6. `bankDetails/{bankId}`
Bank account details for deposits.

```json
{
  "id": "string — Unique bank ID",
  "bankName": "string — Bank name (e.g., 'بنك الكريمي')",
  "accountName": "string — Account holder name",
  "accountNumber": "string — Account number",
  "isActive": "boolean — Whether bank is active for deposits",
  "createdAt": "string — ISO 8601 date"
}
```

### 7. `depositRequests/{depositId}`
User deposit requests.

```json
{
  "id": "string — Unique deposit request ID",
  "userId": "string — Requester UID",
  "userName": "string — Requester display name",
  "userEmail": "string — Requester email",
  "bankId": "string? — Selected bank ID",
  "bankName": "string — Bank display name",
  "amount": "number — Deposit amount in RYR",
  "referenceNumber": "string — Transaction reference number",
  "status": "string — 'pending' | 'approved' | 'rejected'",
  "rejectionReason": "string? — Reason if rejected",
  "imageBase64": "string? — Base64 receipt image",
  "reviewedBy": "string? — Admin UID who reviewed",
  "reviewedAt": "string? — ISO 8601 review date",
  "createdAt": "string — ISO 8601 date"
}
```

### 8. `advertisements/{adId}`
App advertisements/promotions.

```json
{
  "id": "string — Unique ad ID",
  "title": "string — Ad title",
  "description": "string — Ad description",
  "imageUrl": "string? — External image URL",
  "imageBase64": "string? — Base64 encoded ad image",
  "isActive": "boolean — Whether ad is currently displayed",
  "priority": "number — Display order (higher = shown first)",
  "createdAt": "string — ISO 8601 date"
}
```

### 9. `redeemCodes/{codeId}`
Single-use redeem codes for balance.

```json
{
  "id": "string — Unique code ID",
  "code": "string — Redeem code string",
  "amount": "number — Balance amount in RYR",
  "isUsed": "boolean — Whether code has been redeemed",
  "usedBy": "string? — UID of user who redeemed",
  "usedByName": "string? — Display name of redeemer",
  "usedAt": "string? — ISO 8601 redemption date",
  "createdBy": "string? — Admin UID who created the code",
  "createdAt": "string — ISO 8601 date"
}
```

### 10. `sharedRedeemCodes/{codeId}`
Multi-use redeem codes.

```json
{
  "id": "string — Unique code ID",
  "code": "string — Shared redeem code string",
  "amount": "number — Balance amount per redemption",
  "maxRedemptions": "number — Maximum number of uses",
  "currentRedemptions": "number — Current number of uses",
  "description": "string? — Code description",
  "isActive": "boolean — Whether code is still valid",
  "createdBy": "string? — Admin UID",
  "createdAt": "string — ISO 8601 date"
}
```

### 11. `notifications/{uid}/{notificationId}`
Per-user notification records.

```json
{
  "id": "string — Unique notification ID",
  "type": "string — 'info' | 'warning' | 'success' | 'deposit' | 'card' | 'promotion'",
  "title": "string — Notification title",
  "message": "string — Notification body",
  "isRead": "boolean — Whether user has read it",
  "relatedId": "string? — ID of related entity (deposit, card, etc.)",
  "createdAt": "string — ISO 8601 date"
}
```

### 12. `bulkNotifications/{notificationId}`
Admin-sent bulk notifications log.

```json
{
  "id": "string — Unique bulk notification ID",
  "title": "string — Notification title",
  "message": "string — Notification body",
  "type": "string — 'info' | 'warning' | 'promotion'",
  "targetCount": "number — Number of users targeted",
  "sentBy": "string — Admin UID who sent",
  "sentAt": "string — ISO 8601 date"
}
```

### 13. `starlinkProducts/{productId}`
Starlink device products.

```json
{
  "id": "string — Unique product ID",
  "name": "string — Product name",
  "description": "string — Product description",
  "priceUSD": "number — Price in USD",
  "quantity": "number — Available stock",
  "imageBase64": "string? — Base64 product image",
  "specs": {
    "downloadSpeed": "string — e.g., '50-200 Mbps'",
    "uploadSpeed": "string — e.g., '10-20 Mbps'",
    "latency": "string — e.g., '20-40ms'",
    "coverage": "string — e.g., 'Up to 5km radius'"
  },
  "isActive": "boolean — Whether product is available for ordering",
  "createdAt": "string — ISO 8601 date"
}
```

### 14. `starlinkOrders/{orderId}`
Starlink product orders.

```json
{
  "id": "string — Unique order ID",
  "userId": "string — Buyer UID",
  "userName": "string — Buyer display name",
  "userEmail": "string — Buyer email",
  "userPhone": "string? — Buyer phone number",
  "productId": "string — Product ID",
  "productName": "string — Product name",
  "priceUSD": "number — Price in USD at time of order",
  "status": "string — 'pending' | 'confirmed' | 'shipped' | 'delivered' | 'cancelled'",
  "notes": "string? — Order notes",
  "createdAt": "string — ISO 8601 date"
}
```

### 15. `subscriptionPlans/{planId}`
Subscription plan definitions.

```json
{
  "id": "string — Unique plan ID",
  "name": "string — Plan name",
  "price": "number — Price in RYR",
  "description": "string — Plan description",
  "durationDays": "number — Plan duration in days",
  "features": ["string — Feature 1", "string — Feature 2"],
  "isActive": "boolean — Whether plan is available",
  "createdAt": "string — ISO 8601 date"
}
```

### 16. `userSubscriptions/{subscriptionId}`
User subscription records.

```json
{
  "id": "string — Unique subscription ID",
  "uid": "string — User UID",
  "planId": "string — Plan ID",
  "planName": "string — Plan name at time of subscription",
  "activatedAt": "string — ISO 8601 activation date",
  "expiresAt": "string — ISO 8601 expiration date",
  "isActive": "boolean — Whether subscription is current",
  "autoRenew": "boolean — Whether subscription auto-renews"
}
```

### 17. `commissionSettings/{settingId}`
Network manager commission settings.

```json
{
  "id": "string — Unique setting ID",
  "managerUid": "string — Network manager UID",
  "managerName": "string — Manager display name",
  "networkId": "string — Associated network ID",
  "networkName": "string — Network display name",
  "defaultRate": "number — Default commission percentage",
  "provinceRates": {"provinceId": "number — Rate per province"},
  "districtRates": {"districtName": "number — Rate per district"},
  "tierRates": {"tierLabel": "number — Rate per tier"},
  "updatedAt": "string — ISO 8601 date"
}
```

### 18. `commissionEntries/{entryId}`
Individual commission records.

```json
{
  "id": "string — Unique entry ID",
  "managerUid": "string — Network manager UID",
  "managerName": "string — Manager display name",
  "networkId": "string — Network ID",
  "networkName": "string — Network name",
  "cardId": "string — Sold card ID",
  "cardPrice": "number — Card price in RYR",
  "commissionRate": "number — Commission rate percentage",
  "commissionAmount": "number — Commission amount in RYR",
  "soldAt": "string — ISO 8601 date of sale",
  "isPaid": "boolean — Whether commission has been paid"
}
```

### 19. `monthlyPayouts/{payoutId}`
Monthly commission payout records.

```json
{
  "id": "string — Unique payout ID",
  "managerUid": "string — Network manager UID",
  "managerName": "string — Manager display name",
  "networkId": "string — Network ID",
  "amount": "number — Total payout amount in RYR",
  "month": "string — Month (e.g., '2026-01')",
  "status": "string — 'pending' | 'paid'",
  "paidAt": "string? — ISO 8601 date when paid",
  "entries": "number — Number of commission entries included"
}
```

### 20. `settings`
Global app settings (single object).

```json
{
  "appVersion": "string — Current app version (e.g., '2.1.0')",
  "forceUpdate": "boolean — Force users to update",
  "maintenanceMode": "boolean — App under maintenance",
  "depositEnabled": "boolean — Allow deposits",
  "registrationOpen": "boolean — Allow new registrations",
  "maxBalance": "number — Maximum user balance (default: 50000)",
  "minDeposit": "number — Minimum deposit amount (default: 500)",
  "ownerName": "string — App owner name",
  "ownerPhone": "string — Owner phone",
  "ownerEmail": "string — Owner email",
  "ownerPhotoBase64": "string? — Owner photo base64",
  "whatsappNumber": "string — WhatsApp support number",
  "supportEmail": "string — Support email",
  "updatedAt": "string — ISO 8601 date"
}
```

### 21. `appContent`
Editable app content (single object).

```json
{
  "privacyPolicyAr": "string — Arabic privacy policy",
  "privacyPolicyEn": "string — English privacy policy",
  "termsOfUseAr": "string — Arabic terms of use",
  "termsOfUseEn": "string — English terms of use",
  "aboutAppAr": "string — Arabic about text",
  "aboutAppEn": "string — English about text",
  "updatedAt": "string — ISO 8601 date"
}
```

### 22. `homeBanners/{bannerId}`
Home page banner images.

```json
{
  "id": "string — Unique banner ID",
  "title": "string — Banner title",
  "imageBase64": "string? — Base64 banner image",
  "imageUrl": "string? — External image URL",
  "order": "number — Display order",
  "isActive": "boolean — Whether banner is shown",
  "createdAt": "string — ISO 8601 date"
}
```

### 23. `networkSubmissions/{submissionId}`
User-submitted network requests.

```json
{
  "id": "string — Unique submission ID",
  "userId": "string — Submitter UID",
  "userName": "string — Submitter name",
  "userEmail": "string — Submitter email",
  "networkName": "string — Proposed network name",
  "networkType": "string — Network type",
  "provinceId": "string — Province ID",
  "provinceName": "string — Province name",
  "district": "string — District name",
  "exactLocation": "string — Exact location",
  "ownerName": "string — Network owner name",
  "ownerPhone": "string — Owner phone",
  "description": "string? — Additional description",
  "status": "string — 'pending' | 'approved' | 'rejected'",
  "reviewedBy": "string? — Admin UID",
  "reviewedAt": "string? — ISO 8601 date",
  "createdAt": "string — ISO 8601 date"
}
```

### 24. `cardSaleLocations/{locationId}`
Physical card sale locations.

```json
{
  "id": "string — Unique location ID",
  "name": "string — Location name",
  "address": "string — Location address",
  "phone": "string — Contact phone",
  "provinceId": "string — Province ID",
  "provinceName": "string — Province name",
  "district": "string — District name",
  "networkId": "string? — Associated network ID",
  "networkName": "string? — Network name",
  "isActive": "boolean — Whether location is active",
  "createdAt": "string — ISO 8601 date"
}
```

### 25. `simCards/{simId}`
SIM card inventory.

```json
{
  "id": "string — Unique SIM ID",
  "simNumber": "string — SIM card number",
  "networkId": "string — Associated network ID",
  "networkName": "string — Network name",
  "isActive": "boolean — Whether SIM is active",
  "assignedTo": "string? — User UID if assigned",
  "assignedAt": "string? — ISO 8601 date",
  "createdAt": "string — ISO 8601 date"
}
```

### 26. `credit/{uid}/{creditId}`
User credit/balance history.

```json
{
  "id": "string — Unique credit entry ID",
  "type": "string — 'deposit' | 'purchase' | 'gift' | 'redeem' | 'commission' | 'refund'",
  "amount": "number — Amount in RYR (positive for credit, negative for debit)",
  "description": "string — Description of transaction",
  "relatedId": "string? — Related entity ID (deposit, card, etc.)",
  "date": "string — ISO 8601 date"
}
```

### 27. `networkTiers/{networkTierId}`
Network-specific tier configurations.

```json
{
  "id": "string — Unique ID",
  "networkId": "string — Network ID",
  "tierId": "string — Tier ID",
  "isAvailable": "boolean — Whether this tier is available for this network",
  "customPrice": "number? — Override price if different from default",
  "createdAt": "string — ISO 8601 date"
}
```

---

## Indexes (Recommended)

```json
{
  "rules": {
    "cards": {
      ".indexOn": ["network", "tier", "isUsed", "createdAt"]
    },
    "depositRequests": {
      ".indexOn": ["userId", "status", "createdAt"]
    },
    "orders": {
      ".indexOn": ["userId", "network", "tier", "purchasedAt"]
    },
    "redeemCodes": {
      ".indexOn": ["code", "isUsed", "createdAt"]
    },
    "sharedRedeemCodes": {
      ".indexOn": ["code", "isActive"]
    },
    "notifications": {
      "$uid": {
        ".indexOn": ["isRead", "createdAt"]
      }
    },
    "starlinkOrders": {
      ".indexOn": ["userId", "status", "createdAt"]
    },
    "commissionEntries": {
      ".indexOn": ["managerUid", "networkId", "isPaid", "soldAt"]
    },
    "networkSubmissions": {
      ".indexOn": ["status", "createdAt"]
    },
    "credit": {
      "$uid": {
        ".indexOn": ["type", "date"]
      }
    },
    "users": {
      ".indexOn": ["role", "isActive"]
    },
    "simCards": {
      ".indexOn": ["networkId", "isActive"]
    }
  }
}
```

---

## Data Validation Rules

### User Data
- `email` must be valid email format
- `role` must be one of: `user`, `admin`, `network_manager`
- `balance` must be >= 0 and <= maxBalance (default: 50000)
- `isActive` defaults to `true`

### Card Data
- `code` must be unique across all cards
- `price` must be > 0
- `isUsed` can only transition from `false` to `true` (one-way)
- `tier` must match an existing tier in `tiers` node

### Deposit Data
- `amount` must be >= minDeposit (default: 500)
- `status` transitions: `pending` -> `approved` | `rejected`
- `rejectionReason` required when status is `rejected`

### Network Data
- `ownerId` must reference existing user with role `admin` or `network_manager`
- `provinceId` must be from the valid provinces list
- `district` must be from the valid districts for that province

---

## Initialization Script

To initialize the database with default data, use the Firebase Console or a script to set:

1. **Default networks** (from AppConstants.defaultNetworks)
2. **Default tiers** (from AppConstants.defaultTiers)
3. **Settings** with default values
4. **Bank details** for Yemeni banks

---

*Last updated: 2026-06-04 | Apple.NET v2.1.0 | QTBM DEV*
