import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';



part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
@HiveType(typeId: 0)
class ProductModel with _$ProductModel {
  const factory ProductModel({
    @HiveField(0) required int id,
    @HiveField(1) required String title,
    @HiveField(2) required String description,
    @HiveField(3) required num price,
    @HiveField(4) required String thumbnail,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
}