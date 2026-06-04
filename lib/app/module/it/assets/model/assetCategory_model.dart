class AssetCategoryModel {
  final int    id;
  final String name;

  const AssetCategoryModel({required this.id, required this.name});

  factory AssetCategoryModel.fromJson(Map<String, dynamic> json) =>
      AssetCategoryModel(
        id:   json['id']   as int,
        name: json['name'] as String,
      );
}