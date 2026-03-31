// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Deal _$DealFromJson(Map<String, dynamic> json) => _Deal(
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
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => DealItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      customer: json['customer'] == null
          ? null
          : Customer.fromJson(json['customer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DealToJson(_Deal instance) => <String, dynamic>{
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
      'items': instance.items,
      'customer': instance.customer,
    };
