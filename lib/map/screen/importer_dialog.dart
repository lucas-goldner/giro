import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/healthkit/cubit/healthkit_cubit.dart';
import 'package:giro/healthkit/repository/healthkit_repo_method_channel_impl.dart';

class ImporterDialogPage extends StatelessWidget {
  const ImporterDialogPage({super.key});
  static const String routeName = '/import';

  MaterialPageRoute<void> get route => MaterialPageRoute(
        builder: (_) => this,
      );

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => HealthkitCubit(HealthkitRepoMethodChannelImpl()),
        child: const ImporterDialog(),
      );
}

class ImporterDialog extends StatefulWidget {
  const ImporterDialog({super.key});

  @override
  State<ImporterDialog> createState() => _ImporterDialogState();
}

class _ImporterDialogState extends State<ImporterDialog> {
  bool _hasImported = false;

  Future<void> import() async {
    await context
        .read<HealthkitCubit>()
        .retrieveLastWalkingWorkouts()
        .then((_) => setState(() => _hasImported = true));
  }

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Past workouts',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                CupertinoButton.filled(
                  onPressed: import,
                  child: const Text('Import'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_hasImported) ...[
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text('Title $index'),
                      subtitle: const Text('Jul 20, 2019'),
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text(
                          '$index',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: 15,
              ),
            ),
          ],
        ],
      );
}
