import 'package:equatable/equatable.dart';
import '../../domain/entities/member_entity.dart';

abstract class MemberManagementState extends Equatable {
  const MemberManagementState();

  @override
  List<Object?> get props => [];
}

class MemberManagementInitial extends MemberManagementState {
  const MemberManagementInitial();
}

class MemberManagementLoading extends MemberManagementState {
  const MemberManagementLoading();
}

class MemberManagementLoaded extends MemberManagementState {
  final List<MemberEntity> allMembers;
  final List<MemberEntity> filteredMembers;
  final String searchQuery;
  final bool isSubmitting;
  final String? actionMessage;
  final String? actionError;

  const MemberManagementLoaded({
    required this.allMembers,
    required this.filteredMembers,
    this.searchQuery = '',
    this.isSubmitting = false,
    this.actionMessage,
    this.actionError,
  });

  MemberManagementLoaded copyWith({
    List<MemberEntity>? allMembers,
    List<MemberEntity>? filteredMembers,
    String? searchQuery,
    bool? isSubmitting,
    String? actionMessage,
    String? actionError,
    bool clearFeedback = false,
  }) {
    return MemberManagementLoaded(
      allMembers: allMembers ?? this.allMembers,
      filteredMembers: filteredMembers ?? this.filteredMembers,
      searchQuery: searchQuery ?? this.searchQuery,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionMessage: clearFeedback
          ? null
          : (actionMessage ?? this.actionMessage),
      actionError: clearFeedback ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [
    allMembers,
    filteredMembers,
    searchQuery,
    isSubmitting,
    actionMessage,
    actionError,
  ];
}

class MemberManagementError extends MemberManagementState {
  final String message;

  const MemberManagementError(this.message);

  @override
  List<Object?> get props => [message];
}
