package com.barber.booking.controller;

import com.barber.booking.config.JwtTokenProvider;
import com.barber.booking.dto.AuthResponse;
import com.barber.booking.dto.LoginRequest;
import com.barber.booking.dto.RegisterRequest;
import com.barber.booking.model.Location;
import com.barber.booking.model.User;
import com.barber.booking.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtTokenProvider tokenProvider;

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@RequestBody RegisterRequest request) {
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("message", "User already exists"));
        }

        User user = new User();
        user.setName(request.getName());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(request.getRole() != null ? request.getRole() : "customer");
        user.setProfilePic(request.getProfilePic() != null ? request.getProfilePic() : "");

        User savedUser = userRepository.save(user);
        String token = tokenProvider.generateToken(savedUser.getId());

        AuthResponse response = new AuthResponse(
                savedUser.getId(),
                savedUser.getName(),
                savedUser.getEmail(),
                savedUser.getRole(),
                savedUser.getProfilePic(),
                savedUser.getLocationText().isEmpty() ? "Pune" : savedUser.getLocationText(),
                token
        );

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/login")
    public ResponseEntity<?> loginUser(@RequestBody LoginRequest request) {
        Optional<User> userOptional = userRepository.findByEmail(request.getEmail());

        if (userOptional.isPresent() && passwordEncoder.matches(request.getPassword(), userOptional.get().getPassword())) {
            User user = userOptional.get();
            String token = tokenProvider.generateToken(user.getId());

            AuthResponse response = new AuthResponse(
                    user.getId(),
                    user.getName(),
                    user.getEmail(),
                    user.getRole(),
                    user.getProfilePic(),
                    user.getLocationText().isEmpty() ? "Pune" : user.getLocationText(),
                    token
            );
            return ResponseEntity.ok(response);
        }

        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Invalid email or password"));
    }

    @GetMapping("/profile")
    public ResponseEntity<?> getUserProfile(Authentication authentication) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authenticated"));
        }

        AuthResponse response = new AuthResponse(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getRole(),
                user.getProfilePic(),
                user.getLocationText().isEmpty() ? "Pune" : user.getLocationText(),
                null
        );
        return ResponseEntity.ok(response);
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateUserProfile(Authentication authentication, @RequestBody Map<String, Object> body) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User currentUser)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Not authenticated"));
        }

        Optional<User> userOptional = userRepository.findById(currentUser.getId());
        if (userOptional.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "User not found"));
        }

        User user = userOptional.get();

        if (body.containsKey("name")) user.setName((String) body.get("name"));
        if (body.containsKey("email")) user.setEmail((String) body.get("email"));
        if (body.containsKey("password") && body.get("password") != null) {
            user.setPassword(passwordEncoder.encode((String) body.get("password")));
        }
        if (body.containsKey("profilePic")) user.setProfilePic((String) body.get("profilePic"));

        if (body.containsKey("location")) {
            Object loc = body.get("location");
            if (loc instanceof String locStr) {
                user.setLocationText(locStr);
            }
        }

        User updatedUser = userRepository.save(user);
        String token = tokenProvider.generateToken(updatedUser.getId());

        AuthResponse response = new AuthResponse(
                updatedUser.getId(),
                updatedUser.getName(),
                updatedUser.getEmail(),
                updatedUser.getRole(),
                updatedUser.getProfilePic(),
                updatedUser.getLocationText().isEmpty() ? "Pune" : updatedUser.getLocationText(),
                token
        );

        return ResponseEntity.ok(response);
    }
}
