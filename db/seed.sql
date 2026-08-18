-- =============================================================
-- seed.sql — E-commerce Catalog Seed Data (v2)
-- Джерело: DummyJSON (dummyjson.com), тільки модні категорії
-- Дата: 2026-06-28
--
-- СТАТИСТИКА:
--   products : 49 рядків
--   variants : 307 рядків
--
-- РОЗМІРНА ЛОГІКА (variants):
--   Одяг    (mens-shirts, womens-dresses, tops)
--             → size: 'S' | 'M' | 'L' | 'XL'   (4 розміри × кольори)
--   Взуття  (mens-shoes, womens-shoes)
--             → size: '40'|'41'|'42'|'43'|'44'|'45'  (EU, text, 6 розмірів × кольори)
--             Реалізм: 41-43 більший stock, 40/45 — менший або 0
--   Решта   (mens-watches, womens-watches, womens-bags,
--             womens-jewellery, sunglasses)
--             → size: NULL  (один рядок на колір, без розмірів)
-- =============================================================
--
-- ⚠️  ЯК ВИРІШЕНО FK (нагадування):
--   products.id генерується Postgres автоматично (bigserial).
--   У кожному INSERT variants.product_id береться підзапитом:
--
--     (SELECT id FROM products WHERE name = 'Назва товару')
--
--   Апостроф у назві → подвоєний апостроф: 'Women''s'.
--   NULL пишеться БЕЗ лапок — саме NULL.
-- =============================================================


-- =============================================================
-- ЧАСТИНА 1: PRODUCTS (без змін від v1)
-- =============================================================

INSERT INTO products (name, description, image_url, gender, price) VALUES

-- ── mens-shirts ─────────────────────────────────────────────
('Blue & Black Check Shirt',
 'The Blue & Black Check Shirt is a stylish and comfortable men''s shirt featuring a classic check pattern. Made from high-quality fabric, it''s suitable for both casual and semi-formal occasions.',
 'https://cdn.dummyjson.com/product-images/mens-shirts/blue-&-black-check-shirt/thumbnail.webp',
 'mens', 29.99),

('Gigabyte Aorus Men Tshirt',
 'The Gigabyte Aorus Men Tshirt is a cool and casual shirt for gaming enthusiasts. With the Aorus logo and sleek design, it''s perfect for expressing your gaming style.',
 'https://cdn.dummyjson.com/product-images/mens-shirts/gigabyte-aorus-men-tshirt/thumbnail.webp',
 'mens', 24.99),

('Man Plaid Shirt',
 'The Man Plaid Shirt is a timeless and versatile men''s shirt with a classic plaid pattern. Its comfortable fit and casual style make it a wardrobe essential for various occasions.',
 'https://cdn.dummyjson.com/product-images/mens-shirts/man-plaid-shirt/thumbnail.webp',
 'mens', 34.99),

('Man Short Sleeve Shirt',
 'The Man Short Sleeve Shirt is a breezy and stylish option for warm days. With a comfortable fit and short sleeves, it''s perfect for a laid-back yet polished look.',
 'https://cdn.dummyjson.com/product-images/mens-shirts/man-short-sleeve-shirt/thumbnail.webp',
 'mens', 19.99),

('Men Check Shirt',
 'The Men Check Shirt is a classic and versatile shirt featuring a stylish check pattern. Suitable for various occasions, it adds a smart and polished touch to your wardrobe.',
 'https://cdn.dummyjson.com/product-images/mens-shirts/men-check-shirt/thumbnail.webp',
 'mens', 27.99),

-- ── mens-shoes ──────────────────────────────────────────────
('Nike Air Jordan 1 Red And Black',
 'The Nike Air Jordan 1 in Red and Black is an iconic basketball sneaker known for its stylish design and high-performance features, making it a favorite among sneaker enthusiasts and athletes.',
 'https://cdn.dummyjson.com/product-images/mens-shoes/nike-air-jordan-1-red-and-black/thumbnail.webp',
 'mens', 149.99),

('Nike Baseball Cleats',
 'Nike Baseball Cleats are designed for maximum traction and performance on the baseball field. They provide stability and support for players during games and practices.',
 'https://cdn.dummyjson.com/product-images/mens-shoes/nike-baseball-cleats/thumbnail.webp',
 'mens', 79.99),

('Puma Future Rider Trainers',
 'The Puma Future Rider Trainers offer a blend of retro style and modern comfort. Perfect for casual wear, these trainers provide a fashionable and comfortable option for everyday use.',
 'https://cdn.dummyjson.com/product-images/mens-shoes/puma-future-rider-trainers/thumbnail.webp',
 'mens', 89.99),

('Sports Sneakers Off White & Red',
 'The Sports Sneakers in Off White and Red combine style and functionality, making them a fashionable choice for sports enthusiasts. The red and off-white color combination adds a bold and energetic touch.',
 'https://cdn.dummyjson.com/product-images/mens-shoes/sports-sneakers-off-white-&-red/thumbnail.webp',
 'mens', 119.99),

('Sports Sneakers Off White Red',
 'Another variant of the Sports Sneakers in Off White Red, featuring a unique design. These sneakers offer style and comfort for casual occasions.',
 'https://cdn.dummyjson.com/product-images/mens-shoes/sports-sneakers-off-white-red/thumbnail.webp',
 'mens', 109.99),

-- ── mens-watches ────────────────────────────────────────────
('Brown Leather Belt Watch',
 'The Brown Leather Belt Watch is a stylish timepiece with a classic design. Featuring a genuine leather strap and a sleek dial, it adds a touch of sophistication to your look.',
 'https://cdn.dummyjson.com/product-images/mens-watches/brown-leather-belt-watch/thumbnail.webp',
 'mens', 89.99),

('Longines Master Collection',
 'The Longines Master Collection is an elegant and refined watch known for its precision and craftsmanship. With a timeless design, it''s a symbol of luxury and sophistication.',
 'https://cdn.dummyjson.com/product-images/mens-watches/longines-master-collection/thumbnail.webp',
 'mens', 1499.99),

('Rolex Cellini Date Black Dial',
 'The Rolex Cellini Date with Black Dial is a classic and prestigious watch. With a black dial and date complication, it exudes sophistication and is a symbol of Rolex''s heritage.',
 'https://cdn.dummyjson.com/product-images/mens-watches/rolex-cellini-date-black-dial/thumbnail.webp',
 'mens', 8999.99),

('Rolex Cellini Moonphase',
 'The Rolex Cellini Moonphase is a masterpiece of horology, featuring a moon phase complication and exquisite design. It reflects Rolex''s commitment to precision and elegance.',
 'https://cdn.dummyjson.com/product-images/mens-watches/rolex-cellini-moonphase/thumbnail.webp',
 'mens', 12999.99),

('Rolex Datejust',
 'The Rolex Datejust is an iconic and versatile timepiece with a date window. Known for its timeless design and reliability, it''s a symbol of Rolex''s watchmaking excellence.',
 'https://cdn.dummyjson.com/product-images/mens-watches/rolex-datejust/thumbnail.webp',
 'mens', 10999.99),

