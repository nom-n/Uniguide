# حل مشكلة تسجيل الدخول بجوجل (Google Sign-In Configuration)

المشكلة تكمن في أن تطبيق الأندرويد يحتاج إلى "Web Client ID" ليتمكن من الحصول على `idToken` الذي يرسله للخلفية (backend). الرسالة تظهر لأن المتغير `GOOGLE_WEB_CLIENT_ID` فارغ حالياً.

## الخطوات المطلوبة للحل

### 1. إضافة بصمات الحماية (SHA) إلى Firebase
لقد قمت باستخراج البصمات الخاصة بجهازك:
- **SHA-1**: `95:46:0A:EF:E1:E7:31:FE:9E:06:2D:36:14:00:1F:AD:BB:66:97:59`
- **SHA-256**: `E6:43:B9:C5:41:83:60:F5:98:73:20:D9:19:05:DE:FA:B2:AC:45:10:0C:0F:70:73:F4:BB:40:DC:F8:FC:7A:3B`

**الخطوات:**
1. اذهب إلى [Firebase Console](https://console.firebase.google.com/).
2. في إعدادات المشروع (Project Settings) -> عام (General) -> تطبيقاتك (Your apps).
3. اضغط على "Add fingerprint" وأضف كلاً من SHA-1 و SHA-256.
4. قم بتحميل ملف `google-services.json` الجديد وضعه في `android/app/` (استبدل الملف القديم).

### 2. إعداد Firebase و Google Cloud
- اذهب إلى [Firebase Console](https://console.firebase.google.com/).
- في إعدادات المشروع (Project Settings) -> عام (General) -> تطبيقاتك (Your apps).
- أضف بصمة SHA-1 التي استخرجتها.
- قم بتحميل ملف `google-services.json` الجديد وضعه في `android/app/` (استبدل الملف القديم).
- اذهب إلى [Google Cloud Console](https://console.cloud.google.com/apis/credentials).
- ابحث عن OAuth 2.0 Client IDs. ستجد نوع "Web client (Auto-managed for Google Sign-in)".
- انسخ "Client ID".

### 3. تشغيل التطبيق بالمعرف الصحيح
يجب تمرير المعرف عند تشغيل التطبيق باستخدام `--dart-define`.

```bash
flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=your_client_id_here
```

## التغييرات المقترحة في الكود

### [Auth Component]

سأقوم بتحديث `AuthService` ليكون الخطأ أكثر وضوحاً إذا لم يتم توفير المعرف، ولتسهيل عملية الإعداد.

#### [MODIFY] [auth_service.dart](file:///C:/Users/am9ad/uniguide/lib/core/auth/auth_service.dart)
- تحسين رسالة الخطأ لتوجيه المطور للخطوات الصحيحة.
- إضافة تعليق يوضح كيفية الحصول على المعرف.

## خطة التحقق (Verification Plan)

### التحقق اليدوي
- تشغيل التطبيق باستخدام `--dart-define` ومعرف صالح.
- الضغط على زر "جوجل".
- التأكد من ظهور نافذة اختيار الحساب وعدم ظهور الخطأ السابق.
