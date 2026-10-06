package com.barber.booking.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Payment {
    private String method = "Cash";
    private Double amount = 0.0;
    private Date transactionTime = new Date();
    private String transactionId = "";
}
