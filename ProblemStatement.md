# Global Library Dimensional Modeling Exercise

## 1. Domain Context

A global library platform operates across multiple countries and cities. Members can borrow physical items from any branch and must return them to the **same branch**.

The platform supports:

- Books
- Magazines
- Journals

Each borrowed item represents a **physical copy** identified by a unique barcode.

The operational system contains following member data:

- Member name
- Email
- Phone number
- Address
- Membership ID

---

## 2. Business Goals

Libraries want analytics on:

- Borrowing trends
- Inventory usage and circulation
- Fines and delays
- Regional reading behavior
- Revenue generated from fines and rentals
- Currency-normalized global reporting

---

## 3. Key Domain Rules

- A **borrow transaction (bill)** can contain multiple items
- Each borrowed item:
  - Has its own due date
  - May have a different return date
  - Can incur a different fine or rental fee
- Items must be returned to the **same branch**
- Branches exist across multiple:
  - Countries
  - States/Provinces
  - Cities
- Each branch operates in a **local currency**

---

## 5. Currency and Revenue Context

Libraries generate revenue from:

- Late return fines
- Premium rental items

Challenges:

- Multi-currency data (INR, USD, EUR, JPY)
- Local vs global reporting
- FX conversion timing (borrow date vs return date)

You should assume:

- Each branch records revenue in **local currency**
- Finance wants reporting in **USD standard currency**

---

## 6. Sample Borrow Bill (Enhanced)

**Borrow ID:** B1001\
**Member:** Amol Gaikwad\
**Email:** [amol@example.com](mailto\:amol@example.com)\
**Phone:** +91-9876543210\
**Branch:** Pune Central Library\
**Location:** Pune, Maharashtra, India\
**Currency:** INR\
**Borrow Date:** 1 Jan 2026

| Item | Product Line | Title                   | Barcode | Due Date | Returned On | Rental Fee | Fine | Currency |
| ---- | ------------ | ----------------------- | ------- | -------- | ----------- | ---------- | ---- | -------- |
| 1    | Book         | Clean Code              | BC101   | 15 Jan   | 14 Jan      | 100        | 0    | INR      |
| 2    | Book         | Domain-Driven Design    | BC205   | 15 Jan   | 20 Jan      | 150        | 50   | INR      |
| 3    | Magazine     | National Geographic Jan | MG330   | 7 Jan    | 7 Jan       | 50         | 0    | INR      |

---

## 7. Sample Borrow Dataset (50 Rows)

Columns:

- Borrow ID
- Member Name (PII)
- Email (PII)
- Phone (PII)
- Product Line
- Title
- Barcode
- Branch
- City
- State/Province
- Country
- Currency
- Borrow Date
- Due Date
- Return Date
- Rental Fee (Local)
- Fine (Local)

> Note: NULL return dates indicate items not yet returned.

