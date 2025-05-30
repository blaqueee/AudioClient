import 'package:audio_client/di.dart';
import 'package:audio_client/domain/usecases/fetch_child_customs_offices_usecase.dart';
import 'package:audio_client/domain/usecases/fetch_root_customs_offices_usecase.dart';
import 'package:audio_client/presentation/bloc/customs_office_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_treeview/flutter_treeview.dart';

class CustomsOfficeTree extends StatelessWidget {
  const CustomsOfficeTree({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomsOfficeTreeCubit(
        fetchRootNodesUseCase: getIt<FetchRootCustomsOfficesUseCase>(),
        fetchChildNodesUseCase: getIt<FetchChildCustomsOfficesUseCase>(),
      )..loadRootNodes(),
      child: BlocBuilder<CustomsOfficeTreeCubit, TreeViewController>(
        builder: (context, controller) {
          return TreeView(
            controller: controller,
            allowParentSelect: false,
            supportParentDoubleTap: false,
            onNodeTap: (key) {
              context.read<CustomsOfficeTreeCubit>().toggleNode(key);
            },
            theme: TreeViewTheme(
              expanderTheme: ExpanderThemeData(
                type: ExpanderType.caret,
                modifier: ExpanderModifier.none,
                position: ExpanderPosition.start,
                size: 20,
                color: Colors.blue,
              ),
              labelStyle: TextStyle(
                fontSize: 16,
                letterSpacing: 0.3,
              ),
              parentLabelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
              iconTheme: IconThemeData(
                size: 18,
                color: Colors.grey[700],
              ),
              colorScheme: ColorScheme.light(),
            ),
          );
        },
      ),
    );
  }
}
