<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Log in | Sign up from</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.1.1/css/all.min.css" integrity="sha512-KfkfwYDsLkIlwQp6LFnl8zNdLGxu9YAA1QvwINks4PhcElQSvqcyVLLD9aMhXd13uQjoXtEKNosOWaZqXgel0g==" crossorigin="anonymous" referrerpolicy="no-referrer" />
        <link rel="stylesheet" href="css/login.css">
    </head>
    <body>

        <div class="container" id="container">
            <div class="form-container sign-up-container">
               <form action="register" method="post">
                    <h1>Create Account</h1>
                    <div class="social-container">
                        <a href="#" class="social"><i class="fab fa-facebook-f"></i></a>
                        <a href="#" class="social"><i class="fab fa-google-plus-g"></i></a>
                        <a href="#" class="social"><i class="fab fa-linkedin-in"></i></a>
                    </div>
                    <div class="infield">
                        <input type="text" placeholder="Name" name="name"/>
                        <label></label>
                    </div>
                    <div class="infield">
                        <input type="email" placeholder="Email" name="email"/>
                        <label></label>
                    </div>
                     <div class="infield">
                         <input type="text" placeholder="Phone Number" name="phoneNumber" />
                        <label></label>
                    </div>
                    <div class="infield">
                        <input type="password" placeholder="Password" name="password"/>
                        <label></label>
                    </div>
                    <input type="hidden" name="role" value="user" />
                    <button>Sign Up</button>
                </form>
            </div>
            <div class="form-container sign-in-container">
             <form id="loginForm" action="login" method="post">
    <h1>Log in</h1>
    <div class="social-container">
        <a href="#" class="social"><i class="fab fa-facebook-f"></i></a>
        <a href="#" class="social"><i class="fab fa-google-plus-g"></i></a>
        <a href="#" class="social"><i class="fab fa-linkedin-in"></i></a>
    </div>
    <span>or use your account</span>
    <div class="infield">
        <input type="email" placeholder="Email" name="email" required/>
        <label></label>
    </div>
    <div class="infield">
        <input type="password" placeholder="Password" name="password" required/>
        <label></label>
    </div>
    <div class="remember-me">
        <input type="checkbox" id="rememberMe" name="rememberMe">
        <label for="rememberMe">Remember Me</label>
    </div>
    <button type="submit">Log In</button>
</form>

            </div>
            <div class="overlay-container" id="overlayCon">
                <div class="overlay">
                    <div class="overlay-panel overlay-left">
                        <div class="logo-container">
                            <img src="images/logo.png" alt="Cineverse" class="form-logo">
                        </div>
                        <h1>One of Us?</h1>
                        <p>Sign in and continue your movie journey with us!</p>
                        <button>Log In</button>
                    </div>
                    <div class="overlay-panel overlay-right">
                        <div class="logo-container">
                            <img src="images/logo.png" alt="Cineverse" class="form-logo">
                        </div>
                        <h1>New Here?</h1>
                        <p>Join us and experience the best movie booking experience!</p>
                        <button type="submit">Sign Up</button>
                    </div>
                </div>
                <button id="overlayBtn"></button>
            </div>
        </div>

       <script>
    const container = document.getElementById('container');
    const overlayCon = document.getElementById('overlayCon');
    const overlayBtn = document.getElementById('overlayBtn');

    overlayBtn.addEventListener('click', () => {
        container.classList.toggle('right-panel-active');
    });

    document.querySelector('.overlay-left button').addEventListener('click', () => {
        container.classList.remove('right-panel-active');
    });

    document.querySelector('.overlay-right button').addEventListener('click', () => {
        container.classList.add('right-panel-active');
    });
</script>
<script>
    
    window.onload = function() {
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        
        if(msg === 'success') {
            alert("Registration successful! Please login.");
        } else if(msg === 'exists') {
            alert("Email already exists! Please use a different email.");
        } else if(msg === 'error') {
            alert("Registration failed. Please try again.");
        }
    }
</script>

    </body>
</html>
