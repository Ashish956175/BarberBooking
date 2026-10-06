package com.barber.booking.controller;

import com.barber.booking.model.Review;
import com.barber.booking.model.Shop;
import com.barber.booking.model.User;
import com.barber.booking.repository.ReviewRepository;
import com.barber.booking.repository.ShopRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/reviews")
public class ReviewController {

    @Autowired
    private ReviewRepository reviewRepository;

    @Autowired
    private ShopRepository shopRepository;

    @GetMapping("/{shopId}")
    public ResponseEntity<?> getShopReviews(@PathVariable String shopId) {
        List<Review> reviews = reviewRepository.findByShopId(shopId, Sort.by(Sort.Direction.DESC, "createdAt"));
        return ResponseEntity.ok(reviews);
    }

    @PostMapping
    public ResponseEntity<?> addReview(Authentication authentication, @RequestBody Map<String, Object> body) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        String shopId = (String) body.get("shopId");
        Double rating = Double.parseDouble(body.get("rating").toString());
        String comment = (String) body.get("comment");

        Optional<Shop> shopOptional = shopRepository.findById(shopId);
        if (shopOptional.isEmpty()) return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Shop not found"));

        Shop shop = shopOptional.get();

        Review review = new Review();
        review.setUser(user);
        review.setShop(shop);
        review.setRating(rating);
        review.setComment(comment);

        Review savedReview = reviewRepository.save(review);

        // Update Shop average rating
        List<Review> allReviews = reviewRepository.findByShopId(shopId);
        double avg = allReviews.stream().mapToDouble(Review::getRating).average().orElse(rating);

        shop.setRating(avg);
        shop.setNumReviews(allReviews.size());
        shopRepository.save(shop);

        return ResponseEntity.status(HttpStatus.CREATED).body(savedReview);
    }
}
