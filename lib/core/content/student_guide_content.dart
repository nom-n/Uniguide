import 'package:flutter/material.dart';
import 'package:uniguide/l10n/app_localizations.dart';

enum GuideCategory {
  preArrival,
  afterArrival,
  banking,
  housing,
  universityLife,
  transport,
  studentTips,
  maps,
}

class GuideStep {
  const GuideStep({
    required this.title,
    required this.details,
    this.requiredDocuments = const [],
    this.warnings = const [],
    this.links = const [],
  });

  final String title;
  final String details;
  final List<String> requiredDocuments;
  final List<String> warnings;
  final List<GuideLink> links;
}

class GuideLink {
  const GuideLink({required this.label, required this.url});

  final String label;
  final String url;
}

class GuideArticle {
  const GuideArticle({
    required this.id,
    required this.category,
    required this.icon,
    required this.title,
    required this.summary,
    required this.steps,
    this.tags = const [],
  });

  final String id;
  final GuideCategory category;
  final IconData icon;
  final String title;
  final String summary;
  final List<GuideStep> steps;
  final List<String> tags;

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    final haystack = [
      id,
      title,
      summary,
      ...tags,
      for (final step in steps) ...[
        step.title,
        step.details,
        ...step.requiredDocuments,
        ...step.warnings,
      ],
    ].join(' ').toLowerCase();
    return haystack.contains(normalized);
  }
}

class StudentTask {
  const StudentTask({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
  });

  final String id;
  final String title;
  final String description;
  final GuideCategory category;
  final int priority;
}

class ImportantPlace {
  const ImportantPlace({
    required this.name,
    required this.type,
    required this.city,
    required this.description,
    required this.url,
  });

  final String name;
  final String type;
  final String city;
  final String description;
  final String url;
}

class StudentGuideContent {
  const StudentGuideContent._();

  static List<GuideArticle> articles(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return _arabicArticles;
      case 'tr':
        return _turkishArticles;
      case 'fr':
        return _frenchArticles;
      case 'id':
        return _indonesianArticles;
      case 'kk':
        return _kazakhArticles;
      case 'so':
        return _somaliArticles;
      case 'ur':
        return _urduArticles;
      default:
        return _englishArticles;
    }
  }

  static List<StudentTask> tasks(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return _arabicTasks;
      case 'tr':
        return _turkishTasks;
      case 'fr':
        return _frenchTasks;
      case 'id':
        return _indonesianTasks;
      case 'kk':
        return _kazakhTasks;
      case 'so':
        return _somaliTasks;
      case 'ur':
        return _urduTasks;
      default:
        return _englishTasks;
    }
  }

  static List<ImportantPlace> places(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return _arabicPlaces;
      case 'tr':
        return _turkishPlaces;
      case 'fr':
        return _frenchPlaces;
      case 'id':
        return _indonesianPlaces;
      case 'kk':
        return _kazakhPlaces;
      case 'so':
        return _somaliPlaces;
      case 'ur':
        return _urduPlaces;
      default:
        return _englishPlaces;
    }
  }

  static String categoryLabel(GuideCategory category, BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    switch (category) {
      case GuideCategory.preArrival:
        return lang.categoryPreArrival;
      case GuideCategory.afterArrival:
        return lang.categoryAfterArrival;
      case GuideCategory.banking:
        return lang.categoryBanking;
      case GuideCategory.housing:
        return lang.categoryHousing;
      case GuideCategory.universityLife:
        return lang.categoryUniversityLife;
      case GuideCategory.transport:
        return lang.categoryTransport;
      case GuideCategory.studentTips:
        return lang.categoryStudentTips;
      case GuideCategory.maps:
        return lang.categoryMaps;
    }
  }

  static GuideArticle? nextRecommendedArticle({
    required Locale locale,
    required Set<String> completedTaskIds,
  }) {
    final pendingTasks =
        tasks(
            locale,
          ).where((task) => !completedTaskIds.contains(task.id)).toList()
          ..sort((a, b) => a.priority.compareTo(b.priority));
    if (pendingTasks.isEmpty) return articles(locale).first;
    final nextCategory = pendingTasks.first.category;
    for (final article in articles(locale)) {
      if (article.category == nextCategory) return article;
    }
    return articles(locale).first;
  }
}

const _arabicArticles = [
  GuideArticle(
    id: 'pre-arrival-checklist',
    category: GuideCategory.preArrival,
    icon: Icons.flight_takeoff,
    title: 'قائمة ما قبل السفر',
    summary: 'كل ما تحتاجه لتجهيز ملف الجامعة والتأشيرة والسفر إلى تركيا بثقة.',
    tags: ['تأشيرة', 'قبول', 'سفر', 'وثائق'],
    steps: [
      GuideStep(
        title: 'جهّز ملف الجامعة',
        details:
            'احتفظ بنسخ رقمية وورقية من القبول، الشهادة، كشف العلامات، جواز السفر، وصور شخصية حديثة.',
        requiredDocuments: [
          'قبول الجامعة',
          'جواز سفر صالح',
          'الشهادات مترجمة ومصدقة',
          'صور شخصية',
        ],
      ),
      GuideStep(
        title: 'راجع متطلبات التأشيرة',
        details:
            'تختلف المتطلبات حسب الجنسية. راجع القنصلية أو موقع التأشيرة قبل حجز الرحلة.',
        requiredDocuments: [
          'قبول جامعي',
          'تأمين سفر عند الطلب',
          'إثبات مالي عند الطلب',
        ],
      ),
      GuideStep(
        title: 'استعد للسفر',
        details:
            'احمل الوثائق المهمة في حقيبة اليد، واحفظ عنوان السكن المؤقت ورقم تواصل في تركيا.',
        warnings: [
          'لا تشحن الوثائق الأصلية في حقيبة السفر.',
          'تأكد من صلاحية الجواز لأكثر من 6 أشهر.',
        ],
      ),
    ],
  ),
  GuideArticle(
    id: 'after-arrival-residence',
    category: GuideCategory.afterArrival,
    icon: Icons.assignment_ind,
    title: 'الإقامة الطلابية والخطوات الرسمية',
    summary:
        'خطة عملية لاستخراج الرقم الضريبي، التأمين، تثبيت العنوان، وموعد الإقامة.',
    tags: ['إقامة', 'رقم ضريبي', 'تأمين صحي', 'عنوان'],
    steps: [
      GuideStep(
        title: 'استخرج الرقم الضريبي',
        details:
            'يمكن استخراجه عبر الإنترنت أو من دائرة الضرائب، وغالباً تحتاجه للبنك والإقامة.',
        requiredDocuments: ['جواز السفر', 'عنوان في تركيا'],
      ),
      GuideStep(
        title: 'أكمل التسجيل الجامعي',
        details:
            'ثبّت قيدك في الجامعة واحصل على وثيقة الطالب لاستخدامها في الإقامة وكرت المواصلات.',
      ),
      GuideStep(
        title: 'احجز موعد الإقامة',
        details:
            'أكمل الطلب، جهّز التأمين الصحي، وثيقة الطالب، صور شخصية، وصل الرسوم، وعقد/تثبيت العنوان.',
      ),
    ],
  ),
  GuideArticle(
    id: 'banking-for-students',
    category: GuideCategory.banking,
    icon: Icons.account_balance,
    title: 'فتح حساب بنكي للطلاب',
    summary: 'مقارنة عملية للبنوك وخطوات فتح الحساب والمستندات المطلوبة.',
    tags: ['بنك', 'حساب', 'كرت', 'IBAN'],
    steps: [
      GuideStep(
        title: 'اختر البنك المناسب',
        details:
            'قارن قرب الفروع، دعم الإنجليزية/العربية، رسوم التحويل، وجود تطبيق جيد، وسهولة فتح الحساب للأجانب.',
      ),
      GuideStep(
        title: 'جهز المستندات',
        details:
            'غالباً تحتاج جواز السفر، الرقم الضريبي، رقم هاتف تركي، وعنوان سكن.',
        requiredDocuments: [
          'جواز السفر',
          'رقم ضريبي',
          'رقم هاتف تركي',
          'عنوان',
        ],
      ),
      GuideStep(
        title: 'فعّل التطبيق والبطاقة',
        details:
            'بعد فتح الحساب، فعّل تطبيق البنك ولا تشارك كلمات المرور أو رموز SMS مع أي شخص.',
        warnings: ['احذر الوسطاء الذين يطلبون بيانات الدخول البنكية.'],
      ),
    ],
  ),
  GuideArticle(
    id: 'housing-guide',
    category: GuideCategory.housing,
    icon: Icons.apartment,
    title: 'السكن الآمن والمناسب',
    summary: 'أنواع السكن، أسئلة المعاينة، وكيف تتجنب الاحتيال عند الاستئجار.',
    tags: ['سكن', 'شقة', 'KYK', 'احتيال'],
    steps: [
      GuideStep(
        title: 'قارن الخيارات',
        details:
            'السكن الحكومي أرخص غالباً، السكن الخاص أسهل للطلاب الدوليين، والشقق تمنح مرونة أكبر لكنها تحتاج عقداً واضحاً.',
      ),
      GuideStep(
        title: 'افحص قبل الدفع',
        details:
            'عاين المكان، اسأل عن الفواتير، الإنترنت، التدفئة، المواصلات، وسياسة الضيوف.',
      ),
      GuideStep(
        title: 'احم نفسك من الاحتيال',
        details:
            'لا تدفع مبلغاً كبيراً قبل رؤية السكن وتوقيع عقد واضح مع بيانات المالك.',
        warnings: [
          'تجنب إعلانات الأسعار غير المنطقية.',
          'لا ترسل صورة جوازك لجهة غير موثوقة.',
        ],
      ),
    ],
  ),
  GuideArticle(
    id: 'university-life',
    category: GuideCategory.universityLife,
    icon: Icons.school,
    title: 'فهم الحياة الجامعية',
    summary: 'نظام المواد والساعات، التسجيل، الامتحانات، الأنشطة، والتخرج.',
    tags: ['جامعة', 'مواد', 'امتحانات', 'تخرج'],
    steps: [
      GuideStep(
        title: 'افهم نظام الساعات',
        details:
            'كل مادة لها ساعات/اعتمادات. راقب المتطلبات الإجبارية والاختيارية وخطة التخرج.',
      ),
      GuideStep(
        title: 'سجّل المواد مبكراً',
        details:
            'استخدم نظام الجامعة، راجع المرشد الأكاديمي، ولا تؤخر التسجيل حتى تمتلئ الشعب.',
      ),
      GuideStep(
        title: 'استفد من الأنشطة',
        details:
            'انضم للنوادي الطلابية ومكاتب الطلاب الدوليين لأنها تسهل الاندماج وتعلم اللغة.',
      ),
    ],
  ),
  GuideArticle(
    id: 'transport',
    category: GuideCategory.transport,
    icon: Icons.directions_bus,
    title: 'المواصلات والخصومات الطلابية',
    summary: 'كيف تستخدم المترو والحافلات والترام وتستفيد من بطاقة الطالب.',
    tags: ['مترو', 'حافلات', 'ترام', 'كرت مواصلات'],
    steps: [
      GuideStep(
        title: 'استخرج كرت المواصلات',
        details:
            'استخدم وثيقة الطالب والصورة الشخصية حسب نظام مدينتك للحصول على خصم الطالب.',
      ),
      GuideStep(
        title: 'خطط رحلتك',
        details:
            'اعتمد على تطبيقات الخرائط الرسمية أو Google Maps، واحسب وقت الذروة.',
      ),
      GuideStep(
        title: 'احفظ قواعد المدينة',
        details:
            'بعض المدن تستخدم كرتاً مختلفاً وتفرض قواعد خاصة للتحويلات والاشتراكات الشهرية.',
      ),
    ],
  ),
  GuideArticle(
    id: 'student-tips',
    category: GuideCategory.studentTips,
    icon: Icons.psychology_alt,
    title: 'نصائح للنجاح والتكيف',
    summary: 'إدارة الوقت، تعلم التركية، بناء شبكة دعم، وتجنب أخطاء البداية.',
    tags: ['لغة تركية', 'وقت', 'نجاح', 'تأقلم'],
    steps: [
      GuideStep(
        title: 'ابنِ روتيناً أسبوعياً',
        details:
            'خصص وقتاً ثابتاً للمحاضرات، المذاكرة، الأوراق الرسمية، الراحة، وتعلم اللغة.',
      ),
      GuideStep(
        title: 'تعلم التركية يومياً',
        details:
            'ابدأ بعبارات الخدمات والمواصلات والجامعة. 20 دقيقة يومياً تصنع فرقاً كبيراً.',
      ),
      GuideStep(
        title: 'تجنب أخطاء الجدد',
        details:
            'لا تؤجل الإقامة، لا تعتمد على مصدر واحد للمعلومة، ولا توقع عقوداً لا تفهمها.',
      ),
    ],
  ),
  GuideArticle(
    id: 'maps-important-places',
    category: GuideCategory.maps,
    icon: Icons.map,
    title: 'المواقع المهمة',
    summary:
        'أين تبحث عن الجامعات، مديرية الهجرة، البنوك، المستشفيات، ومراكز الخدمات.',
    tags: ['خرائط', 'هجرة', 'بنوك', 'مستشفيات'],
    steps: [
      GuideStep(
        title: 'ابحث باسم الجهة الرسمي',
        details:
            'استخدم اسم الجامعة أو Göç İdaresi أو Vergi Dairesi مع اسم المدينة للحصول على نتائج أدق.',
      ),
      GuideStep(
        title: 'تأكد من ساعات العمل',
        details:
            'راجع أوقات العمل والعطل الرسمية قبل الذهاب، وخذ موعداً عندما يكون مطلوباً.',
      ),
    ],
  ),
];

