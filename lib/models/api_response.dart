class ApiResponse<T> {
  final T result;
  final String message;
  final int status;
  final dynamic error;

  ApiResponse({
    required this.result,
    required this.message,
    required this.status,
    required this.error,
  });

  // Convertir la respuesta JSON a un objeto ApiResponse
  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return ApiResponse<T>(
      result: fromJsonT(json['result']),
      message: json['message'],
      status: json['status'],
      error: json['error'],
    );
  }

  // Convertir un ApiResponse a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'message': message,
      'status': status,
      'error': error,
    };
  }
}
