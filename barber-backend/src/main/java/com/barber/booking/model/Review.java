package com.barber.booking.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.DocumentReference;

import java.util.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "reviews")
public class Review {
    @Id
    @JsonProperty("_id")
    private String id;

    @DocumentReference(collection = "users")
    private User user;

    @DocumentReference(collection = "shops")
    private Shop shop;

    private Double rating;
    private String comment;
    private Date createdAt = new Date();
}
