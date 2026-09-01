class Product {
  final String image;
  final String badge;
  final String badgeColor;
  final String brand;
  final String name;
  final String rating;
  final String reviews;
  final String price;
  final String oldPrice;
  final String discount;

  const Product({
    required this.image,
    required this.badge,
    required this.badgeColor,
    required this.brand,
    required this.name,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.oldPrice,
    required this.discount,
  });
}

const List<Product> products = [
  Product(
    image: 'assets/Diapers.png',
    badge: 'Best Seller',
    badgeColor: 'orange',
    brand: 'HUGGIES',
    name: 'Huggies Little Snugglers Diapers',
    rating: '★★★★★',
    reviews: '2,341',
    price: '\$24.99',
    oldPrice: '\$32.99',
    discount: '-24%',
  ),

  Product(
    image: 'assets/Image_Pampers.png',
    badge: 'Top Rated',
    badgeColor: 'orange',
    brand: 'PAMPERS',
    name: 'Pampers Swaddlers Sensitive',
    rating: '★★★★★',
    reviews: '3,932',
    price: '\$29.99',
    oldPrice: '\$36.99',
    discount: '-19%',
  ),

  Product(
    image: 'assets/Image_Baby Food.png',
    badge: 'Organic',
    badgeColor: 'green',
    brand: 'GERBER',
    name: 'Gerber Organic 1st Foods Baby Food',
    rating: '★★★★★',
    reviews: '1,204',
    price: '\$8.99',
    oldPrice: '\$11.99',
    discount: '-25%',
  ),

  Product(
    image: 'assets/Image_Infant Formula.png',
    badge: 'Organic',
    badgeColor: 'green',
    brand: 'HIPP',
    name: 'HiPP Organic Infant Formula Stage 1',
    rating: '★★★★★',
    reviews: '876',
    price: '\$42.99',
    oldPrice: '\$52.99',
    discount: '-19%',
  ),

  Product(
    image: 'assets/Image_Bodysuits.png',
    badge: 'Sale',
    badgeColor: 'red',
    brand: "CARTER'S",
    name: "Carter's 5-Pack Cotton Bodysuits",
    rating: '★★★★★',
    reviews: '5,621',
    price: '\$19.99',
    oldPrice: '\$28.99',
    discount: '-31%',
  ),

  Product(
    image: 'assets/Image_Knitted Baby Sweater Set.png',
    badge: 'New',
    badgeColor: 'blue',
    brand: 'PETIT BATEAU',
    name: 'Knitted Baby Sweater Set',
    rating: '★★★★★',
    reviews: '891',
    price: '\$34.99',
    oldPrice: '\$44.99',
    discount: '-22%',
  ),
];
