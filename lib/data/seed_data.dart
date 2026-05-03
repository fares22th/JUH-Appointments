import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/insurance.dart';
import '../models/relative.dart';
import '../models/specialty.dart';

class SeedData {
  SeedData._();

  static const List<InsuranceType> insurances = [
    InsuranceType(id: 'civil', nameAr: 'التأمين المدني', nameEn: 'Civil Insurance', icon: '🏛️'),
    InsuranceType(id: 'military', nameAr: 'التأمين العسكري', nameEn: 'Military Insurance', icon: '⭐'),
    InsuranceType(id: 'univ', nameAr: 'تأمين الجامعة', nameEn: 'University Insurance', icon: '🎓'),
    InsuranceType(id: 'private', nameAr: 'تأمين خاص', nameEn: 'Private Insurance', icon: '🏥'),
    InsuranceType(id: 'self', nameAr: 'دفع ذاتي', nameEn: 'Self Pay', icon: '💳'),
  ];

  static const List<Specialty> specialties = [
    Specialty(id: 'cardio', nameAr: 'القلب والأوعية الدموية', nameEn: 'Cardiology', icon: '🫀'),
    Specialty(id: 'neuro', nameAr: 'الأمراض العصبية', nameEn: 'Neurology', icon: '🧠'),
    Specialty(id: 'ortho', nameAr: 'العظام والمفاصل', nameEn: 'Orthopedics', icon: '🦴'),
    Specialty(id: 'peds', nameAr: 'طب الأطفال', nameEn: 'Pediatrics', icon: '👶'),
    Specialty(id: 'derm', nameAr: 'الأمراض الجلدية', nameEn: 'Dermatology', icon: '🩺'),
    Specialty(id: 'ent', nameAr: 'الأنف والأذن والحنجرة', nameEn: 'ENT', icon: '👂'),
    Specialty(id: 'ophthal', nameAr: 'طب العيون', nameEn: 'Ophthalmology', icon: '👁️'),
    Specialty(id: 'gen', nameAr: 'الطب الباطني العام', nameEn: 'General Medicine', icon: '🩻'),
    Specialty(id: 'psych', nameAr: 'الطب النفسي', nameEn: 'Psychiatry', icon: '🧘'),
    Specialty(id: 'gyne', nameAr: 'النساء والولادة', nameEn: 'Gynecology', icon: '🌸'),
  ];

  static const List<Doctor> doctors = [
    // Cardiology
    Doctor(
      id: 'd1', specialtyId: 'cardio',
      nameAr: 'د. أحمد الرشيد', nameEn: 'Dr. Ahmad Al-Rashid',
      titleAr: 'استشاري قلب وأوعية دموية', titleEn: 'Consultant Cardiologist',
      rating: 4.9, reviewCount: 312,
    ),
    Doctor(
      id: 'd2', specialtyId: 'cardio',
      nameAr: 'د. سارة المنصور', nameEn: 'Dr. Sara Al-Mansour',
      titleAr: 'أخصائية قلب', titleEn: 'Cardiologist',
      rating: 4.7, reviewCount: 198,
    ),
    // Neurology
    Doctor(
      id: 'd3', specialtyId: 'neuro',
      nameAr: 'د. خالد العمري', nameEn: 'Dr. Khalid Al-Omari',
      titleAr: 'استشاري أمراض عصبية', titleEn: 'Consultant Neurologist',
      rating: 4.8, reviewCount: 245,
    ),
    // Orthopedics
    Doctor(
      id: 'd4', specialtyId: 'ortho',
      nameAr: 'د. ليلى حسن', nameEn: 'Dr. Layla Hassan',
      titleAr: 'أخصائية عظام ومفاصل', titleEn: 'Orthopedic Specialist',
      rating: 4.6, reviewCount: 167,
    ),
    Doctor(
      id: 'd5', specialtyId: 'ortho',
      nameAr: 'د. محمد السالم', nameEn: 'Dr. Mohammed Al-Salem',
      titleAr: 'استشاري جراحة العظام', titleEn: 'Consultant Orthopedic Surgeon',
      rating: 4.9, reviewCount: 421,
    ),
    // Pediatrics
    Doctor(
      id: 'd6', specialtyId: 'peds',
      nameAr: 'د. نور الزيادنة', nameEn: 'Dr. Nour Al-Ziyadneh',
      titleAr: 'استشارية طب أطفال', titleEn: 'Consultant Pediatrician',
      rating: 4.9, reviewCount: 534,
    ),
    // Dermatology
    Doctor(
      id: 'd7', specialtyId: 'derm',
      nameAr: 'د. رنا الحوراني', nameEn: 'Dr. Rana Al-Hourani',
      titleAr: 'أخصائية جلدية وتجميل', titleEn: 'Dermatology & Aesthetics',
      rating: 4.8, reviewCount: 289,
    ),
    // ENT
    Doctor(
      id: 'd8', specialtyId: 'ent',
      nameAr: 'د. علي القاسم', nameEn: 'Dr. Ali Al-Qasem',
      titleAr: 'استشاري أنف وأذن وحنجرة', titleEn: 'Consultant ENT',
      rating: 4.7, reviewCount: 156,
    ),
    // Ophthalmology
    Doctor(
      id: 'd9', specialtyId: 'ophthal',
      nameAr: 'د. هالة نصر', nameEn: 'Dr. Hala Nasr',
      titleAr: 'استشارية طب عيون', titleEn: 'Consultant Ophthalmologist',
      rating: 4.8, reviewCount: 203,
    ),
    // General
    Doctor(
      id: 'd10', specialtyId: 'gen',
      nameAr: 'د. بسام الطراونة', nameEn: 'Dr. Bassam Al-Tarawna',
      titleAr: 'طب باطني عام', titleEn: 'General Internist',
      rating: 4.5, reviewCount: 312,
    ),
    // Psychiatry
    Doctor(
      id: 'd11', specialtyId: 'psych',
      nameAr: 'د. منى الشرفات', nameEn: 'Dr. Mona Al-Sharfat',
      titleAr: 'استشارية طب نفسي', titleEn: 'Consultant Psychiatrist',
      rating: 4.9, reviewCount: 178,
    ),
    // Gynecology
    Doctor(
      id: 'd12', specialtyId: 'gyne',
      nameAr: 'د. إيمان العبادي', nameEn: 'Dr. Iman Al-Abadi',
      titleAr: 'استشارية نساء وولادة', titleEn: 'Consultant Gynecologist',
      rating: 4.9, reviewCount: 467,
    ),
  ];