const _englishArticles = [
  GuideArticle(
    id: 'pre-arrival-checklist',
    category: GuideCategory.preArrival,
    icon: Icons.flight_takeoff,
    title: 'Pre-arrival checklist',
    summary:
        'Prepare your university file, visa basics, travel documents, and first-week plan.',
    tags: ['visa', 'admission', 'travel', 'documents'],
    steps: [
      GuideStep(
        title: 'Prepare your university file',
        details:
            'Keep digital and printed copies of your admission letter, passport, diploma, transcript, and recent photos.',
      ),
      GuideStep(
        title: 'Check visa requirements',
        details:
            'Requirements depend on nationality. Confirm with the consulate or official visa portal before booking.',
      ),
      GuideStep(
        title: 'Travel safely',
        details:
            'Keep original documents in your hand luggage and save a temporary address and contact in Turkey.',
      ),
    ],
  ),
  GuideArticle(
    id: 'after-arrival-residence',
    category: GuideCategory.afterArrival,
    icon: Icons.assignment_ind,
    title: 'Residence and official steps',
    summary:
        'Tax number, university registration, health insurance, address registration, and residence appointment.',
    tags: ['residence', 'tax number', 'insurance', 'address'],
    steps: [
      GuideStep(
        title: 'Get a tax number',
        details: 'You may need it for banking and residence procedures.',
      ),
      GuideStep(
        title: 'Complete university registration',
        details:
            'Get your student certificate as soon as your university registration is active.',
      ),
      GuideStep(
        title: 'Book residence appointment',
        details:
            'Prepare insurance, student document, photos, fee receipt, and address proof.',
      ),
    ],
  ),
  GuideArticle(
    id: 'banking-for-students',
    category: GuideCategory.banking,
    icon: Icons.account_balance,
    title: 'Student banking',
    summary: 'How to open an account and compare student-friendly banks.',
    tags: ['bank', 'account', 'IBAN'],
    steps: [
      GuideStep(
        title: 'Compare banks',
        details:
            'Check branch access, app quality, language support, transfer fees, and foreign-student procedures.',
      ),
      GuideStep(
        title: 'Bring documents',
        details:
            'Passport, tax number, Turkish phone number, and address are commonly requested.',
      ),
      GuideStep(
        title: 'Protect access',
        details: 'Never share banking passwords or SMS codes.',
      ),
    ],
  ),
  GuideArticle(
    id: 'housing-guide',
    category: GuideCategory.housing,
    icon: Icons.apartment,
    title: 'Safe housing',
    summary:
        'Dorms, private dorms, shared flats, inspection tips, and scam warnings.',
    tags: ['housing', 'dorm', 'flat', 'scam'],
    steps: [
      GuideStep(
        title: 'Compare options',
        details:
            'Government dorms are usually cheaper, private dorms are easier for newcomers, and flats need clearer contracts.',
      ),
      GuideStep(
        title: 'Inspect before paying',
        details:
            'Ask about bills, heating, internet, transportation, deposit, and guest rules.',
      ),
      GuideStep(
        title: 'Avoid scams',
        details:
            'Do not pay large deposits before seeing the place and verifying the contract.',
      ),
    ],
  ),
  GuideArticle(
    id: 'university-life',
    category: GuideCategory.universityLife,
    icon: Icons.school,
    title: 'University life',
    summary:
        'Course credits, registration, exams, graduation, and student activities.',
    tags: ['university', 'courses', 'exams'],
    steps: [
      GuideStep(
        title: 'Understand credits',
        details:
            'Track compulsory and elective courses against your graduation plan.',
      ),
      GuideStep(
        title: 'Register early',
        details:
            'Use your university system and consult your academic advisor.',
      ),
      GuideStep(
        title: 'Join activities',
        details:
            'Student clubs and international offices make adaptation much easier.',
      ),
    ],
  ),
  GuideArticle(
    id: 'transport',
    category: GuideCategory.transport,
    icon: Icons.directions_bus,
    title: 'Transport and student discounts',
    summary:
        'Metro, buses, trams, city cards, and student transportation discounts.',
    tags: ['metro', 'bus', 'tram', 'student card'],
    steps: [
      GuideStep(
        title: 'Get a transport card',
        details:
            'Use your student certificate and city requirements to access discounts.',
      ),
      GuideStep(
        title: 'Plan routes',
        details:
            'Use official city apps or Google Maps and account for rush hours.',
      ),
    ],
  ),
  GuideArticle(
    id: 'student-tips',
    category: GuideCategory.studentTips,
    icon: Icons.psychology_alt,
    title: 'Study and adaptation tips',
    summary:
        'Time management, Turkish learning, academic success, and common mistakes.',
    tags: ['Turkish', 'time', 'success'],
    steps: [
      GuideStep(
        title: 'Build a weekly routine',
        details:
            'Schedule classes, study, paperwork, rest, and Turkish practice.',
      ),
      GuideStep(
        title: 'Learn Turkish daily',
        details: 'Start with service, transport, and campus phrases.',
      ),
      GuideStep(
        title: 'Avoid newcomer mistakes',
        details:
            'Do not delay residence procedures or sign contracts you do not understand.',
      ),
    ],
  ),
  GuideArticle(
    id: 'maps-important-places',
    category: GuideCategory.maps,
    icon: Icons.map,
    title: 'Important places',
    summary:
        'Find migration offices, universities, banks, hospitals, and service centers.',
    tags: ['maps', 'migration', 'banks', 'hospitals'],
    steps: [
      GuideStep(
        title: 'Search official names',
        details:
            'Use the institution name with the city for better map results.',
      ),
      GuideStep(
        title: 'Check hours',
        details:
            'Verify working hours and appointment requirements before visiting.',
      ),
    ],
  ),
];

const _arabicTasks = [
  StudentTask(
    id: 'tax',
    title: 'استخراج الرقم الضريبي',
    description: 'ابدأ به لأنه مطلوب للبنك وبعض الإجراءات.',
    category: GuideCategory.afterArrival,
    priority: 1,
  ),
  StudentTask(
    id: 'university-registration',
    title: 'تثبيت التسجيل الجامعي',
    description: 'احصل على وثيقة الطالب لاستخدامها في الإقامة والمواصلات.',
    category: GuideCategory.universityLife,
    priority: 2,
  ),
  StudentTask(
    id: 'insurance',
    title: 'تجهيز التأمين الصحي',
    description: 'تأكد من أن التأمين مناسب لطلب الإقامة.',
    category: GuideCategory.afterArrival,
    priority: 3,
  ),
  StudentTask(
    id: 'residence',
    title: 'حجز موعد الإقامة',
    description: 'لا تؤجل الموعد، وجهّز الوثائق مبكراً.',
    category: GuideCategory.afterArrival,
    priority: 4,
  ),
  StudentTask(
    id: 'bank',
    title: 'فتح حساب بنكي',
    description: 'قارن البنوك وجهّز الرقم الضريبي ورقم الهاتف.',
    category: GuideCategory.banking,
    priority: 5,
  ),
  StudentTask(
    id: 'transport-card',
    title: 'استخراج كرت المواصلات',
    description: 'استخدم وثيقة الطالب للحصول على الخصم.',
    category: GuideCategory.transport,
    priority: 6,
  ),
];

const _englishTasks = [
  StudentTask(
    id: 'tax',
    title: 'Get a tax number',
    description: 'Start here because it is needed for banking and paperwork.',
    category: GuideCategory.afterArrival,
    priority: 1,
  ),
  StudentTask(
    id: 'university-registration',
    title: 'Complete university registration',
    description: 'Get your student certificate for residence and transport.',
    category: GuideCategory.universityLife,
    priority: 2,
  ),
  StudentTask(
    id: 'insurance',
    title: 'Prepare health insurance',
    description: 'Make sure it is valid for residence procedures.',
    category: GuideCategory.afterArrival,
    priority: 3,
  ),
  StudentTask(
    id: 'residence',
    title: 'Book residence appointment',
    description: 'Do not delay; prepare documents early.',
    category: GuideCategory.afterArrival,
    priority: 4,
  ),
  StudentTask(
    id: 'bank',
    title: 'Open a bank account',
    description: 'Compare banks and bring tax number and phone number.',
    category: GuideCategory.banking,
    priority: 5,
  ),
  StudentTask(
    id: 'transport-card',
    title: 'Get a transport card',
    description: 'Use your student certificate for discounts.',
    category: GuideCategory.transport,
    priority: 6,
  ),
];

