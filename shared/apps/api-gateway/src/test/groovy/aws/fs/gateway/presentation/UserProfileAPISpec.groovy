package aws.fs.gateway.presentation

import aws.fs.gateway.core.entities.UserProfile
import aws.fs.gateway.test.utils.TestClient
import io.micronaut.test.extensions.spock.annotation.MicronautTest
import spock.lang.Specification

import javax.inject.Inject

@MicronautTest
class UserProfileAPISpec extends Specification {

    @Inject
    TestClient client

    void "should create a new user profile"() {

        given: "a request to create a new user"
        def testProfile = new UserProfile()
        testProfile.fullName = "Test 123"

        when:
        def result = client.createUserProfile(testProfile)

        then: "echo back the newly-created user with id"
        result
        result.userId
        result.fullName == testProfile.fullName
    }

}