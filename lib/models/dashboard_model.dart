/// draftDocCount : 30
/// pendingDocCount : 0
/// sentDocCount : 6
/// signedDocCount : 25
/// completedDocCount : 111
/// voidDocCount : 13

class DashboardModel {
  DashboardModel({
      num? draftDocCount, 
      num? pendingDocCount, 
      num? sentDocCount, 
      num? signedDocCount, 
      num? completedDocCount, 
      num? voidDocCount,}){
    _draftDocCount = draftDocCount;
    _pendingDocCount = pendingDocCount;
    _sentDocCount = sentDocCount;
    _signedDocCount = signedDocCount;
    _completedDocCount = completedDocCount;
    _voidDocCount = voidDocCount;
}

  DashboardModel.fromJson(dynamic json) {
    _draftDocCount = json['draftDocCount'];
    _pendingDocCount = json['pendingDocCount'];
    _sentDocCount = json['sentDocCount'];
    _signedDocCount = json['signedDocCount'];
    _completedDocCount = json['completedDocCount'];
    _voidDocCount = json['voidDocCount'];
  }
  num? _draftDocCount;
  num? _pendingDocCount;
  num? _sentDocCount;
  num? _signedDocCount;
  num? _completedDocCount;
  num? _voidDocCount;
DashboardModel copyWith({  num? draftDocCount,
  num? pendingDocCount,
  num? sentDocCount,
  num? signedDocCount,
  num? completedDocCount,
  num? voidDocCount,
}) => DashboardModel(  draftDocCount: draftDocCount ?? _draftDocCount,
  pendingDocCount: pendingDocCount ?? _pendingDocCount,
  sentDocCount: sentDocCount ?? _sentDocCount,
  signedDocCount: signedDocCount ?? _signedDocCount,
  completedDocCount: completedDocCount ?? _completedDocCount,
  voidDocCount: voidDocCount ?? _voidDocCount,
);
  num? get draftDocCount => _draftDocCount;
  num? get pendingDocCount => _pendingDocCount;
  num? get sentDocCount => _sentDocCount;
  num? get signedDocCount => _signedDocCount;
  num? get completedDocCount => _completedDocCount;
  num? get voidDocCount => _voidDocCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['draftDocCount'] = _draftDocCount;
    map['pendingDocCount'] = _pendingDocCount;
    map['sentDocCount'] = _sentDocCount;
    map['signedDocCount'] = _signedDocCount;
    map['completedDocCount'] = _completedDocCount;
    map['voidDocCount'] = _voidDocCount;
    return map;
  }

}