const _arabicPlaces = [
  ImportantPlace(
    name: 'مديرية الهجرة',
    type: 'إقامة',
    city: 'كل المدن',
    description: 'مواعيد ومعاملات الإقامة الطلابية.',
    url: 'https://maps.google.com/?q=Göç+İdaresi',
  ),
  ImportantPlace(
    name: 'دائرة الضرائب',
    type: 'رقم ضريبي',
    city: 'كل المدن',
    description: 'استخراج الرقم الضريبي وتحديث البيانات.',
    url: 'https://maps.google.com/?q=Vergi+Dairesi',
  ),
  ImportantPlace(
    name: 'مستشفى حكومي',
    type: 'صحة',
    city: 'كل المدن',
    description: 'خدمات صحية وطوارئ قريبة منك.',
    url: 'https://maps.google.com/?q=Devlet+Hastanesi',
  ),
  ImportantPlace(
    name: 'فرع بنك قريب',
    type: 'بنوك',
    city: 'كل المدن',
    description: 'فتح حساب وسحب وإيداع وخدمات طلابية.',
    url: 'https://maps.google.com/?q=Banka',
  ),
];

const _englishPlaces = [
  ImportantPlace(
    name: 'Migration office',
    type: 'Residence',
    city: 'All cities',
    description: 'Student residence appointments and procedures.',
    url: 'https://maps.google.com/?q=Göç+İdaresi',
  ),
  ImportantPlace(
    name: 'Tax office',
    type: 'Tax number',
    city: 'All cities',
    description: 'Tax number and official data updates.',
    url: 'https://maps.google.com/?q=Vergi+Dairesi',
  ),
  ImportantPlace(
    name: 'Public hospital',
    type: 'Health',
    city: 'All cities',
    description: 'Nearby healthcare and emergency services.',
    url: 'https://maps.google.com/?q=Devlet+Hastanesi',
  ),
  ImportantPlace(
    name: 'Nearby bank branch',
    type: 'Banking',
    city: 'All cities',
    description: 'Account opening, cash, and student banking services.',
    url: 'https://maps.google.com/?q=Banka',
  ),
];

const _turkishArticles = [
  GuideArticle(
    id: 'pre-arrival-checklist',
    category: GuideCategory.preArrival,
    icon: Icons.flight_takeoff,
    title: 'Varış öncesi kontrol listesi',
    summary:
        'Üniversite dosyanızı, vize temellerini, seyahat belgelerini ve ilk hafta planınızı hazırlayın.',
    tags: ['vize', 'kabul', 'seyahat', 'belgeler'],
    steps: [
      GuideStep(
        title: 'Üniversite dosyanızı hazırlayın',
        details:
            'Kabul mektubunuzun, pasaportunuzun, diplomanızın, transkriptinizin ve güncel fotoğraflarınızın dijital ve basılı kopyalarını bulundurun.',
      ),
      GuideStep(
        title: 'Vize gereksinimlerini kontrol edin',
        details:
            'Gereksinimler uyruğa bağlıdır. Rezervasyon yapmadan önce konsolosluk veya resmi vize portalı ile onaylayın.',
      ),
      GuideStep(
        title: 'Güvenli seyahat edin',
        details:
            'Orijinal belgeleri el bagajınızda bulundurun ve Türkiye\'de geçici bir adres ve iletişim bilgisi kaydedin.',
      ),
    ],
  ),
  GuideArticle(
    id: 'after-arrival-residence',
    category: GuideCategory.afterArrival,
    icon: Icons.assignment_ind,
    title: 'İkamet ve resmi adımlar',
    summary:
        'Vergi numarası, üniversite kaydı, sağlık sigortası, adres kaydı ve ikamet randevusu.',
    tags: ['ikamet', 'vergi numarası', 'sigorta', 'adres'],
    steps: [
      GuideStep(
        title: 'Vergi numarası alın',
        details: 'Bankacılık ve ikamet işlemleri için buna ihtiyacınız olabilir.',
      ),
      GuideStep(
        title: 'Üniversite kaydını tamamlayın',
        details:
            'Üniversite kaydınız aktif olur olmaz öğrenci belgenizi alın.',
      ),
      GuideStep(
        title: 'İkamet randevusu alın',
        details:
            'Sigorta, öğrenci belgesi, fotoğraflar, harç makbuzu ve adres belgesini hazırlayın.',
      ),
    ],
  ),
  GuideArticle(
    id: 'banking-for-students',
    category: GuideCategory.banking,
    icon: Icons.account_balance,
    title: 'Öğrenci bankacılığı',
    summary: 'Nasıl hesap açılır ve öğrenci dostu bankalar nasıl karşılaştırılır.',
    tags: ['banka', 'hesap', 'IBAN'],
    steps: [
      GuideStep(
        title: 'Bankaları karşılaştırın',
        details:
            'Şube erişimini, uygulama kalitesini, dil desteğini, transfer ücretlerini ve yabancı öğrenci prosedürlerini kontrol edin.',
      ),
      GuideStep(
        title: 'Belgeleri getirin',
        details:
            'Pasaport, vergi numarası, Türk telefon numarası ve adres genellikle istenir.',
      ),
      GuideStep(
        title: 'Erişimi koruyun',
        details: 'Banka şifrelerini veya SMS kodlarını asla paylaşmayın.',
      ),
    ],
  ),
  GuideArticle(
    id: 'housing-guide',
    category: GuideCategory.housing,
    icon: Icons.apartment,
    title: 'Güvenli konut',
    summary:
        'Yurtlar, özel yurtlar, paylaşımlı daireler, inceleme ipuçları ve dolandırıcılık uyarıları.',
    tags: ['konut', 'yurt', 'daire', 'dolandırıcılık'],
    steps: [
      GuideStep(
        title: 'Seçenekleri karşılaştırın',
        details:
            'Devlet yurtları genellikle daha ucuzdur, özel yurtlar yeni gelenler için daha kolaydır ve dairelerin daha net sözleşmelere ihtiyacı vardır.',
      ),
      GuideStep(
        title: 'Ödeme yapmadan önce inceleyin',
        details:
            'Faturalar, ısınma, internet, ulaşım, depozito ve misafir kuralları hakkında sorular sorun.',
      ),
      GuideStep(
        title: 'Dolandırıcılıklardan kaçının',
        details:
            'Yeri görmeden ve sözleşmeyi doğrulamadan büyük depozitolar ödemeyin.',
      ),
    ],
  ),
  GuideArticle(
    id: 'university-life',
    category: GuideCategory.universityLife,
    icon: Icons.school,
    title: 'Üniversite hayatı',
    summary:
        'Ders kredileri, kayıt, sınavlar, mezuniyet ve öğrenci etkinlikleri.',
    tags: ['üniversite', 'dersler', 'sınavlar'],
    steps: [
      GuideStep(
        title: 'Kredileri anlayın',
        details:
            'Mezuniyet planınıza göre zorunlu ve seçmeli dersleri takip edin.',
      ),
      GuideStep(
        title: 'Erken kayıt olun',
        details:
            'Üniversite sisteminizi kullanın ve akademik danışmanınıza danışın.',
      ),
      GuideStep(
        title: 'Etkinliklere katılın',
        details:
            'Öğrenci kulüpleri ve uluslararası ofisler uyumu çok daha kolaylaştırır.',
      ),
    ],
  ),
  GuideArticle(
    id: 'transport',
    category: GuideCategory.transport,
    icon: Icons.directions_bus,
    title: 'Ulaşım ve öğrenci indirimleri',
    summary:
        'Metro, otobüsler, tramvaylar, şehir kartları ve öğrenci ulaşım indirimleri.',
    tags: ['metro', 'otobüs', 'tramvay', 'öğrenci kartı'],
    steps: [
      GuideStep(
        title: 'Ulaşım kartı alın',
        details:
            'İndirimlerden yararlanmak için öğrenci belgenizi ve şehir gereksinimlerini kullanın.',
      ),
      GuideStep(
        title: 'Rotaları planlayın',
        details:
            'Resmi şehir uygulamalarını veya Google Haritalar\'ı kullanın ve yoğun saatleri hesaba katın.',
      ),
    ],
  ),
  GuideArticle(
    id: 'student-tips',
    category: GuideCategory.studentTips,
    icon: Icons.psychology_alt,
    title: 'Çalışma ve uyum ipuçları',
    summary:
        'Zaman yönetimi, Türkçe öğrenimi, akademik başarı ve yaygın hatalar.',
    tags: ['Türkçe', 'zaman', 'başarı'],
    steps: [
      GuideStep(
        title: 'Haftalık bir rutin oluşturun',
        details:
            'Dersleri, çalışmayı, evrak işlerini, dinlenmeyi ve Türkçe pratiğini planlayın.',
      ),
      GuideStep(
        title: 'Her gün Türkçe öğrenin',
        details: 'Hizmet, ulaşım ve kampüs ifadeleriyle başlayın.',
      ),
      GuideStep(
        title: 'Yeni gelen hatalarından kaçının',
        details:
            'İkamet işlemlerini geciktirmeyin veya anlamadığınız sözleşmeleri imzalamayın.',
      ),
    ],
  ),
  GuideArticle(
    id: 'maps-important-places',
    category: GuideCategory.maps,
    icon: Icons.map,
    title: 'Önemli yerler',
    summary:
        'Göç idarelerini, üniversiteleri, bankaları, hastaneleri ve hizmet merkezlerini bulun.',
    tags: ['haritalar', 'göç', 'bankalar', 'hastaneler'],
    steps: [
      GuideStep(
        title: 'Resmi isimleri arayın',
        details:
            'Daha iyi harita sonuçları için kurum adını şehirle birlikte kullanın.',
      ),
      GuideStep(
        title: 'Saatleri kontrol edin',
        details:
            'Ziyaret etmeden önce çalışma saatlerini ve randevu gereksinimlerini doğrulayın.',
      ),
    ],
  ),
];

const _turkishTasks = [
  StudentTask(
    id: 'tax',
    title: 'Vergi numarası al',
    description: 'Bankacılık ve evrak işleri için gerekli olduğu için buradan başlayın.',
    category: GuideCategory.afterArrival,
    priority: 1,
  ),
  StudentTask(
    id: 'university-registration',
    title: 'Üniversite kaydını tamamla',
    description: 'İkamet ve ulaşım için öğrenci belgenizi alın.',
    category: GuideCategory.universityLife,
    priority: 2,
  ),
  StudentTask(
    id: 'insurance',
    title: 'Sağlık sigortasını hazırla',
    description: 'İkamet işlemleri için geçerli olduğundan emin olun.',
    category: GuideCategory.afterArrival,
    priority: 3,
  ),
  StudentTask(
    id: 'residence',
    title: 'İkamet randevusu al',
    description: 'Gecikmeyin; belgeleri erkenden hazırlayın.',
    category: GuideCategory.afterArrival,
    priority: 4,
  ),
  StudentTask(
    id: 'bank',
    title: 'Banka hesabı aç',
    description: 'Bankaları karşılaştırın ve vergi numarası ile telefon numarasını getirin.',
    category: GuideCategory.banking,
    priority: 5,
  ),
  StudentTask(
    id: 'transport-card',
    title: 'Ulaşım kartı al',
    description: 'İndirimler için öğrenci belgenizi kullanın.',
    category: GuideCategory.transport,
    priority: 6,
  ),
];

