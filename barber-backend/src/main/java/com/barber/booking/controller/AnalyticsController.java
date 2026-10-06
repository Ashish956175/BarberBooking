package com.barber.booking.controller;

import com.barber.booking.dto.AnalyticsResponse;
import com.barber.booking.model.Appointment;
import com.barber.booking.repository.AppointmentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/analytics")
public class AnalyticsController {

    @Autowired
    private AppointmentRepository appointmentRepository;

    @GetMapping("/{shopId}")
    public ResponseEntity<?> getShopAnalytics(@PathVariable String shopId) {
        List<Appointment> allAppts = appointmentRepository.findByShopId(shopId, Sort.by(Sort.Direction.DESC, "date"));

        double totalEarnings = 0.0;
        double projectedEarnings = 0.0;
        int completedCount = 0;
        Map<String, Integer> statusDistribution = new HashMap<>();

        for (Appointment appt : allAppts) {
            String status = appt.getStatus() != null ? appt.getStatus() : "pending";
            statusDistribution.put(status, statusDistribution.getOrDefault(status, 0) + 1);

            double amount = (appt.getPayment() != null && appt.getPayment().getAmount() != null) ? appt.getPayment().getAmount() : 0.0;
            if ("completed".equalsIgnoreCase(status)) {
                totalEarnings += amount;
                completedCount++;
            } else if ("confirmed".equalsIgnoreCase(status)) {
                projectedEarnings += amount;
            }
        }

        List<Appointment> recentTransactions = allAppts.stream().limit(10).toList();

        AnalyticsResponse response = new AnalyticsResponse(
                totalEarnings,
                projectedEarnings,
                completedCount,
                statusDistribution,
                recentTransactions
        );

        return ResponseEntity.ok(response);
    }
}
