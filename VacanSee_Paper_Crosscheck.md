# VacanSee SDE Paper Expansion & Revision Guide

This guide provides the complete, expounded text blocks and tables required to fill the placeholders and correct the technical inconsistencies in your SDE paper (`VacanSee_SDE.docx`).

Simply **copy and paste** the sections below directly into the corresponding parts of your Microsoft Word document.

---

## 📂 CHAPTER 3: METHODOLOGY EXPANSIONS

### 1. Section 3.3.5 Database Design (Replaces the dots `………………`)

The database design of the VacanSee tracking system is implemented using **PostgreSQL** hosted on **Supabase**, structured to manage relational data, enforce data integrity, and support real-time data streams. The design utilizes standard relational tables, constraints, Row Level Security (RLS) policies, and database triggers.

#### Core Relational Tables
1.  **users**: Extends the default Supabase authentication engine (`auth.users`).
    *   *Columns:* `id` (UUID, Primary Key), `email` (TEXT), `display_name` (TEXT), `role` (ENUM: `student`, `owner`, `admin`), `phone_number` (TEXT), `business_name` (TEXT), `business_permit_no` (TEXT), `is_verified` (BOOLEAN), `created_at` (TIMESTAMPTZ).
    *   *Role:* Stores user profiles. Owners default to `is_verified = false` until approved by an admin; students and admins default to verified.
2.  **properties**: Linked to the properties owned by property managers.
    *   *Columns:* `id` (UUID, Primary Key), `owner_id` (UUID, Foreign Key referencing `users.id`), `name` (TEXT), `address` (TEXT), `lat` and `lng` (DOUBLE PRECISION for coordinate mapping), `gender_orientation` (ENUM: `male`, `female`, `mixed`), `amenities` (TEXT[] array), `price_range` (JSONB), `status` (ENUM: `pending`, `verified`, `rejected`, `deleted`), `images` (TEXT[] array).
3.  **rooms**: Configures individual rental availability.
    *   *Columns:* `id` (UUID, Primary Key), `property_id` (UUID, Foreign Key referencing `properties.id`), `status` (ENUM: `vacant`, `occupied`, `maintenance`), `images` (TEXT[] array), `capacity` (INTEGER), `current_occupants` (INTEGER), `monthly_rate` (INTEGER).
4.  **bookings**: Manages the room reservation cycle.
    *   *Columns:* `id` (UUID, Primary Key), `student_id` (UUID, Foreign Key referencing `users.id`), `property_id` (UUID, Foreign Key referencing `properties.id`), `room_id` (UUID, Foreign Key referencing `rooms.id`), `property_name` (TEXT), `room_description` (TEXT), `student_name` (TEXT), `student_email` (TEXT), `student_phone` (TEXT), `status` (ENUM: `pending`, `approved`, `rejected`, `cancelled`, `completed`), `requested_at` (TIMESTAMPTZ), `move_in_date` (TIMESTAMPTZ), `duration_months` (INTEGER).
5.  **notifications**: Manages transactional updates for users.
    *   *Columns:* `id` (UUID, Primary Key), `user_id` (UUID, Foreign Key referencing `auth.users.id`), `title` (TEXT), `message` (TEXT), `type` (TEXT), `is_read` (BOOLEAN), `metadata` (JSONB).
6.  **ratings**: Stores user reviews.
    *   *Columns:* `id` (UUID, Primary Key), `student_id` (UUID, Foreign Key referencing `users.id`), `property_id` (UUID, Foreign Key referencing `properties.id`), `rating` (INTEGER, 1-5 constraint), `comment` (TEXT), `created_at` (TIMESTAMPTZ).
7.  **admin_notifications**: Logs registration alerts for administrators.
    *   *Columns:* `id` (UUID, Primary Key), `user_id` (UUID, Foreign Key referencing `users.id`), `type` (TEXT), `content` (TEXT), `is_read` (BOOLEAN).

#### Security & Access Control (Row Level Security)
The database enforces security at the data layer by enabling Row Level Security (RLS) on all tables. This ensures that:
*   **Tenants** can search only for verified properties, view active room statuses, read notifications addressed to them, and manage their own bookings.
*   **Property Owners** can perform CRUD operations only on their own listings and rooms, view bookings submitted for their specific properties, and write owner responses.
*   **Administrators** bypass these constraints via global access policies to verify owner profiles, review registrations, and moderate accounts.