  static List<Relative> defaultRelatives(String userId) => [
        Relative(
          id: 'self',
          ownerId: userId,
          nameAr: 'أنا',
          nameEn: 'Self',
          relation: 'self',
          nationalId: '9876543210',
          dob: DateTime(1990, 3, 15),
        ),
        Relative(
          id: 'r1',
          ownerId: userId,
          nameAr: 'محمد (الأب)',
          nameEn: 'Mohammed (Father)',
          relation: 'father',
          nationalId: '9876543211',
          dob: DateTime(1962, 7, 20),
        ),
        Relative(
          id: 'r2',
          ownerId: userId,
          nameAr: 'أميرة (الابنة)',
          nameEn: 'Amira (Daughter)',
          relation: 'daughter',
          nationalId: '9876543212',
          dob: DateTime(2018, 1, 5),
        ),
      ];

  static List<Appointment> seedAppointments(String userId) {
    final now = DateTime.now();
    return [
      Appointment(
        id: 'a1',
        patientNameAr: 'فارس أحمد',
        patientNameEn: 'Faris Ahmed',
        doctorNameAr: 'د. أحمد الرشيد',
        doctorNameEn: 'Dr. Ahmad Al-Rashid',
        doctorTitleAr: 'استشاري قلب وأوعية دموية',
        doctorTitleEn: 'Consultant Cardiologist',
        specialtyAr: 'القلب والأوعية الدموية',
        specialtyEn: 'Cardiology',
        insuranceAr: 'التأمين المدني',
        insuranceEn: 'Civil Insurance',
        dateTime: now.add(const Duration(days: 3, hours: 10)),
        location: 'عيادة القلب — الدور الثالث',
        refCode: 'JUH-3142-K7',
        status: ApptStatus.confirmed,
      ),
      Appointment(
        id: 'a2',
        patientNameAr: 'محمد (الأب)',
        patientNameEn: 'Mohammed (Father)',
        doctorNameAr: 'د. خالد العمري',
        doctorNameEn: 'Dr. Khalid Al-Omari',
        doctorTitleAr: 'استشاري أمراض عصبية',
        doctorTitleEn: 'Consultant Neurologist',
        specialtyAr: 'الأمراض العصبية',
        specialtyEn: 'Neurology',
        insuranceAr: 'التأمين المدني',
        insuranceEn: 'Civil Insurance',
        dateTime: now.subtract(const Duration(days: 7, hours: 14)),
        location: 'عيادة الأعصاب — الدور الثاني',
        refCode: 'JUH-2978-M3',
        status: ApptStatus.completed,
      ),
      Appointment(
        id: 'a3',
        patientNameAr: 'أميرة (الابنة)',
        patientNameEn: 'Amira (Daughter)',
        doctorNameAr: 'د. نور الزيادنة',
        doctorNameEn: 'Dr. Nour Al-Ziyadneh',
        doctorTitleAr: 'استشارية طب أطفال',
        doctorTitleEn: 'Consultant Pediatrician',
        specialtyAr: 'طب الأطفال',
        specialtyEn: 'Pediatrics',
        insuranceAr: 'التأمين المدني',
        insuranceEn: 'Civil Insurance',
        dateTime: now.subtract(const Duration(days: 14, hours: 9)),
        location: 'عيادة الأطفال — الدور الأول',
        refCode: 'JUH-2845-P9',
        status: ApptStatus.cancelled,
      ),
    ];
  }

  static List<String> availableSlots = [
    '08:00', '08:20', '08:40', '09:00', '09:20', '09:40',
    '10:00', '10:20', '10:40', '11:00', '11:20', '11:40',
    '13:00', '13:20', '13:40', '14:00', '14:20', '14:40',
  ];
}
