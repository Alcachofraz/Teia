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
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

/** This is an auto generated class representing the Chapter type in your schema. */
@immutable
class Chapter extends Model {
  static const classType = const _ChapterModelType();
  final String id;
  final String? _title;
  final ChapterGraph? _graph;
  final Story? _story;
  final List<Page>? _pages;
  final TemporalDateTime? _createdAt;
  final TemporalDateTime? _updatedAt;
  final String? _chapterGraphId;

  @override
  getInstanceType() => classType;

  @Deprecated(
      '[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;

  ChapterModelIdentifier get modelIdentifier {
    return ChapterModelIdentifier(id: id);
  }

  String get title {
    try {
      return _title!;
    } catch (e) {
      throw new AmplifyCodeGenModelException(AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion: AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString());
    }
  }

  ChapterGraph? get graph {
    return _graph;
  }

  Story? get story {
    return _story;
  }

  List<Page>? get pages {
    return _pages;
  }

  TemporalDateTime? get createdAt {
    return _createdAt;
  }

  TemporalDateTime? get updatedAt {
    return _updatedAt;
  }

  String? get chapterGraphId {
    return _chapterGraphId;
  }

  const Chapter._internal({required this.id, required title, graph, story, pages, createdAt, updatedAt, chapterGraphId})
      : _title = title,
        _graph = graph,
        _story = story,
        _pages = pages,
        _createdAt = createdAt,
        _updatedAt = updatedAt,
        _chapterGraphId = chapterGraphId;

  factory Chapter(
      {String? id,
      required String title,
      ChapterGraph? graph,
      Story? story,
      List<Page>? pages,
      String? chapterGraphId}) {
    return Chapter._internal(
        id: id == null ? UUID.getUUID() : id,
        title: title,
        graph: graph,
        story: story,
        pages: pages != null ? List<Page>.unmodifiable(pages) : pages,
        chapterGraphId: chapterGraphId);
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Chapter &&
        id == other.id &&
        _title == other._title &&
        _graph == other._graph &&
        _story == other._story &&
        DeepCollectionEquality().equals(_pages, other._pages) &&
        _chapterGraphId == other._chapterGraphId;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("Chapter {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("story=" + (_story != null ? _story!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null") + ", ");
    buffer.write("chapterGraphId=" + "$_chapterGraphId");
    buffer.write("}");

    return buffer.toString();
  }

  Chapter copyWith({String? title, ChapterGraph? graph, Story? story, List<Page>? pages, String? chapterGraphId}) {
    return Chapter._internal(
        id: id,
        title: title ?? this.title,
        graph: graph ?? this.graph,
        story: story ?? this.story,
        pages: pages ?? this.pages,
        chapterGraphId: chapterGraphId ?? this.chapterGraphId);
  }

  Chapter.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        _title = json['title'],
        _graph = json['graph']?['serializedData'] != null
            ? ChapterGraph.fromJson(new Map<String, dynamic>.from(json['graph']['serializedData']))
            : null,
        _story = json['story']?['serializedData'] != null
            ? Story.fromJson(new Map<String, dynamic>.from(json['story']['serializedData']))
            : null,
        _pages = json['pages'] is List
            ? (json['pages'] as List)
                .where((e) => e?['serializedData'] != null)
                .map((e) => Page.fromJson(new Map<String, dynamic>.from(e['serializedData'])))
                .toList()
            : null,
        _createdAt = json['createdAt'] != null ? TemporalDateTime.fromString(json['createdAt']) : null,
        _updatedAt = json['updatedAt'] != null ? TemporalDateTime.fromString(json['updatedAt']) : null,
        _chapterGraphId = json['chapterGraphId'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': _title,
        'graph': _graph?.toJson(),
        'story': _story?.toJson(),
        'pages': _pages?.map((Page? e) => e?.toJson()).toList(),
        'createdAt': _createdAt?.format(),
        'updatedAt': _updatedAt?.format(),
        'chapterGraphId': _chapterGraphId
      };

  Map<String, Object?> toMap() => {
        'id': id,
        'title': _title,
        'graph': _graph,
        'story': _story,
        'pages': _pages,
        'createdAt': _createdAt,
        'updatedAt': _updatedAt,
        'chapterGraphId': _chapterGraphId
      };

  static final QueryModelIdentifier<ChapterModelIdentifier> MODEL_IDENTIFIER =
      QueryModelIdentifier<ChapterModelIdentifier>();
  static final QueryField ID = QueryField(fieldName: "id");
  static final QueryField TITLE = QueryField(fieldName: "title");
  static final QueryField GRAPH =
      QueryField(fieldName: "graph", fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: 'ChapterGraph'));
  static final QueryField STORY =
      QueryField(fieldName: "story", fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: 'Story'));
  static final QueryField PAGES =
      QueryField(fieldName: "pages", fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: 'Page'));
  static final QueryField CHAPTERGRAPHID = QueryField(fieldName: "chapterGraphId");
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Chapter";
    modelSchemaDefinition.pluralName = "Chapters";

    modelSchemaDefinition.addField(ModelFieldDefinition.id());

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: Chapter.TITLE, isRequired: true, ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.hasOne(
        key: Chapter.GRAPH, isRequired: false, ofModelName: 'ChapterGraph', associatedKey: ChapterGraph.CHAPTER));

    modelSchemaDefinition.addField(ModelFieldDefinition.belongsTo(
        key: Chapter.STORY, isRequired: false, targetNames: ['storyChaptersId'], ofModelName: 'Story'));

    modelSchemaDefinition.addField(ModelFieldDefinition.hasMany(
        key: Chapter.PAGES, isRequired: false, ofModelName: 'Page', associatedKey: Page.CHAPTER));

    modelSchemaDefinition.addField(ModelFieldDefinition.nonQueryField(
        fieldName: 'createdAt',
        isRequired: false,
        isReadOnly: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)));

    modelSchemaDefinition.addField(ModelFieldDefinition.nonQueryField(
        fieldName: 'updatedAt',
        isRequired: false,
        isReadOnly: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: Chapter.CHAPTERGRAPHID, isRequired: false, ofType: ModelFieldType(ModelFieldTypeEnum.string)));
  });
}

class _ChapterModelType extends ModelType<Chapter> {
  const _ChapterModelType();

  @override
  Chapter fromJson(Map<String, dynamic> jsonData) {
    return Chapter.fromJson(jsonData);
  }

  @override
  String modelName() {
    return 'Chapter';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Chapter] in your schema.
 */
@immutable
class ChapterModelIdentifier implements ModelIdentifier<Chapter> {
  final String id;

  /** Create an instance of ChapterModelIdentifier using [id] the primary key. */
  const ChapterModelIdentifier({required this.id});

  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{'id': id});

  @override
  List<Map<String, dynamic>> serializeAsList() =>
      serializeAsMap().entries.map((entry) => (<String, dynamic>{entry.key: entry.value})).toList();

  @override
  String serializeAsString() => serializeAsMap().values.join('#');

  @override
  String toString() => 'ChapterModelIdentifier(id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ChapterModelIdentifier && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
