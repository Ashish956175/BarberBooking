package com.barber.booking.repository;

import com.barber.booking.model.Shop;
import com.barber.booking.model.User;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ShopRepository extends MongoRepository<Shop, String> {
    List<Shop> findByOwner(User owner);
    List<Shop> findByOwnerId(String ownerId);
    List<Shop> findByStatus(String status);
}
