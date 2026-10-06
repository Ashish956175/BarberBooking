package com.barber.booking.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Location {
    private String type = "Point";
    private List<Double> coordinates = new ArrayList<>(List.of(0.0, 0.0)); // [lng, lat]

    public Location(double lng, double lat) {
        this.type = "Point";
        this.coordinates = List.of(lng, lat);
    }
}
