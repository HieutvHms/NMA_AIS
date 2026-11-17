import 'package:equatable/equatable.dart';
import '../../../domain/entities/device_entity.dart';

enum ConfigSubmissionStatus {
  unchanged,
  sending,
  sent,
  success,
  failure,
  noResponse,
}

class DeviceConfigState extends Equatable {
  final DeviceEntity? device;
  final ConfigSubmissionStatus status;
  final String? message;

  const DeviceConfigState({
    this.device,
    this.status = ConfigSubmissionStatus.unchanged,
    this.message,
  });

  DeviceConfigState copyWith({
    DeviceEntity? device,
    ConfigSubmissionStatus? status,
    String? message,
  }) {
    return DeviceConfigState(
      device: device ?? this.device,
      status: status ?? this.status,
      message: message,
    );
  }

  @override
  List<Object?> get props => [device, status, message];
}
