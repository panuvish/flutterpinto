class StandardResponseBody {
  final bool ok;
  final dynamic data;
  final error;

  StandardResponseBody({required this.ok, this.data, this.error});

  factory StandardResponseBody.fromJson(Map<String, dynamic> json) {
    return StandardResponseBody(
      ok: json['ok'] as bool,
      data: json['data'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ok': ok,
      if (data != null) 'data': data,
      if (error != null) 'error': error,
    };
  }
}
