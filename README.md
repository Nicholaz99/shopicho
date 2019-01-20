Shopicho
&middot;
[![GitLab license](https://img.shields.io/github/license/Day8/re-frame.svg)](LICENSE)
=====
> Shopping is an activity in which a customer browses the available goods or services presented by one or more retailers with the potential intent to purchase a suitable selection of them. A typology of shopper types has been developed by scholars which identifies one group of shoppers as recreational shoppers, that is, those who enjoy shopping and view it as a leisure activity.

## Table Of Contents
- [Introduction](#introduction)
- [Main Features](#main-features)
- [Requirements](#requirements)
- [Run Shopicho](#run-shopicho)
- [Details of Shopicho](#details-of-shopicho)
- [Authors](#authors)
- [Words From Authors](#words-from-authors)
- [List of Endpoints](#list-of-endpoints)

## Introduction
This is the implementation of the barebones of an online marketplace. A server-side web API that can help you build your own online shop. Shopicho was built using **Ruby on Rails** framework.

## Main Features
A few of notable things you can do with Shopicho API:
* Register as a new user
* View available products
* Add products to your shopping cart
* Checkout your cart
* and many more

## Requirements
These are the list of prerequisites those I used:
* Ruby 2.5.3
* Rails 5.2.2
* Bundler2.0.1

## Run Shopicho
Follow these steps to run Shopicho on your local:
1. Make sure you have already fulfilled the requirements.
2. Install all the dependencies with `bundle install`.
3. Execute `rails db:migrate` on your shell to migrate the database.
4. Execute `rails db:seed` on your shell to seed the database.
5. Execute `rails s` on your shell to run the API server on your local.
6. Read the endpoint documentation on the [List of Endpoints](#list-of-endpoints) in order to use Shopicho properly.

## Details of Shopicho
- [**Authentication**](#authentication)
- [**Model**](#model)
- [**Controller**](#controller)
- [**Unit Testing**](#unit-testing)

### Authentication
Shopicho use Token-based Authentication (also known as JSON Web Token) as a way of handling the authentication of users in Shopicho. Token-based authentication is stateless - it does not store anything on the server but creates a unique encoded token that gets checked every time a request is made. This is the JsonWebToken that I create to handle the authentication of users in Shopicho.
```ruby
# lib/json_web_token.rb
class JsonWebToken
  class << self
    def encode(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, Rails.application.credentials.secret_key_base)
    end
 
    def decode(token)
      body = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
      HashWithIndifferentAccess.new body
    rescue
      nil
    end
  end
 end
```
* **encode**: generate the JWT using user_id and Rails secret_key as the payload.
* **decode**: receive JWT and decode it to get the user_id value.

In order to simplify every request authentication using this JWT, I create a class `AuthorizeApiRequest (app/commands/authorize_api_request.rb)` that works like a middleware on every request. This class will use the JWT library to validate the token, whether the token is missing, invalid, or valid. This class will return the current `User` object.

### Model
There are four models those are used on the Shopicho
1. [User](#user)
2. [Product](#product)
3. [Cart](#cart)
4. [CartItem](#cartitem)

#### User
These are the User attributes :
* id: integer
* name: string
* email: string
* password_digest: string
* balance: decimal
* created_at: timestamp
* updated_at: timestamp
* admin: boolean

*Notes:*
User use `has_secure_password` to store user's password as a BCrypt Password. There is admin role that has privileges to CRUD every models in Shopicho. The relationship between User model and Cart model is **one-to-many**.

#### Product
These are the Product attributes :
* id: integer
* title: string
* price: decimal
* inventory_count: integer
* created_at: timestamp
* updated_at: timestamp

*Notes:*
The relationship between Product and CartItem is **one-to-many**.


#### Cart
These are the Cart attributes :
* id: integer
* checkout: booolean
* user_id: integer
* total_amount: decimal
* created_at: timestamp
* updated_at: timestamp

*Notes:*
Cart has checkout attribute to indicate whether Users have paid their cart or haven't paid yet. The relationship between Cart model and CartItem model is **one-to-many**

#### CartItem
These are the CartItem attributes :
* id: integer
* cart_id: integer
* product_id: integer
* price: decimal
* quantity: integer
* created_at: timestamp
* updated_at: timestamp

*Notes:*
I include price column in the CartItem model. My reason why I include it is there is a chance that we want to change the price of products from time to time in the Products model, but we do not want those changes to affect the price already paid for previous orders. By adding the Price column, we will not face a problem when there is a change of price in some products, especially when we want to create an audit trail reports. The relationship between CartItem model and Cart model is **many-to-one**.

### Controller
Every model controllers jobs are to make sure that users could not violate constraints of every features those are stated at [List of Endpoints](#list-of-endpoints) in order to make sure that Shopicho works properly. Controllers also controls the Shopicho authentication flows by running some checker / middleware on every request that Shopicho received.

### Unit Testing
In order to run the unit testing, execute `bundle exec rspec` in your shell. I create 159 examples to make sure that my endpoints were working well. You can check all the unit testing in `spec` folder. I've tried to make it as humanly as possible so that everyone could understand all test cases with their intended behaviors.

## Authors
Nicholas Rianto Putra - nicholasrputra@gmail.com - https://github.com/nicholaz99

## Words from Authors
Thanks to Shopify Careers for your amazing [Summer 2019 Developer Intern Challenge](https://docs.google.com/document/d/1J49NAOIoWYOumaoQCKopPfudWI_jsQWVKlXmw1f1r-4/preview). Your challenge gives me the opportunity to improve my software engineering skills. I learn a lot by doing your amazing challenge, just like your Director of Engineering words.
> *"Shopify gives me the opportunity to continually grow and discover my strengths, technically and people-wise."*
> *, IBK Ajila — Director of Engineering Shopify*

## List of Endpoints
These are the available endpoints on Shopicho with the explanations.

Available to every user

Name | URL | Method | Params | Constraint
--- | --- | --- | --- | ---
Register New User | /users | POST | <li>name: string</li><li>email: string</li><li>balance: decimal</li><li>password: string</li><li>password_confirmation: string</li> | <li>User is not allowed to register as an admin</li>
Login | /login | POST | <li>email: string</li><li>password: string</li> | 
View User Detail | /users/:id | GET | | <li>Authorization: JWT</li><li>Normal Users are not allowed to view other users details</li><li>Admin is allowed to view any users details</li>
Update User Detail | /users/:id | PUT | <li>name: string</li><li>email: string</li><li>balance: decimal</li><li>password: string</li><li>password_confirmation: string</li> | <li>Authorization: JWT</li><li>Normal Users are not allowed to update other users details</li><li>Admin is allowed to update any users details</li><li>You don't need to update all params, just choose the details you want to change</li>
Delete User | /users/:id | DELETE | | <li>Authorization: JWT</li><li>Normal Users are not allowed to delete other users</li><li>Admin is allowed to delete any users</li>
View Available Products | /products | GET | | <li>Authorization: JWT</li><li>Products with inventory_count = 0 is not showed</li>
View Product Detail | /products/:id | GET | | <li>Authorization: JWT</li><li>Products with inventory_count = 0 is not showed</li>
View User Carts | /carts | GET | | <li>Authorization: JWT</li>
View User Cart Detail | /carts/:id | GET | | <li>Authorization: JWT</li><li>Normal Users are not allowed to view other users carts</li><li>Admin is allowed to view any users carts</li>
View User Cart Items | /carts/:id/cart_items | GET | | <li>Authorization: JWT</li><li>Normal Users are not allowed to view other users cart items</li><li>Admin is allowed to view any users cart items</li>
Add Items to Cart | /carts/:id/cart_items | POST | <li>product_id: integer</li><li>quantity: integer</li> | <li>Authorization: JWT</li><li>Normal Users are not allowed to add item to other users carts</li><li>Admin is allowed to add items to any users carts</li><li>Quantity params must be less or equal than product inventory_count</li><li>if CartItem belongs to user cart with same product_id exists, rather than add a new cart item, this method will update the quantity of that cartItem</li><li>Cart total_amount get updated</li>
Update Cart Items | /carts/:id/cart_items/:item_id | PUT | <li>quantity: integer</li> | <li>Authorization: JWT</li><li>Normal Users are not allowed to update other users cart items</li><li>Admin is allowed to update any users cart items</li><li>Quantity params must be less or equal than product inventory_count</li><li>Cart total_amount get updated</li>
Remove Cart Items | /carts/:id/cart_items/:item_id | DELETE | | <li>Authorization: JWT</li><li>Normal Users are not allowed to remove other users cart items</li><li>Admin is allowed to remove any users cart items</li><li>Cart total_amount get updated</li>
Checkout Cart | /carts/:id | PUT | | <li>Authorization: JWT</li><li>Normal Users are not allowed to checkout other users carts</li><li>Admin is allowed to checkout any users carts</li><li>User balance must be greater or equal than cart total_amount</li><li>Controller will make sure that every cart item is not out of stock</li>
View All Users (Admin Only) | /users | GET | | <li>Authorization: JWT</li><li>Only Admin can view all existing users</li>
Add New Product (Admin Only) | /products | POST | <li>title: string</li><li>price: decimal</li><li>inventory_count: integer</li> | <li>Authorization: JWT</li><li>Only Admin can add new product</li>
Update Product Detail (Admin Only) | /products/:id | PUT | <li>title: string</li><li>price: decimal</li><li>inventory_count: integer</li> | <li>Authorization: JWT</li><li>Only Admin can update new product</li><li>You don't need to update all params, just choose the details you want to change</li>
Update Product Detail (Admin Only) | /products/:id | DELETE | | <li>Authorization: JWT</li><li>Only Admin can delete product</li>
