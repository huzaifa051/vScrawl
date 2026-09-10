/// workflowId : 39030
/// documentCount : 1
/// recipientCount : 1
/// name : "Application"
/// ownerName : "Haider Saeed"
/// ownerEmail : "haiderjutt@yopmail.com"
/// isViewed : true
/// isEVRGenerated : false
/// status : "DRAFT"
/// workflowStatus : "DRAFT"
/// updatedOn : "2026-08-24T11:00:18.000+00:00"
/// signaturesDetail : null
/// anyDigitalSignature : null
/// protectedDoc : false
/// recipientId : 55628
/// recipientRole : "SIGNER"
/// enforceIdentity : false
/// workflowType : "SELFSIGN"
/// isPowerSurvey : false
/// isPowerSurveyChild : false
/// dispatchedCount : null
/// completedCount : null

class DocumentModel {
  DocumentModel({
      num? workflowId, 
      num? documentCount, 
      num? recipientCount, 
      String? name, 
      String? ownerName, 
      String? ownerEmail, 
      bool? isViewed, 
      bool? isEVRGenerated, 
      String? status, 
      String? workflowStatus, 
      String? updatedOn, 
      dynamic signaturesDetail, 
      dynamic anyDigitalSignature, 
      bool? protectedDoc, 
      num? recipientId, 
      String? recipientRole, 
      bool? enforceIdentity, 
      String? workflowType, 
      bool? isPowerSurvey, 
      bool? isPowerSurveyChild, 
      dynamic dispatchedCount, 
      dynamic completedCount,}){
    _workflowId = workflowId;
    _documentCount = documentCount;
    _recipientCount = recipientCount;
    _name = name;
    _ownerName = ownerName;
    _ownerEmail = ownerEmail;
    _isViewed = isViewed;
    _isEVRGenerated = isEVRGenerated;
    _status = status;
    _workflowStatus = workflowStatus;
    _updatedOn = updatedOn;
    _signaturesDetail = signaturesDetail;
    _anyDigitalSignature = anyDigitalSignature;
    _protectedDoc = protectedDoc;
    _recipientId = recipientId;
    _recipientRole = recipientRole;
    _enforceIdentity = enforceIdentity;
    _workflowType = workflowType;
    _isPowerSurvey = isPowerSurvey;
    _isPowerSurveyChild = isPowerSurveyChild;
    _dispatchedCount = dispatchedCount;
    _completedCount = completedCount;
}