| Borrow ID | Member | Email                                        | Phone   | Product Line | Title              | Barcode | Branch           | City     | State            | Country | Curr | Borrow | Due    | Return | Rental | Fine |
| --------- | ------ | -------------------------------------------- | ------- | ------------ | ------------------ | ------- | ---------------- | -------- | ---------------- | ------- | ---- | ------ | ------ | ------ | ------ | ---- |
| B1001     | Amol   | [amol@example.com](mailto\:amol@example.com) | +91-111 | Book         | Clean Code         | BC101   | Pune Central     | Pune     | Maharashtra      | India   | INR  | 1 Jan  | 15 Jan | 14 Jan | 0      | 0    |
| B1001     | Amol   | [amol@example.com](mailto\:amol@example.com) | +91-111 | Book         | DDD                | BC205   | Pune Central     | Pune     | Maharashtra      | India   | INR  | 1 Jan  | 15 Jan | 20 Jan | 0      | 50   |
| B1001     | Amol   | [amol@example.com](mailto\:amol@example.com) | +91-111 | Magazine     | NatGeo Jan         | MG330   | Pune Central     | Pune     | Maharashtra      | India   | INR  | 1 Jan  | 7 Jan  | 7 Jan  | 10     | 0    |
| B1002     | Sarah  | [sarah@us.com](mailto\:sarah@us.com)         | +1-222  | Book         | Dune               | US778   | Austin Public    | Austin   | Texas            | USA     | USD  | 3 Jan  | 17 Jan | 16 Jan | 0      | 0    |
| B1002     | Sarah  | [sarah@us.com](mailto\:sarah@us.com)         | +1-222  | Journal      | AI Monthly         | JR900   | Austin Public    | Austin   | Texas            | USA     | USD  | 3 Jan  | 10 Jan | 15 Jan | 5      | 30   |
| B1003     | Kenji  | [kenji@jp.com](mailto\:kenji@jp.com)         | +81-333 | Book         | Kafka on Shore     | JP991   | Tokyo East       | Tokyo    | Tokyo Prefecture | Japan   | JPY  | 5 Jan  | 19 Jan | 28 Jan | 0      | 300  |
| B1004     | Lars   | [lars@de.com](mailto\:lars@de.com)           | +49-444 | Book         | Sapiens            | DE551   | Berlin Mitte     | Berlin   | Berlin           | Germany | EUR  | 6 Jan  | 20 Jan | NULL   | 0      | 0    |
| B1004     | Lars   | [lars@de.com](mailto\:lars@de.com)           | +49-444 | Magazine     | Der Spiegel        | MG880   | Berlin Mitte     | Berlin   | Berlin           | Germany | EUR  | 6 Jan  | 10 Jan | 9 Jan  | 4      | 0    |
| B1005     | Amol   | [amol@example.com](mailto\:amol@example.com) | +91-111 | Book         | Refactoring        | BC333   | Mumbai South     | Mumbai   | Maharashtra      | India   | INR  | 8 Jan  | 22 Jan | 21 Jan | 0      | 0    |
| B1005     | Amol   | [amol@example.com](mailto\:amol@example.com) | +91-111 | Journal      | IEEE Software      | JR111   | Mumbai South     | Mumbai   | Maharashtra      | India   | INR  | 8 Jan  | 15 Jan | 25 Jan | 0      | 80   |
| B1006     | Maria  | [maria@us.com](mailto\:maria@us.com)         | +1-555  | Book         | Clean Architecture | US555   | New York Central | New York | New York         | USA     | USD  | 10 Jan | 24 Jan | 10 Feb | 0      | 200  |
| B1006     | Maria  | [maria@us.com](mailto\:maria@us.com)         | +1-555  | Magazine     | Time Weekly        | MG771   | New York Central | New York | New York         | USA     | USD  | 10 Jan | 14 Jan | 13 Jan | 6      | 0    |
| B1007     | Ravi   | [ravi@in.com](mailto\:ravi@in.com)           | +91-666 | Book         | Mythical Man-Month | BC222   | Pune Central     | Pune     | Maharashtra      | India   | INR  | 11 Jan | 25 Jan | 24 Jan | 0      | 0    |
| B1007     | Ravi   | [ravi@in.com](mailto\:ravi@in.com)           | +91-666 | Magazine     | India Today        | MG550   | Pune Central     | Pune     | Maharashtra      | India   | INR  | 11 Jan | 18 Jan | 20 Jan | 8      | 20   |
| B1008     | John   | [john@us.com](mailto\:john@us.com)           | +1-777  | Book         | DDD                | US111   | Dallas Downtown  | Dallas   | Texas            | USA     | USD  | 12 Jan | 26 Jan | 25 Jan | 0      | 0    |
| B1008     | John   | [john@us.com](mailto\:john@us.com)           | +1-777  | Journal      | ACM Queue          | JR333   | Dallas Downtown  | Dallas   | Texas            | USA     | USD  | 12 Jan | 19 Jan | 30 Jan | 3      | 60   |
| B1009     | Yuki   | [yuki@jp.com](mailto\:yuki@jp.com)           | +81-888 | Book         | Norwegian Wood     | JP555   | Tokyo East       | Tokyo    | Tokyo Prefecture | Japan   | JPY  | 13 Jan | 27 Jan | 26 Jan | 0      | 0    |
| B1010     | Klaus  | [klaus@de.com](mailto\:klaus@de.com)         | +49-999 | Book         | Clean Code         | DE222   | Munich Central   | Munich   | Bavaria          | Germany | EUR  | 14 Jan | 28 Jan | 5 Feb  | 0      | 120  |
| B1010     | Klaus  | [klaus@de.com](mailto\:klaus@de.com)         | +49-999 | Magazine     | Auto Bild          | MG990   | Munich Central   | Munich   | Bavaria          | Germany | EUR  | 14 Jan | 21 Jan | 21 Jan | 5      | 0    |
| B1011     | Amol   | [amol@example.com](mailto\:amol@example.com) | +91-111 | Book         | Dune               | BC444   | Pune West        | Pune     | Maharashtra      | India   | INR  | 15 Jan | 29 Jan | 29 Jan | 0      | 0    |
| B1011     | Amol   | [amol@example.com](mailto\:amol@example.com) | +91-111 | Journal      | Data Eng Weekly    | JR777   | Pune West        | Pune     | Maharashtra      | India   | INR  | 15 Jan | 22 Jan | 28 Jan | 0      | 40   |
| B1012     | Sarah  | [sarah@us.com](mailto\:sarah@us.com)         | +1-222  | Book         | Sapiens            | US999   | Austin Public    | Austin   | Texas            | USA     | USD  | 16 Jan | 30 Jan | 5 Feb  | 0      | 70   |
| B1013     | Kenji  | [kenji@jp.com](mailto\:kenji@jp.com)         | +81-333 | Magazine     | Anime World        | MG123   | Tokyo East       | Tokyo    | Tokyo Prefecture | Japan   | JPY  | 17 Jan | 24 Jan | 24 Jan | 7      | 0    |
| B1014     | Lars   | [lars@de.com](mailto\:lars@de.com)           | +49-444 | Journal      | EU Tech Review     | JR555   | Berlin Mitte     | Berlin   | Berlin           | Germany | EUR  | 18 Jan | 25 Jan | 2 Feb  | 0      | 40   |
| B1015     | Maria  | [maria@us.com](mailto\:maria@us.com)         | +1-555  | Book         | Refactoring        | US222   | New York Central | New York | New York         | USA     | USD  | 19 Jan | 2 Feb  | 2 Feb  | 0      | 0    |
| B1015     | Maria  | [maria@us.com](mailto\:maria@us.com)         | +1-555  | Magazine     | Vogue              | MG700   | New York Central | New York | New York         | USA     | USD  | 19 Jan | 26 Jan | 27 Jan | 10     | 10   |
| B1016     | Ravi   | [ravi@in.com](mailto\:ravi@in.com)           | +91-666 | Book         | Clean Architecture | BC909   | Mumbai South     | Mumbai   | Maharashtra      | India   | INR  | 20 Jan | 3 Feb  | 1 Feb  | 0      | 0    |
| B1017     | John   | [john@us.com](mailto\:john@us.com)           | +1-777  | Book         | Sapiens            | US333   | Dallas Downtown  | Dallas   | Texas            | USA     | USD  | 21 Jan | 4 Feb  | NULL   | 0      | 0    |
| B1018     | Yuki   | [yuki@jp.com](mailto\:yuki@jp.com)           | +81-888 | Journal      | Manga Studies      | JR222   | Tokyo East       | Tokyo    | Tokyo Prefecture | Japan   | JPY  | 22 Jan | 29 Jan | 10 Feb | 0      | 90   |
| B1019     | Klaus  | [[klaus@de.com](mailto\:klaus@de.com)]       |         |              |                    |         |                  |          |                  |         |      |        |        |        |        |      |
