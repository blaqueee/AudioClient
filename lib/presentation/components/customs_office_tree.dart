import 'package:audio_client/di.dart';
import 'package:audio_client/presentation/bloc/customs_office_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomsOfficeTree extends StatelessWidget {
  const CustomsOfficeTree({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.selectPlacement),
      content: SizedBox(
        width: 400,
        height: 300,
        child: BlocProvider(
          create: (_) => getIt<CustomsOfficeTreeCubit>()..loadRootNodes(),
          child: BlocBuilder<CustomsOfficeTreeCubit, TreeViewController>(
            builder: (context, controller) {
              return TreeView(
                controller: controller,
                allowParentSelect: true,
                supportParentDoubleTap: true,
                onNodeTap: (key) {
                  context.read<CustomsOfficeTreeCubit>().toggleNode(key);
                },
                onNodeDoubleTap: (key) {
                  final node = controller.getNode(key);
                  if (node != null) {
                    Navigator.of(context).pop({
                      'label': node.label,
                      'id': node.key
                    });
                  }
                },
                nodeBuilder: (context, node) {
                  final isExpanded = node.expanded;

                  return Row(
                    children: [
                      FaIcon(
                        isExpanded ? FontAwesomeIcons.folderOpen : FontAwesomeIcons.folder,
                        size: 20,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 8, height: 32),
                      Expanded(
                        child: Text(
                          node.label,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  );
                }
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        )
      ],
    );
  }
}
