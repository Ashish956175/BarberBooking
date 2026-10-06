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
@Document(collection = "tickets")
public class Ticket {
    @Id
    @JsonProperty("_id")
    private String id;

    @DocumentReference(collection = "users")
    private User user;

    private String subject;
    private String description;
    private String status = "open"; // open, in_progress, resolved, closed
    private String priority = "medium"; // low, medium, high
    private Date createdAt = new Date();
}
