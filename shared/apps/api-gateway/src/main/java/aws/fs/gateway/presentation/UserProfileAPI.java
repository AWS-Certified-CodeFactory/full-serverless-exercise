package aws.fs.gateway.presentation;

import aws.fs.gateway.core.entities.UserProfile;
import aws.fs.gateway.core.UserProfileService;
import io.micronaut.http.annotation.Body;
import io.micronaut.http.annotation.Controller;
import io.micronaut.http.annotation.Post;
import lombok.RequiredArgsConstructor;

import java.util.UUID;

@RequiredArgsConstructor
@Controller("user-profile")
public class UserProfileAPI {

    private final UserProfileService service;

    /**
     * http POST :8080/user-profile fullName=test
     *
     * @param userProfile
     * @return
     */
    @Post
    public UserProfile create(@Body UserProfile userProfile) {
        userProfile.setUserId(UUID.randomUUID().toString());
        return service.create(userProfile);
    }
}