const _turkishPlaces = [
  ImportantPlace(
    name: 'Göç idaresi',
    type: 'İkamet',
    city: 'Tüm şehirler',
    description: 'Öğrenci ikamet randevuları ve işlemleri.',
    url: 'https://maps.google.com/?q=Göç+İdaresi',
  ),
  ImportantPlace(
    name: 'Vergi dairesi',
    type: 'Vergi numarası',
    city: 'Tüm şehirler',
    description: 'Vergi numarası ve resmi veri güncellemeleri.',
    url: 'https://maps.google.com/?q=Vergi+Dairesi',
  ),
  ImportantPlace(
    name: 'Devlet hastanesi',
    type: 'Sağlık',
    city: 'Tüm şehirler',
    description: 'Yakındaki sağlık ve acil servisler.',
    url: 'https://maps.google.com/?q=Devlet+Hastanesi',
  ),
  ImportantPlace(
    name: 'Yakın banka şubesi',
    type: 'Bankacılık',
    city: 'Tüm şehirler',
    description: 'Hesap açma, nakit ve öğrenci bankacılığı hizmetleri.',
    url: 'https://maps.google.com/?q=Banka',
  ),
];

const _frenchArticles = [
  GuideArticle(
    id: 'pre-arrival-checklist',
    category: GuideCategory.preArrival,
    icon: Icons.flight_takeoff,
    title: 'Liste de contrôle avant l\'arrivée',
    summary:
        'Préparez votre dossier universitaire, les bases du visa, les documents de voyage et le plan de votre première semaine.',
    tags: ['visa', 'admission', 'voyage', 'documents'],
    steps: [
      GuideStep(
        title: 'Préparez votre dossier universitaire',
        details:
            'Conservez des copies numériques et imprimées de votre lettre d\'admission, passeport, diplôme, relevé de notes et photos récentes.',
      ),
      GuideStep(
        title: 'Vérifiez les exigences de visa',
        details:
            'Les exigences dépendent de la nationalité. Confirmez avec le consulat ou le portail officiel des visas avant de réserver.',
      ),
      GuideStep(
        title: 'Voyagez en toute sécurité',
        details:
            'Gardez les documents originaux dans votre bagage à main et enregistrez une adresse temporaire et un contact en Turquie.',
      ),
    ],
  ),
  GuideArticle(
    id: 'after-arrival-residence',
    category: GuideCategory.afterArrival,
    icon: Icons.assignment_ind,
    title: 'Résidence et démarches officielles',
    summary:
        'Numéro fiscal, inscription universitaire, assurance maladie, enregistrement de l\'adresse et rendez-vous de résidence.',
    tags: ['résidence', 'numéro fiscal', 'assurance', 'adresse'],
    steps: [
      GuideStep(
        title: 'Obtenez un numéro fiscal',
        details: 'Vous en aurez besoin pour les procédures bancaires et de résidence.',
      ),
      GuideStep(
        title: 'Terminez l\'inscription universitaire',
        details:
            'Obtenez votre certificat d\'étudiant dès que votre inscription universitaire est active.',
      ),
      GuideStep(
        title: 'Prenez rendez-vous pour la résidence',
        details:
            'Préparez l\'assurance, le document d\'étudiant, les photos, le reçu des frais et la preuve d\'adresse.',
      ),
    ],
  ),
  GuideArticle(
    id: 'banking-for-students',
    category: GuideCategory.banking,
    icon: Icons.account_balance,
    title: 'Services bancaires pour étudiants',
    summary: 'Comment ouvrir un compte et comparer les banques adaptées aux étudiants.',
    tags: ['banque', 'compte', 'IBAN'],
    steps: [
      GuideStep(
        title: 'Comparez les banques',
        details:
            'Vérifiez l\'accès aux agences, la qualité de l\'application, le support linguistique, les frais de transfert et les procédures pour étudiants étrangers.',
      ),
      GuideStep(
        title: 'Apportez les documents',
        details:
            'Le passeport, le numéro fiscal, un numéro de téléphone turc et une adresse sont couramment demandés.',
      ),
      GuideStep(
        title: 'Protégez l\'accès',
        details: 'Ne partagez jamais vos mots de passe bancaires ou vos codes SMS.',
      ),
    ],
  ),
  GuideArticle(
    id: 'housing-guide',
    category: GuideCategory.housing,
    icon: Icons.apartment,
    title: 'Logement sécurisé',
    summary:
        'Dortoirs, dortoirs privés, appartements partagés, conseils d\'inspection et avertissements sur les fraudes.',
    tags: ['logement', 'dortoir', 'appartement', 'fraude'],
    steps: [
      GuideStep(
        title: 'Comparez les options',
        details:
            'Les dortoirs gouvernementaux sont généralement moins chers, les dortoirs privés sont plus faciles pour les nouveaux arrivants, et les appartements nécessitent des contrats plus clairs.',
      ),
      GuideStep(
        title: 'Inspectez avant de payer',
        details:
            'Renseignez-vous sur les factures, le chauffage, Internet, les transports, la caution et les règles pour les invités.',
      ),
      GuideStep(
        title: 'Évitez les fraudes',
        details:
            'Ne payez pas de grosses cautions avant de voir le logement et de vérifier le contrat.',
      ),
    ],
  ),
  GuideArticle(
    id: 'university-life',
    category: GuideCategory.universityLife,
    icon: Icons.school,
    title: 'Vie universitaire',
    summary:
        'Crédits de cours, inscription, examens, remise des diplômes et activités étudiantes.',
    tags: ['université', 'cours', 'examens'],
    steps: [
      GuideStep(
        title: 'Comprenez les crédits',
        details:
            'Suivez les cours obligatoires et électifs par rapport à votre plan de fin d\'études.',
      ),
      GuideStep(
        title: 'Inscrivez-vous tôt',
        details:
            'Utilisez le système de votre université et consultez votre conseiller pédagogique.',
      ),
      GuideStep(
        title: 'Participez aux activités',
        details:
            'Les clubs étudiants et les bureaux internationaux facilitent grandement l\'adaptation.',
      ),
    ],
  ),
  GuideArticle(
    id: 'transport',
    category: GuideCategory.transport,
    icon: Icons.directions_bus,
    title: 'Transport et réductions étudiantes',
    summary:
        'Métro, bus, tramways, cartes de ville et réductions de transport pour étudiants.',
    tags: ['métro', 'bus', 'tramway', 'carte d\'étudiant'],
    steps: [
      GuideStep(
        title: 'Obtenez une carte de transport',
        details:
            'Utilisez votre certificat d\'étudiant et les exigences de la ville pour accéder aux réductions.',
      ),
      GuideStep(
        title: 'Planifiez vos itinéraires',
        details:
            'Utilisez les applications officielles de la ville ou Google Maps et tenez compte des heures de pointe.',
      ),
    ],
  ),
  GuideArticle(
    id: 'student-tips',
    category: GuideCategory.studentTips,
    icon: Icons.psychology_alt,
    title: 'Conseils d\'études et d\'adaptation',
    summary:
        'Gestion du temps, apprentissage du turc, réussite académique et erreurs courantes.',
    tags: ['turc', 'temps', 'succès'],
    steps: [
      GuideStep(
        title: 'Établissez une routine hebdomadaire',
        details:
            'Planifiez les cours, l\'étude, la paperasse, le repos et la pratique du turc.',
      ),
      GuideStep(
        title: 'Apprenez le turc quotidiennement',
        details: 'Commencez par des phrases pour le service, le transport et le campus.',
      ),
      GuideStep(
        title: 'Évitez les erreurs de débutant',
        details:
            'Ne retardez pas les procédures de résidence et ne signez pas de contrats que vous ne comprenez pas.',
      ),
    ],
  ),
  GuideArticle(
    id: 'maps-important-places',
    category: GuideCategory.maps,
    icon: Icons.map,
    title: 'Lieux importants',
    summary:
        'Trouvez les bureaux de migration, les universités, les banques, les hôpitaux et les centres de services.',
    tags: ['cartes', 'migration', 'banques', 'hôpitaux'],
    steps: [
      GuideStep(
        title: 'Recherchez les noms officiels',
        details:
            'Utilisez le nom de l\'institution avec la ville pour de meilleurs résultats sur la carte.',
      ),
      GuideStep(
        title: 'Vérifiez les horaires',
        details:
            'Vérifiez les heures de travail et les exigences de rendez-vous avant de vous déplacer.',
      ),
    ],
  ),
];

const _frenchTasks = [
  StudentTask(
    id: 'tax',
    title: 'Obtenir un numéro fiscal',
    description: 'Commencez ici car il est nécessaire pour les services bancaires et la paperasse.',
    category: GuideCategory.afterArrival,
    priority: 1,
  ),
  StudentTask(
    id: 'university-registration',
    title: 'Terminer l\'inscription universitaire',
    description: 'Obtenez votre certificat d\'étudiant pour la résidence et le transport.',
    category: GuideCategory.universityLife,
    priority: 2,
  ),
  StudentTask(
    id: 'insurance',
    title: 'Préparer l\'assurance maladie',
    description: 'Assurez-vous qu\'elle est valide pour les procédures de résidence.',
    category: GuideCategory.afterArrival,
    priority: 3,
  ),
  StudentTask(
    id: 'residence',
    title: 'Prendre rendez-vous pour la résidence',
    description: 'Ne tardez pas ; préparez les documents tôt.',
    category: GuideCategory.afterArrival,
    priority: 4,
  ),
  StudentTask(
    id: 'bank',
    title: 'Ouvrir un compte bancaire',
    description: 'Comparez les banques et apportez le numéro fiscal et le numéro de téléphone.',
    category: GuideCategory.banking,
    priority: 5,
  ),
  StudentTask(
    id: 'transport-card',
    title: 'Obtenir une carte de transport',
    description: 'Utilisez votre certificat d\'étudiant pour les réductions.',
    category: GuideCategory.transport,
    priority: 6,
  ),
];

const _frenchPlaces = [
  ImportantPlace(
    name: 'Bureau de migration',
    type: 'Résidence',
    city: 'Toutes les villes',
    description: 'Rendez-vous et procédures de résidence étudiante.',
    url: 'https://maps.google.com/?q=Göç+İdaresi',
  ),
  ImportantPlace(
    name: 'Bureau des impôts',
    type: 'Numéro fiscal',
    city: 'Toutes les villes',
    description: 'Numéro fiscal et mises à jour des données officielles.',
    url: 'https://maps.google.com/?q=Vergi+Dairesi',
  ),
  ImportantPlace(
    name: 'Hôpital public',
    type: 'Santé',
    city: 'Toutes les villes',
    description: 'Services de santé et d\'urgence à proximité.',
    url: 'https://maps.google.com/?q=Devlet+Hastanesi',
  ),
  ImportantPlace(
    name: 'Agence bancaire à proximité',
    type: 'Banque',
    city: 'Toutes les villes',
    description: 'Ouverture de compte, espèces et services bancaires aux étudiants.',
    url: 'https://maps.google.com/?q=Banka',
  ),
];

