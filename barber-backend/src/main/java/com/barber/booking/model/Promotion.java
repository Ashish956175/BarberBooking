package com.barber.booking.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.bson.types.ObjectId;

import java.util.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Promotion {
    @JsonProperty("_id")
    private String id = new ObjectId().toHexString();

    private String title;
    private String description;
    private String discount;
    private Date validUntil;
    private Boolean active = true;
}
