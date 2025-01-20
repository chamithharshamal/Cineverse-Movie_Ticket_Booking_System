package cineverse.dao;

import cineverse.connection.DbConnection;
import cineverse.model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    private Connection connection;

    public UserDAO() {
        connection = DbConnection.getConnection();
    }

    // Register new user
    public boolean registerUser(User user) {
    String query = "INSERT INTO users (name, email, password, phone_number, role) VALUES (?, ?, ?, ?, ?)";
    try {
        PreparedStatement pst = connection.prepareStatement(query);
        pst.setString(1, user.getName());
        pst.setString(2, user.getEmail());
        pst.setString(3, user.getPassword());
        pst.setString(4, user.getPhoneNumber());
        pst.setString(5, user.getRole());
        
        int result = pst.executeUpdate();
        return result > 0;
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}


    // Login user
    public User loginUser(String email, String password) {
        String query = "SELECT * FROM users WHERE email = ? AND password = ?";
        try {
            PreparedStatement pst = connection.prepareStatement(query);
            pst.setString(1, email);
            pst.setString(2, password);
            
            ResultSet rs = pst.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setName(rs.getString("name"));
                user.setEmail(rs.getString("email"));
                user.setPhoneNumber(rs.getString("phone_number"));
                user.setRole(rs.getString("role"));
                return user;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Check if email exists
    public boolean checkEmail(String email) {
        String query = "SELECT * FROM users WHERE email = ?";
        try {
            PreparedStatement pst = connection.prepareStatement(query);
            pst.setString(1, email);
            ResultSet rs = pst.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get all users with role = "user"
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String query = "SELECT * FROM users WHERE role = 'user' ORDER BY created_at DESC";
        
        try {
            PreparedStatement pst = connection.prepareStatement(query);
            ResultSet rs = pst.executeQuery();
            
            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setName(rs.getString("name"));
                user.setEmail(rs.getString("email"));
                user.setPhoneNumber(rs.getString("phone_number"));
                user.setRole(rs.getString("role"));
                users.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    // Get total number of users (excluding admins)
    public int getTotalUsers() {
        String query = "SELECT COUNT(*) as total FROM users WHERE role = 'user'";
        try {
            PreparedStatement pst = connection.prepareStatement(query);
            ResultSet rs = pst.executeQuery();
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Get user by ID
    public User getUserById(int userId) {
        String query = "SELECT * FROM users WHERE id = ?";
        try {
            PreparedStatement pst = connection.prepareStatement(query);
            pst.setInt(1, userId);
            ResultSet rs = pst.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setName(rs.getString("name"));
                user.setEmail(rs.getString("email"));
                user.setPhoneNumber(rs.getString("phone_number"));
                user.setRole(rs.getString("role"));
                return user;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Get user by Email
    public User getUserByEmail(String email) {
    String query = "SELECT * FROM users WHERE email = ?";
    try {
        PreparedStatement pst = connection.prepareStatement(query);
        pst.setString(1, email);
        ResultSet rs = pst.executeQuery();
        
        if (rs.next()) {
            User user = new User();
            user.setId(rs.getInt("id"));
            user.setName(rs.getString("name"));
            user.setEmail(rs.getString("email"));
            user.setPhoneNumber(rs.getString("phone_number"));
            user.setRole(rs.getString("role"));
            return user;
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return null;
}

    // Delete user
    public boolean deleteUser(int userId) {
        String query = "DELETE FROM users WHERE id = ? AND role = 'user'";
        try {
            PreparedStatement pst = connection.prepareStatement(query);
            pst.setInt(1, userId);
            int rowsAffected = pst.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Update user
    public boolean updateUser(User user) {
        String query = "UPDATE users SET name = ?, email = ?, phone_number = ? WHERE id = ? AND role = 'user'";
        try {
            PreparedStatement pst = connection.prepareStatement(query);
            pst.setString(1, user.getName());
            pst.setString(2, user.getEmail());
            pst.setString(3, user.getPhoneNumber());
            pst.setInt(4, user.getId());
            
            int rowsAffected = pst.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
