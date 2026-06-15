# Server Driven UI Demo

## Overview

This project implements a server-driven form renderer using SwiftUI. The UI is generated dynamically from a JSON configuration and supports multiple field types, validation rules, theming, and graceful handling of unknown field types.

### Supported Components

* Text Field
* Multiline Text
* Secure Text
* Number Input
* URL Input
* Single Select Dropdown
* Multi Select Dropdown
* Toggle
* Checkbox

The application is driven entirely by the JSON payload, allowing form structure, validation rules, and styling to be modified without changing the UI layer.

---

## Running the Project

### Requirements

* Xcode 16+
* iOS 18+

### Steps

1. Open the project in Xcode.
2. Select an iOS Simulator.
3. Build and run the application.
4. The bundled sample JSON file will be loaded automatically.

No additional setup is required.

---

## Architecture Overview

The project follows a simple MVVM architecture.

### Models

The model layer mirrors the JSON schema and uses polymorphic decoding through the `FieldType` enum.

A `FormField` acts as a wrapper around `FieldType`, allowing shared properties such as `id`, `label`, `required`, and `order` to be accessed directly without repeatedly switching on enum cases.

### State Management

Form state is stored using a single `FieldValue` enum:

```swift
enum FieldValue {
    case text(String)
    case dropdown([String])
    case toggle(Bool)
    case checkbox(Bool)
}
```

This keeps all form state in one place and simplifies validation and submission handling.

### ViewModel

`FormViewModel` acts as the single source of truth and is responsible for:

* Loading and decoding JSON
* Managing form state
* Providing bindings to views
* Validation
* Submission formatting

### Views

The rendering layer consists of:

* FormView
* DynamicFieldView
* Individual field components

Each field component is intentionally presentation-focused and receives bindings from the ViewModel.

---

## Technical Decisions

### Unknown Field Types

Unknown field types decode into a `.unknown` case and are ignored during rendering.

This prevents crashes when the server sends a field type the client does not yet support.

### Defensive Decoding

Optional and non-critical values are decoded using safe defaults where appropriate.

Examples include:

* Missing text subtype defaults to `.plain`
* Missing dropdown options default to an empty array
* Missing default values default to an empty array
* Missing required flags default to `false`

This allows the application to handle imperfect payloads gracefully.

### Centralized Validation

Validation logic lives entirely in the ViewModel.

Views are responsible only for displaying state and validation feedback.

### Theme Injection

Theme values are decoded from JSON and injected through a custom SwiftUI environment value, avoiding the need to pass theme information through every view.

---

## Product Decisions

### `order` Is Treated As Required

The assignment explicitly requires fields to be rendered according to their order.

A field without an order value is considered invalid configuration data, so decoding is allowed to fail rather than silently rendering fields unpredictably.

### Regex Validation Fails Open

If the server provides an invalid regex pattern, validation is allowed to pass.

Blocking users because of malformed server configuration would create a worse experience than accepting the input.

### Toggle Fields Always Validate

A toggle is always in a valid state because it has a defined boolean value (`true` or `false`).

For that reason toggle fields are never treated as invalid.

### Optional Fields With Regex Rules

Regex validation only runs when the field contains a value.

An empty optional field is considered valid.

---

## Known Limitations

### Multi-Select Dropdown

The multi-select dropdown uses a lightweight custom implementation designed for a take-home assignment.

A production application would likely use a more sophisticated selection experience.

### No Persistence

Form state is not persisted between launches.

### Client-Side Validation Only

Validation is performed entirely on-device and is not verified by a backend service.

---

## Future Improvements

* Unit tests for decoding and validation
* UI tests for dynamic rendering
* Focus management using `@FocusState`
* Enhanced accessibility support
* Form state persistence
* Additional field types such as date pickers and radio groups

---

## AI Collaboration

AI was used as a design and implementation aid throughout the project.

Areas where AI assistance was used include:

* Architecture discussions
* Model design reviews
* Validation strategy discussions
* SwiftUI implementation suggestions
* Documentation drafting

Final architectural and implementation decisions were reviewed and adjusted before being incorporated into the project.

See `AI_COLLABORATION_LOG.md` for the complete collaboration history.
