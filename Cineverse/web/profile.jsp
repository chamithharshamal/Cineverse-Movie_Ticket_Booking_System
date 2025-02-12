<%@page import="cineverse.model.User"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Profile | Cineverse</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <link href="css/profile.css" rel="stylesheet">
    </head>
    <%

        String userEmail = null;
        String userName = null;

        boolean isLoggedIn = false;

        if (session.getAttribute("user") != null) {
            isLoggedIn = true;
            cineverse.model.User user = (cineverse.model.User) session.getAttribute("user");
            userName = user.getName();

        } else {

            Cookie[] cookies = request.getCookies();
            if (cookies != null) {

                for (Cookie cookie : cookies) {
                    if (cookie.getName().equals("userEmail")) {

                        userEmail = cookie.getValue();
                    }
                }

                if (userEmail != null) {
                    
                    cineverse.dao.UserDAO userDao = new cineverse.dao.UserDAO();
                    cineverse.model.User user = userDao.getUserByEmail(userEmail);

                    if (user != null) {
                        
                        isLoggedIn = true;
                        userName = user.getName();
                        session.setAttribute("user", user);
                    }
                }
            }
        }

        if (!isLoggedIn && request.getParameter("protected") != null) {

            response.sendRedirect("login.jsp");
            return;
        }
    %>

    <body class="bg-light">

        <%        if (!isLoggedIn) {

                response.sendRedirect("login.jsp");
                return;
            }
            User currentUser = (User) session.getAttribute("user");
        %>

        <!-- Navigation -->
        <nav class="navbar navbar-expand-lg fixed-top">
            <div class="container">
                <a class="navbar-brand" href="index.jsp">Cineverse</a>
                <div class="d-flex align-items-center">
                    <a href="index.jsp" class="btn btn-outline-primary me-2">
                        <i class="fas fa-home"></i> Home
                    </a>
                </div>
            </div>
        </nav>

        <div class="container" style="margin-top: 100px">
            <div class="profile-container">
                <!-- Message Display -->
                <div id="message" class="alert" style="display: none;"></div>

                <!-- Profile Header -->
                <div class="profile-header">
                    <div class="profile-avatar">
                        <i class="fas fa-user"></i>
                    </div>
                    <h2 style="color: var(--primary-color)"><%=currentUser.getName()%></h2>
                    <p class="text-light">Member since 2023</p>
                </div>

                <!-- Profile Content -->
                <div class="profile-content">
                    <!-- View Mode -->
                    <div class="view-mode">
                        <h3 class="section-title">Personal Information</h3>
                        <div class="info-group">
                            <div class="info-item">
                                <span class="info-label"><i class="fas fa-user me-2"></i>Name:</span>
                                <span><%=currentUser.getName()%></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label"><i class="fas fa-envelope me-2"></i>Email:</span>
                                <span><%=currentUser.getEmail()%></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label"><i class="fas fa-phone me-2"></i>Phone:</span>
                                <span><%=currentUser.getPhoneNumber()%></span>
                            </div>
                        </div>

                        <div class="action-buttons">
                            <button class="btn btn-primary" onclick="toggleEditMode()">
                                <i class="fas fa-edit me-2"></i>Edit Profile
                            </button>
                            <button class="btn btn-danger" onclick="confirmDelete()">
                                <i class="fas fa-trash me-2"></i>Delete Account
                            </button>
                        </div>
                    </div>

                    <!-- Edit Mode -->
                    <div class="edit-mode">
                        <h3 class="section-title">Edit Profile</h3>
                        <form id="updateProfileForm" action="UpdateProfileServlet" method="POST" onsubmit="return updateProfile(event)">
                            <input type="hidden" name="userId" value="<%=currentUser.getId()%>">

                            <div class="info-group">
                                <div class="mb-3">
                                    <label class="form-label" for="name">Name</label>
                                    <input type="text" class="form-control" id="name" name="name" 
                                           value="<%=currentUser.getName()%>" required>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label" for="email">Email</label>
                                    <input type="email" class="form-control" id="email" name="email" 
                                           value="<%=currentUser.getEmail()%>" required>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label" for="phone">Phone Number</label>
                                    <input type="tel" class="form-control" id="phone" name="phone" 
                                           value="<%=currentUser.getPhoneNumber()%>" required>
                                </div>
                            </div>

                            <h3 class="section-title">Change Password</h3>
                            <div class="info-group">
                                <div class="mb-3">
                                    <label class="form-label" for="currentPassword">Current Password</label>
                                    <input type="password" class="form-control" id="currentPassword" name="currentPassword">
                                </div>

                                <div class="mb-3">
                                    <label class="form-label" for="newPassword">New Password</label>
                                    <input type="password" class="form-control" id="newPassword" name="newPassword">
                                </div>

                                <div class="mb-3">
                                    <label class="form-label" for="confirmPassword">Confirm New Password</label>
                                    <input type="password" class="form-control" id="confirmPassword" name="confirmPassword">
                                </div>
                            </div>

                            <div class="action-buttons">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-save me-2"></i>Save Changes
                                </button>
                                <button type="button" class="btn btn-danger" onclick="toggleEditMode()">
                                    <i class="fas fa-times me-2"></i>Cancel
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
        <script>
      