('Rolex Submariner Watch',
 'The Rolex Submariner is a legendary dive watch with a rich history. Known for its durability and water resistance, it''s a symbol of adventure and exploration.',
 'https://cdn.dummyjson.com/product-images/mens-watches/rolex-submariner-watch/thumbnail.webp',
 'mens', 13999.99),

-- ── womens-dresses ──────────────────────────────────────────
('Black Women''s Gown',
 'The Black Women''s Gown is an elegant and timeless evening gown. With a sleek black design, it''s perfect for formal events and special occasions, exuding sophistication and style.',
 'https://cdn.dummyjson.com/product-images/womens-dresses/black-women''s-gown/thumbnail.webp',
 'womens', 129.99),

('Corset Leather With Skirt',
 'The Corset Leather With Skirt is a bold and edgy ensemble that combines a stylish corset with a matching skirt. Ideal for fashion-forward individuals, it makes a statement at any event.',
 'https://cdn.dummyjson.com/product-images/womens-dresses/corset-leather-with-skirt/thumbnail.webp',
 'womens', 89.99),

('Corset With Black Skirt',
 'The Corset With Black Skirt is a chic and versatile outfit that pairs a fashionable corset with a classic black skirt. It offers a trendy and coordinated look for various occasions.',
 'https://cdn.dummyjson.com/product-images/womens-dresses/corset-with-black-skirt/thumbnail.webp',
 'womens', 79.99),

('Dress Pea',
 'The Dress Pea is a stylish and comfortable dress with a pea pattern. Perfect for casual outings, it adds a playful and fun element to your wardrobe, making it a great choice for day-to-day wear.',
 'https://cdn.dummyjson.com/product-images/womens-dresses/dress-pea/thumbnail.webp',
 'womens', 49.99),

('Marni Red & Black Suit',
 'The Marni Red & Black Suit is a sophisticated and fashion-forward suit ensemble. With a combination of red and black tones, it showcases a modern design for a bold and confident look.',
 'https://cdn.dummyjson.com/product-images/womens-dresses/marni-red-&-black-suit/thumbnail.webp',
 'womens', 179.99),

-- ── womens-bags ─────────────────────────────────────────────
('Blue Women''s Handbag',
 'The Blue Women''s Handbag is a stylish and spacious accessory for everyday use. With a vibrant blue color and multiple compartments, it combines fashion and functionality.',
 'https://cdn.dummyjson.com/product-images/womens-bags/blue-women''s-handbag/thumbnail.webp',
 'womens', 49.99),

('Heshe Women''s Leather Bag',
 'The Heshe Women''s Leather Bag is a luxurious and high-quality leather bag for the sophisticated woman. With a timeless design and durable craftsmanship, it''s a versatile accessory.',
 'https://cdn.dummyjson.com/product-images/womens-bags/heshe-women''s-leather-bag/thumbnail.webp',
 'womens', 129.99),

('Prada Women Bag',
 'The Prada Women Bag is an iconic designer bag that exudes elegance and luxury. Crafted with precision and featuring the Prada logo, it''s a statement piece for fashion enthusiasts.',
 'https://cdn.dummyjson.com/product-images/womens-bags/prada-women-bag/thumbnail.webp',
 'womens', 599.99),

('White Faux Leather Backpack',
 'The White Faux Leather Backpack is a trendy and practical backpack for the modern woman. With a sleek white design and ample storage space, it''s perfect for both casual and on-the-go styles.',
 'https://cdn.dummyjson.com/product-images/womens-bags/white-faux-leather-backpack/thumbnail.webp',
 'womens', 39.99),

('Women Handbag Black',
 'The Women Handbag in Black is a classic and versatile accessory that complements various outfits. With a timeless black color and functional design, it''s a must-have in every woman''s wardrobe.',
 'https://cdn.dummyjson.com/product-images/womens-bags/women-handbag-black/thumbnail.webp',
 'womens', 59.99),

-- ── womens-jewellery ────────────────────────────────────────
('Green Crystal Earring',
 'The Green Crystal Earring is a dazzling accessory that features a vibrant green crystal. With a classic design, it adds a touch of elegance to your ensemble, perfect for formal or special occasions.',
 'https://cdn.dummyjson.com/product-images/womens-jewellery/green-crystal-earring/thumbnail.webp',
 'womens', 29.99),

('Green Oval Earring',
 'The Green Oval Earring is a stylish and versatile accessory with a unique oval shape. Whether for casual or dressy occasions, its green hue and contemporary design make it a standout piece.',
 'https://cdn.dummyjson.com/product-images/womens-jewellery/green-oval-earring/thumbnail.webp',
 'womens', 24.99),

('Tropical Earring',
 'The Tropical Earring is a fun and playful accessory inspired by tropical elements. Featuring vibrant colors and a lively design, it''s perfect for adding a touch of summer to your look.',
 'https://cdn.dummyjson.com/product-images/womens-jewellery/tropical-earring/thumbnail.webp',
 'womens', 19.99),

-- ── womens-shoes ────────────────────────────────────────────
('Black & Brown Slipper',
 'The Black & Brown Slipper is a comfortable and stylish choice for casual wear. Featuring a blend of black and brown colors, it adds a touch of sophistication to your relaxation.',
 'https://cdn.dummyjson.com/product-images/womens-shoes/black-&-brown-slipper/thumbnail.webp',
 'womens', 19.99),

('Calvin Klein Heel Shoes',
 'Calvin Klein Heel Shoes are elegant and sophisticated, designed for formal occasions. With a classic design and high-quality materials, they complement your stylish ensemble.',
 'https://cdn.dummyjson.com/product-images/womens-shoes/calvin-klein-heel-shoes/thumbnail.webp',
 'womens', 79.99),

('Golden Shoes Woman',
 'The Golden Shoes for Women are a glamorous choice for special occasions. Featuring a golden hue and stylish design, they add a touch of luxury to your outfit.',
 'https://cdn.dummyjson.com/product-images/womens-shoes/golden-shoes-woman/thumbnail.webp',
 'womens', 49.99),

('Pampi Shoes',
 'Pampi Shoes offer a blend of comfort and style for everyday use. With a versatile design, they are suitable for various casual occasions, providing a trendy and relaxed look.',
 'https://cdn.dummyjson.com/product-images/womens-shoes/pampi-shoes/thumbnail.webp',
 'womens', 29.99),

('Red Shoes',
 'The Red Shoes make a bold statement with their vibrant red color. Whether for a party or a casual outing, these shoes add a pop of color and style to your wardrobe.',
 'https://cdn.dummyjson.com/product-images/womens-shoes/red-shoes/thumbnail.webp',
 'womens', 34.99),

-- ── womens-watches ──────────────────────────────────────────
('IWC Ingenieur Automatic Steel',
 'The IWC Ingenieur Automatic Steel watch is a durable and sophisticated timepiece. With a stainless steel case and automatic movement, it combines precision and style for watch enthusiasts.',
 'https://cdn.dummyjson.com/product-images/womens-watches/iwc-ingenieur-automatic-steel/thumbnail.webp',
 'womens', 4999.99),

