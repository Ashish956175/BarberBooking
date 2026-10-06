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
@Document(collection = "appointments")
public class Appointment {
    @Id
    @JsonProperty("_id")
    private String id;

    @DocumentReference(collection = "users")
    private User user;

    @DocumentReference(collection = "shops")
    private Shop shop;

    @DocumentReference(collection = "services")
    private ServiceEntity service;

    private Date date;
    private String status = "pending"; // pending, confirmed, completed, cancelled
    private Payment payment = new Payment();
    private Date createdAt = new Date();
}
