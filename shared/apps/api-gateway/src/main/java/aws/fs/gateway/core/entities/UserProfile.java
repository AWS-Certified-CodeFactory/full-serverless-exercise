package aws.fs.gateway.core.entities;

import lombok.Data;

import javax.persistence.Entity;
import javax.persistence.Id;

@Entity
@Data
public class UserProfile {

    @Id
    String userId;

    String fullName;
}
