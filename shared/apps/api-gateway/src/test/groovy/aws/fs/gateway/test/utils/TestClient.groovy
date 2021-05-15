package aws.fs.gateway.test.utils

import aws.fs.gateway.core.entities.UserProfile
import io.micronaut.http.annotation.Body
import io.micronaut.http.annotation.Post
import io.micronaut.http.client.annotation.Client

@Client("/")
interface TestClient {

    @Post("user-profile")
    UserProfile createUserProfile(@Body UserProfile userProfile);
}
