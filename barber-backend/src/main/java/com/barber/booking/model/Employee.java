package com.barber.booking.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.bson.types.ObjectId;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Employee {
    @JsonProperty("_id")
    private String id = new ObjectId().toHexString();

    private String name;
    private String role = "Barber";
    private String image;
}