-- DummyJSON має "Rolex Cellini Moonphase" і в mens-, і в womens-watches.
-- Суфікс " Women" зберігає унікальність назви для підзапиту FK.
('Rolex Cellini Moonphase Women',
 'The Rolex Cellini Moonphase watch is a masterpiece of horology. Featuring a moon phase complication, it showcases the craftsmanship and elegance that Rolex is renowned for.',
 'https://cdn.dummyjson.com/product-images/womens-watches/rolex-cellini-moonphase/thumbnail.webp',
 'womens', 15999.99),

('Rolex Datejust Women',
 'The Rolex Datejust Women''s watch is an iconic timepiece designed for women. With a timeless design and a date complication, it offers both elegance and functionality.',
 'https://cdn.dummyjson.com/product-images/womens-watches/rolex-datejust-women/thumbnail.webp',
 'womens', 10999.99),

('Watch Gold for Women',
 'The Gold Women''s Watch is a stunning accessory that combines luxury and style. Featuring a gold-plated case and a chic design, it adds a touch of glamour to any outfit.',
 'https://cdn.dummyjson.com/product-images/womens-watches/watch-gold-for-women/thumbnail.webp',
 'womens', 799.99),

('Women''s Wrist Watch',
 'The Women''s Wrist Watch is a versatile and fashionable timepiece for everyday wear. With a comfortable strap and a simple yet elegant design, it complements various styles.',
 'https://cdn.dummyjson.com/product-images/womens-watches/women''s-wrist-watch/thumbnail.webp',
 'womens', 129.99),

-- ── tops (gender = 'womens') ─────────────────────────────────
('Blue Frock',
 'The Blue Frock is a charming and stylish dress for various occasions. With a vibrant blue color and a comfortable design, it adds a touch of elegance to your wardrobe.',
 'https://cdn.dummyjson.com/product-images/tops/blue-frock/thumbnail.webp',
 'womens', 29.99),

('Girl Summer Dress',
 'The Girl Summer Dress is a cute and breezy dress designed for warm weather. With playful patterns and lightweight fabric, it''s perfect for keeping cool and stylish during the summer.',
 'https://cdn.dummyjson.com/product-images/tops/girl-summer-dress/thumbnail.webp',
 'womens', 19.99),

('Gray Dress',
 'The Gray Dress is a versatile and chic option for various occasions. With a neutral gray color, it can be dressed up or down, making it a wardrobe staple for any fashion-forward individual.',
 'https://cdn.dummyjson.com/product-images/tops/gray-dress/thumbnail.webp',
 'womens', 34.99),

('Short Frock',
 'The Short Frock is a playful and trendy dress with a shorter length. Ideal for casual outings or special occasions, it combines style and comfort for a fashionable look.',
 'https://cdn.dummyjson.com/product-images/tops/short-frock/thumbnail.webp',
 'womens', 24.99),

('Tartan Dress',
 'The Tartan Dress features a classic tartan pattern, bringing a timeless and sophisticated touch to your wardrobe. Perfect for fall and winter, it adds a hint of traditional charm.',
 'https://cdn.dummyjson.com/product-images/tops/tartan-dress/thumbnail.webp',
 'womens', 39.99),

-- ── sunglasses (gender = 'unisex') ───────────────────────────
('Black Sun Glasses',
 'The Black Sun Glasses are a classic and stylish choice, featuring a sleek black frame and tinted lenses. They provide both UV protection and a fashionable look.',
 'https://cdn.dummyjson.com/product-images/sunglasses/black-sun-glasses/thumbnail.webp',
 'unisex', 29.99),

('Classic Sun Glasses',
 'The Classic Sun Glasses offer a timeless design with a neutral frame and UV-protected lenses. These sunglasses are versatile and suitable for various occasions.',
 'https://cdn.dummyjson.com/product-images/sunglasses/classic-sun-glasses/thumbnail.webp',
 'unisex', 24.99),

('Green and Black Glasses',
 'The Green and Black Glasses feature a bold combination of green and black colors, adding a touch of vibrancy to your eyewear collection. They are both stylish and eye-catching.',
 'https://cdn.dummyjson.com/product-images/sunglasses/green-and-black-glasses/thumbnail.webp',
 'unisex', 34.99),

('Party Glasses',
 'The Party Glasses are designed to add flair to your party outfit. With unique shapes or colorful frames, they''re perfect for adding a playful touch to your look during celebrations.',
 'https://cdn.dummyjson.com/product-images/sunglasses/party-glasses/thumbnail.webp',
 'unisex', 19.99),

('Sunglasses',
 'The Sunglasses offer a classic and simple design with a focus on functionality. These sunglasses provide essential UV protection while maintaining a timeless look.',
 'https://cdn.dummyjson.com/product-images/sunglasses/sunglasses/thumbnail.webp',
 'unisex', 22.99);


-- =============================================================
-- ЧАСТИНА 2: VARIANTS
--
-- Формат рядка:
--   (product_id_subquery, size, color, stock)
--
-- Одяг    → size як рядок: 'S', 'M', 'L', 'XL'
-- Взуття  → size як рядок EU: '40', '41', '42', '43', '44', '45'
--           Реалізм: середні розміри 41-43 мають більший stock,
--                    крайні 40 і 45 — менший або 0.
-- Безрозмірні → size: NULL (без лапок!)
--               Один рядок на колір. Luxury items (Rolex, Prada)
--               мають свідомо низький stock (1-5 одиниць).
-- =============================================================

INSERT INTO variants (product_id, size, color, stock) VALUES

-- ════════════════════════════════════════════════════════════
-- ОДЯГ — розміри S / M / L / XL
-- ════════════════════════════════════════════════════════════

-- ── Blue & Black Check Shirt · Navy Blue / White ─────────────
((SELECT id FROM products WHERE name = 'Blue & Black Check Shirt'), 'S',  'Navy Blue', 7),
((SELECT id FROM products WHERE name = 'Blue & Black Check Shirt'), 'M',  'Navy Blue', 0),
((SELECT id FROM products WHERE name = 'Blue & Black Check Shirt'), 'L',  'Navy Blue', 19),
((SELECT id FROM products WHERE name = 'Blue & Black Check Shirt'), 'XL', 'Navy Blue', 5),
((SELECT id FROM products WHERE name = 'Blue & Black Check Shirt'), 'S',  'White', 12),
((SELECT id FROM products WHERE name = 'Blue & Black Check Shirt'), 'M',  'White', 28),
((SELECT id FROM products WHERE name = 'Blue & Black Check Shirt'), 'L',  'White', 0),
((SELECT id FROM products WHERE name = 'Blue & Black Check Shirt'), 'XL', 'White', 9),

