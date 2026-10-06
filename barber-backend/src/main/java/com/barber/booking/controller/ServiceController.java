package com.barber.booking.controller;

import com.barber.booking.model.ServiceEntity;
import com.barber.booking.model.Shop;
import com.barber.booking.model.User;
import com.barber.booking.repository.ServiceRepository;
import com.barber.booking.repository.ShopRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/services")
public class ServiceController {

    @Autowired
    private ServiceRepository serviceRepository;

    @Autowired
    private ShopRepository shopRepository;

    @PostMapping
    public ResponseEntity<?> addService(Authentication authentication, @RequestBody Map<String, Object> body) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        String shopId = (String) body.get("shopId");
        Optional<Shop> shopOptional = shopRepository.findById(shopId);

        if (shopOptional.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Shop not found"));
        }

        Shop shop = shopOptional.get();
        if (shop.getOwner() != null && !shop.getOwner().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        ServiceEntity service = new ServiceEntity();
        service.setShop(shop);
        service.setName((String) body.get("name"));
        service.setDescription((String) body.get("description"));

        if (body.get("price") != null) {
            service.setPrice(Double.parseDouble(body.get("price").toString()));
        }

        if (body.get("duration") != null) {
            service.setDuration(Integer.parseInt(body.get("duration").toString()));
        }

        ServiceEntity savedService = serviceRepository.save(service);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedService);
    }

    @GetMapping("/{shopId}")
    public ResponseEntity<?> getServicesByShop(@PathVariable String shopId) {
        Optional<Shop> shopOptional = shopRepository.findById(shopId);
        if (shopOptional.isPresent()) {
            List<ServiceEntity> services = serviceRepository.findByShop(shopOptional.get());
            return ResponseEntity.ok(services);
        }
        List<ServiceEntity> services = serviceRepository.findByShopId(shopId);
        return ResponseEntity.ok(services);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateService(@PathVariable String id, Authentication authentication, @RequestBody Map<String, Object> body) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        Optional<ServiceEntity> serviceOptional = serviceRepository.findById(id);
        if (serviceOptional.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Service not found"));
        }

        ServiceEntity service = serviceOptional.get();
        if (service.getShop() != null && service.getShop().getOwner() != null
                && !service.getShop().getOwner().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        if (body.containsKey("name")) service.setName((String) body.get("name"));
        if (body.containsKey("description")) service.setDescription((String) body.get("description"));
        if (body.containsKey("price")) service.setPrice(Double.parseDouble(body.get("price").toString()));
        if (body.containsKey("duration")) service.setDuration(Integer.parseInt(body.get("duration").toString()));

        ServiceEntity updated = serviceRepository.save(service);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteService(@PathVariable String id, Authentication authentication) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        Optional<ServiceEntity> serviceOptional = serviceRepository.findById(id);
        if (serviceOptional.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Service not found"));
        }

        ServiceEntity service = serviceOptional.get();
        if (service.getShop() != null && service.getShop().getOwner() != null
                && !service.getShop().getOwner().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        serviceRepository.delete(service);
        return ResponseEntity.ok(Map.of("message", "Service removed"));
    }
}