  DocumentModel.fromJson(dynamic json) {
    _workflowId = json['workflowId'];
    _documentCount = json['documentCount'];
    _recipientCount = json['recipientCount'];
    _name = json['name'];
    _ownerName = json['ownerName'];
    _ownerEmail = json['ownerEmail'];
    _isViewed = json['isViewed'];
    _isEVRGenerated = json['isEVRGenerated'];
    _status = json['status'];
    _workflowStatus = json['workflowStatus'];
    _updatedOn = json['updatedOn'];
    _signaturesDetail = json['signaturesDetail'];
    _anyDigitalSignature = json['anyDigitalSignature'];
    _protectedDoc = json['protectedDoc'];
    _recipientId = json['recipientId'];
    _recipientRole = json['recipientRole'];
    _enforceIdentity = json['enforceIdentity'];
    _workflowType = json['workflowType'];
    _isPowerSurvey = json['isPowerSurvey'];
    _isPowerSurveyChild = json['isPowerSurveyChild'];
    _dispatchedCount = json['dispatchedCount'];
    _completedCount = json['completedCount'];
  }
  num? _workflowId;
  num? _documentCount;
  num? _recipientCount;
  String? _name;
  String? _ownerName;
  String? _ownerEmail;
  bool? _isViewed;
  bool? _isEVRGenerated;
  String? _status;
  String? _workflowStatus;
  String? _updatedOn;
  dynamic _signaturesDetail;
  dynamic _anyDigitalSignature;
  bool? _protectedDoc;
  num? _recipientId;
  String? _recipientRole;
  bool? _enforceIdentity;
  String? _workflowType;
  bool? _isPowerSurvey;
  bool? _isPowerSurveyChild;
  dynamic _dispatchedCount;
  dynamic _completedCount;
DocumentModel copyWith({  num? workflowId,
  num? documentCount,
  num? recipientCount,
  String? name,
  String? ownerName,
  String? ownerEmail,
  bool? isViewed,
  bool? isEVRGenerated,
  String? status,
  String? workflowStatus,
  String? updatedOn,
  dynamic signaturesDetail,
  dynamic anyDigitalSignature,
  bool? protectedDoc,
  num? recipientId,
  String? recipientRole,
  bool? enforceIdentity,
  String? workflowType,
  bool? isPowerSurvey,
  bool? isPowerSurveyChild,
  dynamic dispatchedCount,
  dynamic completedCount,
}) => DocumentModel(  workflowId: workflowId ?? _workflowId,
  documentCount: documentCount ?? _documentCount,
  recipientCount: recipientCount ?? _recipientCount,
  name: name ?? _name,
  ownerName: ownerName ?? _ownerName,
  ownerEmail: ownerEmail ?? _ownerEmail,
  isViewed: isViewed ?? _isViewed,
  isEVRGenerated: isEVRGenerated ?? _isEVRGenerated,
  status: status ?? _status,
  workflowStatus: workflowStatus ?? _workflowStatus,
  updatedOn: updatedOn ?? _updatedOn,
  signaturesDetail: signaturesDetail ?? _signaturesDetail,
  anyDigitalSignature: anyDigitalSignature ?? _anyDigitalSignature,
  protectedDoc: protectedDoc ?? _protectedDoc,
  recipientId: recipientId ?? _recipientId,
  recipientRole: recipientRole ?? _recipientRole,
  enforceIdentity: enforceIdentity ?? _enforceIdentity,
  workflowType: workflowType ?? _workflowType,
  isPowerSurvey: isPowerSurvey ?? _isPowerSurvey,
  isPowerSurveyChild: isPowerSurveyChild ?? _isPowerSurveyChild,
  dispatchedCount: dispatchedCount ?? _dispatchedCount,
  completedCount: completedCount ?? _completedCount,
);
  num? get workflowId => _workflowId;
  num? get documentCount => _documentCount;
  num? get recipientCount => _recipientCount;
  String? get name => _name;
  String? get ownerName => _ownerName;
  String? get ownerEmail => _ownerEmail;
  bool? get isViewed => _isViewed;
  bool? get isEVRGenerated => _isEVRGenerated;
  String? get status => _status;
  String? get workflowStatus => _workflowStatus;
  String? get updatedOn => _updatedOn;
  dynamic get signaturesDetail => _signaturesDetail;
  dynamic get anyDigitalSignature => _anyDigitalSignature;
  bool? get protectedDoc => _protectedDoc;
  num? get recipientId => _recipientId;
  String? get recipientRole => _recipientRole;
  bool? get enforceIdentity => _enforceIdentity;
  String? get workflowType => _workflowType;
  bool? get isPowerSurvey => _isPowerSurvey;
  bool? get isPowerSurveyChild => _isPowerSurveyChild;
  dynamic get dispatchedCount => _dispatchedCount;
  dynamic get completedCount => _completedCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['workflowId'] = _workflowId;
    map['documentCount'] = _documentCount;
    map['recipientCount'] = _recipientCount;
    map['name'] = _name;
    map['ownerName'] = _ownerName;
    map['ownerEmail'] = _ownerEmail;
    map['isViewed'] = _isViewed;
    map['isEVRGenerated'] = _isEVRGenerated;
    map['status'] = _status;
    map['workflowStatus'] = _workflowStatus;
    map['updatedOn'] = _updatedOn;
    map['signaturesDetail'] = _signaturesDetail;
    map['anyDigitalSignature'] = _anyDigitalSignature;
    map['protectedDoc'] = _protectedDoc;
    map['recipientId'] = _recipientId;
    map['recipientRole'] = _recipientRole;
    map['enforceIdentity'] = _enforceIdentity;
    map['workflowType'] = _workflowType;
    map['isPowerSurvey'] = _isPowerSurvey;
    map['isPowerSurveyChild'] = _isPowerSurveyChild;
    map['dispatchedCount'] = _dispatchedCount;
    map['completedCount'] = _completedCount;
    return map;
  }

}