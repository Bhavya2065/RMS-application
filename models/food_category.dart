import 'product.dart';

final Map<String, List<Product>> foodCategories = {
  'Punjabi Food': [
    Product(
      name: 'Paneer Butter Masala',
      image: 'assets/images/img_1.png',
      price: '175',
      description: 'A delicious Indian curry with soft paneer cubes simmered in a rich, buttery tomato-based gravy.',
      discount: '10',
    ),
    Product(
      name: 'Paneer Tikka Masala',
      image: 'assets/images/img_2.png',
      price: '250',
      description: 'Paneer Tikka Masala is a popular Indian curry where cubes of paneer (Indian cottage cheese), onions and peppers are marinated with yogurt and spices, grilled and then tossed in a creamy tomato based curry. This dish goes extremely well with butter naan or paratha or basmati rice.',
      discount: '20',
    ),
    Product(
      name: 'Aloo Paratha',
      image: 'assets/images/img_3.png',
      price: '100',
      description: 'Aloo Paratha is a popular Indian flatbread stuffed with a spiced potato filling. It is a staple in many North Indian homes and restaurants, often enjoyed for breakfast or dinner.',
      discount: '5',
    ),
  ],
  'South Indian Food': [
    Product(
      name: 'Dosa',
      image: 'assets/images/img_4.png',
      price: '150',
      description: 'Dosa is a thin, crispy or soft savory crepe made from a fermented batter of ground black gram and rice. It is a popular breakfast and snack food in South India and Sri Lanka.',
      discount: '10',
    ),
    Product(
      name: 'Vada',
      image: 'assets/images/img_6.png',
      price: '50',
      description: 'Medu Vada is a popular South Indian breakfast snack made from Vigna mungo (black lentil). It is usually made in a doughnut shape, with a crispy exterior and soft interior. A popular food item in South Indian cuisine it is generally eaten as a breakfast or a snack.',
      discount: '3',
    ),
    Product(
      name: 'Idli',
      image: 'assets/images/img_5.png',
      price: '80',
      description: 'Idli is a savory, steamed rice cake that originated in South India. It is a popular breakfast food in South India and Sri Lanka.',
      discount: '5',
    ),
  ],
  'Italian Food': [
    Product(
      name: 'Margherita Pizza',
      image: 'assets/images/img_7.png',
      price: '300',
      description: 'Margherita Pizza is a classic Italian pizza made with simple, fresh ingredients like tomato sauce, mozzarella cheese, and fresh basil leaves, typically served on a thin and crispy crust.',
      discount: '15',
    ),
    Product(
      name: 'Manchurian',
      image: 'assets/images/img_8.png',
      price: '250',
      description: 'Manchurian is a class of Indian Chinese dishes made by roughly chopping and deep-frying ingredients such as chicken, cauliflower (gobi), prawns, fish, mutton, and paneer, and then sautéeing them in a sauce flavored with soy sauce.',
      discount: '7',
    ),
    Product(
      name: 'Tiramisu',
      image: 'assets/images/img_9.png',
      price: '200',
      description: 'Tiramisu is an Italian dessert made of ladyfinger pastries dipped in coffee, layered with a whipped mixture of egg yolks, sugar, and mascarpone, and flavored with cocoa powder.',
      discount: '5',
    ),
  ],
};