class TemplateItemModel {
  final String? id;
  final String? name;
  final String? ownerName;
  final String? ownerEmail;
  final String? description;
  final String? workflowName;
  final String? createdOn;

  TemplateItemModel({
    this.id,
    this.name,
    this.ownerName,
    this.ownerEmail,
    this.description,
    this.workflowName,
    this.createdOn,
  });

  factory TemplateItemModel.fromJson(Map<String, dynamic> json) {
    return TemplateItemModel(
      id: json['id'],
      name: json['name'],
      ownerName: json['ownerName'],
      ownerEmail: json['ownerEmail'],
      description: json['description'],
      workflowName: json['workflow']?['workflowName'],
      createdOn: json['createdOn'],
    );
  }
}

class TemplateListResponse {
  final List<TemplateItemModel> templates;
  final int totalElements;

  TemplateListResponse({required this.templates, required this.totalElements});

  factory TemplateListResponse.fromJson(Map<String, dynamic> json) {
    final content = (json['content'] as List<dynamic>? ?? [])
        .map((e) => TemplateItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return TemplateListResponse(
      templates: content,
      totalElements: json['totalElements'] ?? content.length,
    );
  }
}

class TemplateFolderModel {
  final int? id;
  final String? name;
  final int? parentFolderId;
  final String? ownerName;
  final int? itemCount;
  final String? createdAt;

  TemplateFolderModel({
    this.id,
    this.name,
    this.parentFolderId,
    this.ownerName,
    this.itemCount,
    this.createdAt,
  });

  factory TemplateFolderModel.fromJson(Map<String, dynamic> json) {
    return TemplateFolderModel(
      id: json['id'],
      name: json['name'],
      parentFolderId: json['parentFolderId'],
      ownerName: json['ownerName'],
      itemCount: json['itemCount'],
      createdAt: json['createdAt'],
    );
  }
}