-- ── Gigabyte Aorus Men Tshirt · Black / Grey ─────────────────
((SELECT id FROM products WHERE name = 'Gigabyte Aorus Men Tshirt'), 'S',  'Black', 15),
((SELECT id FROM products WHERE name = 'Gigabyte Aorus Men Tshirt'), 'M',  'Black', 22),
((SELECT id FROM products WHERE name = 'Gigabyte Aorus Men Tshirt'), 'L',  'Black', 0),
((SELECT id FROM products WHERE name = 'Gigabyte Aorus Men Tshirt'), 'XL', 'Black', 8),
((SELECT id FROM products WHERE name = 'Gigabyte Aorus Men Tshirt'), 'S',  'Grey', 6),
((SELECT id FROM products WHERE name = 'Gigabyte Aorus Men Tshirt'), 'M',  'Grey', 30),
((SELECT id FROM products WHERE name = 'Gigabyte Aorus Men Tshirt'), 'L',  'Grey', 11),
((SELECT id FROM products WHERE name = 'Gigabyte Aorus Men Tshirt'), 'XL', 'Grey', 0),

-- ── Man Plaid Shirt · Red Plaid / Blue Plaid ─────────────────
((SELECT id FROM products WHERE name = 'Man Plaid Shirt'), 'S',  'Red Plaid', 0),
((SELECT id FROM products WHERE name = 'Man Plaid Shirt'), 'M',  'Red Plaid', 14),
((SELECT id FROM products WHERE name = 'Man Plaid Shirt'), 'L',  'Red Plaid', 20),
((SELECT id FROM products WHERE name = 'Man Plaid Shirt'), 'XL', 'Red Plaid', 3),
((SELECT id FROM products WHERE name = 'Man Plaid Shirt'), 'S',  'Blue Plaid', 9),
((SELECT id FROM products WHERE name = 'Man Plaid Shirt'), 'M',  'Blue Plaid', 0),
((SELECT id FROM products WHERE name = 'Man Plaid Shirt'), 'L',  'Blue Plaid', 17),
((SELECT id FROM products WHERE name = 'Man Plaid Shirt'), 'XL', 'Blue Plaid', 25),

-- ── Man Short Sleeve Shirt · White / Light Blue ──────────────
((SELECT id FROM products WHERE name = 'Man Short Sleeve Shirt'), 'S',  'White', 18),
((SELECT id FROM products WHERE name = 'Man Short Sleeve Shirt'), 'M',  'White', 0),
((SELECT id FROM products WHERE name = 'Man Short Sleeve Shirt'), 'L',  'White', 7),
((SELECT id FROM products WHERE name = 'Man Short Sleeve Shirt'), 'XL', 'White', 13),
((SELECT id FROM products WHERE name = 'Man Short Sleeve Shirt'), 'S',  'Light Blue', 0),
((SELECT id FROM products WHERE name = 'Man Short Sleeve Shirt'), 'M',  'Light Blue', 22),
((SELECT id FROM products WHERE name = 'Man Short Sleeve Shirt'), 'L',  'Light Blue', 5),
((SELECT id FROM products WHERE name = 'Man Short Sleeve Shirt'), 'XL', 'Light Blue', 11),

-- ── Men Check Shirt · Khaki / Navy ───────────────────────────
((SELECT id FROM products WHERE name = 'Men Check Shirt'), 'S',  'Khaki', 16),
((SELECT id FROM products WHERE name = 'Men Check Shirt'), 'M',  'Khaki', 8),
((SELECT id FROM products WHERE name = 'Men Check Shirt'), 'L',  'Khaki', 0),
((SELECT id FROM products WHERE name = 'Men Check Shirt'), 'XL', 'Khaki', 24),
((SELECT id FROM products WHERE name = 'Men Check Shirt'), 'S',  'Navy', 0),
((SELECT id FROM products WHERE name = 'Men Check Shirt'), 'M',  'Navy', 12),
((SELECT id FROM products WHERE name = 'Men Check Shirt'), 'L',  'Navy', 19),
((SELECT id FROM products WHERE name = 'Men Check Shirt'), 'XL', 'Navy', 0),

-- ── Black Women's Gown · Black / Midnight Blue ────────────────
((SELECT id FROM products WHERE name = 'Black Women''s Gown'), 'S',  'Black', 6),
((SELECT id FROM products WHERE name = 'Black Women''s Gown'), 'M',  'Black', 0),
((SELECT id FROM products WHERE name = 'Black Women''s Gown'), 'L',  'Black', 14),
((SELECT id FROM products WHERE name = 'Black Women''s Gown'), 'XL', 'Black', 8),
((SELECT id FROM products WHERE name = 'Black Women''s Gown'), 'S',  'Midnight Blue', 0),
((SELECT id FROM products WHERE name = 'Black Women''s Gown'), 'M',  'Midnight Blue', 11),
((SELECT id FROM products WHERE name = 'Black Women''s Gown'), 'L',  'Midnight Blue', 3),
((SELECT id FROM products WHERE name = 'Black Women''s Gown'), 'XL', 'Midnight Blue', 20),

-- ── Corset Leather With Skirt · Black / Brown ─────────────────
((SELECT id FROM products WHERE name = 'Corset Leather With Skirt'), 'S',  'Black', 9),
((SELECT id FROM products WHERE name = 'Corset Leather With Skirt'), 'M',  'Black', 17),
((SELECT id FROM products WHERE name = 'Corset Leather With Skirt'), 'L',  'Black', 0),
((SELECT id FROM products WHERE name = 'Corset Leather With Skirt'), 'XL', 'Black', 5),
((SELECT id FROM products WHERE name = 'Corset Leather With Skirt'), 'S',  'Brown', 12),
((SELECT id FROM products WHERE name = 'Corset Leather With Skirt'), 'M',  'Brown', 0),
((SELECT id FROM products WHERE name = 'Corset Leather With Skirt'), 'L',  'Brown', 22),
((SELECT id FROM products WHERE name = 'Corset Leather With Skirt'), 'XL', 'Brown', 7),

-- ── Corset With Black Skirt · Black / Burgundy ────────────────
((SELECT id FROM products WHERE name = 'Corset With Black Skirt'), 'S',  'Black', 0),
((SELECT id FROM products WHERE name = 'Corset With Black Skirt'), 'M',  'Black', 15),
((SELECT id FROM products WHERE name = 'Corset With Black Skirt'), 'L',  'Black', 8),
((SELECT id FROM products WHERE name = 'Corset With Black Skirt'), 'XL', 'Black', 0),
((SELECT id FROM products WHERE name = 'Corset With Black Skirt'), 'S',  'Burgundy', 20),
((SELECT id FROM products WHERE name = 'Corset With Black Skirt'), 'M',  'Burgundy', 6),
((SELECT id FROM products WHERE name = 'Corset With Black Skirt'), 'L',  'Burgundy', 0),
((SELECT id FROM products WHERE name = 'Corset With Black Skirt'), 'XL', 'Burgundy', 13),

-- ── Dress Pea · Green Print / Blue Print ──────────────────────
((SELECT id FROM products WHERE name = 'Dress Pea'), 'S',  'Green Print', 18),
((SELECT id FROM products WHERE name = 'Dress Pea'), 'M',  'Green Print', 0),
((SELECT id FROM products WHERE name = 'Dress Pea'), 'L',  'Green Print', 10),
((SELECT id FROM products WHERE name = 'Dress Pea'), 'XL', 'Green Print', 25),
((SELECT id FROM products WHERE name = 'Dress Pea'), 'S',  'Blue Print', 7),
((SELECT id FROM products WHERE name = 'Dress Pea'), 'M',  'Blue Print', 14),
((SELECT id FROM products WHERE name = 'Dress Pea'), 'L',  'Blue Print', 0),
((SELECT id FROM products WHERE name = 'Dress Pea'), 'XL', 'Blue Print', 5),

