from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify
import mysql.connector
from mysql.connector import Error
from datetime import datetime
import os
from werkzeug.utils import secure_filename
import random

app = Flask(__name__)
app.secret_key = 'smartinventorysecretkey'
app.config['UPLOAD_FOLDER'] = 'static/uploads'
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max upload

# Ensure upload directory exists
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# Database connection function
def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="dbs123",
        database="manman",
        autocommit=True  # Default setting, will be overridden in transaction
    )


def execute_query(query, params=None, fetchone=False, commit=False):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(query, params or ())
        if fetchone:
            result = cursor.fetchone()
        else:
            result = cursor.fetchall()
        if commit:
            conn.commit()
        return result
    except Error as e:
        print(f"Database error: {e}")
        if commit:
            conn.rollback()
        return None
    finally:
        cursor.close()
        conn.close()


# Helper function for calling stored procedures
def call_procedure(proc_name, params=(), fetch_results=False):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        result = cursor.callproc(proc_name, params)
        if fetch_results:
            stored_results = []
            for result in cursor.stored_results():
                stored_results.append(result.fetchall())
            conn.commit()
            return stored_results
        else:
            conn.commit()
            return result
    except Error as e:
        print(f"Procedure error: {e}")
        conn.rollback()
        return None
    finally:
        cursor.close()
        conn.close()

