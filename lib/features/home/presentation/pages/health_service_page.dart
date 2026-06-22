import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/responsive/responsive_spacing.dart';
import '../../../../core/responsive/responsive_text.dart';
import '../../../../shared/widgets/top_header.dart';

class HealthServicePage extends StatelessWidget {
  const HealthServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const TopHeader(showBack: true, showThemeToggle: false),
      ),
      body: ResponsiveContainer.safe(
        child: ResponsiveContainer.scrollable(
          context: context,
          child: ResponsiveContainer.adaptive(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Get Health Service',
                  style: ResponsiveText.titleStyle(
                    context,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: ResponsiveSpacing.smSpacing(context)),
                Text(
                  'Find nearby health facilities and services that match your needs.',
                  style: ResponsiveText.bodyStyle(
                    context,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: ResponsiveSpacing.xlSpacing(context)),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 250,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(ResponsiveSpacing.xlSpacing(context)),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_hospital_outlined,
                            size: 44,
                            color: colorScheme.primary,
                          ),
                          SizedBox(height: ResponsiveSpacing.mdSpacing(context)),
                          Text(
                            'Service Finder',
                            style: ResponsiveText.subtitleStyle(
                              context,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: ResponsiveSpacing.xsSpacing(context)),
                          Text(
                            'Browse nearby clinics and get directions quickly.',
                            textAlign: TextAlign.center,
                            style: ResponsiveText.bodyStyle(
                              context,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
