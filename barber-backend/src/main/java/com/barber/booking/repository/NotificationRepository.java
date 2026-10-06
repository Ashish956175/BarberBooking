package com.barber.booking.repository;

import com.barber.booking.model.Notification;
import com.barber.booking.model.User;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends MongoRepository<Notification, String> {
    List<Notification> findByUser(User user, Sort sort);
    List<Notification> findByUserId(String userId, Sort sort);
}
