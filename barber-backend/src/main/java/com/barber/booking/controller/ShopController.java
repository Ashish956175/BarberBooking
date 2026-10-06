package com.barber.booking.controller;

import com.barber.booking.model.Employee;
import com.barber.booking.model.Location;
import com.barber.booking.model.Promotion;
import com.barber.booking.model.Shop;
import com.barber.booking.model.User;
import com.barber.booking.repository.ServiceRepository;
import com.barber.booking.repository.ShopRepository;
import com.barber.booking.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/shops")
public class ShopController {

    @Autowired
    private ShopRepository shopRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ServiceRepository serviceRepository;

    @PostMapping
    public ResponseEntity<?> createShop(Authentication authentication, @RequestBody Map<String, Object> body) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        Shop shop = new Shop();
        shop.setOwner(user);
        shop.setName((String) body.get("name"));
        shop.setAddress((String) body.get("address"));
        shop.setDescription((String) body.get("description"));
        shop.setRating(5.0);
        shop.setNumReviews(1);
        shop.setStatus("pending");

        if (body.get("openingHours") instanceof Map<?, ?> hoursMap) {
            Map<String, String> hours = new HashMap<>();
            hoursMap.forEach((k, v) -> hours.put(String.valueOf(k), String.valueOf(v)));
            shop.setOpeningHours(hours);
        }

        if (body.get("images") instanceof List<?> imgList) {
            List<String> images = new ArrayList<>();
            imgList.forEach(img -> images.add(String.valueOf(img)));
            shop.setImages(images);
        }

        if (body.get("coordinates") instanceof List<?> coords && coords.size() >= 2) {
            double lng = Double.parseDouble(coords.get(0).toString());
            double lat = Double.parseDouble(coords.get(1).toString());
            shop.setLocation(new Location(lng, lat));
        }

        Shop savedShop = shopRepository.save(shop);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedShop);
    }

    @GetMapping("/my")
    public ResponseEntity<?> getMyShops(Authentication authentication) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        List<Shop> shops = shopRepository.findByOwner(user);
        return ResponseEntity.ok(shops);
    }

    @GetMapping
    public ResponseEntity<?> getShops(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lng,
            @RequestParam(required = false) Double radius) {

        List<Shop> allShops = shopRepository.findAll();
        List<Shop> filtered = new ArrayList<>();

        for (Shop shop : allShops) {
            // Filter by search term if provided
            if (search != null && !search.trim().isEmpty() && !"All".equalsIgnoreCase(search)) {
                String q = search.toLowerCase();
                boolean matches = (shop.getName() != null && shop.getName().toLowerCase().contains(q))
                        || (shop.getDescription() != null && shop.getDescription().toLowerCase().contains(q));

                if (!matches && shop.getPromotions() != null) {
                    matches = shop.getPromotions().stream().anyMatch(p ->
                            (p.getTitle() != null && p.getTitle().toLowerCase().contains(q)) ||
                            (p.getDescription() != null && p.getDescription().toLowerCase().contains(q)));
                }

                if (!matches) {
                    continue;
                }
            }

            filtered.add(shop);
        }

        return ResponseEntity.ok(filtered);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getShopById(@PathVariable String id) {
        Optional<Shop> shopOptional = shopRepository.findById(id);
        if (shopOptional.isPresent()) {
            return ResponseEntity.ok(shopOptional.get());
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Shop not found"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateShop(@PathVariable String id, Authentication authentication, @RequestBody Map<String, Object> body) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        Optional<Shop> shopOptional = shopRepository.findById(id);
        if (shopOptional.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Shop not found"));
        }

        Shop shop = shopOptional.get();
        if (shop.getOwner() != null && !shop.getOwner().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        if (body.containsKey("name")) shop.setName((String) body.get("name"));
        if (body.containsKey("address")) shop.setAddress((String) body.get("address"));
        if (body.containsKey("description")) shop.setDescription((String) body.get("description"));

        Shop updated = shopRepository.save(shop);
        return ResponseEntity.ok(updated);
    }

    @PostMapping("/{id}/gallery")
    public ResponseEntity<?> addGalleryImage(@PathVariable String id, Authentication authentication, @RequestBody Map<String, String> body) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        Optional<Shop> shopOptional = shopRepository.findById(id);
        if (shopOptional.isEmpty()) return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Shop not found"));

        Shop shop = shopOptional.get();
        if (shop.getOwner() != null && !shop.getOwner().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        String imageUrl = body.get("imageUrl");
        if (imageUrl != null) {
            shop.getImages().add(imageUrl);
            shopRepository.save(shop);
        }

        return ResponseEntity.ok(shop);
    }

    @PostMapping("/{id}/employees")
    public ResponseEntity<?> addEmployee(@PathVariable String id, Authentication authentication, @RequestBody Map<String, String> body) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        Optional<Shop> shopOptional = shopRepository.findById(id);
        if (shopOptional.isEmpty()) return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Shop not found"));

        Shop shop = shopOptional.get();
        if (shop.getOwner() != null && !shop.getOwner().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        Employee employee = new Employee();
        employee.setName(body.get("name"));
        employee.setRole(body.getOrDefault("role", "Barber"));
        employee.setImage(body.get("imageUrl"));

        shop.getEmployees().add(employee);
        shopRepository.save(shop);

        return ResponseEntity.ok(shop);
    }

    @DeleteMapping("/{id}/employees/{employeeId}")
    public ResponseEntity<?> removeEmployee(@PathVariable String id, @PathVariable String employeeId, Authentication authentication) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        Optional<Shop> shopOptional = shopRepository.findById(id);
        if (shopOptional.isEmpty()) return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Shop not found"));

        Shop shop = shopOptional.get();
        if (shop.getOwner() != null && !shop.getOwner().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        shop.getEmployees().removeIf(emp -> emp.getId().equals(employeeId));
        shopRepository.save(shop);

        return ResponseEntity.ok(shop);
    }

    @PostMapping("/{id}/promotions")
    public ResponseEntity<?> addPromotion(@PathVariable String id, Authentication authentication, @RequestBody Map<String, String> body) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        Optional<Shop> shopOptional = shopRepository.findById(id);
        if (shopOptional.isEmpty()) return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Shop not found"));

        Shop shop = shopOptional.get();
        if (shop.getOwner() != null && !shop.getOwner().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        Promotion promo = new Promotion();
        promo.setTitle(body.get("title"));
        promo.setDescription(body.get("description"));
        promo.setDiscount(body.get("discount"));

        shop.getPromotions().add(promo);
        shopRepository.save(shop);

        return ResponseEntity.ok(shop);
    }

    @DeleteMapping("/{id}/promotions/{promoId}")
    public ResponseEntity<?> removePromotion(@PathVariable String id, @PathVariable String promoId, Authentication authentication) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        Optional<Shop> shopOptional = shopRepository.findById(id);
        if (shopOptional.isEmpty()) return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Shop not found"));

        Shop shop = shopOptional.get();
        if (shop.getOwner() != null && !shop.getOwner().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        shop.getPromotions().removeIf(p -> p.getId().equals(promoId));
        shopRepository.save(shop);

        return ResponseEntity.ok(shop);
    }
}
