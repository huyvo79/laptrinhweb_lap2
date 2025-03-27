USE bke;
---1. Liệt kê các hóa đơn của khách hàng, thông tin hiển thị gồm: mã user, tên user, mã hóa đơn
SELECT u.user_id, u.user_name, o.order_id
FROM users u , orders o
WHERE u.user_id LIKE o.user_id

---2. Liệt kê số lượng các hóa đơn của khách hàng: mã user, tên user, số đơn hàng
SELECT u.user_id, u.user_name, COUNT(o.order_id) AS total_orders
FROM users u, orders o
WHERE u.user_id LIKE o.user_id
GROUP BY u.user_id, u.user_name;

---3. Liệt kê thông tin hóa đơn: mã đơn hàng, số sản phẩm
SELECT o.order_id, COUNT(od.product_id) AS total_products
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.order_id;

---4. Liệt kê thông tin mua hàng của người dùng: mã user, tên user, mã đơn hàng, tên sản phẩm
SELECT u.user_id, u.user_name, o.order_id, p.product_name
FROM users u, orders o, order_details od, products p
WHERE u.user_id = o.user_id
AND o.order_id = od.order_id
AND od.product_id = p.product_id
ORDER BY o.order_id;


---5. Liệt kê 7 người dùng có số lượng đơn hàng nhiều nhất
SELECT u.user_id, u.user_name, COUNT(o.order_id) AS total_orders
FROM users u
JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.user_name
ORDER BY total_orders DESC
LIMIT 7;

---6. Liệt kê 7 người dùng mua sản phẩm có tên: Samsung hoặc Apple trong tên sản phẩm
SELECT DISTINCT u.user_id, u.user_name, o.order_id, p.product_name
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
WHERE p.product_name LIKE '%Samsung%' OR p.product_name LIKE '%Apple%'
LIMIT 7;

---7. Liệt kê danh sách mua hàng của user bao gồm giá tiền của mỗi đơn hàng, thông tinh hiển thị gồm: mã user, tên user, mã đơn hàng, tổng tiền
SELECT u.user_id, user_name, o.order_id, sum(p.product_price) as Total
FROM users u, orders o, order_details d, products p
WHERE u.user_id = o.user_id and o.order_id = d.order_id and d.product_id = p.product_id
GROUP BY o.order_id;

---8. Liệt kê danh sách mua hàng của user, mỗi user chỉ chọn 1 đơn hàng có giá tiền lớn nhất
SELECT u.user_id, u.user_name, o.order_id, MAX(order_total) AS max_total_price
FROM (
    SELECT o.user_id, o.order_id, SUM(p.price * od.quantity) AS order_total
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN products p ON od.product_id = p.product_id
    GROUP BY o.user_id, o.order_id
) AS order_summary
JOIN users u ON order_summary.user_id = u.user_id
GROUP BY u.user_id, u.user_name;

---9. Liệt kê danh sách mua hàng của user, mỗi user chỉ chọn 1 đơn hàng có giá tiền nhỏ nhất
SELECT user_id, user_name, order_id, total_price, total_products
FROM (
    SELECT u.user_id, u.user_name, o.order_id, 
           SUM(p.price * od.quantity) AS total_price,
           COUNT(od.product_id) AS total_products,
           RANK() OVER (PARTITION BY u.user_id ORDER BY SUM(p.price * od.quantity) ASC) AS rnk
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    JOIN order_details od ON o.order_id = od.order_id
    JOIN products p ON od.product_id = p.product_id
    GROUP BY u.user_id, u.user_name, o.order_id
) ranked_orders
WHERE rnk = 1;

---10. Liệt kê danh sách mua hàng của user, mỗi user chỉ chọn 1 đơn hàng có số sản phẩm nhiều nhất
SELECT user_id, user_name, order_id, total_price, total_products
FROM (
    SELECT u.user_id, u.user_name, o.order_id, 
           SUM(p.price * od.quantity) AS total_price,
           COUNT(od.product_id) AS total_products,
           RANK() OVER (PARTITION BY u.user_id ORDER BY COUNT(od.product_id) DESC) AS rnk
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    JOIN order_details od ON o.order_id = od.order_id
    JOIN products p ON od.product_id = p.product_id
    GROUP BY u.user_id, u.user_name, o.order_id
) ranked_orders
WHERE rnk = 1;
