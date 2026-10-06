package com.barber.booking.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "users")
public class User {
    @Id
    @JsonProperty("_id")
    private String id;

    private String name;
    private String email;
    private String password;
    private String role = "customer"; // customer, barber, admin
    private String googleId;
    private String profilePic = "";
    private String locationText = "";
    private Location location = new Location();
    private Date createdAt = new Date();
}
