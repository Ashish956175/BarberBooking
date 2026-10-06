package com.barber.booking.controller;

import com.barber.booking.model.*;
import com.barber.booking.repository.AppointmentRepository;
import com.barber.booking.repository.ServiceRepository;
import com.barber.booking.repository.ShopRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.*;

@RestController
@RequestMapping("/api/appointments")
public class AppointmentController {

    @Autowired
    private AppointmentRepository appointmentRepository;

    @Autowired
    private ShopRepository shopRepository;

    @Autowired
    private ServiceRepository serviceRepository;

    @PostMapping
    public ResponseEntity<?> bookAppointment(Authentication authentication, @RequestBody Map<String, Object> body) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        String shopId = (String) body.get("shopId");
        String serviceId = (String) body.get("serviceId");
        String dateStr = (String) body.get("date");

        Optional<Shop> shopOptional = shopRepository.findById(shopId);
        if (shopOptional.isEmpty()) return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Shop not found"));

        Optional<ServiceEntity> serviceOptional = serviceRepository.findById(serviceId);
        if (serviceOptional.isEmpty()) return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Service not found"));

        Appointment appt = new Appointment();
        appt.setUser(user);
        appt.setShop(shopOptional.get());
        appt.setService(serviceOptional.get());
        appt.setStatus("pending");

        if (dateStr != null) {
            try {
                appt.setDate(Date.from(Instant.parse(dateStr)));
            } catch (Exception ex) {
                appt.setDate(new Date());
            }
        } else {
            appt.setDate(new Date());
        }

        if (body.containsKey("paymentMethod") && body.containsKey("paymentAmount")) {
            Payment payment = new Payment();
            payment.setMethod((String) body.get("paymentMethod"));
            payment.setAmount(Double.parseDouble(body.get("paymentAmount").toString()));
            payment.setTransactionTime(new Date());
            payment.setTransactionId("TXN" + System.currentTimeMillis() + (int)(Math.random() * 1000));
            appt.setPayment(payment);
        }

        Appointment savedAppt = appointmentRepository.save(appt);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedAppt);
    }

    @GetMapping("/my")
    public ResponseEntity<?> getMyAppointments(Authentication authentication) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        List<Appointment> appointments = appointmentRepository.findByUserId(user.getId(), Sort.by(Sort.Direction.DESC, "date"));
        return ResponseEntity.ok(appointments);
    }

    @GetMapping("/shop/{shopId}")
    public ResponseEntity<?> getShopAppointments(@PathVariable String shopId, Authentication authentication) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        Optional<Shop> shopOptional = shopRepository.findById(shopId);
        if (shopOptional.isEmpty()) return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Shop not found"));

        Shop shop = shopOptional.get();
        if (shop.getOwner() != null && !shop.getOwner().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        List<Appointment> appointments = appointmentRepository.findByShopId(shopId, Sort.by(Sort.Direction.ASC, "date"));
        return ResponseEntity.ok(appointments);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateAppointmentStatus(@PathVariable String id, Authentication authentication, @RequestBody Map<String, String> body) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        Optional<Appointment> apptOptional = appointmentRepository.findById(id);
        if (apptOptional.isEmpty()) return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Appointment not found"));

        Appointment appt = apptOptional.get();
        String newStatus = body.get("status");

        boolean authorized = false;
        if (appt.getUser() != null && appt.getUser().getId().equals(user.getId())) {
            if ("cancelled".equalsIgnoreCase(newStatus)) authorized = true;
        } else if (appt.getShop() != null && appt.getShop().getOwner() != null && appt.getShop().getOwner().getId().equals(user.getId())) {
            authorized = true;
        }

        if (!authorized) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        appt.setStatus(newStatus);
        Appointment updated = appointmentRepository.save(appt);
        return ResponseEntity.ok(updated);
    }
}
