# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# clean current data
CartItem.destroy_all
Cart.destroy_all
User.destroy_all
Product.destroy_all

# create admin user
User.create!({ name: 'admin', email: 'admin@shopify.com', balance: '99999', password: 'admin99', password_confirmation: 'admin99', admin: true })
Cart.create!({ user_id: 1 })

# populate products
Product.create!([{
  title: 'Fried Chicken',
  price: '132.14',
  inventory_count: 3
},
{
  title: 'Baked Chicken',
  price: '232.14',
  inventory_count: 2
},
{
  title: 'Steam Chicken',
  price: '32.14',
  inventory_count: 10
}])
