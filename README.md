# Rivu

Efficient transaction management and tracking.

## Always wanted to create this application where i can maintain my expenses and subs with different banking cards and accounts.

### I will be adding more features which are written down in projects notebook

### I choose Provider as a state management solution for this application because of the simplicity and its a small project so no need to go overboard with MVVM which i mainly use in my large apps

### Used supabase because i just like working with it and have knowledge of postgresQL. Also don't need to worry about auth and storage as it includes all the necessary features.

## Features

- **User Authentication:** Secure user authentication powered by **Supabase**. Users can sign up and sign in to manage their data.
- **Transaction Management:**
  - Ability to record and manage financial transactions.
  - Support for adding descriptions, amounts (using `Decimal` for precision), and associated stores.
  - **Receipt Image Uploads:** Users can attach receipt images to their transactions.
- **Item Management:** Generic dialogs (`ManageItemsDialog`, `ManageItemsBottomSheet`) for creating, reading, updating, and deleting (`CRUD`) various items like stores or categories, promoting reusable UI components.
- **State Management:** Utilizes the **Provider** package with `ChangeNotifier` to efficiently manage the application's state, particularly for authentication (`AuthProvider`) and transaction data (`TransactionProvider`).

## Architecture and Logic

The application follows a modular architecture using the Provider pattern for state management:

- **`lib/auth_provider.dart`**: Handles all user authentication logic, including sign-up, sign-in, and managing the current user session with Supabase. It exposes the authentication state to the rest of the app via a `ChangeNotifier`.
- **`lib/transaction_provider.dart`** (inferred): Manages the application's transaction data, likely handling creation, retrieval, updating, and deletion of transactions.
- **`lib/models/transaction.dart` & `lib/models/store.dart`**: Define the data structures for transactions and stores within the application.
- **`lib/widgets/transaction_form.dart`**: A key UI component for entering and modifying transaction details, showcasing "progressive-disclosure UX patterns" to allow quick logging and later refinement. It also integrates image picking for receipts.
- **`lib/widgets/manage_items_dialog.dart`**: A reusable widget designed for generic CRUD operations on various lists of items (e.g., managing stores or transaction categories).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Custom made assets using Figma and canva for gifs and short mp4 videos
