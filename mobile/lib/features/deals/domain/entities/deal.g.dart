// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DealImpl _$$DealImplFromJson(Map<String, dynamic> json) => _$DealImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      customerId: json['customer_id'] as String,
      contactId: json['contact_id'] as String?,
      stage: json['stage'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      probability: (json['probability'] as num?)?.toInt(),
      expectedClose: json['expected_close'] == null
          ? null
          : DateTime.parse(json['expected_close'] as String),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$DealImplToJson(_$DealImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'customer_id': instance.customerId,
      'contact_id': instance.contactId,
      'stage': instance.stage,
      'status': instance.status,
      'amount': instance.amount,
      'probability': instance.probability,
      'expected_close': instance.expectedClose?.toIso8601String(),
      'description': instance.description,
    };
