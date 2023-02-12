/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart';
import 'package:flutter/foundation.dart';

/** This is an auto generated class representing the ChapterGraph type in your schema. */
@immutable
class ChapterGraph extends Model {
  static const classType = const _ChapterGraphModelType();
  final String id;
  final Chapter? _chapter;
  final Map<int, List<int>>? _nodes;
  final TemporalDateTime? _createdAt;
  final TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;

  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;

  ChapterGraphModelIdentifier get modelIdentifier {
    return ChapterGraphModelIdentifier(id: id);
  }

  Chapter? get chapter {
    return _chapter;
  }

  Map<int, List<int>>? get nodes {
    return _nodes;
  }

  TemporalDateTime? get createdAt {
    return _createdAt;
  }

  TemporalDateTime? get updatedAt {
    return _updatedAt;
  }

  const ChapterGraph._internal({required this.id, chapter, nodes, createdAt, updatedAt})
      : _chapter = chapter,
        _nodes = nodes,
        _createdAt = createdAt,
        _updatedAt = updatedAt;

  factory ChapterGraph({String? id, Chapter? chapter, String? nodes}) {
    return ChapterGraph._internal(id: id == null ? UUID.getUUID() : id, chapter: chapter, nodes: nodes);
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChapterGraph && id == other.id && _chapter == other._chapter && _nodes == other._nodes;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("ChapterGraph {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("chapter=" + (_chapter != null ? _chapter!.toString() : "null") + ", ");
    buffer.write("nodes=" + "$_nodes" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");

    return buffer.toString();
  }

  ChapterGraph copyWith({Chapter? chapter, String? nodes}) {
    return ChapterGraph._internal(id: id, chapter: chapter ?? this.chapter, nodes: nodes ?? this.nodes);
  }

  ChapterGraph.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        _chapter =
            json['chapter']?['serializedData'] != null ? Chapter.fromJson(new Map<String, dynamic>.from(json['chapter']['serializedData'])) : null,
        _nodes = json['nodes'],
        _createdAt = json['createdAt'] != null ? TemporalDateTime.fromString(json['createdAt']) : null,
        _updatedAt = json['updatedAt'] != null ? TemporalDateTime.fromString(json['updatedAt']) : null;

  Map<String, dynamic> toJson() =>
      {'id': id, 'chapter': _chapter?.toJson(), 'nodes': _nodes, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()};

  Map<String, Object?> toMap() => {'id': id, 'chapter': _chapter, 'nodes': _nodes, 'createdAt': _createdAt, 'updatedAt': _updatedAt};

  static final QueryModelIdentifier<ChapterGraphModelIdentifier> MODEL_IDENTIFIER = QueryModelIdentifier<ChapterGraphModelIdentifier>();
  static final QueryField ID = QueryField(fieldName: "id");
  static final QueryField CHAPTER = QueryField(fieldName: "chapter", fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: 'Chapter'));
  static final QueryField NODES = QueryField(fieldName: "nodes");
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "ChapterGraph";
    modelSchemaDefinition.pluralName = "ChapterGraphs";

    modelSchemaDefinition.addField(ModelFieldDefinition.id());

    modelSchemaDefinition.addField(
        ModelFieldDefinition.belongsTo(key: ChapterGraph.CHAPTER, isRequired: false, targetNames: ['chapterGraphChapterId'], ofModelName: 'Chapter'));

    modelSchemaDefinition
        .addField(ModelFieldDefinition.field(key: ChapterGraph.NODES, isRequired: false, ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.nonQueryField(
        fieldName: 'createdAt', isRequired: false, isReadOnly: true, ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)));

    modelSchemaDefinition.addField(ModelFieldDefinition.nonQueryField(
        fieldName: 'updatedAt', isRequired: false, isReadOnly: true, ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)));
  });

  // Execute [action] for each connection of the graph.
  // * [action] Action (function) to execute for start and end (nodes) ID's of the connection.
  void forEachConnection(Function(int start, int end) action) {
    if (_nodes == null) return;
    _nodes!.forEach((start, endList) {
      for (var end in endList) {
        action(start, end);
      }
    });
  }

  // Add connection from [start] to [end] to graph.
  // * [start] Start node ID (page ID).
  // * [end] End node ID (page ID).
  // Returns false if [start] doesn't exist or if nodes is null.
  bool addConnection(int start, int end) {
    if (_nodes == null) return false;
    if (_nodes!.containsKey(start)) {
      _nodes![start]!.add(end);
      _nodes![end] = [];
      return true;
    } else {
      return false;
    }
  }

  // Get total number of pages in the graph.
  int numberOfPages() {
    if (_nodes == null) return 0;
    return _nodes!.keys.length;
  }

  // Check if page is leaf (has no child connections).
  // Returns true if pageId doesn't exist or nodes is null.
  bool isLeaf(int pageId) {
    if (_nodes == null) return true;
    final children = _nodes![pageId];
    if (children == null) return true;
    return children.isEmpty;
  }
}

class _ChapterGraphModelType extends ModelType<ChapterGraph> {
  const _ChapterGraphModelType();

  @override
  ChapterGraph fromJson(Map<String, dynamic> jsonData) {
    return ChapterGraph.fromJson(jsonData);
  }

  @override
  String modelName() {
    return 'ChapterGraph';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [ChapterGraph] in your schema.
 */
@immutable
class ChapterGraphModelIdentifier implements ModelIdentifier<ChapterGraph> {
  final String id;

  /** Create an instance of ChapterGraphModelIdentifier using [id] the primary key. */
  const ChapterGraphModelIdentifier({required this.id});

  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{'id': id});

  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap().entries.map((entry) => (<String, dynamic>{entry.key: entry.value})).toList();

  @override
  String serializeAsString() => serializeAsMap().values.join('#');

  @override
  String toString() => 'ChapterGraphModelIdentifier(id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ChapterGraphModelIdentifier && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
