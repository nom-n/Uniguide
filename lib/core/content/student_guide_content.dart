import 'package:flutter/material.dart';

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
    final isArabic = locale.languageCode == 'ar';
    return isArabic ? _arabicArticles : _englishArticles;
  }

  static List<StudentTask> tasks(Locale locale) {
    final isArabic = locale.languageCode == 'ar';
    return isArabic ? _arabicTasks : _englishTasks;
  }

  static List<ImportantPlace> places(Locale locale) {
    final isArabic = locale.languageCode == 'ar';
    return isArabic ? _arabicPlaces : _englishPlaces;
  }

  static String categoryLabel(GuideCategory category, Locale locale) {
    final isArabic = locale.languageCode == 'ar';
    final labels = isArabic ? _arCategoryLabels : _enCategoryLabels;
    return labels[category]!;
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

const _arCategoryLabels = {
  GuideCategory.preArrival: 'قبل الوصول',
  GuideCategory.afterArrival: 'بعد الوصول',
  GuideCategory.banking: 'الخدمات البنكية',
  GuideCategory.housing: 'السكن',
  GuideCategory.universityLife: 'الحياة الجامعية',
  GuideCategory.transport: 'المواصلات',
  GuideCategory.studentTips: 'نصائح طلابية',
  GuideCategory.maps: 'خرائط ومواقع',
};

const _enCategoryLabels = {
  GuideCategory.preArrival: 'Pre-arrival',
  GuideCategory.afterArrival: 'After arrival',
  GuideCategory.banking: 'Banking',
  GuideCategory.housing: 'Housing',
  GuideCategory.universityLife: 'University life',
  GuideCategory.transport: 'Transport',
  GuideCategory.studentTips: 'Student tips',
  GuideCategory.maps: 'Maps & places',
};

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
