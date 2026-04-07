import '../models/learning_content_block.dart';
import '../models/learning_module.dart';
import '../models/learning_section.dart';

final List<LearningModule> learningModules = [
  LearningModule(
    id: 'hiv',
    title: 'Human immune virus (HIV)',
    shortDescription:
        'Learn the basics of HIV, how it spreads, how to prevent it, and available care options.',
    introText:
        'HIV stands for human immunodeficiency virus. It affects and destroys cells of the immune system, making it harder to fight infections and other diseases.',
    note:
        'Early testing and treatment can help people with HIV live healthy lives and reduce transmission.',
    imageUrl: 'assets/images/hiv_module.jpg',
    isAssetImage: true,
    imagePosition: ModuleImagePosition.bottom,
    sections: const [
      LearningSection(
        id: 'hiv_def',
        title: 'Definition',
        order: 1,
        blocks: [
          LearningContentBlock(
            id: 'hiv_def_sub',
            type: LearningContentType.subtitle,
            text: 'What is HIV?',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
          LearningContentBlock(
            id: 'hiv_def_p1',
            type: LearningContentType.paragraph,
            text:
                'HIV is a virus that weakens the immune system by attacking important cells that help the body fight infection.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 2,
          ),
          LearningContentBlock(
            id: 'hiv_def_note',
            type: LearningContentType.note,
            text:
                'Without treatment, HIV can make the body less able to protect itself from disease.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 3,
          ),
        ],
      ),
      LearningSection(
        id: 'hiv_trans',
        title: 'Mode of transmission',
        order: 2,
        blocks: [
          LearningContentBlock(
            id: 'hiv_trans_p1',
            type: LearningContentType.paragraph,
            text:
                'HIV can spread through unprotected sexual contact, infected blood, sharing contaminated sharp materials, and from mother to child during pregnancy, birth, or breastfeeding.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
          LearningContentBlock(
            id: 'hiv_trans_list',
            type: LearningContentType.bullets,
            text: '',
            items: [
              'Unprotected sexual contact',
              'Exposure to infected blood',
              'Sharing contaminated sharp materials',
              'Mother-to-child transmission',
            ],
            imageUrl: '',
            isAssetImage: false,
            order: 2,
          ),
        ],
      ),
      LearningSection(
        id: 'hiv_prev',
        title: 'Methods of prevention',
        order: 3,
        blocks: [
          LearningContentBlock(
            id: 'hiv_prev_sub',
            type: LearningContentType.subtitle,
            text: 'Key prevention methods',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
          LearningContentBlock(
            id: 'hiv_prev_list',
            type: LearningContentType.bullets,
            text: '',
            items: [
              'Use condoms correctly',
              'Avoid sharing needles or sharp tools',
              'Get tested regularly',
              'Seek professional guidance',
            ],
            imageUrl: '',
            isAssetImage: false,
            order: 2,
          ),
          LearningContentBlock(
            id: 'hiv_prev_note',
            type: LearningContentType.note,
            text:
                'Correct information and early action help reduce risk.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 3,
          ),
        ],
      ),
      LearningSection(
        id: 'hiv_test',
        title: 'Testing',
        order: 4,
        blocks: [
          LearningContentBlock(
            id: 'hiv_test_p1',
            type: LearningContentType.paragraph,
            text:
                'HIV can be detected through medical testing at health facilities. Early testing is strongly encouraged.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
          LearningContentBlock(
            id: 'hiv_test_img',
            type: LearningContentType.image,
            text: '',
            items: [],
            imageUrl: 'assets/images/hiv_module.jpg',
            isAssetImage: true,
            order: 2,
          ),
        ],
      ),
      LearningSection(
        id: 'hiv_treat',
        title: 'Treatment',
        order: 5,
        blocks: [
          LearningContentBlock(
            id: 'hiv_treat_p1',
            type: LearningContentType.paragraph,
            text:
                'HIV has no complete cure, but antiretroviral treatment helps control the virus and allows people to live longer, healthier lives.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
          LearningContentBlock(
            id: 'hiv_treat_note',
            type: LearningContentType.note,
            text:
                'Treatment should be started and followed under professional medical guidance.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 2,
          ),
        ],
      ),
    ],
  ),
  LearningModule(
    id: 'sti',
    title: 'Sexually transmitted infections (STI)',
    shortDescription:
        'Understand common STIs, how they spread, how to prevent them, and when to get treatment.',
    introText:
        'STIs are infections commonly spread through sexual contact. Some may show symptoms, while others may not.',
    note:
        'Untreated STIs can lead to serious health complications. Early testing and treatment are important.',
    imageUrl: 'assets/images/sti_module.jpg',
    isAssetImage: true,
    imagePosition: ModuleImagePosition.top,
    sections: const [
      LearningSection(
        id: 'sti_def',
        title: 'Definition',
        order: 1,
        blocks: [
          LearningContentBlock(
            id: 'sti_def_p1',
            type: LearningContentType.paragraph,
            text:
                'STIs are infections transmitted mainly through sexual contact.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
      LearningSection(
        id: 'sti_trans',
        title: 'Mode of transmission',
        order: 2,
        blocks: [
          LearningContentBlock(
            id: 'sti_trans_sub',
            type: LearningContentType.subtitle,
            text: 'How STIs can spread',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
          LearningContentBlock(
            id: 'sti_trans_list',
            type: LearningContentType.bullets,
            text: '',
            items: [
              'Vaginal sex',
              'Oral sex',
              'Anal sex',
              'In some cases, from mother to child',
            ],
            imageUrl: '',
            isAssetImage: false,
            order: 2,
          ),
        ],
      ),
      LearningSection(
        id: 'sti_prev',
        title: 'Methods of prevention',
        order: 3,
        blocks: [
          LearningContentBlock(
            id: 'sti_prev_list',
            type: LearningContentType.bullets,
            text: '',
            items: [
              'Use condoms correctly',
              'Limit risky exposure',
              'Seek regular testing',
              'Get medical advice quickly when symptoms appear',
            ],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
      LearningSection(
        id: 'sti_test',
        title: 'Testing',
        order: 4,
        blocks: [
          LearningContentBlock(
            id: 'sti_test_p1',
            type: LearningContentType.paragraph,
            text:
                'Testing is available in health facilities and is important even when no symptoms are present.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
      LearningSection(
        id: 'sti_treat',
        title: 'Treatment',
        order: 5,
        blocks: [
          LearningContentBlock(
            id: 'sti_treat_p1',
            type: LearningContentType.paragraph,
            text:
                'Many STIs can be treated, and some can be cured. Medical follow-up is important.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
          LearningContentBlock(
            id: 'sti_treat_note',
            type: LearningContentType.note,
            text:
                'Getting treatment early helps reduce complications and further spread.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 2,
          ),
        ],
      ),
    ],
  ),
  LearningModule(
    id: 'hepatitis',
    title: 'Hepatitis',
    shortDescription:
        'Learn what hepatitis is, how it affects the liver, and how prevention and treatment work.',
    introText:
        'Hepatitis is inflammation of the liver. Some forms are caused by viruses and can spread through different routes.',
    note:
        'Vaccination, hygiene, and medical care are important in preventing and managing hepatitis.',
    imageUrl: 'assets/images/hepatitis_module.jpg',
    isAssetImage: true,
    imagePosition: ModuleImagePosition.bottom,
    sections: const [
      LearningSection(
        id: 'hep_def',
        title: 'Definition',
        order: 1,
        blocks: [
          LearningContentBlock(
            id: 'hep_def_p1',
            type: LearningContentType.paragraph,
            text:
                'Hepatitis is a condition that causes liver inflammation and can affect liver function.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
      LearningSection(
        id: 'hep_trans',
        title: 'Mode of transmission',
        order: 2,
        blocks: [
          LearningContentBlock(
            id: 'hep_trans_p1',
            type: LearningContentType.paragraph,
            text:
                'Different types of hepatitis spread in different ways, including contaminated food, blood exposure, and sexual contact.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
      LearningSection(
        id: 'hep_prev',
        title: 'Methods of prevention',
        order: 3,
        blocks: [
          LearningContentBlock(
            id: 'hep_prev_list',
            type: LearningContentType.bullets,
            text: '',
            items: [
              'Get vaccinated when available',
              'Maintain good hygiene',
              'Use safe medical practices',
              'Avoid unsafe blood exposure',
            ],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
      LearningSection(
        id: 'hep_test',
        title: 'Testing',
        order: 4,
        blocks: [
          LearningContentBlock(
            id: 'hep_test_p1',
            type: LearningContentType.paragraph,
            text:
                'Health facilities can provide tests to identify hepatitis infection.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
      LearningSection(
        id: 'hep_treat',
        title: 'Treatment',
        order: 5,
        blocks: [
          LearningContentBlock(
            id: 'hep_treat_p1',
            type: LearningContentType.paragraph,
            text:
                'Treatment depends on the type of hepatitis and should be guided by health professionals.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
    ],
  ),
  LearningModule(
    id: 'gbv',
    title: 'Gender-based violence (GBV)',
    shortDescription:
        'Understand GBV, warning signs, support options, and where to seek help.',
    introText:
        'Gender-based violence includes harmful acts directed at a person because of gender. It can be physical, emotional, sexual, or economic.',
    note:
        'Support services and professional help are important. Survivors should be treated with dignity, safety, and confidentiality.',
    imageUrl: 'assets/images/gbv_module.jpg',
    isAssetImage: true,
    imagePosition: ModuleImagePosition.top,
    sections: const [
      LearningSection(
        id: 'gbv_def',
        title: 'Definition',
        order: 1,
        blocks: [
          LearningContentBlock(
            id: 'gbv_def_p1',
            type: LearningContentType.paragraph,
            text:
                'GBV refers to violence or abuse directed at someone based on gender.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
      LearningSection(
        id: 'gbv_trans',
        title: 'Mode of transmission',
        order: 2,
        blocks: [
          LearningContentBlock(
            id: 'gbv_trans_p1',
            type: LearningContentType.paragraph,
            text:
                'This section can be replaced later by admin content more appropriate for GBV education flow.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
      LearningSection(
        id: 'gbv_prev',
        title: 'Methods of prevention',
        order: 3,
        blocks: [
          LearningContentBlock(
            id: 'gbv_prev_list',
            type: LearningContentType.bullets,
            text: '',
            items: [
              'Increase awareness and education',
              'Build safe reporting systems',
              'Promote respectful relationships',
              'Strengthen community support',
            ],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
      LearningSection(
        id: 'gbv_test',
        title: 'Testing',
        order: 4,
        blocks: [
          LearningContentBlock(
            id: 'gbv_test_p1',
            type: LearningContentType.paragraph,
            text:
                'This section can later be replaced with support and referral guidance depending on your backend content design.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
      LearningSection(
        id: 'gbv_treat',
        title: 'Treatment',
        order: 5,
        blocks: [
          LearningContentBlock(
            id: 'gbv_treat_p1',
            type: LearningContentType.paragraph,
            text:
                'Medical care, counseling, legal support, and referral services may all be needed depending on the case.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
          LearningContentBlock(
            id: 'gbv_treat_note',
            type: LearningContentType.note,
            text:
                'Admin can later replace this with the exact support pathways used by your system.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 2,
          ),
        ],
      ),
    ],
  ),
  LearningModule(
    id: 'srh',
    title: 'Sexual and reproductive health (SRH)',
    shortDescription:
        'Explore core SRH knowledge, healthy choices, care options, and protection methods.',
    introText:
        'Sexual and reproductive health includes physical, emotional, and social well-being related to sexuality and reproduction.',
    note:
        'Access to correct information and youth-friendly services helps young people make informed choices.',
    imageUrl: 'assets/images/srh_module.jpg',
    isAssetImage: true,
    imagePosition: ModuleImagePosition.bottom,
    sections: const [
      LearningSection(
        id: 'srh_def',
        title: 'Definition',
        order: 1,
        blocks: [
          LearningContentBlock(
            id: 'srh_def_p1',
            type: LearningContentType.paragraph,
            text:
                'SRH focuses on informed, safe, and respectful health choices related to sexuality and reproduction.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
      LearningSection(
        id: 'srh_trans',
        title: 'Mode of transmission',
        order: 2,
        blocks: [
          LearningContentBlock(
            id: 'srh_trans_p1',
            type: LearningContentType.paragraph,
            text:
                'Admin can later customize this section depending on SRH content strategy.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
      LearningSection(
        id: 'srh_prev',
        title: 'Methods of prevention',
        order: 3,
        blocks: [
          LearningContentBlock(
            id: 'srh_prev_list',
            type: LearningContentType.bullets,
            text: '',
            items: [
              'Get correct information',
              'Use youth-friendly services',
              'Make healthy and informed decisions',
              'Seek support from professionals when needed',
            ],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
      LearningSection(
        id: 'srh_test',
        title: 'Testing',
        order: 4,
        blocks: [
          LearningContentBlock(
            id: 'srh_test_p1',
            type: LearningContentType.paragraph,
            text:
                'Health facilities can provide SRH-related services, checkups, and counseling.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
      LearningSection(
        id: 'srh_treat',
        title: 'Treatment',
        order: 5,
        blocks: [
          LearningContentBlock(
            id: 'srh_treat_p1',
            type: LearningContentType.paragraph,
            text:
                'Treatment depends on the specific issue and should be guided by trained health professionals.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
    ],
  ),
  LearningModule(
    id: 'substance_abuse',
    title: 'Substance Abuse',
    shortDescription:
        'Learn about substance abuse, common warning signs, effects, and ways to seek help.',
    introText:
        'Substance abuse involves harmful or risky use of substances that can negatively affect health, behavior, and daily life.',
    note:
        'Early awareness and support can prevent long-term health and social consequences.',
    imageUrl: 'assets/images/substance_module.jpg',
    isAssetImage: true,
    imagePosition: ModuleImagePosition.top,
    sections: const [
      LearningSection(
        id: 'sub_def',
        title: 'Definition',
        order: 1,
        blocks: [
          LearningContentBlock(
            id: 'sub_def_p1',
            type: LearningContentType.paragraph,
            text:
                'Substance abuse refers to harmful use of drugs, alcohol, or other substances.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
      LearningSection(
        id: 'sub_trans',
        title: 'Mode of transmission',
        order: 2,
        blocks: [
          LearningContentBlock(
            id: 'sub_trans_p1',
            type: LearningContentType.paragraph,
            text:
                'Admin can replace this section with a more suitable label later if needed.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
      LearningSection(
        id: 'sub_prev',
        title: 'Methods of prevention',
        order: 3,
        blocks: [
          LearningContentBlock(
            id: 'sub_prev_list',
            type: LearningContentType.bullets,
            text: '',
            items: [
              'Increase awareness and education',
              'Create supportive environments',
              'Encourage counseling and early support',
              'Promote positive coping strategies',
            ],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
      LearningSection(
        id: 'sub_test',
        title: 'Testing',
        order: 4,
        blocks: [
          LearningContentBlock(
            id: 'sub_test_p1',
            type: LearningContentType.paragraph,
            text:
                'Assessment and screening can help identify harmful substance use patterns early.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
        ],
      ),
      LearningSection(
        id: 'sub_treat',
        title: 'Treatment',
        order: 5,
        blocks: [
          LearningContentBlock(
            id: 'sub_treat_p1',
            type: LearningContentType.paragraph,
            text:
                'Treatment may include counseling, medical support, rehabilitation, and family or community support.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 1,
          ),
          LearningContentBlock(
            id: 'sub_treat_note',
            type: LearningContentType.note,
            text:
                'Recovery support often works best when medical, family, and community support are combined.',
            items: [],
            imageUrl: '',
            isAssetImage: false,
            order: 2,
          ),
        ],
      ),
    ],
  ),
];