function toggleEditMode() {
    const viewMode = document.querySelector('.view-mode');
    const editMode = document.querySelector('.edit-mode');
    
    if (viewMode.style.display === 'none' || viewMode.style.display === '') {
        viewMode.style.display = 'block';
        editMode.style.display = 'none';
    } else {
        viewMode.style.display = 'none';
        editMode.style.display = 'block';
    }
}


function confirmDelete() {
    if (confirm('Are you sure you want to delete your account? This action cannot be undone.')) {
        // Create and submit form for deletion
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = 'DeleteAccountServlet';
        
        const userIdInput = document.createElement('input');
        userIdInput.type = 'hidden';
        userIdInput.name = 'userId';
        userIdInput.value = document.querySelector('input[name="userId"]').value;
        
        form.appendChild(userIdInput);
        document.body.appendChild(form);
        form.submit();
    }
}

// Show alert messages
function showMessage(message, type) {
    const messageDiv = document.getElementById('message');
    messageDiv.className = `alert alert-${type}`;
    messageDiv.textContent = message;
    messageDiv.style.display = 'block';
    
    setTimeout(() => {
        messageDiv.style.display = 'none';
    }, 3000);
}


function updateProfile(event) {
    event.preventDefault();
    
    const currentPassword = document.getElementById('currentPassword').value;
    const newPassword = document.getElementById('newPassword').value;
    
    // Validate password changes
    if (newPassword && !currentPassword) {
        showMessage('Please enter your current password', 'danger');
        return false;
    }
    
    if (!validatePasswordUpdate()) {
        return false;
    }
    
   
    if (confirm('Are you sure you want to update your profile?')) {
        const form = document.getElementById('updateProfileForm');
        form.submit();
    }
}

// Validate password update
function validatePasswordUpdate() {
    const newPassword = document.getElementById('newPassword').value;
    const confirmPassword = document.getElementById('confirmPassword').value;
    
    if (newPassword && newPassword !== confirmPassword) {
        showMessage('New passwords do not match!', 'danger');
        return false;
    }
    return true;
}

// Add event listeners when document is loaded
document.addEventListener('DOMContentLoaded', function() {
   
    const editBtn = document.querySelector('.btn-primary');
    if (editBtn) {
        editBtn.addEventListener('click', toggleEditMode);
    }
    
   
    const deleteBtn = document.querySelector('.btn-danger');
    if (deleteBtn) {
        deleteBtn.addEventListener('click', confirmDelete);
    }
    
    // Update profile form
    const updateForm = document.getElementById('updateProfileForm');
    if (updateForm) {
        updateForm.addEventListener('submit', updateProfile);
    }
});

        </script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
