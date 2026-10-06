package com.barber.booking.repository;

import com.barber.booking.model.ServiceEntity;
import com.barber.booking.model.Shop;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ServiceRepository extends MongoRepository<ServiceEntity, String> {
    List<ServiceEntity> findByShop(Shop shop);

    @Query("{ 'shop': ?0 }")
    List<ServiceEntity> findByShopId(String shopId);

    List<ServiceEntity> findByNameContainingIgnoreCase(String name);
}
