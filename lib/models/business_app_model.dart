class BusinessAppModel {
  final String? clientId;
  final String? appName;
  final String? description;
  final String? callbackUrl;
  final String? status;
  final String? webhookUrl;
  final dynamic webhookEvents;
  final bool? webhookActive;

  BusinessAppModel({
    this.clientId,
    this.appName,
    this.description,
    this.callbackUrl,
    this.status,
    this.webhookUrl,
    this.webhookEvents,
    this.webhookActive,
  });

  factory BusinessAppModel.fromJson(Map<String, dynamic> json) {
    return BusinessAppModel(
      clientId: json['clientId'],
      appName: json['appName'],
      description: json['description'],
      callbackUrl: json['callbackUrl'],
      status: json['status'],
      webhookUrl: json['webhookUrl'],
      webhookEvents: json['webhookEvents'],
      webhookActive: json['webhookActive'],
    );
  }
}

class BusinessAppListResponse {
  final List<BusinessAppModel> apps;
  final int totalElements;

  BusinessAppListResponse({required this.apps, required this.totalElements});

  factory BusinessAppListResponse.fromJson(Map<String, dynamic> json) {
    final content = (json['content'] as List<dynamic>? ?? [])
        .map((e) => BusinessAppModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return BusinessAppListResponse(
      apps: content,
      totalElements: json['totalElements'] ?? content.length,
    );
  }
}