package com.barber.booking.seeder;

import com.barber.booking.model.*;
import com.barber.booking.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.*;

@Component
public class DatabaseSeeder implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ShopRepository shopRepository;

    @Autowired
    private ServiceRepository serviceRepository;

    @Autowired
    private AppointmentRepository appointmentRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        // Ensure Admin account exists regardless of current DB state
        if (userRepository.findByEmail("admin@barber.com").isEmpty()) {
            User admin = new User();
            admin.setName("Super Admin");
            admin.setEmail("admin@barber.com");
            admin.setPassword(passwordEncoder.encode("admin123"));
            admin.setRole("admin");
            userRepository.save(admin);
            System.out.println("👑 Super Admin user created: admin@barber.com / admin123");
        } else {
            System.out.println("👑 Admin account verified (admin@barber.com)");
        }

        if (userRepository.count() > 1) {
            System.out.println("✅ Database already contains users. Skipping demo data seeder.");
            return;
        }

        // Create Customers
        User c1 = new User();
        c1.setName("Rahul Sharma");
        c1.setEmail("customer@test.com");
        c1.setPassword(passwordEncoder.encode("123456"));
        c1.setRole("customer");
        c1 = userRepository.save(c1);

        User c2 = new User();
        c2.setName("Priya Patel");
        c2.setEmail("priya@test.com");
        c2.setPassword(passwordEncoder.encode("123456"));
        c2.setRole("customer");
        c2 = userRepository.save(c2);

        // Create Barbers
        User b1 = new User();
        b1.setName("John The Barber");
        b1.setEmail("barber@test.com");
        b1.setPassword(passwordEncoder.encode("123456"));
        b1.setRole("barber");
        b1 = userRepository.save(b1);

        User b2 = new User();
        b2.setName("Rohan Deshmukh");
        b2.setEmail("rohan@barber.com");
        b2.setPassword(passwordEncoder.encode("123456"));
        b2.setRole("barber");
        b2 = userRepository.save(b2);

        // Create Shop
        Shop shop1 = new Shop();
        shop1.setOwner(b1);
        shop1.setName("Royal Maratha Grooming");
        shop1.setAddress("Shop 4, North Main Road, Koregaon Park, Pune");
        shop1.setDescription("Luxury grooming experience in the heart of KP.");
        shop1.setLocation(new Location(73.8940, 18.5362));
        shop1.setRating(4.8);
        shop1.setNumReviews(145);
        shop1.setStatus("approved");
        shop1.setImages(List.of("https://images.unsplash.com/photo-1585747860715-2ba37e788b70"));

        Employee emp1 = new Employee();
        emp1.setName("Rajesh Kumar");
        emp1.setRole("Senior Barber");
        shop1.setEmployees(List.of(emp1));

        shop1 = shopRepository.save(shop1);

        // Create Services
        ServiceEntity s1 = new ServiceEntity();
        s1.setShop(shop1);
        s1.setName("Puneri Special Cut");
        s1.setDescription("Traditional styling with modern twist");
        s1.setPrice(250.0);
        s1.setDuration(30);
        s1 = serviceRepository.save(s1);

        ServiceEntity s2 = new ServiceEntity();
        s2.setShop(shop1);
        s2.setName("Royal Beard Trim");
        s2.setDescription("Precision beard shaping");
        s2.setPrice(200.0);
        s2.setDuration(25);
        s2 = serviceRepository.save(s2);

        // Create Sample Appointment
        Appointment appt = new Appointment();
        appt.setUser(c1);
        appt.setShop(shop1);
        appt.setService(s1);
        appt.setDate(new Date());
        appt.setStatus("confirmed");

        Payment p = new Payment();
        p.setMethod("UPI");
        p.setAmount(250.0);
        p.setTransactionTime(new Date());
        p.setTransactionId("TXN123456");
        appt.setPayment(p);

        appointmentRepository.save(appt);

        System.out.println("🎉 Database Seeded Successfully!");
    }
}
