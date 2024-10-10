# Understanding Enums in Rails
In Rails, enums are a convenient way to map symbolic names to integer values in the database. By default, when you define an enum in a Rails model, it stores the values as integers.

Example:

```ruby
class InboundWebhook < ApplicationRecord
enum status: %i[pending processing processed failed unhandled], validate: true
end
```
This maps:

```ruby
pending => 0
processing => 1
processed => 2
failed => 3
unhandled => 4
```

### Storing Enums as Integers
**Pros:**
- Storage Efficiency:
  - Integers take up less space than strings.
  - Faster indexing and querying due to smaller data size.
- Performance:
  - Numeric comparisons are generally faster.
  
**Cons**:
- Readability:
  - Database records are less human-readable.
  - Debugging and manual queries become harder.
- Mapping Issues:
  - Changing the order of enum declarations can break data integrity.
  - Adding new statuses in between existing ones can shift the mappings.
- Data Migration Risks:
  - Renaming or reordering enum values requires careful data migration to prevent mismatches.
  
### Storing Enums as Strings
**Pros**:
- Readability:
  - Database entries are human-readable. 
  - Easier to debug and perform manual queries.
- Flexibility:
  - Adding new statuses doesn't affect existing data. 
  - Renaming statuses doesn't require data migration (as long as you keep the string values consistent).
- Data Integrity:
  - The actual value is stored, reducing the risk of mapping errors.
  
**Cons**:
- Storage Size:
  - Strings take up more space than integers.
  - Might slightly impact performance on very large datasets.
- Validation:
  - Need to ensure that only valid strings are stored.
  - However, Rails enums handle this validation for you.
  
### Best Practices
Given the trade-offs, storing enums as strings is generally considered a better practice, especially for attributes like status that benefit from clarity and flexibility.

**Reasons**:
- Human-Readable Data:
  - Easier for developers and database administrators to understand the data directly from the database.
- Avoiding Mapping Issues:
  - Prevents bugs related to integer mapping changes when modifying the enum declarations.
- Ease of Maintenance:
  - Simplifies adding, removing, or renaming statuses without complex migrations.

### When to Use ActiveRecord Enums
- Need for Flexibility: 
  - If your application's enum values are likely to change (e.g., adding new statuses). 
- Cross-Database Compatibility: 
  - If you want to keep the option open to switch databases in the future.
- Simplicity: 
- If you prefer straightforward migrations and minimal database-specific code.
- Full Rails Integration: 
  - If you want to leverage Rails' built-in features without additional setup.

### When to Use PostgreSQL Enums
- Strict Data Integrity Requirements: 
  - If it's critical to enforce valid values at the database level.
- Performance Optimization: 
  - For large datasets where storage efficiency and indexing are crucial.
- Database-Centric Design: 
  - If your application heavily relies on database features and you're committed to PostgreSQL.
- Schema Clarity: 
  - When you want the database schema to explicitly define allowed values.

#### Implementation
- Migration to Create Enum Type

```ruby
  class CreateStatusEnum < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      CREATE TYPE status AS ENUM ('pending', 'processing', 'processed', 'failed', 'unhandled');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE status;
    SQL
  end
end
```

- Using the Enum in a Table

```ruby
class AddStatusToInboundWebhooks < ActiveRecord::Migration[7.0]
  def change
    add_column :inbound_webhooks, :status, :status, default: 'pending', null: false
  end
end
```
- Model Definition

```ruby
class InboundWebhook < ApplicationRecord
  # You can still use enums for convenience methods
  enum status: {
    pending: 'pending',
    processing: 'processing',
    processed: 'processed',
    failed: 'failed',
    unhandled: 'unhandled'
  }
end
```

**Pros**
1. Data Integrity
   - Database-Level Enforcement: The database strictly enforces valid values, preventing invalid data even from direct SQL operations. 
   - Consistency: Ensures that all data stored conforms to the defined enum.
2. Performance
   - Efficient Storage: PostgreSQL stores enums efficiently, often as integers internally.
   - Indexing: Enums can be indexed effectively, leading to performant queries.
3. Strong Typing
   - Schema Clarity: The database schema clearly defines the allowed values for a column.
   - Validation at Multiple Layers: Both the application and database enforce constraints.

**Cons**
1. Flexibility
   - Difficulty in Modifying Enums: Adding or removing enum values requires running migrations and can be complex.
   - Downtime Risks: Changing enum types may require locking tables, leading to potential downtime.
2. Database Dependence
   - Database-Specific: Ties your application closely to PostgreSQL, reducing portability to other databases.
   - Complex Migrations: Managing enums across different environments (development, staging, production) can be tricky.
3. ORM Limitations
   - ActiveRecord Support: Limited built-in support for PostgreSQL enums in Rails migrations and models.
   - Third-Party Gems: May need to use additional gems or custom code to handle enums smoothly.

### Comparison
| Aspect               | ActiveRecord Enums                  | PostgreSQL Enums                      |
|----------------------|-------------------------------------|---------------------------------------|
| Data Integrity       | Enforced at application level       | Enforced at database level            |
| Flexibility          | Easy to add/change enum values      | Difficult to modify once defined      |
| Database Dependency  | Database-agnostic                   | Tied to PostgreSQL                    |
| Performance          | Good, with potential mapping issues | Efficient storage and indexing        |
| Migration Complexity | Simple migrations                   | Complex migrations, risk of downtime  |
| Tooling Support      | Full support in Rails               | Limited support, may need gems        |
| Readability          | Good with string enums              | Excellent, enforced at schema level   |

#### Resources: 
- https://naturaily.com/blog/ruby-on-rails-enum
