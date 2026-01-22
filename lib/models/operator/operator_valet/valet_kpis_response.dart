class ValetKpisResponse {
  final int totalValets;
  final int availableValets;
  final int onDutyValets;
  final int onBreakValets;

  ValetKpisResponse({
    required this.totalValets,
    required this.availableValets,
    required this.onDutyValets,
    required this.onBreakValets,
  });

  factory ValetKpisResponse.fromJson(Map<String, dynamic> json) {
    return ValetKpisResponse(
      totalValets: json['totalValets'] as int,
      availableValets: json['availableValets'] as int,
      onDutyValets: json['onDutyValets'] as int,
      onBreakValets: json['onBreakValets'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalValets': totalValets,
      'availableValets': availableValets,
      'onDutyValets': onDutyValets,
      'onBreakValets': onBreakValets,
    };
  }
}
