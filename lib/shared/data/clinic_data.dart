import '../models/clinic_model.dart';

final List<Clinic> clinicList = [
  Clinic(
    id: '1',
    name: 'Addis Ababa Health Center',
    address: 'Addis Ababa, Ethiopia',
    description:
        'Provides free HIV testing, SRH counseling, and GBV support services.',
    services: ['HIV', 'SRH', 'GBV'],
    distance: '1.2 km',
    imageUrl: 'assets/images/clinic1.png',
    openingHours: '8:00 AM',
    closingHours: '5:00 PM',
    phone: '+251 911 123 456',
  ),
  Clinic(
    id: '2',
    name: 'Bole Community Clinic',
    address: 'Bole, Addis Ababa',
    description:
        'Youth-friendly clinic offering HIV testing and mental health support.',
    services: ['HIV', 'SRH'],
    distance: '2.1 km',
    imageUrl: 'assets/images/clinic2.jpg',
    openingHours: '9:00 AM',
    closingHours: '6:00 PM',
    phone: '+251 922 456 789',
  ),
  Clinic(
    id: '3',
    name: 'Yeka Referral Clinic',
    address: 'Yeka, Addis Ababa',
    description:
        'Specialized services for GBV survivors and hepatitis screening.',
    services: ['GBV', 'Hepatitis'],
    distance: '3.0 km',
    imageUrl: 'assets/images/clinic3.jpg',
    openingHours: '8:30 AM',
    closingHours: '4:30 PM',
    phone: '+251 933 888 777',
  ),
  Clinic(
    id: '4',
    name: 'Kality Health Center',
    address: 'Kality, Addis Ababa',
    description:
        'Substance use counseling and sexual health education.',
    services: ['Drug Risk', 'SRH'],
    distance: '3.4 km',
    imageUrl: 'assets/images/clinic4.jpg',
    openingHours: '9:00 AM',
    closingHours: '5:00 PM',
    phone: '+251 944 222 111',
  ),
  Clinic(
    id: '5',
    name: 'Piassa Medical Clinic',
    address: 'Piassa, Addis Ababa',
    description:
        'Comprehensive youth health services including HIV prevention.',
    services: ['HIV', 'SRH', 'Hepatitis'],
    distance: '4.0 km',
    imageUrl: 'assets/images/clinic5.jpg',
    openingHours: '8:00 AM',
    closingHours: '6:00 PM',
    phone: '+251 955 333 222',
  ),
];
