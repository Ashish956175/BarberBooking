package com.barber.booking.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.DocumentReference;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "shops")
public class Shop {
    @Id
    @JsonProperty("_id")
    private String id;

    @DocumentReference(lazy = true)
    private User owner;

    private String name;
    private String address;
    private Location location = new Location();
    private String description;
    private List<String> images = new ArrayList<>();
    private Map<String, String> openingHours = new HashMap<>();
    private Double rating = 0.0;
    private String status = "pending"; // pending, approved, rejected
    private Integer numReviews = 0;
    private List<Employee> employees = new ArrayList<>();
    private List<Promotion> promotions = new ArrayList<>();
    private Date createdAt = new Date();
}
