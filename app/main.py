from flask import Flask, make_response, request, render_template, redirect, jsonify
from random import random
import datetime
import jwt
import calc_functions as calc_functions

SECRET_KEY = "C7E2F9D46E92DCF2234D18BEF8C6D"
flask_app = Flask(__name__)

# @component External:Guest (#guest)
# @component External:User (#user)

# @threat Token Theft (#tokentheft)
def verify_token(token):
    if token:
        decoded_token = jwt.decode(token, SECRET_KEY, "HS256")
        print(decoded_token)
        # Check whther the information in decoded_token is correct or not

        return True # if the information is correct, otherwise return False
    else:
        return False

# @component CalcApp:Web:Server:Index (#index)
# @connects #guest to #index with HTTP-GET
# @connects #index to #guest with HTTP-GET

# @threat Cross Site Scripting (#xss)
# @control Sanitize Code (#sanitize)
# @exposes #index to #xss with #xss

# @threat Buffer overflow (#buffer)
# @exposes #index to Buffer Overflow with #buffer
# @exposes #login to Buffer Overthrow with #buffer
# @exposes #web_server to Buffer Overflow with #buffer

# @threat Cross site scripting (reflected) (#xss)
# @exposes #index to javascript manipulation with #xss

# @threat Cross Site Request Forgery (#csrf)
# @exposes #index to tampering with #csrf
# @exposes #calculate to tampering with #csrf
# @exposes #calculate2 to tampering with #csrf
# @exposes #calculator to tampering with #csrf


@flask_app.route('/')
def index_page():
    print(request.headers)
    isUserLoggedIn = False
    if 'token' in request.cookies:
        isUserLoggedIn = verify_token(request.cookies['token'])

    if isUserLoggedIn:
        return "Welcome back to the website"
    else:
        user_id = random()
        print(f"User ID: {user_id}")
        resp = make_response(render_template('index.html'))
        resp.set_cookie('user_id', str(user_id))
        return resp

# @component CalcApp:Web:Server:Help (#help)
# @connects #guest to #help with HTTP-GET
# @connects #help to #guest with HTTP-GET

@flask_app.route('/help')
def help_page():
    return "This is the help page"

# @component CalcApp:Web:Server:Login (#login)

# @connects #guest to #login with HTTP-GET
# @connects #login to guest with HTTP-GET

# @threat SQL injection (#sqlinjection)
# @control Validate User Input (#validate)
# @mitigates #login against #sqlinjection with #validate

# @threat Password Brute Forcing (#brute)
# @control Strong Password Policy (#passpolicy)
# @mitigates #login against #brute with #passpolicy
# @exposes #login to information disclosure with #brute

@flask_app.route('/login')
def login_page():
    return render_template('login.html')

def create_token(username, password):
    validity = datetime.datetime.utcnow() + datetime.timedelta(days=15)
    print(validity)
    token = jwt.encode({'user_id': 123154, 'username': username, 'exp': validity}, SECRET_KEY, "HS256")
    return token

# @component CalcApp:Web:Server:Authenticate (#authenticate)
# @connects #guest to #authenticate with HTTP-POST
# @connects #authenticate with #guest with HTTP-POST

# @connects #user to #authenticate with HTTPs-POST
# @connects #authenticate to #user with HTTPs-POST

@flask_app.route('/authenticate', methods = ['POST'])
def authenticate_users():
    data = request.form
    username = data['username']
    password = data['password']

    # check whether the username and password are correct
    user_token = create_token(username, password)

    resp = make_response(redirect('/calculator'))
    #resp.set_cookie("loggedIn", "True")
    resp.set_cookie('token', user_token)
    return resp

# @component CalcApp:Web:Server:Calculator (#calculator)

# @connects #guest to #calculator with HTTP-GET
# @connects #calculator to #guest with HTTP-GET

# @connects #user to #calculator with HTTP-GET
# @connects #calculator to #user with HTTP-GET

# @exposes #calculator to #sqlinjection with #sqlinjection
# @exposes #calculator to #tokentheft with #tokenforgery
@flask_app.route('/calculator', methods = ['GET'])
def calculator_get():
    isUserLoggedIn = False
    if 'token' in request.cookies:
        isUserLoggedIn = verify_token(request.cookies['token'])

    if isUserLoggedIn:
        return render_template("calculator.html")
    else:
        resp = make_response(redirect('/login'))
        return resp

# @component CalcApp:Web:Server:Calculate (#calculate)

# @connects #user to #calculate with HTTP-POST
# @connects #calculate to #user with HTTP-POST

@flask_app.route('/calculate', methods = ['POST'])
def calculate_post():
    number_1 = request.form.get('number_1', type = int)
    number_2 = request.form.get('number_2', type = int)
    operation= request.form.get('operation')

    result = calc_functions.process(number_1, number_2, operation)

    return str(result)

# @component CalcApp:Web:Server:Calculate2 (#calculate2)

# @connects #user to #calculate2 with HTTP-POST
# @connects #calculate2 to #user with HTTP-POST


@flask_app.route('/calculate2', methods = ['POST'])
def calculate_post2():
    print(request.form)
    number_1 = request.form.get('number_1', type = int)
    number_2 = request.form.get('number_2', type = int)
    operation= request.form.get('operation', type= str)

    result = calc_functions.process(number_1, number_2, operation)

    print(result)
    response_data = {
        'data': result
    }
    return make_response(jsonify(response_data))

if __name__ == "__main__":
    print("This is a Secure REST API Server")
    flask_app.run(host="0.0.0.0", debug = True, ssl_context=('cert/cert.pem', 'cert/key.pem'))


# with closing(sqlite3.connect("data.db")) as connection:
#     with closing(connection.cursor()) as cursor:
#         try:
#             cursor.execute("CREATE TABLE operations_table (id, INTEGER PRIMARY KEY, username TEXT, password);")
#             connection.commit()
#         except Exception as e:
#             raise
#
