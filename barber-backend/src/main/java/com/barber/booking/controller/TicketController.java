package com.barber.booking.controller;

import com.barber.booking.model.Ticket;
import com.barber.booking.model.User;
import com.barber.booking.repository.TicketRepository;
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
@RequestMapping("/api/tickets")
public class TicketController {

    @Autowired
    private TicketRepository ticketRepository;

    @PostMapping
    public ResponseEntity<?> createTicket(Authentication authentication, @RequestBody Map<String, String> body) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        Ticket ticket = new Ticket();
        ticket.setUser(user);
        ticket.setSubject(body.get("subject"));
        ticket.setDescription(body.get("description"));
        ticket.setPriority(body.getOrDefault("priority", "medium"));

        Ticket saved = ticketRepository.save(ticket);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @GetMapping("/my")
    public ResponseEntity<?> getMyTickets(Authentication authentication) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authorized"));
        }

        List<Ticket> tickets = ticketRepository.findByUserId(user.getId(), Sort.by(Sort.Direction.DESC, "createdAt"));
        return ResponseEntity.ok(tickets);
    }

    @GetMapping
    public ResponseEntity<?> getAllTickets() {
        List<Ticket> tickets = ticketRepository.findAll(Sort.by(Sort.Direction.DESC, "createdAt"));
        return ResponseEntity.ok(tickets);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateTicketStatus(@PathVariable String id, @RequestBody Map<String, String> body) {
        Optional<Ticket> ticketOptional = ticketRepository.findById(id);
        if (ticketOptional.isEmpty()) return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Ticket not found"));

        Ticket ticket = ticketOptional.get();
        ticket.setStatus(body.get("status"));
        Ticket updated = ticketRepository.save(ticket);
        return ResponseEntity.ok(updated);
    }
}
