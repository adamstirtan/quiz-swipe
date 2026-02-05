import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/persona_manager.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<PersonaManager>(
          builder: (ctx, personaMgr, _) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 24),
                _buildTitle(),
                const SizedBox(height: 45),
                _buildPersonaSection(ctx, personaMgr),
                const SizedBox(height: 35),
                _buildPrivacySection(ctx, personaMgr),
                const SizedBox(height: 35),
                _buildDataSection(ctx, personaMgr),
                const SizedBox(height: 35),
                _buildInfoSection(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferences',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A237E),
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Customize your experience',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF757575),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonaSection(BuildContext ctx, PersonaManager mgr) {
    return _buildCard(
      titleText: 'Profile Info',
      ico: Icons.account_circle_rounded,
      icoColor: const Color(0xFF5C6BC0),
      children: [
        _buildDetailRow(
          'Age Group',
          mgr.data.demographic ?? 'Not specified',
          Icons.cake_rounded,
          () => _showDemographicPicker(ctx, mgr),
        ),
        const Divider(height: 1),
        _buildDetailRow(
          'Region',
          mgr.data.region ?? 'Not specified',
          Icons.public_rounded,
          () => _showRegionPicker(ctx, mgr),
        ),
      ],
    );
  }

  Widget _buildPrivacySection(BuildContext ctx, PersonaManager mgr) {
    return _buildCard(
      titleText: 'Privacy Controls',
      ico: Icons.lock_rounded,
      icoColor: const Color(0xFF66BB6A),
      children: [
        SwitchListTile(
          title: const Text(
            'Share Anonymous Data',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: const Text(
            'Enable better insights by sharing your anonymized responses',
            style: TextStyle(fontSize: 14),
          ),
          value: mgr.data.sharingEnabled,
          onChanged: (newVal) {
            mgr.modify(sharingEnabled: newVal);
          },
          activeColor: const Color(0xFF66BB6A),
        ),
      ],
    );
  }

  Widget _buildDataSection(BuildContext ctx, PersonaManager mgr) {
    return _buildCard(
      titleText: 'Data Management',
      ico: Icons.storage_rounded,
      icoColor: const Color(0xFFFF7043),
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bar_chart_rounded, color: Color(0xFFFF7043)),
          ),
          title: const Text(
            'Total Responses',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          trailing: Text(
            '${mgr.totalAnswered}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A237E),
            ),
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFE57373)),
          ),
          title: const Text(
            'Erase All My Data',
            style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFD32F2F)),
          ),
          subtitle: const Text(
            'Permanently delete all responses and profile',
            style: TextStyle(fontSize: 14),
          ),
          onTap: () => _showEraseDialog(ctx, mgr),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return _buildCard(
      titleText: 'Information',
      ico: Icons.info_rounded,
      icoColor: const Color(0xFFAB47BC),
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.label_rounded, color: Color(0xFFAB47BC)),
          ),
          title: const Text(
            'QuizSwipe',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: const Text('v1.0.0'),
        ),
        const Divider(height: 1),
        const ListTile(
          leading: Icon(Icons.gavel_rounded, color: Color(0xFFAB47BC)),
          title: Text(
            'Terms & Privacy',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          trailing: Icon(Icons.open_in_new_rounded),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String titleText,
    required IconData ico,
    required Color icoColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: icoColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(ico, color: icoColor, size: 28),
                ),
                const SizedBox(width: 16),
                Text(
                  titleText,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String val,
    IconData ico,
    VoidCallback onEdit,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.indigo.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(ico, color: const Color(0xFF5C6BC0)),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(val),
      trailing: const Icon(Icons.edit_rounded, size: 22),
      onTap: onEdit,
    );
  }

  void _showDemographicPicker(BuildContext ctx, PersonaManager mgr) {
    final options = ['Under 18', '18-24', '25-34', '35-44', '45-54', '55+'];
    
    showDialog(
      context: ctx,
      builder: (BuildContext dialogCtx) {
        return AlertDialog(
          title: const Text('Choose Age Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              return ListTile(
                title: Text(opt),
                onTap: () {
                  mgr.modify(demographic: opt);
                  Navigator.pop(dialogCtx);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showRegionPicker(BuildContext ctx, PersonaManager mgr) {
    final regions = [
      'North America',
      'South America',
      'Europe',
      'Asia',
      'Africa',
      'Oceania',
    ];
    
    showDialog(
      context: ctx,
      builder: (BuildContext dialogCtx) {
        return AlertDialog(
          title: const Text('Choose Region'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: regions.map((reg) {
              return ListTile(
                title: Text(reg),
                onTap: () {
                  mgr.modify(region: reg);
                  Navigator.pop(dialogCtx);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showEraseDialog(BuildContext ctx, PersonaManager mgr) {
    showDialog(
      context: ctx,
      builder: (BuildContext dialogCtx) {
        return AlertDialog(
          title: const Text('Erase All Data?'),
          content: const Text(
            'This will permanently delete all your responses and profile info. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await mgr.purgeAll();
                if (ctx.mounted) {
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('All data erased')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFD32F2F)),
              child: const Text('Erase'),
            ),
          ],
        );
      },
    );
  }
}