const _indonesianArticles = [
  GuideArticle(
    id: 'pre-arrival-checklist',
    category: GuideCategory.preArrival,
    icon: Icons.flight_takeoff,
    title: 'Daftar periksa sebelum kedatangan',
    summary:
        'Siapkan berkas universitas, dasar-dasar visa, dokumen perjalanan, dan rencana minggu pertama Anda.',
    tags: ['visa', 'penerimaan', 'perjalanan', 'dokumen'],
    steps: [
      GuideStep(
        title: 'Siapkan berkas universitas Anda',
        details:
            'Simpan salinan digital dan cetak dari surat penerimaan, paspor, ijazah, transkrip, dan foto terbaru Anda.',
      ),
      GuideStep(
        title: 'Periksa persyaratan visa',
        details:
            'Persyaratan tergantung pada kewarganegaraan. Konfirmasikan dengan konsulat atau portal visa resmi sebelum memesan.',
      ),
      GuideStep(
        title: 'Bepergian dengan aman',
        details:
            'Simpan dokumen asli di bagasi kabin Anda dan simpan alamat sementara serta kontak di Turki.',
      ),
    ],
  ),
  GuideArticle(
    id: 'after-arrival-residence',
    category: GuideCategory.afterArrival,
    icon: Icons.assignment_ind,
    title: 'Izin tinggal dan langkah resmi',
    summary:
        'Nomor pajak, pendaftaran universitas, asuransi kesehatan, pendaftaran alamat, dan janji temu izin tinggal.',
    tags: ['izin tinggal', 'nomor pajak', 'asuransi', 'alamat'],
    steps: [
      GuideStep(
        title: 'Dapatkan nomor pajak',
        details: 'Anda mungkin membutuhkannya untuk prosedur perbankan dan izin tinggal.',
      ),
      GuideStep(
        title: 'Selesaikan pendaftaran universitas',
        details:
            'Dapatkan sertifikat mahasiswa Anda segera setelah pendaftaran universitas Anda aktif.',
      ),
      GuideStep(
        title: 'Pesan janji temu izin tinggal',
        details:
            'Siapkan asuransi, dokumen mahasiswa, foto, tanda terima biaya, dan bukti alamat.',
      ),
    ],
  ),
  GuideArticle(
    id: 'banking-for-students',
    category: GuideCategory.banking,
    icon: Icons.account_balance,
    title: 'Perbankan mahasiswa',
    summary: 'Cara membuka rekening dan membandingkan bank yang ramah mahasiswa.',
    tags: ['bank', 'rekening', 'IBAN'],
    steps: [
      GuideStep(
        title: 'Bandingkan bank',
        details:
            'Periksa akses cabang, kualitas aplikasi, dukungan bahasa, biaya transfer, dan prosedur mahasiswa asing.',
      ),
      GuideStep(
        title: 'Bawa dokumen',
        details:
            'Paspor, nomor pajak, nomor telepon Turki, dan alamat biasanya diminta.',
      ),
      GuideStep(
        title: 'Lindungi akses',
        details: 'Jangan pernah membagikan kata sandi perbankan atau kode SMS.',
      ),
    ],
  ),
  GuideArticle(
    id: 'housing-guide',
    category: GuideCategory.housing,
    icon: Icons.apartment,
    title: 'Hunian aman',
    summary:
        'Asrama, asrama swasta, apartemen bersama, tips pemeriksaan, dan peringatan penipuan.',
    tags: ['perumahan', 'asrama', 'flat', 'penipuan'],
    steps: [
      GuideStep(
        title: 'Bandingkan opsi',
        details:
            'Asrama pemerintah biasanya lebih murah, asrama swasta lebih mudah bagi pendatang baru, dan flat membutuhkan kontrak yang lebih jelas.',
      ),
      GuideStep(
        title: 'Periksa sebelum membayar',
        details:
            'Tanyakan tentang tagihan, pemanas, internet, transportasi, deposit, dan aturan tamu.',
      ),
      GuideStep(
        title: 'Hindari penipuan',
        details:
            'Jangan membayar deposit besar sebelum melihat tempat dan memverifikasi kontrak.',
      ),
    ],
  ),
  GuideArticle(
    id: 'university-life',
    category: GuideCategory.universityLife,
    icon: Icons.school,
    title: 'Kehidupan universitas',
    summary:
        'Kredit mata kuliah, pendaftaran, ujian, kelulusan, dan aktivitas mahasiswa.',
    tags: ['universitas', 'mata kuliah', 'ujian'],
    steps: [
      GuideStep(
        title: 'Pahami kredit',
        details:
            'Pantau mata kuliah wajib dan pilihan sesuai rencana kelulusan Anda.',
      ),
      GuideStep(
        title: 'Daftar lebih awal',
        details:
            'Gunakan sistem universitas Anda dan berkonsultasi dengan penasihat akademik.',
      ),
      GuideStep(
        title: 'Ikuti aktivitas',
        details:
            'Klub mahasiswa dan kantor internasional membuat adaptasi jauh lebih mudah.',
      ),
    ],
  ),
  GuideArticle(
    id: 'transport',
    category: GuideCategory.transport,
    icon: Icons.directions_bus,
    title: 'Transportasi dan diskon mahasiswa',
    summary:
        'Metro, bus, trem, kartu kota, dan diskon transportasi mahasiswa.',
    tags: ['metro', 'bus', 'trem', 'kartu mahasiswa'],
    steps: [
      GuideStep(
        title: 'Dapatkan kartu transportasi',
        details:
            'Gunakan sertifikat mahasiswa dan persyaratan kota untuk mengakses diskon.',
      ),
      GuideStep(
        title: 'Rencanakan rute',
        details:
            'Gunakan aplikasi resmi kota atau Google Maps dan perhitungkan jam sibuk.',
      ),
    ],
  ),
  GuideArticle(
    id: 'student-tips',
    category: GuideCategory.studentTips,
    icon: Icons.psychology_alt,
    title: 'Tips belajar dan adaptasi',
    summary:
        'Manajemen waktu, belajar bahasa Turki, kesuksesan akademik, dan kesalahan umum.',
    tags: ['Turki', 'waktu', 'sukses'],
    steps: [
      GuideStep(
        title: 'Bangun rutinitas mingguan',
        details:
            'Jadwalkan kelas, belajar, dokumen, istirahat, dan latihan bahasa Turki.',
      ),
      GuideStep(
        title: 'Belajar bahasa Turki setiap hari',
        details: 'Mulai dengan frasa layanan, transportasi, dan kampus.',
      ),
      GuideStep(
        title: 'Hindari kesalahan pendatang baru',
        details:
            'Jangan menunda prosedur izin tinggal atau menandatangani kontrak yang tidak Anda mengerti.',
      ),
    ],
  ),
  GuideArticle(
    id: 'maps-important-places',
    category: GuideCategory.maps,
    icon: Icons.map,
    title: 'Tempat penting',
    summary:
        'Temukan kantor imigrasi, universitas, bank, rumah sakit, dan pusat layanan.',
    tags: ['peta', 'imigrasi', 'bank', 'rumah sakit'],
    steps: [
      GuideStep(
        title: 'Cari nama resmi',
        details:
            'Gunakan nama institusi dengan kota untuk hasil peta yang lebih baik.',
      ),
      GuideStep(
        title: 'Periksa jam operasional',
        details:
            'Verifikasi jam kerja dan persyaratan janji temu sebelum berkunjung.',
      ),
    ],
  ),
];

const _indonesianTasks = [
  StudentTask(
    id: 'tax',
    title: 'Dapatkan nomor pajak',
    description: 'Mulai di sini karena diperlukan untuk perbankan dan dokumen.',
    category: GuideCategory.afterArrival,
    priority: 1,
  ),
  StudentTask(
    id: 'university-registration',
    title: 'Selesaikan pendaftaran universitas',
    description: 'Dapatkan sertifikat mahasiswa untuk izin tinggal dan transportasi.',
    category: GuideCategory.universityLife,
    priority: 2,
  ),
  StudentTask(
    id: 'insurance',
    title: 'Siapkan asuransi kesehatan',
    description: 'Pastikan valid untuk prosedur izin tinggal.',
    category: GuideCategory.afterArrival,
    priority: 3,
  ),
  StudentTask(
    id: 'residence',
    title: 'Pesan janji temu izin tinggal',
    description: 'Jangan menunda; siapkan dokumen lebih awal.',
    category: GuideCategory.afterArrival,
    priority: 4,
  ),
  StudentTask(
    id: 'bank',
    title: 'Buka rekening bank',
    description: 'Bandingkan bank dan bawa nomor pajak serta nomor telepon.',
    category: GuideCategory.banking,
    priority: 5,
  ),
  StudentTask(
    id: 'transport-card',
    title: 'Dapatkan kartu transportasi',
    description: 'Gunakan sertifikat mahasiswa untuk diskon.',
    category: GuideCategory.transport,
    priority: 6,
  ),
];

const _indonesianPlaces = [
  ImportantPlace(
    name: 'Kantor Imigrasi',
    type: 'Izin Tinggal',
    city: 'Semua kota',
    description: 'Janji temu dan prosedur izin tinggal mahasiswa.',
    url: 'https://maps.google.com/?q=Göç+İdaresi',
  ),
  ImportantPlace(
    name: 'Kantor Pajak',
    type: 'Nomor Pajak',
    city: 'Semua kota',
    description: 'Nomor pajak dan pembaruan data resmi.',
    url: 'https://maps.google.com/?q=Vergi+Dairesi',
  ),
  ImportantPlace(
    name: 'Rumah Sakit Umum',
    type: 'Kesehatan',
    city: 'Semua kota',
    description: 'Layanan kesehatan dan darurat terdekat.',
    url: 'https://maps.google.com/?q=Devlet+Hastanesi',
  ),
  ImportantPlace(
    name: 'Cabang bank terdekat',
    type: 'Perbankan',
    city: 'Semua kota',
    description: 'Pembukaan rekening, uang tunai, dan layanan perbankan mahasiswa.',
    url: 'https://maps.google.com/?q=Banka',
  ),
];

