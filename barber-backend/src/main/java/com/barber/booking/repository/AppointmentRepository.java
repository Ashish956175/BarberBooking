package com.barber.booking.repository;

import com.barber.booking.model.Appointment;
import com.barber.booking.model.Shop;
import com.barber.booking.model.User;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AppointmentRepository extends MongoRepository<Appointment, String> {
    List<Appointment> findByUser(User user, Sort sort);

    @Query("{ 'user': ?0 }")
    List<Appointment> findByUserId(String userId, Sort sort);

    List<Appointment> findByShop(Shop shop, Sort sort);

    @Query("{ 'shop': ?0 }")
    List<Appointment> findByShopId(String shopId, Sort sort);

    @Query("{ 'shop': ?0, 'status': ?1 }")
    List<Appointment> findByShopIdAndStatus(String shopId, String status);

    List<Appointment> findByStatus(String status);
}
