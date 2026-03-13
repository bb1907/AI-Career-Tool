import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/auth_controller.dart';
import '../domain/entities/candidate_profile.dart';
import 'profile_import_controller.dart';

final candidateProfileControllerProvider =
    AsyncNotifierProvider<CandidateProfileController, CandidateProfile?>(
      CandidateProfileController.new,
    );

class CandidateProfileController extends AsyncNotifier<CandidateProfile?> {
  @override
  Future<CandidateProfile?> build() async {
    final userId = ref.watch(
      authControllerProvider.select((authState) => authState.session?.userId),
    );

    if (userId == null) {
      return null;
    }

    return ref.read(profileImportRepositoryProvider).fetchLatestProfile();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(profileImportRepositoryProvider).fetchLatestProfile(),
    );
  }

  void setImportedProfile(CandidateProfile profile) {
    state = AsyncData(profile);
  }

  Future<CandidateProfile> updateProfile(CandidateProfile profile) async {
    final updatedProfile = await ref
        .read(profileImportRepositoryProvider)
        .updateProfile(profile);
    state = AsyncData(updatedProfile);
    return updatedProfile;
  }
}
