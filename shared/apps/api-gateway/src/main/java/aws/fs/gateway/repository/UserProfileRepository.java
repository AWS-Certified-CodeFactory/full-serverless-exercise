package aws.fs.gateway.repository;

import aws.fs.gateway.core.entities.UserProfile;
import io.micronaut.data.annotation.Repository;
import io.micronaut.data.repository.CrudRepository;

@Repository
public interface UserProfileRepository extends CrudRepository<UserProfile, String> {
}
