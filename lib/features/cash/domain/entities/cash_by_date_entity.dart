// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:delivery/features/cash/domain/entities/cash_order_entity.dart';
import 'package:equatable/equatable.dart';

class CashByDateEntity extends Equatable {
  final DateTime date;
  final int count;
  final int totalMoney;
  final List<CashOrderEntity> cashOrders;

  const CashByDateEntity({
    required this.date,
    required this.count,
    required this.totalMoney,
    required this.cashOrders,
  });

  @override
  List<Object> get props => [date, count, totalMoney, cashOrders];

  CashByDateEntity copyWith({
    DateTime? date,
    int? count,
    int? totalMoney,
    List<CashOrderEntity>? cashOrders,
  }) {
    return CashByDateEntity(
      date: date ?? this.date,
      count: count ?? this.count,
      totalMoney: totalMoney ?? this.totalMoney,
      cashOrders: cashOrders ?? this.cashOrders,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date.toIso8601String(),
      'count': count,
      'totalMoney': totalMoney,
      'cashOrders': cashOrders.map((x) => x.toMap()).toList(),
    };
  }

  factory CashByDateEntity.fromMap(Map<String, dynamic> map) {
    return CashByDateEntity(
      date: DateTime.parse(map['date'] as String),
      count: map['count'] as int,
      totalMoney: map['totalMoney'] as int,
      cashOrders: List<CashOrderEntity>.from(
        (map['cashOrderDTOs'] as List).map<CashOrderEntity>(
          (x) => CashOrderEntity.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory CashByDateEntity.fromJson(String source) =>
      CashByDateEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
