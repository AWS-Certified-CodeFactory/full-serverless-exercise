package aws.fs.gateway.core;


import aws.fs.gateway.core.entities.UserProfile;
import aws.fs.gateway.repository.UserProfileRepository;
import lombok.RequiredArgsConstructor;

import javax.inject.Singleton;

@RequiredArgsConstructor
@Singleton
public class UserProfileService {

    private final UserProfileRepository repository;

    public UserProfile create(UserProfile userProfile) {
        return repository.save(userProfile);
    }
}