-- ── Marni Red & Black Suit · Red & Black / White & Black ──────
((SELECT id FROM products WHERE name = 'Marni Red & Black Suit'), 'S',  'Red & Black', 4),
((SELECT id FROM products WHERE name = 'Marni Red & Black Suit'), 'M',  'Red & Black', 0),
((SELECT id FROM products WHERE name = 'Marni Red & Black Suit'), 'L',  'Red & Black', 11),
((SELECT id FROM products WHERE name = 'Marni Red & Black Suit'), 'XL', 'Red & Black', 17),
((SELECT id FROM products WHERE name = 'Marni Red & Black Suit'), 'S',  'White & Black', 0),
((SELECT id FROM products WHERE name = 'Marni Red & Black Suit'), 'M',  'White & Black', 8),
((SELECT id FROM products WHERE name = 'Marni Red & Black Suit'), 'L',  'White & Black', 23),
((SELECT id FROM products WHERE name = 'Marni Red & Black Suit'), 'XL', 'White & Black', 0),

-- ── Blue Frock · Blue / White ─────────────────────────────────
((SELECT id FROM products WHERE name = 'Blue Frock'), 'S',  'Blue', 11),
((SELECT id FROM products WHERE name = 'Blue Frock'), 'M',  'Blue', 0),
((SELECT id FROM products WHERE name = 'Blue Frock'), 'L',  'Blue', 19),
((SELECT id FROM products WHERE name = 'Blue Frock'), 'XL', 'Blue', 7),
((SELECT id FROM products WHERE name = 'Blue Frock'), 'S',  'White', 15),
((SELECT id FROM products WHERE name = 'Blue Frock'), 'M',  'White', 22),
((SELECT id FROM products WHERE name = 'Blue Frock'), 'L',  'White', 0),
((SELECT id FROM products WHERE name = 'Blue Frock'), 'XL', 'White', 5),

-- ── Girl Summer Dress · Pink / Yellow / White ─────────────────
((SELECT id FROM products WHERE name = 'Girl Summer Dress'), 'S',  'Pink', 14),
((SELECT id FROM products WHERE name = 'Girl Summer Dress'), 'M',  'Pink', 21),
((SELECT id FROM products WHERE name = 'Girl Summer Dress'), 'L',  'Pink', 0),
((SELECT id FROM products WHERE name = 'Girl Summer Dress'), 'XL', 'Pink', 8),
((SELECT id FROM products WHERE name = 'Girl Summer Dress'), 'S',  'Yellow', 0),
((SELECT id FROM products WHERE name = 'Girl Summer Dress'), 'M',  'Yellow', 17),
((SELECT id FROM products WHERE name = 'Girl Summer Dress'), 'L',  'Yellow', 9),
((SELECT id FROM products WHERE name = 'Girl Summer Dress'), 'XL', 'Yellow', 0),
((SELECT id FROM products WHERE name = 'Girl Summer Dress'), 'S',  'White', 25),
((SELECT id FROM products WHERE name = 'Girl Summer Dress'), 'M',  'White', 6),
((SELECT id FROM products WHERE name = 'Girl Summer Dress'), 'L',  'White', 0),
((SELECT id FROM products WHERE name = 'Girl Summer Dress'), 'XL', 'White', 13),

-- ── Gray Dress · Grey / Black ─────────────────────────────────
((SELECT id FROM products WHERE name = 'Gray Dress'), 'S',  'Grey', 12),
((SELECT id FROM products WHERE name = 'Gray Dress'), 'M',  'Grey', 0),
((SELECT id FROM products WHERE name = 'Gray Dress'), 'L',  'Grey', 24),
((SELECT id FROM products WHERE name = 'Gray Dress'), 'XL', 'Grey', 8),
((SELECT id FROM products WHERE name = 'Gray Dress'), 'S',  'Black', 0),
((SELECT id FROM products WHERE name = 'Gray Dress'), 'M',  'Black', 16),
((SELECT id FROM products WHERE name = 'Gray Dress'), 'L',  'Black', 5),
((SELECT id FROM products WHERE name = 'Gray Dress'), 'XL', 'Black', 19),

-- ── Short Frock · Pink / Mint ─────────────────────────────────
((SELECT id FROM products WHERE name = 'Short Frock'), 'S',  'Pink', 0),
((SELECT id FROM products WHERE name = 'Short Frock'), 'M',  'Pink', 14),
((SELECT id FROM products WHERE name = 'Short Frock'), 'L',  'Pink', 22),
((SELECT id FROM products WHERE name = 'Short Frock'), 'XL', 'Pink', 6),
((SELECT id FROM products WHERE name = 'Short Frock'), 'S',  'Mint', 18),
((SELECT id FROM products WHERE name = 'Short Frock'), 'M',  'Mint', 0),
((SELECT id FROM products WHERE name = 'Short Frock'), 'L',  'Mint', 10),
((SELECT id FROM products WHERE name = 'Short Frock'), 'XL', 'Mint', 7),

-- ── Tartan Dress · Red Tartan / Green Tartan ──────────────────
((SELECT id FROM products WHERE name = 'Tartan Dress'), 'S',  'Red Tartan', 9),
((SELECT id FROM products WHERE name = 'Tartan Dress'), 'M',  'Red Tartan', 0),
((SELECT id FROM products WHERE name = 'Tartan Dress'), 'L',  'Red Tartan', 16),
((SELECT id FROM products WHERE name = 'Tartan Dress'), 'XL', 'Red Tartan', 23),
((SELECT id FROM products WHERE name = 'Tartan Dress'), 'S',  'Green Tartan', 0),
((SELECT id FROM products WHERE name = 'Tartan Dress'), 'M',  'Green Tartan', 11),
((SELECT id FROM products WHERE name = 'Tartan Dress'), 'L',  'Green Tartan', 5),
((SELECT id FROM products WHERE name = 'Tartan Dress'), 'XL', 'Green Tartan', 0),


-- ════════════════════════════════════════════════════════════
-- ВЗУТТЯ — розміри EU '40' / '41' / '42' / '43' / '44' / '45'
-- Середні розміри (41-43) — більший stock.
-- Крайні (40, 45) — менший або 0.
-- ════════════════════════════════════════════════════════════

