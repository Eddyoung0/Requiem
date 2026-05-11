import java.sql.Timestamp;

public class User {
    private int userId;
    private String name;
    private String email;
    private String password;
    private String role;
    private String status;
    private Timestamp createdAt;

    /// Getter 

    public int getUserId() {
        return userId;
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public String getRole() {
        return role;
    }

    public String getStatus() {
        return status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public boolean isAdmin() {
        return "admin".equals(role);
    }

    public boolean isActive() {
        return "active".equals(status);
    }

    // setter

    public void setUserId(int v) {
        this.userId = v;
    }

    public void setName(String v) {
        this.name = v;
    }

    public void setEmail(String v) {
        this.email = v;
    }

    public void setPassword(String v) {
        this.password = v;
    }

    public void setRole(String v) {
        this.role = v;
    }

    public void setStatus(String v) {
        this.status = v;
    }

    public void setCreatedAt(Timestamp v) {
        this.createdAt = v;
    }
}
