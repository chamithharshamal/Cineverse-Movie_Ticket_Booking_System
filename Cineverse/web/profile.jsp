<%@page import="cineverse.model.User"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Profile | Cineverse</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>
            .profile-container {
                max-width: 800px;
                margin: 2rem auto;
                padding: 2rem;
                background: white;
                border-radius: 15px;
                box-shadow: 0 0 20px rgba(0,0,0,0.1);
            }
            .profile-header {
                text-align: center;
                margin-bottom: 2rem;
            }
            .profile-avatar {
                width: 150px;
                height: 150px;
                border-radius: 50%;
                margin-bottom: 1rem;
                background: #f0f0f0;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 3rem;
                margin: 0 auto;
            }
            .form-group {
                margin-bottom: 1.5rem;
            }
            .action-buttons {
                display: flex;
                gap: 1rem;
                justify-content: center;
                margin-top: 2rem;
            }
            .edit-mode {
                display: none;
            }
            .view-mode {
                display: block;
            }
        </style>
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
        <%
            if (!isLoggedIn) {
                response.sendRedirect("login.jsp");
                return;
            }
            User currentUser = (User) session.getAttribute("user");
        %>

        <div class="container">
            <div class="profile-container">
                <!-- Message Display -->
                <div id="message" class="alert" style="display: none;"></div>

                <!-- Profile Header -->
                <div class="profile-header">
                    <div class="profile-avatar">
                        <i class="fas fa-user"></i>
                    </div>
                    <h2 class="mt-3"><%=currentUser.getName()%></h2>
                </div>

                <!-- View Mode -->
                <div class="view-mode">
                    <div class="row mb-4">
                        <div class="col-md-6">
                            <h5>Personal Information</h5>
                            <p><strong>Name:</strong> <%=currentUser.getName()%></p>
                            <p><strong>Email:</strong> <%=currentUser.getEmail()%></p>
                            <p><strong>Phone:</strong> <%=currentUser.getPhoneNumber()%></p>
                        </div>
                    </div>
                    <div class="action-buttons">
                        <button class="btn btn-primary" onclick="toggleEditMode()">
    <i class="fas fa-edit"></i> Edit Profile
</button>

                       <button class="btn btn-danger" onclick="confirmDelete()">
    <i class="fas fa-trash"></i> Delete Account
</button>

                    </div>
                </div>

                <!-- Edit Mode -->
                <div class="edit-mode">
                    <form id="updateProfileForm" action="UpdateProfileServlet" method="POST" onsubmit="return updateProfile(event)">
                        <input type="hidden" name="userId" value="<%=currentUser.getId()%>">

                        <div class="form-group">
                            <label for="name">Name</label>
                            <input type="text" class="form-control" id="name" name="name" 
                                   value="<%=currentUser.getName()%>" required>
                        </div>

                        <div class="form-group">
                            <label for="email">Email</label>
                            <input type="email" class="form-control" id="email" name="email" 
                                   value="<%=currentUser.getEmail()%>" required>
                        </div>

                        <div class="form-group">
                            <label for="phone">Phone Number</label>
                            <input type="tel" class="form-control" id="phone" name="phone" 
                                   value="<%=currentUser.getPhoneNumber()%>" required>
                        </div>

                        <div class="form-group">
                            <label for="currentPassword">Current Password</label>
                            <input type="password" class="form-control" id="currentPassword" name="currentPassword">
                        </div>
                        <div class="form-group">
                            <label for="newPassword">New Password</label>
                            <input type="password" class="form-control" id="newPassword" name="newPassword">
                        </div>
                        <div class="form-group">
                            <label for="confirmPassword">Confirm New Password</label>
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword">
                        </div>

                        <div class="action-buttons">
                            <button type="submit" class="btn btn-success">
                                <i class="fas fa-save"></i> Save Changes
                            </button>
                            <button type="button" class="btn btn-secondary" onclick="toggleEditMode()">
                                <i class="fas fa-times"></i> Cancel
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
<script>
    function toggleEditMode() {
        const viewMode = document.querySelector('.view-mode');
        const editMode = document.querySelector('.edit-mode');
        
        if (viewMode.style.display !== 'none') {
            viewMode.style.display = 'none';
            editMode.style.display = 'block';
        } else {
            viewMode.style.display = 'block';
            editMode.style.display = 'none';
        }
    }

    function confirmDelete() {
        if (confirm('Are you sure you want to delete your account? This action cannot be undone.')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'DeleteProfileServlet';
            
            const userIdInput = document.createElement('input');
            userIdInput.type = 'hidden';
            userIdInput.name = 'userId';
            userIdInput.value = '<%= currentUser.getId() %>';
            
            form.appendChild(userIdInput);
            document.body.appendChild(form);
            form.submit();
        }
    }

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
        
        const currentPassword = document.getElementById('currentPassword')?.value;
        const newPassword = document.getElementById('newPassword')?.value;
        
        if (newPassword && !currentPassword) {
            showMessage('Please enter your current password', 'danger');
            return false;
        }
        
        if (!validatePasswordUpdate()) {
            return false;
        }
        
        if (confirm('Are you sure you want to update your profile?')) {
            document.getElementById('updateProfileForm').submit();
        }
    }

    function validatePasswordUpdate() {
        const newPassword = document.getElementById('newPassword')?.value;
        const confirmPassword = document.getElementById('confirmPassword')?.value;
        
        if (newPassword && newPassword !== confirmPassword) {
            showMessage('New passwords do not match!', 'danger');
            return false;
        }
        return true;
    }
</script>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