# Routes
@app.route('/')
def index():
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        # Check if admin
        admin = execute_query(
            "SELECT * FROM Admin WHERE Aname = %s AND Phone = %s",
            (username, password),
            fetchone=True
        )
        
        if admin:
            session['admin_id'] = admin['AID']
            session['admin_name'] = admin['Aname']
            flash('Admin login successful!')
            return redirect(url_for('admin_dashboard'))
        
        # Check if customer
        user = execute_query(
            "SELECT * FROM Users WHERE Username = %s AND Password = %s",
            (username, password),
            fetchone=True
        )
        
        if user:
            session['user_id'] = user['userID']
            session['user_name'] = user['Name']
            flash('Login successful!')
            return redirect(url_for('customer_dashboard'))
        
        flash('Invalid username or password')
    
    return render_template('login.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        try:
            # Get form data
            username = request.form['username']
            password = request.form['password']
            name = request.form['name']
            address = request.form['address']
            phone = request.form['phone']
            email = request.form['email']
            
            # Print for debugging
            print(f"Attempting to register user: {username}, {name}, {email}")
            
            # Check if username already exists
            conn = get_db_connection()
            cursor = conn.cursor(dictionary=True)
            
            cursor.execute("SELECT * FROM Users WHERE Username = %s", (username,))
            existing_user = cursor.fetchone()
            
            if existing_user:
                flash('Username already exists. Please choose another one.')
                return redirect(url_for('register'))
            
            # Get a random admin to assign
            cursor.execute("SELECT AID FROM Admin ORDER BY RAND() LIMIT 1")
            admin = cursor.fetchone()
            admin_id = admin['AID'] if admin else 1
            
            # Insert new user
            insert_query = """INSERT INTO Users 
                             (Username, Password, Name, Address, Phone, Email, AdminID) 
                             VALUES (%s, %s, %s, %s, %s, %s, %s)"""
            
            cursor.execute(insert_query, 
                          (username, password, name, address, phone, email, admin_id))
            
            # Important: Commit the transaction
            conn.commit()
            
            # Print for debugging
            print(f"User registered successfully: {username}")
            
            flash('Registration successful! Please login.')
            return redirect(url_for('login'))
            
        except Exception as e:
            # Print the error for debugging
            print(f"Error during registration: {str(e)}")
            flash(f'Registration failed: {str(e)}')
            return redirect(url_for('register'))
            
        finally:
            # Close resources
            if 'cursor' in locals() and cursor:
                cursor.close()
            if 'conn' in locals() and conn:
                conn.close()
    
    # GET request - show registration form
    return render_template('register.html')


@app.route('/logout')
def logout():
    session.clear()
    flash('You have been logged out.')
    return redirect(url_for('login'))

# Customer Routes
@app.route('/customer/dashboard')
def customer_dashboard():
    if 'user_id' not in session:
        flash('Please login first')
        return redirect(url_for('login'))
    
    # Get recent products
    products = execute_query(
        "SELECT * FROM Product ORDER BY PID DESC LIMIT 6"
    )
    
    # Get order count
    order_count = execute_query(
        "SELECT COUNT(*) as count FROM Orders WHERE userID = %s",
        (session['user_id'],),
        fetchone=True
    )
    
    return render_template(
        'customer_dashboard.html', 
        products=products, 
        order_count=order_count['count'] if order_count else 0
    )

@app.route('/customer/products')
def customer_products():
    if 'user_id' not in session:
        flash('Please login first')
        return redirect(url_for('login'))
    
    search = request.args.get('search', '')
    category = request.args.get('category', '')
    
    query = "SELECT * FROM Product WHERE 1=1"
    params = []
    
    if search:
        query += " AND Pname LIKE %s"
        params.append(f"%{search}%")
    
    if category:
        query += " AND Category = %s"
        params.append(category)
    
    products = execute_query(query, params)
    
    # Get all categories for filter
    categories = execute_query("SELECT DISTINCT Category FROM Product")
    
    return render_template('customer_products.html', products=products, categories=categories, search=search, selected_category=category)

@app.route('/customer/product/<int:product_id>')
def product_detail(product_id):
    if 'user_id' not in session:
        flash('Please login first')
        return redirect(url_for('login'))
    
    # Get product details with supplier and inventory info
    product = execute_query(
        """SELECT p.*, s.Sname as SupplierName, 
           (SELECT SUM(Quantity) FROM Branch_Inventory WHERE InventoryID = p.InventoryID) as StockQuantity
           FROM Product p
           LEFT JOIN Supplier s ON p.SupID = s.SupID
           WHERE p.PID = %s""",
        (product_id,),
        fetchone=True
    )
    
    if not product:
        flash('Product not found')
        return redirect(url_for('customer_products'))
    
    # Get branches where this product is available
    branches = execute_query(
        """SELECT b.BranchID, b.Bname, bi.Quantity
           FROM Branch b
           JOIN Branch_Inventory bi ON b.BranchID = bi.BranchID
           WHERE bi.InventoryID = %s AND bi.Quantity > 0""",
        (product['InventoryID'],)
    )
    
    return render_template('product_detail.html', product=product, branches=branches)


@app.route('/customer/cart', methods=['GET', 'POST'])
def cart():
    if 'user_id' not in session:
        flash('Please login first')
        return redirect(url_for('login'))
    
    if 'cart' not in session:
        session['cart'] = []
    
    if request.method == 'POST':
        product_id = int(request.form['product_id'])
        quantity = int(request.form['quantity'])
        
        # Check if product exists
        product = execute_query(
            "SELECT * FROM Product WHERE PID = %s",
            (product_id,),
            fetchone=True
        )
        
        if not product:
            flash('Product not found')
            return redirect(url_for('customer_products'))
        
        # Check stock availability
        conn = get_db_connection()
        cursor = conn.cursor()
        
        try:
            # Create a variable to hold the output parameter
            cursor.execute("SET @available = 0")
            
            # Call the procedure
            cursor.execute("CALL CheckStock(%s, %s, @available)", (product_id, quantity))
            
            # Get the output parameter
            cursor.execute("SELECT @available")
            available = cursor.fetchone()[0]
            
            if not available:
                flash('Not enough stock available')
                return redirect(url_for('product_detail', product_id=product_id))
            
            # Add to cart
            cart_item = {
                'product_id': product_id,
                'name': product['Pname'],
                'price': float(product['Price']),
                'quantity': quantity,
                'total': float(product['Price']) * quantity
            }
            
            # Check if product already in cart
            cart = session['cart']
            for i, item in enumerate(cart):
                if item['product_id'] == product_id:
                    cart[i]['quantity'] += quantity
                    cart[i]['total'] = cart[i]['price'] * cart[i]['quantity']
                    session['cart'] = cart
                    flash('Cart updated')
                    return redirect(url_for('cart'))
            
            cart.append(cart_item)
            session['cart'] = cart
            flash('Product added to cart')
            
        except Exception as e:
            print(f"Error checking stock: {e}")
            flash('Error adding product to cart')
        finally:
            cursor.close()
            conn.close()
    
    # Calculate cart total
    cart_total = sum(item['total'] for item in session['cart'])
    
    return render_template('cart.html', cart=session['cart'], cart_total=cart_total)


@app.route('/customer/cart/remove/<int:product_id>')
def remove_from_cart(product_id):
    if 'cart' in session:
        cart = session['cart']
        session['cart'] = [item for item in cart if item['product_id'] != product_id]
        flash('Item removed from cart')
    
    return redirect(url_for('cart'))

@app.route('/customer/checkout', methods=['GET', 'POST'])
def checkout():
    if 'user_id' not in session:
        flash('Please login first')
        return redirect(url_for('login'))
    
    if 'cart' not in session or not session['cart']:
        flash('Your cart is empty')
        return redirect(url_for('customer_products'))
    
    if request.method == 'POST':
        conn = None
        cursor = None
        try:
            # Get form data
            address = request.form['address']
            city = request.form['city']
            street = request.form['street']
            country = request.form['country']
            pincode = request.form['pincode']
            recipient = request.form['recipient']
            
            # Calculate total amount
            total_amount = sum(item['total'] for item in session['cart'])
            
            # Get database connection
            conn = get_db_connection()
            conn.autocommit = False  # Start transaction
            cursor = conn.cursor(dictionary=True)
            
            # Check stock for all items before proceeding
            for item in session['cart']:
                cursor.execute("SET @available = 0")
                cursor.execute("CALL CheckStock(%s, %s, @available)", 
                              (item['product_id'], item['quantity']))
                cursor.execute("SELECT @available")
                available = cursor.fetchone()['@available']
                
                if not available:
                    flash(f"Not enough stock available for {item['name']}")
                    return redirect(url_for('cart'))
            
            # 1. Create delivery record
            cursor.execute(
                """INSERT INTO Delivery (Address, City, Street, Country, PinCode, RecipientName)
                   VALUES (%s, %s, %s, %s, %s, %s)""",
                (address, city, street, country, pincode, recipient)
            )
            delivery_id = cursor.lastrowid

            # Print for debugging
            print(f"Created delivery record with ID: {delivery_id}")

            # Verify delivery_id is valid before proceeding
            if not delivery_id:
                raise Exception("Failed to create delivery record - no ID returned")
            
            # 2. Get a random employee
            cursor.execute("SELECT EID FROM Employee ORDER BY RAND() LIMIT 1")
            employee = cursor.fetchone()
            employee_id = employee['EID'] if employee else None
            
            # 3. Create order - explicitly include DeliveryID
            cursor.execute(
                """INSERT INTO Orders (Date, Amount, userID, EmployeeID, DeliveryID)
                   VALUES (CURDATE(), %s, %s, %s, %s)""",
                (total_amount, session['user_id'], employee_id, delivery_id)
            )
            order_id = cursor.lastrowid
            
            # 4. Add products to order and update inventory
            for item in session['cart']:
                cursor.execute(
                    """INSERT INTO Order_Product (OrderNo, PID, Quantity)
                       VALUES (%s, %s, %s)""",
                    (order_id, item['product_id'], item['quantity'])
                )
                
                # Get inventory ID for this product
                cursor.execute("SELECT InventoryID FROM Product WHERE PID = %s", 
                              (item['product_id'],))
                inventory_id = cursor.fetchone()['InventoryID']
                
                # Update inventory (manually instead of relying on trigger)
                cursor.execute(
                    """UPDATE Branch_Inventory 
                       SET Quantity = Quantity - %s
                       WHERE InventoryID = %s AND Quantity >= %s
                       ORDER BY Quantity DESC
                       LIMIT 1""",
                    (item['quantity'], inventory_id, item['quantity'])
                )
                
                # Verify the update affected a row
                if cursor.rowcount == 0:
                    raise Exception(f"Failed to update inventory for {item['name']}")
            
            # 5. Create invoice
            cursor.execute(
                """INSERT INTO Invoice (OrderNo, InvoiceDate)
                   VALUES (%s, CURDATE())""",
                (order_id,)
            )
            
            # All operations successful, commit transaction
            conn.commit()
            
            # Clear cart
            session.pop('cart', None)
            
            flash('Order placed successfully!')
            return redirect(url_for('order_details', order_id=order_id))
            
        except mysql.connector.Error as error:
            # Handle database errors with detailed debugging information
            if conn:
                conn.rollback()
            print(f"Database error placing order: {error}")
            
            # Display the actual error to help with debugging
            flash(f'Database error details: {str(error)}')
            return redirect(url_for('cart'))
            
        except Exception as e:
            # Handle other errors
            if conn:
                conn.rollback()
            print(f"Error placing order: {e}")
            flash(f'Error placing order: {str(e)}')
            return redirect(url_for('cart'))
            
        finally:
            # Clean up resources
            if cursor:
                cursor.close()
            if conn:
                conn.close()
    
    # GET request - show checkout form
    user = execute_query(
        "SELECT * FROM Users WHERE userID = %s",
        (session['user_id'],),
        fetchone=True
    )
    
    cart_total = sum(item['total'] for item in session['cart'])
    
    return render_template('checkout.html', user=user, cart=session['cart'], cart_total=cart_total)






@app.route('/customer/orders')
def order_history():
    if 'user_id' not in session:
        flash('Please login first')
        return redirect(url_for('login'))
    
    orders = execute_query(
        """SELECT o.OrderNo, o.Date, o.Amount, i.InvoiceID,
           (SELECT COUNT(*) FROM Order_Product WHERE OrderNo = o.OrderNo) as ItemCount
           FROM Orders o
           LEFT JOIN Invoice i ON o.OrderNo = i.OrderNo
           WHERE o.userID = %s
           ORDER BY o.Date DESC""",
        (session['user_id'],)
    )
    
    return render_template('order_history.html', orders=orders)

@app.route('/customer/order/<int:order_id>')
def order_details(order_id):
    if 'user_id' not in session:
        flash('Please login first')
        return redirect(url_for('login'))
    
    # Get order details
    order = execute_query(
        """SELECT o.*, d.*, e.Ename as EmployeeName, i.InvoiceID, i.InvoiceDate
           FROM Orders o
           JOIN Delivery d ON o.DeliveryID = d.DeliveryID
           LEFT JOIN Employee e ON o.EmployeeID = e.EID
           LEFT JOIN Invoice i ON o.OrderNo = i.OrderNo
           WHERE o.OrderNo = %s AND o.userID = %s""",
        (order_id, session['user_id']),
        fetchone=True
    )
    
    if not order:
        flash('Order not found')
        return redirect(url_for('order_history'))
    
    # Get order items
    items = execute_query(
        """SELECT op.*, p.Pname, p.Price, p.Category, s.Sname as SupplierName
           FROM Order_Product op
           JOIN Product p ON op.PID = p.PID
           LEFT JOIN Supplier s ON p.SupID = s.SupID
           WHERE op.OrderNo = %s""",
        (order_id,)
    )
    
    return render_template('order_details.html', order=order, items=items)

@app.route('/customer/invoice/<int:invoice_id>')
def view_invoice(invoice_id):
    if 'user_id' not in session:
        flash('Please login first')
        return redirect(url_for('login'))
    
    # Get invoice details
    invoice = execute_query(
        """SELECT i.*, o.*, d.*, u.Name as CustomerName, u.Email, u.Phone
           FROM Invoice i
           JOIN Orders o ON i.OrderNo = o.OrderNo
           JOIN Delivery d ON o.DeliveryID = d.DeliveryID
           JOIN Users u ON o.userID = u.userID
           WHERE i.InvoiceID = %s AND o.userID = %s""",
        (invoice_id, session['user_id']),
        fetchone=True
    )
    
    if not invoice:
        flash('Invoice not found')
        return redirect(url_for('order_history'))
    
    # Get invoice items
    items = execute_query(
        """SELECT op.*, p.Pname, p.Price, p.Category
           FROM Order_Product op
           JOIN Product p ON op.PID = p.PID
           WHERE op.OrderNo = %s""",
        (invoice['OrderNo'],)
    )
    
    return render_template('invoice.html', invoice=invoice, items=items)

# Admin Routes
@app.route('/admin/dashboard')
def admin_dashboard():
    if 'admin_id' not in session:
        flash('Please login as admin')
        return redirect(url_for('login'))
    
    # Get counts for dashboard
    user_count = execute_query("SELECT COUNT(*) as count FROM Users", fetchone=True)
    product_count = execute_query("SELECT COUNT(*) as count FROM Product", fetchone=True)
    order_count = execute_query("SELECT COUNT(*) as count FROM Orders", fetchone=True)
    
    # Get recent orders
    recent_orders = execute_query(
        """SELECT o.OrderNo, o.Date, o.Amount, u.Name as CustomerName
           FROM Orders o
           JOIN Users u ON o.userID = u.userID
           ORDER BY o.Date DESC LIMIT 5"""
    )
    
    # Get low stock products
    low_stock = execute_query(
        """SELECT p.PID, p.Pname, 
           (SELECT SUM(Quantity) FROM Branch_Inventory WHERE InventoryID = p.InventoryID) as Stock
           FROM Product p
           HAVING Stock < 10 OR Stock IS NULL
           ORDER BY Stock ASC
           LIMIT 5"""
    )
    
    return render_template(
        'admin_dashboard.html',
        user_count=user_count['count'],
        product_count=product_count['count'],
        order_count=order_count['count'],
        recent_orders=recent_orders,
        low_stock=low_stock
    )

@app.route('/admin/users')
def admin_users():
    if 'admin_id' not in session:
        flash('Please login as admin')
        return redirect(url_for('login'))
    
    users = execute_query(
        """SELECT u.*, a.Aname as AdminName,
           (SELECT COUNT(*) FROM Orders WHERE userID = u.userID) as OrderCount
           FROM Users u
           LEFT JOIN Admin a ON u.AdminID = a.AID"""
    )
    
    return render_template('admin_users.html', users=users)

@app.route('/admin/user/<int:user_id>')
def admin_user_details(user_id):
    if 'admin_id' not in session:
        flash('Please login as admin')
        return redirect(url_for('login'))
    
    user = execute_query(
        """SELECT u.*, a.Aname as AdminName
           FROM Users u
           LEFT JOIN Admin a ON u.AdminID = a.AID
           WHERE u.userID = %s""",
        (user_id,),
        fetchone=True
    )
    
    if not user:
        flash('User not found')
        return redirect(url_for('admin_users'))
    
    # Get user orders
    orders = execute_query(
        """SELECT o.OrderNo, o.Date, o.Amount, i.InvoiceID,
           (SELECT COUNT(*) FROM Order_Product WHERE OrderNo = o.OrderNo) as ItemCount
           FROM Orders o
           LEFT JOIN Invoice i ON o.OrderNo = i.OrderNo
           WHERE o.userID = %s
           ORDER BY o.Date DESC""",
        (user_id,)
    )
    
    return render_template('admin_user_details.html', user=user, orders=orders)

@app.route('/admin/products')
def admin_products():
    if 'admin_id' not in session:
        flash('Please login as admin')
        return redirect(url_for('login'))
    
    search = request.args.get('search', '')
    category = request.args.get('category', '')
    
    query = """SELECT p.*, s.Sname as SupplierName, 
               (SELECT SUM(Quantity) FROM Branch_Inventory WHERE InventoryID = p.InventoryID) as StockQuantity
               FROM Product p
               LEFT JOIN Supplier s ON p.SupID = s.SupID
               WHERE 1=1"""
    params = []
    
    if search:
        query += " AND p.Pname LIKE %s"
        params.append(f"%{search}%")
    
    if category:
        query += " AND p.Category = %s"
        params.append(category)
    
    products = execute_query(query, params)
    
    # Get all categories for filter
    categories = execute_query("SELECT DISTINCT Category FROM Product")
    
    # Get all suppliers for adding new product
    suppliers = execute_query("SELECT * FROM Supplier")
    
    # Get all storage locations
    storage = execute_query("SELECT * FROM Storage")
    
    # Get all inventories
    inventories = execute_query("SELECT * FROM Inventory")
    
    return render_template(
        'admin_products.html',
        products=products,
        categories=categories,
        suppliers=suppliers,
        storage=storage,
        inventories=inventories,
        search=search,
        selected_category=category
    )

@app.route('/admin/add_product', methods=['POST'])
def admin_add_product():
    if 'admin_id' not in session:
        flash('Please login as admin')
        return redirect(url_for('login'))
    
    if request.method == 'POST':
        conn = None
        cursor = None
        try:
            # Get form data
            pname = request.form['pname']
            category = request.form['category']
            price = request.form['price']
            supid = request.form['supid']
            storageid = request.form['storageid']
            inventoryid = request.form['inventoryid']
            
            # Print for debugging
            print(f"Attempting to add product: {pname}, {category}, {price}, SupID: {supid}, StorageID: {storageid}, InventoryID: {inventoryid}")
            
            # Validate form data
            if not pname or not category or not price or not supid or not storageid or not inventoryid:
                flash('All fields are required')
                return redirect(url_for('admin_products'))
            
            # Convert numeric values
            try:
                price = float(price)
                supid = int(supid)
                storageid = int(storageid)
                inventoryid = int(inventoryid)
            except ValueError:
                flash('Invalid numeric values')
                return redirect(url_for('admin_products'))
            
            # Get database connection
            conn = get_db_connection()
            cursor = conn.cursor(dictionary=True)
            
            # Verify foreign keys exist
            cursor.execute("SELECT SupID FROM Supplier WHERE SupID = %s", (supid,))
            if not cursor.fetchone():
                flash(f'Supplier with ID {supid} does not exist')
                return redirect(url_for('admin_products'))
                
            cursor.execute("SELECT StorageID FROM Storage WHERE StorageID = %s", (storageid,))
            if not cursor.fetchone():
                flash(f'Storage with ID {storageid} does not exist')
                return redirect(url_for('admin_products'))
                
            cursor.execute("SELECT InventoryID FROM Inventory WHERE InventoryID = %s", (inventoryid,))
            if not cursor.fetchone():
                flash(f'Inventory with ID {inventoryid} does not exist')
                return redirect(url_for('admin_products'))
            
            # Insert the product directly
            insert_query = """INSERT INTO Product 
                             (Pname, Category, Price, SupID, StorageID, InventoryID) 
                             VALUES (%s, %s, %s, %s, %s, %s)"""
            
            cursor.execute(insert_query, 
                          (pname, category, price, supid, storageid, inventoryid))
            
            # Commit the transaction
            conn.commit()
            
            # Print for debugging
            print(f"Product added successfully: {pname}")
            
            flash('Product added successfully')
            return redirect(url_for('admin_products'))
            
        except mysql.connector.Error as error:
            # Print the error for debugging
            print(f"Database error adding product: {str(error)}")
            
            if conn:
                conn.rollback()
                
            # Provide specific error messages based on error code
            if error.errno == 1452:  # Foreign key constraint error
                flash('Error: One of the selected IDs does not exist')
            elif error.errno == 1062:  # Duplicate entry error
                flash('Error: This product already exists')
            else:
                flash(f'Database error: {str(error)}')
                
            return redirect(url_for('admin_products'))
            
        except Exception as e:
            # Print the error for debugging
            print(f"Error adding product: {str(e)}")
            
            if conn:
                conn.rollback()
                
            flash(f'Error adding product: {str(e)}')
            return redirect(url_for('admin_products'))
            
        finally:
            # Close resources
            if cursor:
                cursor.close()
            if conn:
                conn.close()
    
    # Should not reach here for POST request
    return redirect(url_for('admin_products'))


@app.route('/admin/delete_product/<int:product_id>', methods=['POST'])
def admin_delete_product(product_id):
    if 'admin_id' not in session:
        flash('Please login as admin')
        return redirect(url_for('login'))
    
    # Check if product is in any orders
    order_products = execute_query(
        "SELECT COUNT(*) as count FROM Order_Product WHERE PID = %s",
        (product_id,),
        fetchone=True
    )
    
    if order_products['count'] > 0:
        flash('Cannot delete product that is in orders')
        return redirect(url_for('admin_products'))
    
    # Delete product
    execute_query(
        "DELETE FROM Product WHERE PID = %s",
        (product_id,),
        commit=True
    )
    
    flash('Product deleted successfully')
    return redirect(url_for('admin_products'))

@app.route('/admin/inventory')
def admin_inventory():
    if 'admin_id' not in session:
        flash('Please login as admin')
        return redirect(url_for('login'))
    
    # Get inventory with branch details
    inventory = execute_query(
        """SELECT i.InventoryID, i.Itemname, b.BranchID, b.Bname, bi.Quantity
           FROM Inventory i
           JOIN Branch_Inventory bi ON i.InventoryID = bi.InventoryID
           JOIN Branch b ON bi.BranchID = b.BranchID
           ORDER BY i.InventoryID, b.BranchID"""
    )
    
    # Get all branches
    branches = execute_query("SELECT * FROM Branch")
    
    # Get all inventories
    inventories = execute_query("SELECT * FROM Inventory")
    
    return render_template(
        'admin_inventory.html',
        inventory=inventory,
        branches=branches,
        inventories=inventories
    )

@app.route('/admin/update_inventory', methods=['POST'])
def admin_update_inventory():
    if 'admin_id' not in session:
        flash('Please login as admin')
        return redirect(url_for('login'))
    
    inventoryid = int(request.form['inventoryid'])
    branchid = int(request.form['branchid'])
    quantity = int(request.form['quantity'])
    
    # Check if inventory-branch combination exists
    existing = execute_query(
        "SELECT * FROM Branch_Inventory WHERE InventoryID = %s AND BranchID = %s",
        (inventoryid, branchid),
        fetchone=True
    )
    
    if existing:
        # Update existing record
        execute_query(
            "UPDATE Branch_Inventory SET Quantity = %s WHERE InventoryID = %s AND BranchID = %s",
            (quantity, inventoryid, branchid),
            commit=True
        )
        flash('Inventory updated successfully')
    else:
        # Insert new record
        execute_query(
            "INSERT INTO Branch_Inventory (InventoryID, BranchID, Quantity) VALUES (%s, %s, %s)",
            (inventoryid, branchid, quantity),
            commit=True
        )
        flash('Inventory added successfully')
    
    return redirect(url_for('admin_inventory'))

@app.route('/admin/orders')
def admin_orders():
    if 'admin_id' not in session:
        flash('Please login as admin')
        return redirect(url_for('login'))
    
    orders = execute_query(
        """SELECT o.OrderNo, o.Date, o.Amount, u.Name as CustomerName, e.Ename as EmployeeName,
           i.InvoiceID, d.Address, d.City
           FROM Orders o
           JOIN Users u ON o.userID = u.userID
           LEFT JOIN Employee e ON o.EmployeeID = e.EID
           LEFT JOIN Invoice i ON o.OrderNo = i.OrderNo
           LEFT JOIN Delivery d ON o.DeliveryID = d.DeliveryID
           ORDER BY o.Date DESC"""
    )
    
    return render_template('admin_orders.html', orders=orders)

@app.route('/admin/order/<int:order_id>')
def admin_order_details(order_id):
    if 'admin_id' not in session:
        flash('Please login as admin')
        return redirect(url_for('login'))
    
    # Get order details
    order = execute_query(
        """SELECT o.*, d.*, e.Ename as EmployeeName, i.InvoiceID, i.InvoiceDate,
           u.Name as CustomerName, u.Email as CustomerEmail, u.Phone as CustomerPhone
           FROM Orders o
           JOIN Delivery d ON o.DeliveryID = d.DeliveryID
           LEFT JOIN Employee e ON o.EmployeeID = e.EID
           LEFT JOIN Invoice i ON o.OrderNo = i.OrderNo
           JOIN Users u ON o.userID = u.userID
           WHERE o.OrderNo = %s""",
        (order_id,),
        fetchone=True
    )
    
    if not order:
        flash('Order not found')
        return redirect(url_for('admin_orders'))
    
    # Get order items
    items = execute_query(
        """SELECT op.*, p.Pname, p.Price, p.Category, s.Sname as SupplierName
           FROM Order_Product op
           JOIN Product p ON op.PID = p.PID
           LEFT JOIN Supplier s ON p.SupID = s.SupID
           WHERE op.OrderNo = %s""",
        (order_id,)
    )
    
    return render_template('admin_order_details.html', order=order, items=items)

@app.route('/admin/report')
def admin_report():
    if 'admin_id' not in session:
        flash('Please login as admin')
        return redirect(url_for('login'))
    
    # Generate report using cursor
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        args = [None]
        cursor.callproc('GenerateAdminReport', args)
        
        # Get the report text
        cursor.execute("SELECT @_GenerateAdminReport_0")
        report_text = cursor.fetchone()[0]
        
        # Get additional statistics
        total_users = execute_query("SELECT COUNT(*) as count FROM Users", fetchone=True)['count']
        total_orders = execute_query("SELECT COUNT(*) as count FROM Orders", fetchone=True)['count']
        total_revenue = execute_query("SELECT SUM(Amount) as total FROM Orders", fetchone=True)['total'] or 0
        
        # Get top products
        top_products = execute_query(
            """SELECT p.PID, p.Pname, SUM(op.Quantity) as TotalSold
               FROM Product p
               JOIN Order_Product op ON p.PID = op.PID
               GROUP BY p.PID
               ORDER BY TotalSold DESC
               LIMIT 5"""
        )
        
        # Get branch performance
        branch_performance = execute_query(
            """SELECT b.BranchID, b.Bname, SUM(bi.Quantity) as TotalStock
               FROM Branch b
               JOIN Branch_Inventory bi ON b.BranchID = bi.BranchID
               GROUP BY b.BranchID
               ORDER BY TotalStock DESC"""
        )
        
        return render_template(
            'admin_report.html',
            report_text=report_text,
            total_users=total_users,
            total_orders=total_orders,
            total_revenue=total_revenue,
            top_products=top_products,
            branch_performance=branch_performance
        )
        
    except Error as e:
        print(f"Error generating report: {e}")
        flash('Error generating report')
        return redirect(url_for('admin_dashboard'))
    finally:
        cursor.close()
        conn.close()

# Run the application
if __name__ == '__main__':
    app.run(debug=True)