const _kazakhArticles = [
  GuideArticle(
    id: 'pre-arrival-checklist',
    category: GuideCategory.preArrival,
    icon: Icons.flight_takeoff,
    title: 'Келгенге дейінгі бақылау тізімі',
    summary:
        'Университет құжаттарын, виза негіздерін, жол жүру құжаттарын және бірінші апта жоспарын дайындаңыз.',
    tags: ['виза', 'қабылдау', 'саяхат', 'құжаттар'],
    steps: [
      GuideStep(
        title: 'Университет құжаттарын дайындаңыз',
        details:
            'Қабылдау хатының, төлқұжаттың, дипломның, транскрипттің және соңғы фотосуреттердің цифрлық және басып шығарылған көшірмелерін сақтаңыз.',
      ),
      GuideStep(
        title: 'Виза талаптарын тексеріңіз',
        details:
            'Талаптар азаматтыққа байланысты. Брондау алдында консулдықпен немесе ресми виза порталымен растаңыз.',
      ),
      GuideStep(
        title: 'Қауіпсіз саяхаттаңыз',
        details:
            'Түпнұсқа құжаттарды қол жүгінде ұстаңыз және Түркиядағы уақытша мекенжай мен байланыс нөмірін сақтаңыз.',
      ),
    ],
  ),
  GuideArticle(
    id: 'after-arrival-residence',
    category: GuideCategory.afterArrival,
    icon: Icons.assignment_ind,
    title: 'Тұруға рұқсат және ресми қадамдар',
    summary:
        'Салық нөмірі, университетке тіркелу, медициналық сақтандыру, мекенжайды тіркеу және тұруға рұқсат алуға жазылу.',
    tags: ['тұруға рұқсат', 'салық нөмірі', 'сақтандыру', 'мекенжай'],
    steps: [
      GuideStep(
        title: 'Салық нөмірін алыңыз',
        details: 'Бұл сізге банктік және тұруға рұқсат алу процедуралары үшін қажет болуы мүмкін.',
      ),
      GuideStep(
        title: 'Университетке тіркелуді аяқтаңыз',
        details:
            'Университетке тіркелуіңіз белсенді болған бойда студенттік куәлікті алыңыз.',
      ),
      GuideStep(
        title: 'Тұруға рұқсат алуға жазылыңыз',
        details:
            'Сақтандыруды, студенттік құжатты, фотосуреттерді, түбіртекті және мекенжайды растайтын құжатты дайындаңыз.',
      ),
    ],
  ),
  GuideArticle(
    id: 'banking-for-students',
    category: GuideCategory.banking,
    icon: Icons.account_balance,
    title: 'Студенттік банкинг',
    summary: 'Шотты қалай ашуға болады және студенттерге қолайлы банктерді қалай салыстыруға болады.',
    tags: ['банк', 'шот', 'IBAN'],
    steps: [
      GuideStep(
        title: 'Банктерді салыстырыңыз',
        details:
            'Бөлімшелердің қолжетімділігін, қолданба сапасын, тілдік қолдауды, аударым комиссияларын және шетелдік студенттерге арналған процедураларды тексеріңіз.',
      ),
      GuideStep(
        title: 'Құжаттарды әкеліңіз',
        details:
            'Әдетте төлқұжат, салық нөмірі, түрік телефон нөмірі және мекенжай талап етіледі.',
      ),
      GuideStep(
        title: 'Қолжетімділікті қорғаңыз',
        details: 'Банктік құпия сөздерді немесе SMS кодтарын ешқашан бөліспеңіз.',
      ),
    ],
  ),
  GuideArticle(
    id: 'housing-guide',
    category: GuideCategory.housing,
    icon: Icons.apartment,
    title: 'Қауіпсіз тұрғын үй',
    summary:
        'Жатақханалар, жеке жатақханалар, ортақ пәтерлер, тексеру бойынша кеңестер және алаяқтық туралы ескертулер.',
    tags: ['тұрғын үй', 'жатақхана', 'пәтер', 'алаяқтық'],
    steps: [
      GuideStep(
        title: 'Нұсқаларды салыстырыңыз',
        details:
            'Мемлекеттік жатақханалар әдетте арзанырақ, жеке жатақханалар жаңадан келгендер үшін оңайырақ, ал пәтерлер үшін нақтырақ келісімшарттар қажет.',
      ),
      GuideStep(
        title: 'Төлем жасамас бұрын тексеріңіз',
        details:
            'Шоттар, жылыту, интернет, көлік, депозит және қонақтар ережелері туралы сұраңыз.',
      ),
      GuideStep(
        title: 'Алаяқтықтан аулақ болыңыз',
        details:
            'Орынды көрмей және келісімшартты тексермей тұрып үлкен депозиттер төлемеңіз.',
      ),
    ],
  ),
  GuideArticle(
    id: 'university-life',
    category: GuideCategory.universityLife,
    icon: Icons.school,
    title: 'Университет өмірі',
    summary:
        'Курс кредиттері, тіркелу, емтихандар, бітіру және студенттік іс-шаралар.',
    tags: ['университет', 'курстар', 'емтихандар'],
    steps: [
      GuideStep(
        title: 'Кредиттерді түсініңіз',
        details:
            'Оқу бітіру жоспарына сәйкес міндетті және таңдау курстарын қадағалаңыз.',
      ),
      GuideStep(
        title: 'Ерте тіркеліңіз',
        details:
            'Университет жүйесін пайдаланыңыз және академиялық кеңесшіңізбен кеңесіңіз.',
      ),
      GuideStep(
        title: 'Іс-шараларға қатысыңыз',
        details:
            'Студенттік клубтар мен халықаралық кеңселер бейімделуді әлдеқайда жеңілдетеді.',
      ),
    ],
  ),
  GuideArticle(
    id: 'transport',
    category: GuideCategory.transport,
    icon: Icons.directions_bus,
    title: 'Көлік және студенттік жеңілдіктер',
    summary:
        'Метро, автобустар, трамвайлар, қалалық карталар және студенттік көлік жеңілдіктері.',
    tags: ['метро', 'автобус', 'трамвай', 'студенттік карта'],
    steps: [
      GuideStep(
        title: 'Көлік картасын алыңыз',
        details:
            'Жеңілдіктерге қол жеткізу үшін студенттік құжатты және қала талаптарын пайдаланыңыз.',
      ),
      GuideStep(
        title: 'Маршруттарды жоспарлаңыз',
        details:
            'Ресми қалалық қолданбаларды немесе Google Maps қолданыңыз және қарбалас уақытты ескеріңіз.',
      ),
    ],
  ),
  GuideArticle(
    id: 'student-tips',
    category: GuideCategory.studentTips,
    icon: Icons.psychology_alt,
    title: 'Оқу және бейімделу бойынша кеңестер',
    summary:
        'Уақытты басқару, түрік тілін үйрену, академиялық жетістік және жиі жіберілетін қателер.',
    tags: ['Түрік тілі', 'уақыт', 'жетістік'],
    steps: [
      GuideStep(
        title: 'Апталық күн тәртібін құрыңыз',
        details:
            'Сабақтарды, оқуды, құжаттарды, демалысты және түрік тілін жаттықтыруды жоспарлаңыз.',
      ),
      GuideStep(
        title: 'Күн сайын түрік тілін үйреніңіз',
        details: 'Қызмет көрсету, көлік және кампус тіркестерінен бастаңыз.',
      ),
      GuideStep(
        title: 'Жаңадан келгендердің қателіктерінен аулақ болыңыз',
        details:
            'Тұруға рұқсат алу процедураларын кешіктірмеңіз немесе өзіңіз түсінбейтін келісімшарттарға қол қоймаңыз.',
      ),
    ],
  ),
  GuideArticle(
    id: 'maps-important-places',
    category: GuideCategory.maps,
    icon: Icons.map,
    title: 'Маңызды орындар',
    summary:
        'Көші-қон кеңселерін, университеттерді, банктерді, ауруханаларды және қызмет көрсету орталықтарын табыңыз.',
    tags: ['карталар', 'көші-қон', 'банктер', 'ауруханалар'],
    steps: [
      GuideStep(
        title: 'Ресми атауларды іздеңіз',
        details:
            'Картадан жақсырақ нәтиже алу үшін мекеме атауын қаламен бірге пайдаланыңыз.',
      ),
      GuideStep(
        title: 'Жұмыс уақытын тексеріңіз',
        details:
            'Бару алдында жұмыс уақытын және жазылу талаптарын тексеріңіз.',
      ),
    ],
  ),
];

const _kazakhTasks = [
  StudentTask(
    id: 'tax',
    title: 'Салық нөмірін алыңыз',
    description: 'Осыдан бастаңыз, өйткені ол банкинг пен құжаттар үшін қажет.',
    category: GuideCategory.afterArrival,
    priority: 1,
  ),
  StudentTask(
    id: 'university-registration',
    title: 'Университетке тіркелуді аяқтаңыз',
    description: 'Тұруға рұқсат пен көлік үшін студенттік құжатыңызды алыңыз.',
    category: GuideCategory.universityLife,
    priority: 2,
  ),
  StudentTask(
    id: 'insurance',
    title: 'Медициналық сақтандыруды дайындаңыз',
    description: 'Оның тұруға рұқсат алу процедуралары үшін жарамды екеніне көз жеткізіңіз.',
    category: GuideCategory.afterArrival,
    priority: 3,
  ),
  StudentTask(
    id: 'residence',
    title: 'Тұруға рұқсат алуға жазылыңыз',
    description: 'Кешіктірмеңіз; құжаттарды ерте дайындаңыз.',
    category: GuideCategory.afterArrival,
    priority: 4,
  ),
  StudentTask(
    id: 'bank',
    title: 'Банк шотын ашыңыз',
    description: 'Банктерді салыстырыңыз және салық нөмірі мен телефон нөмірін әкеліңіз.',
    category: GuideCategory.banking,
    priority: 5,
  ),
  StudentTask(
    id: 'transport-card',
    title: 'Көлік картасын алыңыз',
    description: 'Жеңілдіктер үшін студенттік құжатыңызды пайдаланыңыз.',
    category: GuideCategory.transport,
    priority: 6,
  ),
];

const _kazakhPlaces = [
  ImportantPlace(
    name: 'Көші-қон кеңсесі',
    type: 'Тұруға рұқсат',
    city: 'Барлық қалалар',
    description: 'Студенттердің тұруға рұқсат алуына жазылу және процедуралар.',
    url: 'https://maps.google.com/?q=Göç+İdaresi',
  ),
  ImportantPlace(
    name: 'Салық кеңсесі',
    type: 'Салық нөмірі',
    city: 'Барлық қалалар',
    description: 'Салық нөмірі және ресми деректерді жаңарту.',
    url: 'https://maps.google.com/?q=Vergi+Dairesi',
  ),
  ImportantPlace(
    name: 'Мемлекеттік аурухана',
    type: 'Денсаулық',
    city: 'Барлық қалалар',
    description: 'Жақын маңдағы денсаулық сақтау және жедел жәрдем қызметтері.',
    url: 'https://maps.google.com/?q=Devlet+Hastanesi',
  ),
  ImportantPlace(
    name: 'Жақын маңдағы банк бөлімшесі',
    type: 'Банкинг',
    city: 'Барлық қалалар',
    description: 'Шот ашу, қолма-қол ақша және студенттерге банктік қызмет көрсету.',
    url: 'https://maps.google.com/?q=Banka',
  ),
];

