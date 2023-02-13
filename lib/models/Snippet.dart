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


/** This is an auto generated class representing the Snippet type in your schema. */
@immutable
class Snippet extends Model {
  static const classType = const _SnippetModelType();
  final String id;
  final String? _text;
  final Page? _page;
  final TemporalDateTime? _createdAt;
  final TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  SnippetModelIdentifier get modelIdentifier {
      return SnippetModelIdentifier(
        id: id
      );
  }
  
  String get text {
    try {
      return _text!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  Page? get page {
    return _page;
  }
  
  TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Snippet._internal({required this.id, required text, page, createdAt, updatedAt}): _text = text, _page = page, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Snippet({String? id, required String text, Page? page}) {
    return Snippet._internal(
      id: id == null ? UUID.getUUID() : id,
      text: text,
      page: page);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Snippet &&
      id == other.id &&
      _text == other._text &&
      _page == other._page;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Snippet {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("text=" + "$_text" + ", ");
    buffer.write("page=" + (_page != null ? _page!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Snippet copyWith({String? text, Page? page}) {
    return Snippet._internal(
      id: id,
      text: text ?? this.text,
      page: page ?? this.page);
  }
  
  Snippet.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _text = json['text'],
      _page = json['page']?['serializedData'] != null
        ? Page.fromJson(new Map<String, dynamic>.from(json['page']['serializedData']))
        : null,
      _createdAt = json['createdAt'] != null ? TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'text': _text, 'page': _page?.toJson(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id, 'text': _text, 'page': _page, 'createdAt': _createdAt, 'updatedAt': _updatedAt
  };

  static final QueryModelIdentifier<SnippetModelIdentifier> MODEL_IDENTIFIER = QueryModelIdentifier<SnippetModelIdentifier>();
  static final QueryField ID = QueryField(fieldName: "id");
  static final QueryField TEXT = QueryField(fieldName: "text");
  static final QueryField PAGE = QueryField(
    fieldName: "page",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: 'Page'));
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Snippet";
    modelSchemaDefinition.pluralName = "Snippets";
    
    modelSchemaDefinition.addField(ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Snippet.TEXT,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.belongsTo(
      key: Snippet.PAGE,
      isRequired: false,
      targetNames: ['pageSnippetsId'],
      ofModelName: 'Page'
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
}

class _SnippetModelType extends ModelType<Snippet> {
  const _SnippetModelType();
  
  @override
  Snippet fromJson(Map<String, dynamic> jsonData) {
    return Snippet.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Snippet';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Snippet] in your schema.
 */
@immutable
class SnippetModelIdentifier implements ModelIdentifier<Snippet> {
  final String id;

  /** Create an instance of SnippetModelIdentifier using [id] the primary key. */
  const SnippetModelIdentifier({
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
  String toString() => 'SnippetModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is SnippetModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}