-- ── Nike Air Jordan 1 Red And Black · Red & Black / White & Black
((SELECT id FROM products WHERE name = 'Nike Air Jordan 1 Red And Black'), '40', 'Red & Black', 5),
((SELECT id FROM products WHERE name = 'Nike Air Jordan 1 Red And Black'), '41', 'Red & Black', 12),
((SELECT id FROM products WHERE name = 'Nike Air Jordan 1 Red And Black'), '42', 'Red & Black', 18),
((SELECT id FROM products WHERE name = 'Nike Air Jordan 1 Red And Black'), '43', 'Red & Black', 15),
((SELECT id FROM products WHERE name = 'Nike Air Jordan 1 Red And Black'), '44', 'Red & Black', 7),
((SELECT id FROM products WHERE name = 'Nike Air Jordan 1 Red And Black'), '45', 'Red & Black', 0),
((SELECT id FROM products WHERE name = 'Nike Air Jordan 1 Red And Black'), '40', 'White & Black', 0),
((SELECT id FROM products WHERE name = 'Nike Air Jordan 1 Red And Black'), '41', 'White & Black', 9),
((SELECT id FROM products WHERE name = 'Nike Air Jordan 1 Red And Black'), '42', 'White & Black', 20),
((SELECT id FROM products WHERE name = 'Nike Air Jordan 1 Red And Black'), '43', 'White & Black', 14),
((SELECT id FROM products WHERE name = 'Nike Air Jordan 1 Red And Black'), '44', 'White & Black', 8),
((SELECT id FROM products WHERE name = 'Nike Air Jordan 1 Red And Black'), '45', 'White & Black', 3),

-- ── Nike Baseball Cleats · Black / White ─────────────────────
((SELECT id FROM products WHERE name = 'Nike Baseball Cleats'), '40', 'Black', 3),
((SELECT id FROM products WHERE name = 'Nike Baseball Cleats'), '41', 'Black', 15),
((SELECT id FROM products WHERE name = 'Nike Baseball Cleats'), '42', 'Black', 22),
((SELECT id FROM products WHERE name = 'Nike Baseball Cleats'), '43', 'Black', 17),
((SELECT id FROM products WHERE name = 'Nike Baseball Cleats'), '44', 'Black', 0),
((SELECT id FROM products WHERE name = 'Nike Baseball Cleats'), '45', 'Black', 6),
((SELECT id FROM products WHERE name = 'Nike Baseball Cleats'), '40', 'White', 0),
((SELECT id FROM products WHERE name = 'Nike Baseball Cleats'), '41', 'White', 8),
((SELECT id FROM products WHERE name = 'Nike Baseball Cleats'), '42', 'White', 19),
((SELECT id FROM products WHERE name = 'Nike Baseball Cleats'), '43', 'White', 11),
((SELECT id FROM products WHERE name = 'Nike Baseball Cleats'), '44', 'White', 5),
((SELECT id FROM products WHERE name = 'Nike Baseball Cleats'), '45', 'White', 0),

-- ── Puma Future Rider Trainers · White / Grey / Black ─────────
((SELECT id FROM products WHERE name = 'Puma Future Rider Trainers'), '40', 'White', 7),
((SELECT id FROM products WHERE name = 'Puma Future Rider Trainers'), '41', 'White', 20),
((SELECT id FROM products WHERE name = 'Puma Future Rider Trainers'), '42', 'White', 25),
((SELECT id FROM products WHERE name = 'Puma Future Rider Trainers'), '43', 'White', 18),
((SELECT id FROM products WHERE name = 'Puma Future Rider Trainers'), '44', 'White', 9),
((SELECT id FROM products WHERE name = 'Puma Future Rider Trainers'), '45', 'White', 0),
((SELECT id FROM products WHERE name = 'Puma Future Rider Trainers'), '40', 'Grey', 0),
((SELECT id FROM products WHERE name = 'Puma Future Rider Trainers'), '41', 'Grey', 12),
((SELECT id FROM products WHERE name = 'Puma Future Rider Trainers'), '42', 'Grey', 16),
((SELECT id FROM products WHERE name = 'Puma Future Rider Trainers'), '43', 'Grey', 13),
((SELECT id FROM products WHERE name = 'Puma Future Rider Trainers'), '44', 'Grey', 0),
((SELECT id FROM products WHERE name = 'Puma Future Rider Trainers'), '45', 'Grey', 5),
((SELECT id FROM products WHERE name = 'Puma Future Rider Trainers'), '40', 'Black', 4),
((SELECT id FROM products WHERE name = 'Puma Future Rider Trainers'), '41', 'Black', 18),
((SELECT id FROM products WHERE name = 'Puma Future Rider Trainers'), '42', 'Black', 22),
((SELECT id FROM products WHERE name = 'Puma Future Rider Trainers'), '43', 'Black', 19),
((SELECT id FROM products WHERE name = 'Puma Future Rider Trainers'), '44', 'Black', 7),
((SELECT id FROM products WHERE name = 'Puma Future Rider Trainers'), '45', 'Black', 0),

-- ── Sports Sneakers Off White & Red · Off White & Red / Black & Red
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White & Red'), '40', 'Off White & Red', 0),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White & Red'), '41', 'Off White & Red', 11),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White & Red'), '42', 'Off White & Red', 17),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White & Red'), '43', 'Off White & Red', 13),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White & Red'), '44', 'Off White & Red', 5),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White & Red'), '45', 'Off White & Red', 0),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White & Red'), '40', 'Black & Red', 6),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White & Red'), '41', 'Black & Red', 14),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White & Red'), '42', 'Black & Red', 0),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White & Red'), '43', 'Black & Red', 16),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White & Red'), '44', 'Black & Red', 8),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White & Red'), '45', 'Black & Red', 2),

-- ── Sports Sneakers Off White Red · Off White / Charcoal ──────
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White Red'), '40', 'Off White', 5),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White Red'), '41', 'Off White', 16),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White Red'), '42', 'Off White', 21),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White Red'), '43', 'Off White', 14),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White Red'), '44', 'Off White', 0),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White Red'), '45', 'Off White', 3),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White Red'), '40', 'Charcoal', 0),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White Red'), '41', 'Charcoal', 10),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White Red'), '42', 'Charcoal', 18),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White Red'), '43', 'Charcoal', 12),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White Red'), '44', 'Charcoal', 6),
((SELECT id FROM products WHERE name = 'Sports Sneakers Off White Red'), '45', 'Charcoal', 0),

-- ── Black & Brown Slipper · Black & Brown / All Black ─────────
((SELECT id FROM products WHERE name = 'Black & Brown Slipper'), '40', 'Black & Brown', 8),
((SELECT id FROM products WHERE name = 'Black & Brown Slipper'), '41', 'Black & Brown', 0),
((SELECT id FROM products WHERE name = 'Black & Brown Slipper'), '42', 'Black & Brown', 15),
((SELECT id FROM products WHERE name = 'Black & Brown Slipper'), '43', 'Black & Brown', 11),
((SELECT id FROM products WHERE name = 'Black & Brown Slipper'), '44', 'Black & Brown', 6),
((SELECT id FROM products WHERE name = 'Black & Brown Slipper'), '45', 'Black & Brown', 0),
((SELECT id FROM products WHERE name = 'Black & Brown Slipper'), '40', 'All Black', 0),
((SELECT id FROM products WHERE name = 'Black & Brown Slipper'), '41', 'All Black', 13),
((SELECT id FROM products WHERE name = 'Black & Brown Slipper'), '42', 'All Black', 20),
((SELECT id FROM products WHERE name = 'Black & Brown Slipper'), '43', 'All Black', 17),
((SELECT id FROM products WHERE name = 'Black & Brown Slipper'), '44', 'All Black', 4),
((SELECT id FROM products WHERE name = 'Black & Brown Slipper'), '45', 'All Black', 0),

