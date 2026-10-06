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
@Document(collection = "services")
public class ServiceEntity {
    @Id
    @JsonProperty("_id")
    private String id;

    @DocumentReference(collection = "shops")
    private Shop shop;

    private String name;
    private String description;
    private Double price;
    private Integer duration; // in minutes
    private Date createdAt = new Date();
}
