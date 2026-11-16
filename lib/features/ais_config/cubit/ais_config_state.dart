import 'package:equatable/equatable.dart';
import '../data/models/ais_config_model.dart';

class AisConfigState extends Equatable {
  final AisConfigModel? config;
  final bool isLoading;
  final bool isSuccess;
  final String? message;

  const AisConfigState({
    this.config,
    this.isLoading = false,
    this.isSuccess = false,
    this.message,
  });

  AisConfigState copyWith({
    AisConfigModel? config,
    bool? isLoading,
    bool? isSuccess,
    String? message,
  }) {
    return AisConfigState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      message: message,
    );
  }

  @override
  List<Object?> get props => [config, isLoading, isSuccess, message];
}

