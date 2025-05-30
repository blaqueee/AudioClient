import 'package:audio_client/domain/usecases/fetch_child_customs_offices_usecase.dart';
import 'package:audio_client/domain/usecases/fetch_root_customs_offices_usecase.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_treeview/flutter_treeview.dart';

class CustomsOfficeTreeCubit extends Cubit<TreeViewController> {
  final FetchRootCustomsOfficesUseCase fetchRootNodesUseCase;
  final FetchChildCustomsOfficesUseCase fetchChildNodesUseCase;
  final Dio dio;

  CustomsOfficeTreeCubit({
    required this.fetchRootNodesUseCase,
    required this.fetchChildNodesUseCase,
    required this.dio,
  }) : super(TreeViewController(children: []));

  Future<void> loadRootNodes() async {
    if (dio.options.baseUrl.isEmpty) {
      emit(TreeViewController(children: []));
      return;
    }

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
      expanded: false,
    )).toList();

    final parentNode = state.getNode(parentKey);
    if (parentNode != null) {
      final updatedParent = parentNode.copyWith(
        children: childNodes,
        expanded: true,
      );

      final updatedNodes = updateNode(state.children, parentKey, updatedParent);

      emit(state.copyWith(children: updatedNodes));
    }
  }

  void toggleNode(String key) async {
    final node = state.getNode(key);

    if (node != null) {
      if (node.children.isEmpty) {
        await loadChildNodes(key);
      } else {
        final updatedNode = node.copyWith(expanded: !node.expanded);
        final updatedNodes = updateNode(state.children, key, updatedNode);

        emit(state.copyWith(children: updatedNodes, selectedKey: key));
      }
    }
  }

  List<Node> updateNode(List<Node> nodes, String key, Node newNode) {
    return nodes.map((child) {
      if (child.key == key) {
        return newNode;
      } else if (child.children.isNotEmpty) {
        return child.copyWith(
          children: updateNode(child.children, key, newNode),
        );
      } else {
        return child;
      }
    }).toList();
  }


}
