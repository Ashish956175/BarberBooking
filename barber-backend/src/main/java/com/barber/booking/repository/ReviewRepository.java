package com.barber.booking.repository;

import com.barber.booking.model.Review;
import com.barber.booking.model.Shop;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReviewRepository extends MongoRepository<Review, String> {
    List<Review> findByShop(Shop shop, Sort sort);

    @Query("{ 'shop': ?0 }")
    List<Review> findByShopId(String shopId, Sort sort);

    @Query("{ 'shop': ?0 }")
    List<Review> findByShopId(String shopId);
}