-- ── Calvin Klein Heel Shoes · Black / Nude ───────────────────
((SELECT id FROM products WHERE name = 'Calvin Klein Heel Shoes'), '40', 'Black', 6),
((SELECT id FROM products WHERE name = 'Calvin Klein Heel Shoes'), '41', 'Black', 14),
((SELECT id FROM products WHERE name = 'Calvin Klein Heel Shoes'), '42', 'Black', 0),
((SELECT id FROM products WHERE name = 'Calvin Klein Heel Shoes'), '43', 'Black', 12),
((SELECT id FROM products WHERE name = 'Calvin Klein Heel Shoes'), '44', 'Black', 5),
((SELECT id FROM products WHERE name = 'Calvin Klein Heel Shoes'), '45', 'Black', 0),
((SELECT id FROM products WHERE name = 'Calvin Klein Heel Shoes'), '40', 'Nude', 0),
((SELECT id FROM products WHERE name = 'Calvin Klein Heel Shoes'), '41', 'Nude', 9),
((SELECT id FROM products WHERE name = 'Calvin Klein Heel Shoes'), '42', 'Nude', 18),
((SELECT id FROM products WHERE name = 'Calvin Klein Heel Shoes'), '43', 'Nude', 15),
((SELECT id FROM products WHERE name = 'Calvin Klein Heel Shoes'), '44', 'Nude', 0),
((SELECT id FROM products WHERE name = 'Calvin Klein Heel Shoes'), '45', 'Nude', 4),

-- ── Golden Shoes Woman · Gold / Silver ───────────────────────
((SELECT id FROM products WHERE name = 'Golden Shoes Woman'), '40', 'Gold', 3),
((SELECT id FROM products WHERE name = 'Golden Shoes Woman'), '41', 'Gold', 11),
((SELECT id FROM products WHERE name = 'Golden Shoes Woman'), '42', 'Gold', 16),
((SELECT id FROM products WHERE name = 'Golden Shoes Woman'), '43', 'Gold', 13),
((SELECT id FROM products WHERE name = 'Golden Shoes Woman'), '44', 'Gold', 0),
((SELECT id FROM products WHERE name = 'Golden Shoes Woman'), '45', 'Gold', 5),
((SELECT id FROM products WHERE name = 'Golden Shoes Woman'), '40', 'Silver', 0),
((SELECT id FROM products WHERE name = 'Golden Shoes Woman'), '41', 'Silver', 8),
((SELECT id FROM products WHERE name = 'Golden Shoes Woman'), '42', 'Silver', 14),
((SELECT id FROM products WHERE name = 'Golden Shoes Woman'), '43', 'Silver', 10),
((SELECT id FROM products WHERE name = 'Golden Shoes Woman'), '44', 'Silver', 0),
((SELECT id FROM products WHERE name = 'Golden Shoes Woman'), '45', 'Silver', 3),

-- ── Pampi Shoes · White / Beige / Pink ───────────────────────
((SELECT id FROM products WHERE name = 'Pampi Shoes'), '40', 'White', 7),
((SELECT id FROM products WHERE name = 'Pampi Shoes'), '41', 'White', 18),
((SELECT id FROM products WHERE name = 'Pampi Shoes'), '42', 'White', 22),
((SELECT id FROM products WHERE name = 'Pampi Shoes'), '43', 'White', 16),
((SELECT id FROM products WHERE name = 'Pampi Shoes'), '44', 'White', 0),
((SELECT id FROM products WHERE name = 'Pampi Shoes'), '45', 'White', 5),
((SELECT id FROM products WHERE name = 'Pampi Shoes'), '40', 'Beige', 0),
((SELECT id FROM products WHERE name = 'Pampi Shoes'), '41', 'Beige', 12),
((SELECT id FROM products WHERE name = 'Pampi Shoes'), '42', 'Beige', 19),
((SELECT id FROM products WHERE name = 'Pampi Shoes'), '43', 'Beige', 14),
((SELECT id FROM products WHERE name = 'Pampi Shoes'), '44', 'Beige', 8),
((SELECT id FROM products WHERE name = 'Pampi Shoes'), '45', 'Beige', 0),
((SELECT id FROM products WHERE name = 'Pampi Shoes'), '40', 'Pink', 4),
((SELECT id FROM products WHERE name = 'Pampi Shoes'), '41', 'Pink', 15),
((SELECT id FROM products WHERE name = 'Pampi Shoes'), '42', 'Pink', 0),
((SELECT id FROM products WHERE name = 'Pampi Shoes'), '43', 'Pink', 13),
((SELECT id FROM products WHERE name = 'Pampi Shoes'), '44', 'Pink', 6),
((SELECT id FROM products WHERE name = 'Pampi Shoes'), '45', 'Pink', 2),

-- ── Red Shoes · Red / Black ───────────────────────────────────
((SELECT id FROM products WHERE name = 'Red Shoes'), '40', 'Red', 0),
((SELECT id FROM products WHERE name = 'Red Shoes'), '41', 'Red', 10),
((SELECT id FROM products WHERE name = 'Red Shoes'), '42', 'Red', 17),
((SELECT id FROM products WHERE name = 'Red Shoes'), '43', 'Red', 14),
((SELECT id FROM products WHERE name = 'Red Shoes'), '44', 'Red', 5),
((SELECT id FROM products WHERE name = 'Red Shoes'), '45', 'Red', 0),
((SELECT id FROM products WHERE name = 'Red Shoes'), '40', 'Black', 6),
((SELECT id FROM products WHERE name = 'Red Shoes'), '41', 'Black', 19),
((SELECT id FROM products WHERE name = 'Red Shoes'), '42', 'Black', 23),
((SELECT id FROM products WHERE name = 'Red Shoes'), '43', 'Black', 16),
((SELECT id FROM products WHERE name = 'Red Shoes'), '44', 'Black', 0),
((SELECT id FROM products WHERE name = 'Red Shoes'), '45', 'Black', 7),


-- ════════════════════════════════════════════════════════════
-- БЕЗРОЗМІРНІ — size: NULL
-- Один рядок на колір. Luxury items мають свідомо низький stock.
-- ════════════════════════════════════════════════════════════

-- ── Brown Leather Belt Watch · Brown / Black ──────────────────
((SELECT id FROM products WHERE name = 'Brown Leather Belt Watch'), NULL, 'Brown', 14),
((SELECT id FROM products WHERE name = 'Brown Leather Belt Watch'), NULL, 'Black', 9),

-- ── Longines Master Collection · Silver / Gold (luxury) ───────
((SELECT id FROM products WHERE name = 'Longines Master Collection'), NULL, 'Silver', 4),
((SELECT id FROM products WHERE name = 'Longines Master Collection'), NULL, 'Gold', 2),

-- ── Rolex Cellini Date Black Dial · Silver / Gold ─────────────
((SELECT id FROM products WHERE name = 'Rolex Cellini Date Black Dial'), NULL, 'Silver', 2),
((SELECT id FROM products WHERE name = 'Rolex Cellini Date Black Dial'), NULL, 'Gold', 1),

