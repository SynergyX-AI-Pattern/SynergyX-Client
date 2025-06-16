class Prediction {
  final String upperBound;
  final String lowerBound;
  final String buyPrice;
  final String sellPrice;
  final String targetRange;

  Prediction({
    required this.upperBound,
    required this.lowerBound,
    required this.buyPrice,
    required this.sellPrice,
    required this.targetRange,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      upperBound: json['upperBound'] ?? '',
      lowerBound: json['lowerBound'] ?? '',
      buyPrice: json['buyPrice'] ?? '',
      sellPrice: json['sellPrice'] ?? '',
      targetRange: json['targetRange'] ?? '',
    );
  }
}

class Financials {
  final String pbr;
  final String per;
  final String psr;
  final String roe;
  final String marketCap;
  final String? dividendYield;

  Financials({
    required this.pbr,
    required this.per,
    required this.psr,
    required this.roe,
    required this.marketCap,
    this.dividendYield,
  });

  factory Financials.fromJson(Map<String, dynamic> json) {
    return Financials(
      pbr: json['pbr'] ?? '',
      per: json['per'] ?? '',
      psr: json['psr'] ?? '',
      roe: json['roe'] ?? '',
      marketCap: json['marketCap'] ?? '',
      dividendYield: json['dividendYield']?.toString(),
    );
  }
}

class StockDetailResponse {
  final String stockName;
  final String price;
  final String changeRate;
  final String changeAmount;
  final bool isWatchlist;
  final Prediction prediction;
  final Financials financials;

  StockDetailResponse({
    required this.stockName,
    required this.price,
    required this.changeRate,
    required this.changeAmount,
    required this.isWatchlist,
    required this.prediction,
    required this.financials,
  });

  factory StockDetailResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    if (result == null) {
      throw Exception('API 응답에 result가 없습니다.');
    }

    final predictionJson = result['prediction'];
    final financialsJson = result['financials'];

    if (predictionJson == null || financialsJson == null) {
      throw Exception('예측 또는 재무 데이터가 누락되었습니다.');
    }

    return StockDetailResponse(
      stockName: result['stockName'],
      price: result['price'] ?? '',
      changeAmount: result['changeAmount'] ?? '',
      changeRate: result['changeRate'] ?? '',
      isWatchlist: result['isWatchlist'] ?? false,
      prediction: Prediction.fromJson(predictionJson),
      financials: Financials.fromJson(financialsJson),
    );
  }
}
