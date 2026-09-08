# baby_shop_hub
# BabyShopHub

## Overview

BabyShopHub is a Flutter-based mobile e-commerce application designed to provide parents and caregivers with a convenient platform for discovering and purchasing baby products.

The application provides an organized shopping experience where users can browse baby products by category, search for products, view product information, manage their shopping cart, and proceed through the ordering process.

## Purpose

The purpose of BabyShopHub is to simplify the process of finding and purchasing essential baby products through a user-friendly mobile application.

The application is designed to provide a convenient, accessible, and reliable shopping experience for parents and caregivers.

## Key Features

* User registration and authentication
* User profile management
* Product categories
* Product search
* Product details
* Shopping cart management
* Checkout and order processing
* Order history and tracking
* Product reviews and ratings
* Seller ratings
* Admin product management
* User and order management
* Customer support and feedback

## Requirements

Before running BabyShopHub, ensure the following are installed:

* Flutter SDK
* Dart SDK compatible with the project requirements
* Android Studio with Android SDK and an Android emulator, or a physical Android device
* Visual Studio Code or another Flutter-compatible IDE
* Git

## Installation

### 1. Clone the Repository

Clone the BabyShopHub repository from GitHub:

```bash
git clone https://github.com/flobaba1/BabyShopHub.git
```

Navigate into the project directory:

```bash
cd BabyShopHub
```

### 2. Install Dependencies

Run the following command to download the project's Flutter dependencies:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 3. Check Flutter Setup

Run:

```bash
flutter doctor
```

Resolve any required Flutter, Android SDK, or device configuration issues before running the application.

## Running the Application

### 1. Start an Android Emulator

Open Android Studio and start an Android emulator, or connect a physical Android device with USB debugging enabled.

### 2. Check Available Devices

From the BabyShopHub project directory, run:

```bash
flutter devices
```

Ensure that a connected Android device or emulator is detected.

### 3. Run the Application

Run the following command:

```bash
flutter run
```

The BabyShopHub application will build and launch on the selected device.

### 4. Select a Specific Device

If more than one device is available, use:

```bash
flutter run -d <device-id>
```

Replace `<device-id>` with the ID shown by `flutter devices`.

## Application Workflow

When the application is launched, users are guided through the following workflow:

1. **Onboarding** – Introduces users to BabyShopHub and its main purpose.
2. **Registration/Login** – New users can create an account, while existing users can log in.
3. **Home** – Users can access the main shopping features of the application.
4. **Categories** – Users can browse products based on different baby product categories.
5. **Product Browsing** – Users can search for products and view their details.
6. **Shopping Cart** – Users can add products to their cart, update quantities, or remove products.
7. **Checkout** – Users can review their order and proceed with the checkout process.
8. **Orders** – Users can view their orders and their order status.
9. **Profile** – Users can manage their account information and other profile details.

## Database

BabyShopHub is a prototype application connected to a remotely hosted MySQL database for storing and managing application data.

The database is used to support the application's data requirements, including user information, product information, orders, and other relevant application data.

### Database Configuration

The project requires the appropriate database connection configuration before it can be fully operated.

Database credentials and other sensitive connection details are not included in the public GitHub repository. They should be provided and configured separately through the project's environment configuration.

> **Note:** Do not commit database passwords, credentials, or other sensitive configuration details to GitHub.


## User Guide

This section provides instructions for users on how to navigate and use the main features of BabyShopHub.

### 1. Getting Started

Launch the BabyShopHub application and follow the onboarding screens to learn about the application.

### 2. Creating an Account

Select the registration option and provide the required personal information. Submit the registration form to create an account.

### 3. Logging In

Enter your registered email and password on the login screen and select the login option to access your account.

### 4. Browsing Products

From the main application interface, users can browse available baby products and select a category to find products of interest.

### 5. Searching for Products

Use the search feature to find products by entering relevant product information in the search field.

### 6. Viewing Product Details

Select a product to view its available information, such as its image, description, price, and other relevant details.

### 7. Managing the Shopping Cart

Add products to the shopping cart. Users can review the items in the cart, update quantities, or remove items before checkout.

### 8. Checkout

Review the selected products and order information, then proceed through the checkout process to place an order.

### 9. Managing Orders

Users can access the orders section to view their order history and available order information.

### 10. Managing the Profile

Users can access their profile to view and manage their account information.

### 11. Support and Feedback

Users can use the available support or feedback features to report issues, request assistance, or provide feedback about the application.






