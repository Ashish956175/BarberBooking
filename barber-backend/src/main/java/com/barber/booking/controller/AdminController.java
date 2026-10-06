package com.barber.booking.controller;

import com.barber.booking.model.*;
import com.barber.booking.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ShopRepository shopRepository;

    @Autowired
    private AppointmentRepository appointmentRepository;

    @Autowired
    private ReviewRepository reviewRepository;

    @Autowired
    private NotificationRepository notificationRepository;

    @GetMapping("/stats")
    public ResponseEntity<?> getSystemStats() {
        long totalUsers = userRepository.count();
        long totalShops = shopRepository.count();
        long totalAppointments = appointmentRepository.count();

        List<Appointment> completedAppts = appointmentRepository.findByStatus("completed");
        double totalRevenue = completedAppts.stream()
                .mapToDouble(a -> a.getPayment() != null && a.getPayment().getAmount() != null ? a.getPayment().getAmount() : 0.0)
                .sum();

        Map<String, Object> stats = new HashMap<>();
        stats.put("users", totalUsers);
        stats.put("shops", totalShops);
        stats.put("appointments", totalAppointments);
        stats.put("revenue", totalRevenue);

        return ResponseEntity.ok(stats);
    }

    @GetMapping("/users")
    public ResponseEntity<?> getAllUsers() {
        List<User> users = userRepository.findAll();
        users.forEach(u -> u.setPassword(null));
        return ResponseEntity.ok(users);
    }

    @DeleteMapping("/users/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable String id) {
        if (!userRepository.existsById(id)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "User not found"));
        }
        userRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "User removed"));
    }

    @GetMapping("/shops")
    public ResponseEntity<?> getAllShops() {
        List<Shop> shops = shopRepository.findAll();
        return ResponseEntity.ok(shops);
    }

    @DeleteMapping("/shops/{id}")
    public ResponseEntity<?> deleteShop(@PathVariable String id) {
        if (!shopRepository.existsById(id)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Shop not found"));
        }
        shopRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "Shop removed"));
    }

    @PutMapping("/shops/{id}/verify")
    public ResponseEntity<?> verifyShop(@PathVariable String id, @RequestBody Map<String, String> body) {
        Optional<Shop> shopOptional = shopRepository.findById(id);
        if (shopOptional.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Shop not found"));
        }

        Shop shop = shopOptional.get();
        shop.setStatus(body.get("status"));
        Shop updated = shopRepository.save(shop);
        return ResponseEntity.ok(updated);
    }

    @GetMapping("/appointments")
    public ResponseEntity<?> getAllAppointments() {
        List<Appointment> appointments = appointmentRepository.findAll(Sort.by(Sort.Direction.DESC, "date"));
        return ResponseEntity.ok(appointments);
    }

    @GetMapping("/reviews")
    public ResponseEntity<?> getAllReviews() {
        List<Review> reviews = reviewRepository.findAll(Sort.by(Sort.Direction.DESC, "createdAt"));
        return ResponseEntity.ok(reviews);
    }

    @DeleteMapping("/reviews/{id}")
    public ResponseEntity<?> deleteReview(@PathVariable String id) {
        if (!reviewRepository.existsById(id)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Review not found"));
        }
        reviewRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "Review removed"));
    }

    @PostMapping("/broadcast")
    public ResponseEntity<?> sendBroadcast(@RequestBody Map<String, String> body) {
        String message = body.get("message");
        String targetRole = body.get("targetRole");

        List<User> targets;
        if (targetRole != null && !"all".equalsIgnoreCase(targetRole)) {
            targets = userRepository.findByRole(targetRole);
        } else {
            targets = userRepository.findAll();
        }

        List<Notification> notifications = new ArrayList<>();
        for (User u : targets) {
            Notification n = new Notification();
            n.setUser(u);
            n.setMessage(message);
            n.setRead(false);
            notifications.add(n);
        }

        notificationRepository.saveAll(notifications);
        return ResponseEntity.ok(Map.of("message", "Broadcast sent to " + targets.size() + " users"));
    }
}
