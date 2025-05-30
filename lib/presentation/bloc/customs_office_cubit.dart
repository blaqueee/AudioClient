import 'package:audio_client/domain/usecases/fetch_child_customs_offices_usecase.dart';
import 'package:audio_client/domain/usecases/fetch_root_customs_offices_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_treeview/flutter_treeview.dart';

class CustomsOfficeTreeCubit extends Cubit<TreeViewController> {
  final FetchRootCustomsOfficesUseCase fetchRootNodesUseCase;
  final FetchChildCustomsOfficesUseCase fetchChildNodesUseCase;

  CustomsOfficeTreeCubit({
    required this.fetchRootNodesUseCase,
    required this.fetchChildNodesUseCase,
  }) : super(TreeViewController(children: []));

  Future<void> loadRootNodes() async {
    final nodes = await fetchRootNodesUseCase();
    final treeNodes = nodes.map((n) => Node(
      key: n.id.toString(),
      label: n.name,
      expanded: false,
      children: [],
    )).toList();

    emit(TreeViewController(children: treeNodes));
  }

  Future<void> loadChildNodes(String parentKey) async {
    final children = await fetchChildNodesUseCase(parentKey);
    final childNodes = children.map((n) => Node(
      key: n.id.toString(),
      label: n.name,
      children: [],
    )).toList();

    final parentNode = state.getNode(parentKey);
    if (parentNode != null) {
      final updatedParent = parentNode.copyWith(
        children: childNodes,
        expanded: true,
      );

      final updatedNodes = state.updateNode(parentKey, updatedParent);

      emit(state.copyWith(children: updatedNodes));
    }
  }

  void toggleNode(String key) async {
    final node = state.getNode(key);

    if (node != null) {
      if (node.children.isEmpty) {
        await loadChildNodes(key);
      }

      final updatedNode = node.copyWith(expanded: !(node.expanded ?? false));

      final updatedNodes = state.updateNode(key, updatedNode);

      emit(state.copyWith(children: updatedNodes, selectedKey: key));
    }
  }

}