-- ── Rolex Cellini Moonphase · Silver / Gold ───────────────────
((SELECT id FROM products WHERE name = 'Rolex Cellini Moonphase'), NULL, 'Silver', 1),
((SELECT id FROM products WHERE name = 'Rolex Cellini Moonphase'), NULL, 'Gold', 3),

-- ── Rolex Datejust · Silver / Black Dial ─────────────────────
((SELECT id FROM products WHERE name = 'Rolex Datejust'), NULL, 'Silver', 3),
((SELECT id FROM products WHERE name = 'Rolex Datejust'), NULL, 'Black Dial', 2),

-- ── Rolex Submariner Watch · Steel & Black / Steel & Blue ─────
((SELECT id FROM products WHERE name = 'Rolex Submariner Watch'), NULL, 'Steel & Black', 4),
((SELECT id FROM products WHERE name = 'Rolex Submariner Watch'), NULL, 'Steel & Blue', 2),

-- ── IWC Ingenieur Automatic Steel · Silver / Black ────────────
((SELECT id FROM products WHERE name = 'IWC Ingenieur Automatic Steel'), NULL, 'Silver', 5),
((SELECT id FROM products WHERE name = 'IWC Ingenieur Automatic Steel'), NULL, 'Black', 3),

-- ── Rolex Cellini Moonphase Women · Silver / Rose Gold ────────
((SELECT id FROM products WHERE name = 'Rolex Cellini Moonphase Women'), NULL, 'Silver', 2),
((SELECT id FROM products WHERE name = 'Rolex Cellini Moonphase Women'), NULL, 'Rose Gold', 1),

-- ── Rolex Datejust Women · Silver / Gold ─────────────────────
((SELECT id FROM products WHERE name = 'Rolex Datejust Women'), NULL, 'Silver', 3),
((SELECT id FROM products WHERE name = 'Rolex Datejust Women'), NULL, 'Gold', 2),

-- ── Watch Gold for Women · Gold / Rose Gold ───────────────────
((SELECT id FROM products WHERE name = 'Watch Gold for Women'), NULL, 'Gold', 7),
((SELECT id FROM products WHERE name = 'Watch Gold for Women'), NULL, 'Rose Gold', 5),

-- ── Women's Wrist Watch · Silver / Black / Rose Gold ──────────
((SELECT id FROM products WHERE name = 'Women''s Wrist Watch'), NULL, 'Silver', 12),
((SELECT id FROM products WHERE name = 'Women''s Wrist Watch'), NULL, 'Black', 8),
((SELECT id FROM products WHERE name = 'Women''s Wrist Watch'), NULL, 'Rose Gold', 15),

-- ── Blue Women's Handbag · Blue / Black ──────────────────────
((SELECT id FROM products WHERE name = 'Blue Women''s Handbag'), NULL, 'Blue', 18),
((SELECT id FROM products WHERE name = 'Blue Women''s Handbag'), NULL, 'Black', 11),

-- ── Heshe Women's Leather Bag · Brown / Black / Tan ───────────
((SELECT id FROM products WHERE name = 'Heshe Women''s Leather Bag'), NULL, 'Brown', 14),
((SELECT id FROM products WHERE name = 'Heshe Women''s Leather Bag'), NULL, 'Black', 9),
((SELECT id FROM products WHERE name = 'Heshe Women''s Leather Bag'), NULL, 'Tan', 7),

-- ── Prada Women Bag · Black / Beige (luxury) ──────────────────
((SELECT id FROM products WHERE name = 'Prada Women Bag'), NULL, 'Black', 3),
((SELECT id FROM products WHERE name = 'Prada Women Bag'), NULL, 'Beige', 2),

-- ── White Faux Leather Backpack · White / Black ───────────────
((SELECT id FROM products WHERE name = 'White Faux Leather Backpack'), NULL, 'White', 20),
((SELECT id FROM products WHERE name = 'White Faux Leather Backpack'), NULL, 'Black', 15),

-- ── Women Handbag Black · Black / Brown ──────────────────────
((SELECT id FROM products WHERE name = 'Women Handbag Black'), NULL, 'Black', 16),
((SELECT id FROM products WHERE name = 'Women Handbag Black'), NULL, 'Brown', 10),

-- ── Green Crystal Earring · Green / Blue ─────────────────────
((SELECT id FROM products WHERE name = 'Green Crystal Earring'), NULL, 'Green', 22),
((SELECT id FROM products WHERE name = 'Green Crystal Earring'), NULL, 'Blue', 14),

-- ── Green Oval Earring · Green / Gold ────────────────────────
((SELECT id FROM products WHERE name = 'Green Oval Earring'), NULL, 'Green', 18),
((SELECT id FROM products WHERE name = 'Green Oval Earring'), NULL, 'Gold', 25),

-- ── Tropical Earring · Multicolor / Pink ─────────────────────
((SELECT id FROM products WHERE name = 'Tropical Earring'), NULL, 'Multicolor', 30),
((SELECT id FROM products WHERE name = 'Tropical Earring'), NULL, 'Pink', 22),

-- ── Black Sun Glasses · Black / Smoke ────────────────────────
((SELECT id FROM products WHERE name = 'Black Sun Glasses'), NULL, 'Black', 25),
((SELECT id FROM products WHERE name = 'Black Sun Glasses'), NULL, 'Smoke', 17),

-- ── Classic Sun Glasses · Brown / Tortoise / Black ───────────
((SELECT id FROM products WHERE name = 'Classic Sun Glasses'), NULL, 'Brown', 19),
((SELECT id FROM products WHERE name = 'Classic Sun Glasses'), NULL, 'Tortoise', 12),
((SELECT id FROM products WHERE name = 'Classic Sun Glasses'), NULL, 'Black', 22),

-- ── Green and Black Glasses · Green & Black / All Black ───────
((SELECT id FROM products WHERE name = 'Green and Black Glasses'), NULL, 'Green & Black', 14),
((SELECT id FROM products WHERE name = 'Green and Black Glasses'), NULL, 'All Black', 20),

-- ── Party Glasses · Blue / Pink ───────────────────────────────
((SELECT id FROM products WHERE name = 'Party Glasses'), NULL, 'Blue', 16),
((SELECT id FROM products WHERE name = 'Party Glasses'), NULL, 'Pink', 11),

-- ── Sunglasses · Black / Brown ────────────────────────────────
((SELECT id FROM products WHERE name = 'Sunglasses'), NULL, 'Black', 23),
((SELECT id FROM products WHERE name = 'Sunglasses'), NULL, 'Brown', 18);

-- =============================================================
-- Кінець файлу. Підсумок:
--   products  : 49 рядків (без змін)
--   variants  : 307 рядків
--     одяг        → 124 рядки (15 товарів × 4 розміри × 2-3 кольори)
--     взуття      → 132 рядки (10 товарів × 6 EU-розмірів × 2-3 кольори)
--     безрозмірні →  51 рядок (24 товари × 2-3 кольори, size = NULL)
-- =============================================================
