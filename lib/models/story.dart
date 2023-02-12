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


/** This is an auto generated class representing the Story type in your schema. */
@immutable
class Story extends Model {
  static const classType = const _StoryModelType();
  final String id;
  final String? _title;
  final TemporalDate? _createdAt;
  final List<UsersWriteStories>? _authors;
  final List<Chapter>? _chapters;
  final TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  StoryModelIdentifier get modelIdentifier {
      return StoryModelIdentifier(
        id: id
      );
  }
  
  String get title {
    try {
      return _title!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  TemporalDate? get createdAt {
    return _createdAt;
  }
  
  List<UsersWriteStories>? get authors {
    return _authors;
  }
  
  List<Chapter>? get chapters {
    return _chapters;
  }
  
  TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Story._internal({required this.id, required title, createdAt, authors, chapters, updatedAt}): _title = title, _createdAt = createdAt, _authors = authors, _chapters = chapters, _updatedAt = updatedAt;
  
  factory Story({String? id, required String title, TemporalDate? createdAt, List<UsersWriteStories>? authors, List<Chapter>? chapters}) {
    return Story._internal(
      id: id == null ? UUID.getUUID() : id,
      title: title,
      createdAt: createdAt,
      authors: authors != null ? List<UsersWriteStories>.unmodifiable(authors) : authors,
      chapters: chapters != null ? List<Chapter>.unmodifiable(chapters) : chapters);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Story &&
      id == other.id &&
      _title == other._title &&
      _createdAt == other._createdAt &&
      DeepCollectionEquality().equals(_authors, other._authors) &&
      DeepCollectionEquality().equals(_chapters, other._chapters);
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Story {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Story copyWith({String? title, TemporalDate? createdAt, List<UsersWriteStories>? authors, List<Chapter>? chapters}) {
    return Story._internal(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      authors: authors ?? this.authors,
      chapters: chapters ?? this.chapters);
  }
  
  Story.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _title = json['title'],
      _createdAt = json['createdAt'] != null ? TemporalDate.fromString(json['createdAt']) : null,
      _authors = json['authors'] is List
        ? (json['authors'] as List)
          .where((e) => e?['serializedData'] != null)
          .map((e) => UsersWriteStories.fromJson(new Map<String, dynamic>.from(e['serializedData'])))
          .toList()
        : null,
      _chapters = json['chapters'] is List
        ? (json['chapters'] as List)
          .where((e) => e?['serializedData'] != null)
          .map((e) => Chapter.fromJson(new Map<String, dynamic>.from(e['serializedData'])))
          .toList()
        : null,
      _updatedAt = json['updatedAt'] != null ? TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'title': _title, 'createdAt': _createdAt?.format(), 'authors': _authors?.map((UsersWriteStories? e) => e?.toJson()).toList(), 'chapters': _chapters?.map((Chapter? e) => e?.toJson()).toList(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id, 'title': _title, 'createdAt': _createdAt, 'authors': _authors, 'chapters': _chapters, 'updatedAt': _updatedAt
  };

  static final QueryModelIdentifier<StoryModelIdentifier> MODEL_IDENTIFIER = QueryModelIdentifier<StoryModelIdentifier>();
  static final QueryField ID = QueryField(fieldName: "id");
  static final QueryField TITLE = QueryField(fieldName: "title");
  static final QueryField CREATEDAT = QueryField(fieldName: "createdAt");
  static final QueryField AUTHORS = QueryField(
    fieldName: "authors",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: 'UsersWriteStories'));
  static final QueryField CHAPTERS = QueryField(
    fieldName: "chapters",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: 'Chapter'));
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Story";
    modelSchemaDefinition.pluralName = "Stories";
    
    modelSchemaDefinition.addField(ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Story.TITLE,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Story.CREATEDAT,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.date)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.hasMany(
      key: Story.AUTHORS,
      isRequired: false,
      ofModelName: 'UsersWriteStories',
      associatedKey: UsersWriteStories.STORY
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.hasMany(
      key: Story.CHAPTERS,
      isRequired: false,
      ofModelName: 'Chapter',
      associatedKey: Chapter.STORY
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _StoryModelType extends ModelType<Story> {
  const _StoryModelType();
  
  @override
  Story fromJson(Map<String, dynamic> jsonData) {
    return Story.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Story';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Story] in your schema.
 */
@immutable
class StoryModelIdentifier implements ModelIdentifier<Story> {
  final String id;

  /** Create an instance of StoryModelIdentifier using [id] the primary key. */
  const StoryModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'StoryModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is StoryModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}