const _somaliArticles = [
  GuideArticle(
    id: 'pre-arrival-checklist',
    category: GuideCategory.preArrival,
    icon: Icons.flight_takeoff,
    title: 'Liiska hubinta ka hor imaatinka',
    summary:
        'Diyaari faylkaaga jaamacadda, aasaaska fiisaha, dukumentiyada safarka, iyo qorshaha toddobaadka koowaad.',
    tags: ['fiisaha', 'ogolaanshaha', 'safarka', 'dukumentiyada'],
    steps: [
      GuideStep(
        title: 'Diyaari faylkaaga jaamacadda',
        details:
            'Haysashada koobiyo dhijitaal ah iyo kuwo daabacan oo ah warqadda ogolaanshaha, baasaboorka, shahaadada, tarjumaadda shahaadada, iyo sawirradii ugu dambeeyay.',
      ),
      GuideStep(
        title: 'Hubi shuruudaha fiisaha',
        details:
            'Shuruuduhu waxay ku xiran yihiin dhalashadaada. Kala xiriir qunsuliyadda ama bogga rasmiga ah ee fiisaha ka hor inta aanad ballansan safarka.',
      ),
      GuideStep(
        title: 'Si ammaan ah u safr',
        details:
            'Ku hay dukumentiyada asalka ah boorsada gacanta, oo keydso ciwaanka hoyga ku meel gaarka ah iyo lambar xiriir oo Turkiga ah.',
      ),
    ],
  ),
  GuideArticle(
    id: 'after-arrival-residence',
    category: GuideCategory.afterArrival,
    icon: Icons.assignment_ind,
    title: 'Deganaanshaha iyo tillaabooyinka rasmiga ah',
    summary:
        'Lambarka cashuurta, diiwaangelinta jaamacadda, caymiska caafimaadka, diiwaangelinta ciwaanka, iyo ballanta deganaanshaha.',
    tags: ['deganaanshaha', 'lambarka cashuurta', 'caymiska', 'ciwaanka'],
    steps: [
      GuideStep(
        title: 'Qaado lambarka cashuurta',
        details: 'Waxaad u baahan kartaa adeegyada bangiga iyo habraaca deganaanshaha.',
      ),
      GuideStep(
        title: 'Dhameystir diiwaangelinta jaamacadda',
        details:
            'Qaado shahaadada ardaynimada isla marka ay diiwaangelintaada jaamacadeed firfircoonaato.',
      ),
      GuideStep(
        title: 'Ballanso ballanta deganaanshaha',
        details:
            'Diyaari caymiska, dukumentiga ardayga, sawirrada, rasiidhka khidmadda, iyo caddaynta ciwaanka.',
      ),
    ],
  ),
  GuideArticle(
    id: 'banking-for-students',
    category: GuideCategory.banking,
    icon: Icons.account_balance,
    title: 'Adeegyada bangiga ee ardayda',
    summary: 'Sida loo furo xisaab bangi iyo isbarbardhigga bangiyada u roon ardayda.',
    tags: ['bangiga', 'xisaab', 'IBAN'],
    steps: [
      GuideStep(
        title: 'Isbarbardhig bangiyada',
        details:
            'Hubi helitaanka laamaha, tayada abka, taageerada luqadda, khidmadaha xawaaladda, iyo habraaca ardayda qalaad.',
      ),
      GuideStep(
        title: 'Keen dukumentiyada',
        details:
            'Baasaboorka, lambarka cashuurta, lambarka taleefanka Turkiga, iyo ciwaanka ayaa inta badan la codsadaa.',
      ),
      GuideStep(
        title: 'Ilaali gelitaanka',
        details: 'Weligaa ha la wadaagin furayaasha bangiga ama koodhadhka SMS-ka.',
      ),
    ],
  ),
  GuideArticle(
    id: 'housing-guide',
    category: GuideCategory.housing,
    icon: Icons.apartment,
    title: 'Hoy ammaan ah',
    summary:
        'Sustuunnada, sustuunnada gaarka loo leeyahay, guryaha la wadaago, talooyinka kormeerka, iyo digniinaha khiyaanada.',
    tags: ['hoyga', 'sustuun', 'guri', 'khiyaano'],
    steps: [
      GuideStep(
        title: 'Isbarbardhig xulashooyinka',
        details:
            'Sustuunnada dawladda ayaa inta badan raqiis ah, sustuunnada gaarka loo leeyahay ayaa u fudud dadka ku cusub, guryuhuna waxay u baahan yihiin heshiisyo cad cad.',
      ),
      GuideStep(
        title: 'Kormeeri ka hor inta aanad bixin lacagta',
        details:
            'Waydii biilasha, kuleylka, internetka, gaadiidka, deebaajiga, iyo qawaaniinta martida.',
      ),
      GuideStep(
        title: 'Ka fogow khiyaanada',
        details:
            'Ha bixin deebaaji weyn ka hor inta aanad arkin hoyga oo aanad xaqiijin heshiiska.',
      ),
    ],
  ),
  GuideArticle(
    id: 'university-life',
    category: GuideCategory.universityLife,
    icon: Icons.school,
    title: 'Nolosha jaamacadda',
    summary:
        'Dhibcaha koorsada, diiwaangelinta, imtixaanada, qalin-jabinta, iyo waxqabadyada ardayda.',
    tags: ['jaamacadda', 'koorsooyinka', 'imtixaanada'],
    steps: [
      GuideStep(
        title: 'Fahan dhibcaha',
        details:
            'Lasocod koorsooyinka qasabka ah iyo kuwa la doorto ee ku aaddan qorshahaaga qalin-jabinta.',
      ),
      GuideStep(
        title: 'Isdiiwaangeli goortii hore',
        details:
            'Isticmaal nidaamka jaamacaddaada oo la tasho la-taliyahaaga tacliinta.',
      ),
      GuideStep(
        title: 'Ku biir waxqabadyada',
        details:
            'Naadiyada ardayda iyo xafiisyada caalamiga ah waxay ka dhigaan la qabsiga mid aad u fudud.',
      ),
    ],
  ),
  GuideArticle(
    id: 'transport',
    category: GuideCategory.transport,
    icon: Icons.directions_bus,
    title: 'Gaadiidka iyo qiimo dhimista ardayda',
    summary:
        'Metro, basaska, taraamyada, kaadhadhka magaalada, iyo qiimo dhimista gaadiidka ardayda.',
    tags: ['metro', 'bas', 'taraam', 'kaarka ardayga'],
    steps: [
      GuideStep(
        title: 'Qaado kaarka gaadiidka',
        details:
            'Isticmaal shahaadadaada ardaynimada iyo shuruudaha magaalada si aad u hesho qiimo dhimis.',
      ),
      GuideStep(
        title: 'Qorshee waddooyinka',
        details:
            'Isticmaal abka rasmiga ah ee magaalada ama Google Maps oo xisaabi saacadaha mashquulka ah.',
      ),
    ],
  ),
  GuideArticle(
    id: 'student-tips',
    category: GuideCategory.studentTips,
    icon: Icons.psychology_alt,
    title: 'Talooyinka waxbarashada iyo la qabsiga',
    summary:
        'Maareynta waqtiga, barashada Turkiga, guusha tacliinta, iyo khaladaadka caadiga ah.',
    tags: ['Turkiga', 'waqtiga', 'guusha'],
    steps: [
      GuideStep(
        title: 'Dhis nidaam toddobaadle ah',
        details:
            'Qorshee xiisadaha, waxbarashada, waraaqaha, nasashada, iyo ku celcelinta Turkiga.',
      ),
      GuideStep(
        title: 'Baro Turkiga maalin kasta',
        details: 'Ku billow weedhaha adeegga, gaadiidka, iyo kaamposka.',
      ),
      GuideStep(
        title: 'Ka fogow khaladaadka dadka ku cusub',
        details:
            'Ha dib dhigin habraaca deganaanshaha ama ha saxiixin heshiisyo aadan fahmin.',
      ),
    ],
  ),
  GuideArticle(
    id: 'maps-important-places',
    category: GuideCategory.maps,
    icon: Icons.map,
    title: 'Goobaha muhiimka ah',
    summary:
        'Soo hel xafiisyada socdaalka, jaamacadaha, bangiyada, isbitaallada, iyo xarumaha adeegga.',
    tags: ['khariidado', 'socdaalka', 'bangiyada', 'isbitaallada'],
    steps: [
      GuideStep(
        title: 'Raadi magacyada rasmiga ah',
        details:
            'Isticmaal magaca machadka iyo magaalada si aad u hesho natiijooyin khariidad oo wanaagsan.',
      ),
      GuideStep(
        title: 'Hubi saacadaha',
        details:
            'Xaqiiji saacadaha shaqada iyo shuruudaha ballanta ka hor intaanad booqan.',
      ),
    ],
  ),
];

const _somaliTasks = [
  StudentTask(
    id: 'tax',
    title: 'Qaado lambarka cashuurta',
    description: 'Halkan ka billow waayo waxaa loo baahan yahay adeegyada bangiga iyo waraaqaha.',
    category: GuideCategory.afterArrival,
    priority: 1,
  ),
  StudentTask(
    id: 'university-registration',
    title: 'Dhameystir diiwaangelinta jaamacadda',
    description: 'Qaado shahaadada ardaynimada ee deganaanshaha iyo gaadiidka.',
    category: GuideCategory.universityLife,
    priority: 2,
  ),
  StudentTask(
    id: 'insurance',
    title: 'Diyaari caymiska caafimaadka',
    description: 'Hubi inay shaqaynayso habraaca deganaanshaha.',
    category: GuideCategory.afterArrival,
    priority: 3,
  ),
  StudentTask(
    id: 'residence',
    title: 'Ballanso ballanta deganaanshaha',
    description: 'Ha dib dhigin; diyaari dukumentiyada goor hore.',
    category: GuideCategory.afterArrival,
    priority: 4,
  ),
  StudentTask(
    id: 'bank',
    title: 'Furo xisaab bangi',
    description: 'Isbarbardhig bangiyada oo keen lambarka cashuurta iyo lambarka taleefanka.',
    category: GuideCategory.banking,
    priority: 5,
  ),
  StudentTask(
    id: 'transport-card',
    title: 'Qaado kaarka gaadiidka',
    description: 'Isticmaal shahaadadaada ardaynimada si aad u hesho qiimo dhimis.',
    category: GuideCategory.transport,
    priority: 6,
  ),
];

const _somaliPlaces = [
  ImportantPlace(
    name: 'Xafiiska socdaalka',
    type: 'Deganaanshaha',
    city: 'Magaalooyinka oo dhan',
    description: 'Ballamaha deganaanshaha ardayda iyo habraacyada.',
    url: 'https://maps.google.com/?q=Göç+İdaresi',
  ),
  ImportantPlace(
    name: 'Xafiiska cashuuraha',
    type: 'Lambarka cashuurta',
    city: 'Magaalooyinka oo dhan',
    description: 'Lambarka cashuurta iyo cusboonaysiinta xogta rasmiga ah.',
    url: 'https://maps.google.com/?q=Vergi+Dairesi',
  ),
  ImportantPlace(
    name: 'Isbitaalka dawladda',
    type: 'Caafimaadka',
    city: 'Magaalooyinka oo dhan',
    description: 'Adeegyada caafimaadka iyo kuwa degdegga ah ee u dhow.',
    url: 'https://maps.google.com/?q=Devlet+Hastanesi',
  ),
  ImportantPlace(
    name: 'Laanta bangiga ee u dhow',
    type: 'Adeegyada Bangiga',
    city: 'Magaalooyinka oo dhan',
    description: 'Furitaanka xisaabta, lacag cadaan ah, iyo adeegyada bangiga ee ardayda.',
    url: 'https://maps.google.com/?q=Banka',
  ),
];

