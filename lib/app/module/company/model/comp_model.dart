class CompanyModel {
  final int id;
  final String type; 
  final String? title;
  final String? imagePath;
  final String? content;
  final int sortOrder;
  final int? uploadedBy;

  CompanyModel({
    required this.id,
    required this.type,
    this.title,
    this.imagePath,
    this.content,
    this.sortOrder = 0,
    this.uploadedBy,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      imagePath: json['image_path'],
      content: json['content'],
      sortOrder: json['sort_order'] ?? 0,
      uploadedBy: json['uploaded_by'],
    );
  }

  String? get imageUrl => imagePath;
}