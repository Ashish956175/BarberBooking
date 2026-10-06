package com.barber.booking.repository;

import com.barber.booking.model.Ticket;
import com.barber.booking.model.User;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TicketRepository extends MongoRepository<Ticket, String> {
    List<Ticket> findByUser(User user, Sort sort);
    List<Ticket> findByUserId(String userId, Sort sort);
}
