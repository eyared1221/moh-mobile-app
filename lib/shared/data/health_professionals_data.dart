import '../models/health_professional.dart';

final List<HealthProfessional> healthProfessionals = [
  HealthProfessional(
    id: '1',
    name: 'Dr. Sara Alemu',
    title: 'Public Health Specialist',
    specialties: [
      'HIV',
      'SRH',
      'GBV',
    ],
    experience: '8 years experience',
    availableTime: 'Mon–Fri | 9:00 AM – 2:00 PM',
    meetingLink: 'https://meet.google.com/example1',
    imageUrl: 'assets/images/doctor1.png',
  ),
  HealthProfessional(
    id: '2',
    name: 'Dr. Daniel Bekele',
    title: 'Clinical Psychologist',
    specialties: [
      'Effects of Drugs',
      'Mental Health',
      'Addiction',
    ],
    experience: '6 years experience',
    availableTime: 'Tue–Sat | 3:00 PM – 7:00 PM',
    meetingLink: 'https://meet.google.com/example2',
    imageUrl: 'assets/images/doctor2.png',
  ),
];