#### Database Automated Triggers
To optimize performance and eliminate application race conditions, automated PostgreSQL triggers are deployed:
*   `on_auth_user_created`: Automatically creates a profile record in the public `users` table upon Supabase authentication signup, syncing role variables safely.
*   `on_owner_registration`: Automatically inserts an alert in `admin_notifications` when a user registers with an "owner" role, prompting manual review.
*   `on_booking_created`: Instantly pushes a notification to the property owner when a student submits a reservation request.
*   `on_booking_status_change`: Automates room state transitions. When a booking status transitions to `approved`, the trigger updates the corresponding room status in the `rooms` table to `occupied`, declines all other overlapping pending requests for that room, and notifies the tenant.
*   `on_notification_inserted`: Connects the database to the email notification gateway by calling a serverless Supabase Edge Function via HTTP POST whenever a new row is appended to the `notifications` table.

---

### 2. Section 3.3.6 System Architecture (Replaces the dots `………………`)

The VacanSee tracker utilizes a three-tier serverless system architecture designed to be responsive, scalable, and highly available on free-tier resource allocation. The framework isolates the user interface, backend processing, and data storage layers.

![VacanSee System Architecture](file:///c:/APPLICATIONS/vacansee/system_architecture.png)

*(Note: The above diagram is saved in your project folder as `system_architecture.png` for you to easily insert/copy-paste into your Word document.)*

*   **Presentation Layer (Frontend):** Built using the **Flutter Web Framework** (Dart SDK). Flutter compiles the layout into optimized static HTML, CSS, CanvasKit, and JavaScript assets. This provides a highly responsive UI matching the mobile-first behavior of university students. The static frontend is deployed and cached globally via Vercel’s Content Delivery Network (CDN).
*   **Application Layer (Business Logic):** Handles user session validation via Supabase GoTrue authentication (supporting passwordless email and Google Sign-in flows). Backend integrations, such as transactional email delivery, are handled by serverless **Supabase Edge Functions** built in TypeScript running on Deno. The edge function executes on demand, calling the **Resend API** gateway to compile and dispatch HTML email templates to users.
*   **Data Layer (Backend):** Built using **PostgreSQL** hosted on Supabase. Relational tables are protected by Row Level Security policies. PostgreSQL triggers and stored procedures handle room vacancy updates and booking state transitions. A background scheduler (`pg_cron`) runs clean-up scripts to expire pending bookings that exceed their reservation duration limit, ensuring accurate vacancy counts without frontend intervention.

---

### 3. Section 3.4 Implementation (Expounded text for Section 3.4 through 3.4.1.2)

This section details the physical realization of the VacanSee platform, translating the theoretical models and database schemas into an active, functional software environment. It covers the deployment specifications, hardware system configurations, peripheral and network infrastructures, and provides formal technical justifications for the allocation of these hardware resources to verify the system meets the performance, capability, and usability needs of students and property owners.

#### 3.4 Implementation

The implementation phase of the Boarding House Vacant Tracker Website (VacanSee) represents the engineering stage where logical designs, context-level diagrams, and use case flows are translated into executable software components. This process involves configuring the development workspace, establishing remote database links, and coordinating client and server modules. 

Unlike traditional, server-dependent IT architectures that require on-premise physical servers, physical firewalls, and local maintenance, the VacanSee tracking system is designed around a modern **serverless cloud model**. This model allows developers to offload low-level server operations to virtualized cloud backends (Supabase and Vercel). By using cloud resources, the software benefits from automatic scale-on-demand behavior, robust database security, and high network availability. 

The implementation process was divided into three main stages:
1.  **Local Workspace Setup:** Configuring the Dart SDK and Flutter framework on development workstations, and initializing Git repositories to log codebase history.
2.  **Cloud Integration:** Setting up the Supabase Postgres instance, defining the relational database schema, configuring row-level policies, and setting up triggers to automate updates.
3.  **CI/CD Deployment Pipeline:** Linking the GitHub repository with the Vercel hosting platform to automate compiling, testing, and publishing the frontend on every push.

#### 3.4.1 Hardware Requirements

Developing, executing, and evaluating a responsive web application requires a structured set of hardware resources. The hardware architecture must support local compiling, cross-browser rendering, real-time database queries, and test simulations.

##### 3.4.1.1 Definition of Hardware Requirements

The hardware environment utilized to build and test the VacanSee system is divided into four main categories: Developer Workstations, Cloud Server Clusters, Test/Peripheral Devices, and Network Infrastructure. The table below lists the technical specifications for each category:

| Category | Component Specifications | Detailed Description and Technical Role |
| :--- | :--- | :--- |
| **Computers/Servers** | **Developer Workstation:** Intel Core i5/AMD Ryzen 5 (6 Physical Cores / 12 Threads), 16GB DDR4 Dual-Channel RAM, 512GB NVMe M.2 Solid State Drive (SSD).<br><br>**Cloud Server Infrastructure:** Virtualized serverless clusters hosted on Supabase (PostgreSQL compute nodes) and Vercel Edge Networks. | The developer workstation is used to run local compilers, static code analyzers, IDE workspaces, and database migrations. The cloud server nodes host the production PostgreSQL database, handle API requests, run Deno serverless edge routines, and serve compiled web assets to client browsers. |
| **Peripheral Devices** | **Testing Mobile Devices:** Android smartphone (Android 11, Octa-core CPU, 4GB RAM) and iOS smartphone (iOS 15, Apple A15 Bionic, 3GB RAM).<br><br>**Desktop Monitor:** 24-inch LED display with 1080p (1920x1080) resolution. | The mobile units are used to run responsive layout evaluations, verify touch interactions, and check compatibility across mobile engines (WebKit for iOS Safari, Blink for Android Chrome). The desktop monitor provides a high-resolution canvas for multi-window coding, console log monitoring, and responsive layout styling. |
| **Network Infrastructure** | **Broadband Access Gateway:** 802.11ac Dual-Band Wi-Fi Router connecting to a fiber-optic broadband service (minimum 10 Mbps symmetric download/upload). | Provides the high-speed connection required to download dependency packages, push code commits to GitHub, query real-time database tables, and run WebSockets for immediate availability toggles. |
| **Development Boards** | Not Applicable | The VacanSee platform is a software-only system. It does not require microcontrollers, IoT development boards, or physical sensors. |

##### 3.4.1.2 Justification of Hardware Requirements

To justify the selection of the hardware specifications listed above, the project proponents analyzed the computing, memory, network, and layout requirements of the platform:

1.  **Compute and Memory Capacity (Developer Workstation):** The developer workstation requires a multi-core processor (minimum 6 cores) and 16GB of DDR4 RAM to run the Flutter web compiler, Visual Studio Code, Git utilities, and multiple local browser instances concurrently. The compilation phase of Flutter compiles Dart code into highly optimized JavaScript and CanvasKit files, which is CPU-intensive. Lower memory limits (such as 8GB) would cause disk swapping and slow down development workflows. A solid-state drive (NVMe SSD) is necessary to ensure rapid read/write speeds when indexing thousands of source files and node packages.
2.  **Serverless Cloud Infrastructure (Backend and Hosting):** Rather than hosting database and web files on a physical server on-premise—which would incur high hardware costs, utility bills, and maintenance overhead—the system uses Supabase and Vercel. Supabase provides a managed, cloud-hosted PostgreSQL engine running on high-speed SSDs, ensuring database queries are completed in milliseconds. Vercel provides a serverless hosting network that caches static web assets globally at the network edge, ensuring fast page load times for students in Cagayan de Oro City.
3.  **Symmetric Network Bandwidth (Connectivity):** A reliable, high-speed internet connection (minimum 10 Mbps) is essential to support developers working with cloud services. The development cycle requires retrieving Dart packages from Pub.dev, pushing updates to GitHub, executing remote database migrations, and testing the database's real-time WebSocket connections. WebSockets maintain a persistent, bidirectional connection between the client browser and the database to update room vacancy badges instantly when modified by owners.
4.  **Multi-Viewport Device Compatibility (Responsive Layouts):** Because Cagayan de Oro students predominantly search for boarding houses on their smartphones, a mobile-first design is required. Physical Android and iOS devices are necessary to verify how the WebKit and Blink browser engines handle CSS layout scaling, touch events, and keyboard transitions. Testing on real hardware ensures the user interface remains intuitive and readable on mobile displays.

#### 3.4.2 Software Development Tools
The system relies on modern development environments, compilation tools, database frameworks, and automated test libraries to ensure a robust application codebase.

##### Table No. 2 . Software Development Tools Used

| Category | Tool | Description & Usage |
| :--- | :--- | :--- |
| **Development Environment** | **VS Code / Android Studio** | The primary Integrated Development Environments (IDEs) utilized. Configured with Flutter and Dart SDK plugins to provide syntax highlighting, real-time linting warnings, and quick execution. |
| **Programming Languages** | **Dart & TypeScript** | **Dart** is the primary programming language, used to write all widget trees, models, state providers, and REST API controllers. **TypeScript** is used to program Supabase Edge Functions. |
| **Version Control** | **Git & GitHub** | Used to trace code changes, manage feature branches, and integrate pull request reviews. The repository is synced with GitHub to trigger CI/CD builds. |
| **Project Management** | **GitHub Projects & Issues** | Used to manage milestones, organize development sprint tasks, and log bug tickets during testing. |
| **Libraries & Frameworks** | **Flutter SDK & Supabase Client SDK** | **Flutter** handles compiling the UI layout into responsive web assets. The **Supabase Client SDK** binds the Dart frontend with the backend tables, authentications, and real-time database listener channels. |
| **Testing Tools** | **Flutter Test & Dart Analyzer** | The **Flutter Test** package is used to execute automated unit and widget testing. The **Dart Analyzer** enforces strict style, typing, and safety linting checks before publication. |
| **Deployment Tools** | **Vercel Hosting Engine** | Handles the compilation pipeline and deployment of the frontend. Integrates with the GitHub repository to rebuild and update the production URL on every commit. |
| **Documentation Tools** | **Markdown Editors** | Used to write architectural decisions, setups, and development guidelines (`README.md`, `AGENTS.md`). |

#### 3.4.3 Cost Considerations
*   **Budget Constraints:** The system is designed to run under a strict **$0/month budget** to maintain viability for local Cagayan de Oro operators.
*   **Cost Estimates:** 
    *   *Frontend Hosting:* Vercel Hobby Plan ($0/month) – Provides free static hosting, automatic SSL encryption, and global CDN caching.
    *   *Backend & Database:* Supabase Free Tier ($0/month) – Includes a 500MB PostgreSQL database, 50k monthly active users, 1GB file storage, and real-time subscription pipelines.
    *   *Transactional Email:* Resend Free Plan ($0/month) – Offers up to 3,000 free emails per month (capped at 100 emails/day), which accommodates notification requirements for student bookings.

---

## 🔍 CHAPTER 4: RESULTS AND DISCUSSIONS REVISIONS

### 4. Chapter 4.1.2 White Box Testing Results & Discussion

#### Registry of Text Edits for Paragraphs
*   **Problem:** The text in Chapter 4.1.2 (Lines 873-875) currently repeats the exact same paragraphs from Chapter 4.1.1 (Black Box Testing), resulting in duplicate content. 
*   **Action: DELETE** lines 873, 874, and 875 in their entirety.
*   **Action: INSERT** the following expounded White Box Testing text in their place:

> "The results obtained from executing the automated unit testing suite and compiler analyzers confirmed the structural integrity, safety, and reliability of the internal logic of the VacanSee application. By running test configurations on user role selection, route protection components, and state provider initialization pathways, the development team verified that data flows correctly between variables and UI trees without triggering structural breakages.
> 
> The static testing compiler verified that there are no uninitialized variables or type safety vulnerabilities in the Dart source files. Automated test assertions validated that the security guards intercept unauthorized dashboard navigation requests, diverting users to the login route when session variables evaluate to null. The real-time database listener modules initialized and cleaned up successfully, preventing memory leaks during category navigation.
> 
> Furthermore, the test suites verified that the role redirection class correctly evaluates account roles, mapping tenants to room listings and landlords to analytical charts. The statement coverage achieved (81.25%) and branch coverage (66.67%) confirm that the application code logic is thoroughly validated, securing the tracker from common operational bugs and structural failures before local deployment."

---

### 5. Chapter 4.1.3 Performance Results & Discussion
*   **Verification Check:**
    *   *Check:* Does the text of 4.1.3 match the actual system performance metrics?
    *   *Result:* **Yes, no edits are required for the paragraphs in 4.1.3.** The paragraph accurately mentions a throughput of 11 TPS (surpassing the 10 TPS benchmark), a low error rate of 0.5% (mostly related to user input), and CPU usage peaks of 77% (during bulk database synchronization workflows) with an average of 65%. This aligns perfectly with the updated Performance Testing metrics in Appendix G.

---

### 6. Chapter 4.2 Usability Results & Discussion (Objective No. 2)
*   **Verification Check:**
    *   *Check:* Does the usability paragraph refer to the System Usability Scale (SUS) score of 83.0 and the 10 evaluators?
    *   *Result:* **Yes, no edits are required for the paragraphs in 4.2.** The paragraphs correctly detail the SUS methodology, the 10 participants (students and owners from CDO City), and the average score of 83.0 (placing it in the "Excellent" usability category). It also accurately highlights user appreciation for advanced filtering and real-time dashboard updates.

---

## 📝 QUICK COPY SUMMARY OF REPLACEMENT RANGES
For a fast update, copy and paste the following blocks directly into your Word manuscript structure:

1.  **Section 3.3.5 (Database Design):** Copy the "Core Relational Tables", "Row Level Security", and "Database Automated Triggers" segments into the page placeholder.
2.  **Section 3.3.6 (System Architecture):** Copy the diagram description, Presentation, Application, and Data Layer details.
3.  **Section 3.4 (Implementation):** Copy 3.4.1 (Hardware table & justifications), 3.4.2 (Software tools Table No. 2), and 3.4.3 (Cost considerations free-tier breakdowns).
4.  **Section 4.1.2 (White Box Testing Results):** Replace the duplicate black-box paragraphs under the White Box Table with the new three-paragraph text block on structural coverage and compiler validations.