const _urduArticles = [
  GuideArticle(
    id: 'pre-arrival-checklist',
    category: GuideCategory.preArrival,
    icon: Icons.flight_takeoff,
    title: 'آمد سے پہلے کی فہرست',
    summary:
        'اپنی یونیورسٹی کی فائل، ویزا کی بنیادی باتیں، سفری دستاویزات، اور پہلے ہفتے کے منصوبے کو تیار کریں۔',
    tags: ['ویزا', 'داخلہ', 'سفر', 'دستاویزات'],
    steps: [
      GuideStep(
        title: 'اپنی یونیورسٹی کی فائل تیار کریں',
        details:
            'اپنے داخلہ لیٹر، پاسپورٹ، ڈپلومہ، ٹرانسکرپٹ، اور حالیہ تصاویر کی ڈیجیٹل اور پرنٹ شدہ کاپیاں پاس رکھیں۔',
      ),
      GuideStep(
        title: 'ویزا کے تقاضے چیک کریں',
        details:
            'تقاضے شہریت پر منحصر ہوتے ہیں۔ بکنگ سے پہلے قونصل خانے یا سرکاری ویزا پورٹل سے تصدیق کریں۔',
      ),
      GuideStep(
        title: 'محفوظ طریقے سے سفر کریں',
        details:
            'اصل دستاویزات کو اپنے ہینڈ بیگ میں رکھیں اور ترکی میں عارضی پتہ اور رابطہ محفوظ کریں۔',
      ),
    ],
  ),
  GuideArticle(
    id: 'after-arrival-residence',
    category: GuideCategory.afterArrival,
    icon: Icons.assignment_ind,
    title: 'رہائش اور سرکاری مراحل',
    summary:
        'ٹیکس نمبر، یونیورسٹی رجسٹریشن، ہیلتھ انشورنس، ایڈریس رجسٹریشن، اور رہائش کی ملاقات۔',
    tags: ['رہائش', 'ٹیکس نمبر', 'انشورنس', 'پتہ'],
    steps: [
      GuideStep(
        title: 'ٹیکس نمبر حاصل کریں',
        details: 'آپ کو بینکنگ اور رہائشی طریقہ کار کے لیے اس کی ضرورت پڑ سکتی ہے۔',
      ),
      GuideStep(
        title: 'یونیورسٹی کی رجسٹریشن مکمل کریں',
        details:
            'جیسے ہی آپ کی یونیورسٹی کی رجسٹریشن فعال ہو، اپنا طالب علم سرٹیفکیٹ حاصل کریں۔',
      ),
      GuideStep(
        title: 'رہائش کی ملاقات (اپوائنٹمنٹ) بک کریں',
        details:
            'انشورنس، طالب علم کی دستاویز، تصاویر، فیس کی رسید، اور پتے کا ثبوت تیار کریں۔',
      ),
    ],
  ),
  GuideArticle(
    id: 'banking-for-students',
    category: GuideCategory.banking,
    icon: Icons.account_balance,
    title: 'طلباء کے لیے بینکنگ',
    summary: 'اکاؤنٹ کیسے کھولا جائے اور طلباء کے لیے موزوں بینکوں کا موازنہ کیسے کیا جائے۔',
    tags: ['بینک', 'اکاؤنٹ', 'آئی بی اے این'],
    steps: [
      GuideStep(
        title: 'بینکوں کا موازنہ کریں',
        details:
            'برانچ تک رسائی، ایپ کے معیار، زبان کی معاونت، ٹرانسفر فیس، اور غیر ملکی طلباء کے طریقہ کار کو چیک کریں۔',
      ),
      GuideStep(
        title: 'دستاویزات لائیں',
        details:
            'پاسپورٹ، ٹیکس نمبر، ترکی کا فون نمبر، اور پتہ عام طور پر طلب کیا جاتا ہے۔',
      ),
      GuideStep(
        title: 'رسائی کی حفاظت کریں',
        details: 'کبھی بھی بینکنگ پاس ورڈ یا ایس ایم ایس کوڈ شیئر نہ کریں۔',
      ),
    ],
  ),
  GuideArticle(
    id: 'housing-guide',
    category: GuideCategory.housing,
    icon: Icons.apartment,
    title: 'محفوظ رہائش',
    summary:
        'ہاسٹلز، پرائیویٹ ہاسٹلز، مشترکہ فلیٹس، معائنہ کے مشورے، اور دھوکہ دہی کے انتباہات۔',
    tags: ['رہائش', 'ہاسٹل', 'فلیٹ', 'دھوکہ دہی'],
    steps: [
      GuideStep(
        title: 'اختیارات کا موازنہ کریں',
        details:
            'سرکاری ہاسٹلز عام طور پر سستے ہوتے ہیں، پرائیویٹ ہاسٹلز نئے آنے والوں کے لیے آسان ہوتے ہیں، اور فلیٹس کے لیے واضح معاہدوں کی ضرورت ہوتی ہے۔',
      ),
      GuideStep(
        title: 'ادائیگی سے پہلے معائنہ کریں',
        details:
            'بلوں، ہیٹنگ، انٹرنیٹ، ٹرانسپورٹ، ڈپازٹ اور مہمانوں کے قوانین کے بارے میں پوچھیں۔',
      ),
      GuideStep(
        title: 'دھوکہ دہی سے بچیں',
        details:
            'جگہ دیکھنے اور معاہدے کی تصدیق کرنے سے پہلے بڑے ڈپازٹ ادا نہ کریں۔',
      ),
    ],
  ),
  GuideArticle(
    id: 'university-life',
    category: GuideCategory.universityLife,
    icon: Icons.school,
    title: 'یونیورسٹی کی زندگی',
    summary:
        'کورس کریڈٹس، رجسٹریشن، امتحانات، گریجویشن، اور طلباء کی سرگرمیاں۔',
    tags: ['یونیورسٹی', 'کورسز', 'امتحانات'],
    steps: [
      GuideStep(
        title: 'کریڈٹس کو سمجھیں',
        details:
            'اپنے گریجویشن پلان کے مطابق لازمی اور اختیاری کورسز کو ٹریک کریں۔',
      ),
      GuideStep(
        title: 'جلدی رجسٹریشن کریں',
        details:
            'اپنے یونیورسٹی سسٹم کا استعمال کریں اور اپنے تعلیمی مشیر سے مشورہ کریں۔',
      ),
      GuideStep(
        title: 'سرگرمیوں میں شامل ہوں',
        details:
            'اسٹوڈنٹ کلب اور انٹرنیشنل دفاتر مطابقت کو بہت آسان بنا دیتے ہیں۔',
      ),
    ],
  ),
  GuideArticle(
    id: 'transport',
    category: GuideCategory.transport,
    icon: Icons.directions_bus,
    title: 'ٹرانسپورٹ اور طلباء کے لیے رعایتیں',
    summary:
        'میٹرو، بسیں، ٹرام، سٹی کارڈز، اور طلباء کے لیے سفری رعایتیں۔',
    tags: ['میٹرو', 'بس', 'ٹرام', 'اسٹوڈنٹ کارڈ'],
    steps: [
      GuideStep(
        title: 'ٹرانسپورٹ کارڈ حاصل کریں',
        details:
            'رعایتوں تک رسائی حاصل کرنے کے لیے اپنا طالب علم سرٹیفکیٹ اور شہر کے تقاضوں کا استعمال کریں۔',
      ),
      GuideStep(
        title: 'راستوں کی منصوبہ بندی کریں',
        details:
            'شہر کی آفیشل ایپس یا گوگل میپس کا استعمال کریں اور رش کے اوقات کا خیال رکھیں۔',
      ),
    ],
  ),
  GuideArticle(
    id: 'student-tips',
    category: GuideCategory.studentTips,
    icon: Icons.psychology_alt,
    title: 'مطالعہ اور مطابقت کے مشورے',
    summary:
        'وقت کا انتظام، ترکی زبان سیکھنا، تعلیمی کامیابی، اور عام غلطیاں۔',
    tags: ['ترکی', 'وقت', 'کامیابی'],
    steps: [
      GuideStep(
        title: 'ہفتہ وار معمول بنائیں',
        details:
            'کلاسز، مطالعہ، کاغذی کارروائی، آرام، اور ترکی کی مشق کا وقت مقرر کریں۔',
      ),
      GuideStep(
        title: 'روزانہ ترکی سیکھیں',
        details: 'سروس، ٹرانسپورٹ اور کیمپس کے جملوں سے شروع کریں۔',
      ),
      GuideStep(
        title: 'نئے آنے والوں کی غلطیوں سے بچیں',
        details:
            'رہائشی طریقہ کار میں تاخیر نہ کریں یا ایسے معاہدوں پر دستخط نہ کریں جنہیں آپ نہیں سمجھتے۔',
      ),
    ],
  ),
  GuideArticle(
    id: 'maps-important-places',
    category: GuideCategory.maps,
    icon: Icons.map,
    title: 'اہم مقامات',
    summary:
        'امیگریشن دفاتر، یونیورسٹیاں، بینک، ہسپتال اور سروس سینٹرز تلاش کریں۔',
    tags: ['نقشے', 'امیگریشن', 'بینک', 'ہسپتال'],
    steps: [
      GuideStep(
        title: 'سرکاری نام تلاش کریں',
        details:
            'بہتر نقشہ کے نتائج کے لیے شہر کے ساتھ ادارے کا نام استعمال کریں۔',
      ),
      GuideStep(
        title: 'اوقات چیک کریں',
        details:
            'جانے سے پہلے کام کے اوقات اور ملاقات کے تقاضوں کی تصدیق کریں۔',
      ),
    ],
  ),
];

const _urduTasks = [
  StudentTask(
    id: 'tax',
    title: 'ٹیکس نمبر حاصل کریں',
    description: 'یہاں سے شروع کریں کیونکہ یہ بینکنگ اور کاغذی کارروائی کے لیے ضروری ہے۔',
    category: GuideCategory.afterArrival,
    priority: 1,
  ),
  StudentTask(
    id: 'university-registration',
    title: 'یونیورسٹی کی رجسٹریشن مکمل کریں',
    description: 'رہائش اور ٹرانسپورٹ کے لیے اپنا طالب علم سرٹیفکیٹ حاصل کریں۔',
    category: GuideCategory.universityLife,
    priority: 2,
  ),
  StudentTask(
    id: 'insurance',
    title: 'ہیلتھ انشورنس تیار کریں',
    description: 'اس بات کو یقینی بنائیں کہ یہ رہائشی طریقہ کار کے لیے موزوں ہے۔',
    category: GuideCategory.afterArrival,
    priority: 3,
  ),
  StudentTask(
    id: 'residence',
    title: 'رہائش کی ملاقات بک کریں',
    description: 'تاخیر نہ کریں؛ دستاویزات جلدی تیار کریں۔',
    category: GuideCategory.afterArrival,
    priority: 4,
  ),
  StudentTask(
    id: 'bank',
    title: 'بینک اکاؤنٹ کھولیں',
    description: 'بینکوں کا موازنہ کریں اور ٹیکس نمبر اور فون نمبر لائیں۔',
    category: GuideCategory.banking,
    priority: 5,
  ),
  StudentTask(
    id: 'transport-card',
    title: 'ٹرانسپورٹ کارڈ حاصل کریں',
    description: 'رعایتوں کے لیے اپنا طالب علم سرٹیفکیٹ استعمال کریں۔',
    category: GuideCategory.transport,
    priority: 6,
  ),
];

const _urduPlaces = [
  ImportantPlace(
    name: 'امیگریشن آفس',
    type: 'رہائش',
    city: 'تمام شہر',
    description: 'طالب علم کی رہائش کی ملاقاتیں اور طریقہ کار۔',
    url: 'https://maps.google.com/?q=Göç+İdaresi',
  ),
  ImportantPlace(
    name: 'ٹیکس آفس',
    type: 'ٹیکس نمبر',
    city: 'تمام شہر',
    description: 'ٹیکس نمبر اور سرکاری ڈیٹا کی اپ ڈیٹس۔',
    url: 'https://maps.google.com/?q=Vergi+Dairesi',
  ),
  ImportantPlace(
    name: 'سرکاری ہسپتال',
    type: 'صحت',
    city: 'تمام شہر',
    description: 'قریبی صحت کی دیکھ بھال اور ہنگامی خدمات۔',
    url: 'https://maps.google.com/?q=Devlet+Hastanesi',
  ),
  ImportantPlace(
    name: 'قریبی بینک برانچ',
    type: 'بینکنگ',
    city: 'تمام شہر',
    description: 'اکاؤنٹ کھولنا، نقد رقم، اور طلباء کے لیے بینکنگ خدمات۔',
    url: 'https://maps.google.com/?q=Banka',
  ),
];
