package com.barber.booking.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AuthResponse {
    @JsonProperty("_id")
    private String id;
    private String name;
    private String email;
    private String role;
    private String profilePic;
    private String location;
    private String token;
}
