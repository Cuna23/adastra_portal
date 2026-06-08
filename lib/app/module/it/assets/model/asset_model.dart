class AssetModel {
  final int id;
  final String assetTag;
  final String? serialNumber;
  final String? brand;
  final String? model;
  final String? status;
  final String? assignedTo;
  final String? department;
  final int?    categoryId; 
  final String? categoryName;
  final String? empId;
  final String? approvedBy;
  final String? purchasedBy;
  final String? remark;

  AssetModel({
    required this.id,
    required this.assetTag,
    this.serialNumber,
    this.brand,
    this.model,
    this.status,
    this.assignedTo,
    this.department,
    this.categoryId,
    this.categoryName,
    this.empId,
    this.approvedBy,
    this.purchasedBy,
    this.remark,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'],
      assetTag: json['asset_tag'] ?? '',
      serialNumber: json['serial_number'],
      brand: json['brand'],
      model: json['model'],
      status: json['status'],
      assignedTo: json['assigned_to'],
      department: json['department'],
      categoryId: json['category_id'],
      categoryName: json['category']?['name'],
      empId: json['emp_id'],
      approvedBy: json['approved_by'],
      purchasedBy: json['purchased_by'],
      remark: json['remark'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_tag': assetTag,
      'serial_number': serialNumber,
      'brand': brand,
      'model': model,
      'status': status,
      'assigned_to': assignedTo,
      'department': department,
      'category_id': categoryId,
      'category_name': categoryName,
    };
  }
}