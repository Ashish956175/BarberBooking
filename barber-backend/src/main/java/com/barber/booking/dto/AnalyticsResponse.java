package com.barber.booking.dto;

import com.barber.booking.model.Appointment;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AnalyticsResponse {
    private Double totalEarnings;
    private Double projectedEarnings;
    private Integer completedAppointments;
    private Map<String, Integer> statusDistribution;
    private List<Appointment> recentTransactions;
}
