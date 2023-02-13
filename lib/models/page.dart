<<<<<<< HEAD
import 'package:teia/models/snippets/snippet.dart';

class Page {
  final int id;
  final List<Snippet> snippets;

  Page(this.id, this.snippets);
=======
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


/** This is an auto generated class representing the Page type in your schema. */
@immutable
class Page extends Model {
  static const classType = const _PageModelType();
  final String id;
  final Chapter? _chapter;
  final List<Snippet>? _snippets;
  final TemporalDateTime? _createdAt;
  final TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  PageModelIdentifier get modelIdentifier {
      return PageModelIdentifier(
        id: id
      );
  }
  
  Chapter? get chapter {
    return _chapter;
  }
  
  List<Snippet>? get snippets {
    return _snippets;
  }
  
  TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Page._internal({required this.id, chapter, snippets, createdAt, updatedAt}): _chapter = chapter, _snippets = snippets, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Page({String? id, Chapter? chapter, List<Snippet>? snippets}) {
    return Page._internal(
      id: id == null ? UUID.getUUID() : id,
      chapter: chapter,
      snippets: snippets != null ? List<Snippet>.unmodifiable(snippets) : snippets);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Page &&
      id == other.id &&
      _chapter == other._chapter &&
      DeepCollectionEquality().equals(_snippets, other._snippets);
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Page {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("chapter=" + (_chapter != null ? _chapter!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Page copyWith({Chapter? chapter, List<Snippet>? snippets}) {
    return Page._internal(
      id: id,
      chapter: chapter ?? this.chapter,
      snippets: snippets ?? this.snippets);
  }
  
  Page.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _chapter = json['chapter']?['serializedData'] != null
        ? Chapter.fromJson(new Map<String, dynamic>.from(json['chapter']['serializedData']))
        : null,
      _snippets = json['snippets'] is List
        ? (json['snippets'] as List)
          .where((e) => e?['serializedData'] != null)
          .map((e) => Snippet.fromJson(new Map<String, dynamic>.from(e['serializedData'])))
          .toList()
        : null,
      _createdAt = json['createdAt'] != null ? TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'chapter': _chapter?.toJson(), 'snippets': _snippets?.map((Snippet? e) => e?.toJson()).toList(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id, 'chapter': _chapter, 'snippets': _snippets, 'createdAt': _createdAt, 'updatedAt': _updatedAt
  };

  static final QueryModelIdentifier<PageModelIdentifier> MODEL_IDENTIFIER = QueryModelIdentifier<PageModelIdentifier>();
  static final QueryField ID = QueryField(fieldName: "id");
  static final QueryField CHAPTER = QueryField(
    fieldName: "chapter",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: 'Chapter'));
  static final QueryField SNIPPETS = QueryField(
    fieldName: "snippets",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: 'Snippet'));
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Page";
    modelSchemaDefinition.pluralName = "Pages";
    
    modelSchemaDefinition.addField(ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(ModelFieldDefinition.belongsTo(
      key: Page.CHAPTER,
      isRequired: false,
      targetNames: ['chapterPagesId'],
      ofModelName: 'Chapter'
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.hasMany(
      key: Page.SNIPPETS,
      isRequired: false,
      ofModelName: 'Snippet',
      associatedKey: Snippet.PAGE
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)
    ));
  });
>>>>>>> d43f899cef355c9fdb4a565efd8c754c0c2a095b
}

class _PageModelType extends ModelType<Page> {
  const _PageModelType();
  
  @override
  Page fromJson(Map<String, dynamic> jsonData) {
    return Page.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Page';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Page] in your schema.
 */
@immutable
class PageModelIdentifier implements ModelIdentifier<Page> {
  final String id;

  /** Create an instance of PageModelIdentifier using [id] the primary key. */
  const PageModelIdentifier({
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
  String toString() => 'PageModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is PageModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}