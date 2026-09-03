# Unolo GraphQL API — Complete Reference

> Generated from the official Unolo API Explorer (`https://apiexplorer.unolo.com`).
> Covers all **50** endpoints (31 queries, 19 mutations) exposed on the external GraphQL API.

---

## 1. Before you start

### Endpoints

| Environment | URL |
|---|---|
| **Production** | `https://apollo-lb-ext-ns.unolo.com/graphql` |
| Staging | `https://graphql-staging.unolo.com/graphql` |
| Flash | `https://graphql-flash.unolo.com/graphql` |

### Authentication

Every request is a `POST` with a custom **`token`** header. There is no `Authorization: Bearer` scheme — this is the single most common migration mistake.

```http
POST /graphql HTTP/1.1
Host: apollo-lb-ext-ns.unolo.com
Content-Type: application/json
token: YOUR_API_KEY
```

### Request shape

```json
{
  "query": "query { get_employees { internalEmpID firstName lastName } }",
  "variables": {}
}
```

A single URL serves everything. You select the operation by name inside the GraphQL document — there are no REST-style paths, verbs, or query strings.

### Error handling

GraphQL returns HTTP `200` even on failure. Do **not** branch on the status code. Check for an `errors` array:

```js
const { data, errors } = await res.json();
if (errors?.length) throw new Error(errors[0].message);
```

---

## 2. Endpoint index

| Module | Endpoint | Type | Purpose |
|---|---|---|---|
| Employees | `get_users_by_company_id` | query | Older sibling of `get_employees`, returning the same `User` objects. |
| Employees | `get_employees` | query | Returns all employees with their details and custom fields |
| Employees | `get_last_location` | query | Returns the real-time last known location of a single employee. Returns null if no location has been recorded. |
| Employees | `get_last_location_emp_batched` | query | Returns the real-time last known location of a batch of employees. External callers filter by internalEmpIDs; admins filter by employeeIDs. Omit the filter to return every employee in the company that has a recorded location. |
| Employees | `get_attendance_status` | query | Returns whether an employee is currently punched in or out, based on their most recent attendance event. |
| Employees | `get_attendance_status_emp_batched` | query | Returns whether a batch of employees are currently punched in or out, based on their most recent attendance event. External callers filter by internalEmpIDs; admins filter by employeeIDs. Omit the filter to return every employee in the company. |
| Employees | `get_designations` | query | Returns all designations |
| Employees | `get_teams` | query | Returns all teams |
| Employees | `get_geofences` | query | Returns all geofences |
| Employees | `get_geofence_pools` | query | Returns all geofence pools |
| Employees | `geo_validate` | query | Validate whether an employee is physically near a store/client. Used for ticket geo-validation. |
| Employees | `upsert_employee` | mutation | Create or update an employee. First call with an internalEmpID creates the employee; subsequent calls with the same internalEmpID update it. |
| Employees | `delete_employee` | mutation | Delete an employee via their unique ID. Optionally transfer data to another employee. |
| Employees | `activate_employee` | mutation | Activate an employee (allow them to use the application again) |
| Employees | `deactivate_employee` | mutation | Deactivate an employee (prevent login, preserve data, auto log out) |
| Admins & Roles | `get_admins` | query | Every reporting manager, with their role, designation and parent admin. |
| Admins & Roles | `get_roles` | query | Returns all roles |
| Admins & Roles | `upsert_admin` | mutation | Create or update a reporting manager. First call with an internalAdminID creates the admin; subsequent calls with the same internalAdminID update it. |
| Admins & Roles | `delete_admin` | mutation | Delete a reporting manager (reassigns children to parent) |
| Clients, Sites & Geofences | `get_clients` | query | Returns all clients (max 10000 per page) |
| Clients, Sites & Geofences | `get_client_by_id` | query | Fetches a single v1 client by `internalClientID`. |
| Clients, Sites & Geofences | `get_clientv2_by_internalClientID` | query | Fetches a single v2 client, including its sites and visibility configuration. |
| Clients, Sites & Geofences | `get_site_pools` | query | Returns all site pools |
| Clients, Sites & Geofences | `get_sites` | query | Lists physical sites with `filters`, `skip` and `take`. |
| Clients, Sites & Geofences | `delete_client_external` | mutation | If a client is deleted then all the incomplete tasks associated with this client will be deleted. |
| Clients, Sites & Geofences | `delete_client_by_id` | mutation | Alternate v1 client delete by `internalClientID`. |
| Clients, Sites & Geofences | `upsert_client_by_id` | mutation | Create or update a client via the external API. First call with an internalClientID creates the client; subsequent calls with the same internalClientID update it. |
| Clients, Sites & Geofences | `upsert_clientv2_external` | mutation | Create or update a V2 client via the external API (internalClientID omitted = create, provided = update) |
| Clients, Sites & Geofences | `delete_clientv2_external` | mutation | Deletes a v2 client. |
| Clients, Sites & Geofences | `get_custom_field_upload_urls` | mutation | Get presigned S3 upload URLs for custom field file/image/audio attachments |
| Tasks | `get_tasks_by_empIDs_date_range` | query | Retrieves tasks for employees within a date range. If no employee filter is provided, returns tasks for all employees in the company. |
| Tasks | `get_task_by_id` | query | Retrieves a task by it's ID |
| Tasks | `get_eligible_employees_for_custom_task` | query | Lists employees permitted to take a named custom task, optionally scoped to a client. |
| Tasks | `upsert_task_external` | mutation | Create or update a task via the external API (internalTaskID omitted = create, provided = update) |
| Tasks | `delete_task_external` | mutation | Delete a task via the external API by its internalTaskID |
| Tasks | `upsert_task_to_best_employee` | mutation | Creates or updates a task and auto-assigns the best-fit employee via the task type's Find Best Employee rules. Accepts a batch; per item: autoAssign true assigns and creates the task, autoAssign false only suggests, and a manual internalEmpID override always wins. |
| Orders | `get_orders_by_date_range` | query | Get all orders in a specific date range |
| Products (SKUs) | `get_skus` | query | Get all products (SKUs) |
| Products (SKUs) | `upsert_skus` | mutation | Mutation to create Products (SKUs) |
| Products (SKUs) | `get_sku_image_upload_urls` | mutation | Get presigned S3 URLs for uploading SKU images (External API only) |
| Leaves | `get_leave_policies_by_companyID` | query | Returns all leave policies configured for your company, including policy details, associated leave types and their configurations (accrual rules, carry-forward settings, etc.). |
| Leaves | `get_leave_typesv2_by_companyID` | query | Returns all leave types defined for your company (e.g. Casual Leave, Sick Leave, Comp-off). Each entry includes the type name, category (REGULAR, INCIDENT, UNPAID, COMPOFF) and description. |
| Leaves | `get_leavesv2_for_employees` | query | Retrieves leave records for employees within a date range. Supports filtering by leave status (PENDING, APPROVED, REJECTED, WITHDRAW) and request type. If no employee filter is provided, returns leaves for all employees in the company. |
| Attendance | `get_attendances_by_companyID` | query | All attendance punches for every employee in your company within a date range. eventTypeID 8 = punch-in, 9 = punch-out. Dates are inclusive and compared against the attendance processing date. Maximum range is 31 days. |
| Guards | `get_guard_posts` | query | Lists all guard posts (fixed duty positions). |
| Guards | `get_guard_assignments` | query | Guard shift assignments for a date range. Maximum range is 7 days. |
| Guards | `get_attendance_rollup` | query | Per-site attendance rollup for a date range. Maximum range is 7 days. |
| Territory | `check_geofence_overlap` | query | Reports whether a geofence overlaps others. |
| Territory | `upsert_territory_by_id` | mutation | Territory — External API (EXTERNAL_API): create/update/delete keyed on internalTerritoryID only |
| Territory | `delete_territory_by_id` | mutation | Deletes territories by a list of `internalTerritoryIDs`. |

---

## 3. Endpoint reference

## 👥 Employees

The employee module is the backbone of the API. Almost every other object (tasks, orders, attendance, leaves) is keyed on `internalEmpID` — the employee ID *from your own system*, not a Unolo-generated ID. Set it correctly on creation and you never have to store a Unolo ID mapping table.

### `get_users_by_company_id`

**Type:** query &nbsp;·&nbsp; **Returns:** `[User]`

**What it does.** Older sibling of `get_employees`, returning the same `User` objects.

**When to use it.** Avoid in new code. It exists for backward compatibility; migrate any usage to `get_employees`.

**Inputs**

_None._

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `userID` | `String` | — |
| `firstName` | `String` | — |
| `lastName` | `String` | — |
| `emailID` | `String` | — |
| `createdTs` | `DateTime` | — |
| `countryCallingCode` | `String` | — |
| `phoneNumber` | `String` | — |
| `mobileNumber` | `String` | — |
| `photoPath` | `String` | — |
| `manufacturer` | `String` | — |
| `modelNumber` | `String` | — |
| `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalAdminID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `role` | `AdminRole` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designation` | `Designation` | — |
| `active` | `Int` | — |
| `joiningDate` | `Date` | — |
| `profileName` | `String` | — |
| `agencyName` | `String` | — |
| `internalEmpID` | `String` | Employee ID |
| `designationName` | `String` | — |
| `imgUrl` | `String` | — |
| `tz` | `String` | — |
| `city` | `String` | — |
| `targetCountry` | `String` | — |
| `customFields` | `JSON` | — |
| `userSettings` | `UserSettings` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `defaultTransportMode` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `locBasedAutoAttEnabled` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `odoEnabled` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `baseLocationID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `linkedGeofenceID` | `ID` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `linkedGeofencePoolID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `autoTaskSitePoolID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceRestrictionToSiteID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceRestrictionToSitePoolID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceOutRestrictionToSiteID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceOutRestrictionToSitePoolID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceInRestrictionBasedOnClient` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceOutRestrictionBasedOnClient` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `workRestrictionGeofenceID` | `ID` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `workRestrictionGeofencePoolID` | `ID` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `workLocationGeofenceID` | `ID` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `workLocationGeofencePoolID` | `ID` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `baseLocation` | `Site` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `linkedGeofence` | `Geofence` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `linkedGeofencePool` | `GeofencePool` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `workRestrictionGeofence` | `Geofence` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `workRestrictionGeofencePool` | `GeofencePool` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `workLocationGeofence` | `Geofence` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `workLocationGeofencePool` | `GeofencePool` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `autoTaskSitePool` | `SitePool` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceRestrictionToSite` | `Site` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceRestrictionToSitePool` | `SitePool` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceOutRestrictionToSite` | `Site` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceOutRestrictionToSitePool` | `SitePool` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `defaultConveyanceCategoryID` | `ID` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `probationPeriodDuration` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `dbTimeStamp` | `DateTime` | — |
| `isDeleted` | `Boolean` | — |

**Example**

```graphql
query Get_users_by_company_id {
  get_users_by_company_id {
      userID
      firstName
      lastName
      emailID
      createdTs
      countryCallingCode
      phoneNumber
      mobileNumber
      photoPath
      manufacturer
      modelNumber
      parentAdmin {
        internalAdminID
        email
        firstname
        lastname
        phoneNumber
        parentAdmin
      }
      active
      joiningDate
      profileName
      agencyName
      internalEmpID
      designationName
      imgUrl
      tz
      city
      targetCountry
      customFields
      userSettings {
        defaultTransportMode
        locBasedAutoAttEnabled
        odoEnabled
        baseLocationID
        linkedGeofenceID
        linkedGeofencePoolID
        autoTaskSitePoolID
        attendanceRestrictionToSiteID
        attendanceRestrictionToSitePoolID
        attendanceOutRestrictionToSiteID
        attendanceOutRestrictionToSitePoolID
        attendanceInRestrictionBasedOnClient
        attendanceOutRestrictionBasedOnClient
        workRestrictionGeofenceID
        workRestrictionGeofencePoolID
        workLocationGeofenceID
        workLocationGeofencePoolID
        defaultConveyanceCategoryID
        probationPeriodDuration
        dbTimeStamp
      }
      isDeleted
  }
}
```

---

### `get_employees`

**Type:** query &nbsp;·&nbsp; **Returns:** `[User]`

Returns all employees with their details and custom fields

**What it does.** Returns every employee in the organisation with their full profile and custom fields.

**When to use it.** Your primary sync endpoint. Run it on a schedule to mirror the Unolo roster into your own DB, or once at migration time to discover which `internalEmpID` values already exist.

> ⚠️ No pagination and no filters — it returns the entire roster in one response. On large orgs cache the result rather than calling it per-request.

**Inputs**

_None._

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `userID` | `String` | — |
| `firstName` | `String` | — |
| `lastName` | `String` | — |
| `emailID` | `String` | — |
| `createdTs` | `DateTime` | — |
| `countryCallingCode` | `String` | — |
| `phoneNumber` | `String` | — |
| `mobileNumber` | `String` | — |
| `photoPath` | `String` | — |
| `manufacturer` | `String` | — |
| `modelNumber` | `String` | — |
| `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalAdminID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `role` | `AdminRole` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designation` | `Designation` | — |
| `active` | `Int` | — |
| `joiningDate` | `Date` | — |
| `profileName` | `String` | — |
| `agencyName` | `String` | — |
| `internalEmpID` | `String` | Employee ID |
| `designationName` | `String` | — |
| `imgUrl` | `String` | — |
| `tz` | `String` | — |
| `city` | `String` | — |
| `targetCountry` | `String` | — |
| `customFields` | `JSON` | — |
| `userSettings` | `UserSettings` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `defaultTransportMode` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `locBasedAutoAttEnabled` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `odoEnabled` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `baseLocationID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `linkedGeofenceID` | `ID` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `linkedGeofencePoolID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `autoTaskSitePoolID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceRestrictionToSiteID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceRestrictionToSitePoolID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceOutRestrictionToSiteID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceOutRestrictionToSitePoolID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceInRestrictionBasedOnClient` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceOutRestrictionBasedOnClient` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `workRestrictionGeofenceID` | `ID` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `workRestrictionGeofencePoolID` | `ID` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `workLocationGeofenceID` | `ID` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `workLocationGeofencePoolID` | `ID` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `baseLocation` | `Site` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `linkedGeofence` | `Geofence` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `linkedGeofencePool` | `GeofencePool` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `workRestrictionGeofence` | `Geofence` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `workRestrictionGeofencePool` | `GeofencePool` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `workLocationGeofence` | `Geofence` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `workLocationGeofencePool` | `GeofencePool` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `autoTaskSitePool` | `SitePool` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceRestrictionToSite` | `Site` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceRestrictionToSitePool` | `SitePool` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceOutRestrictionToSite` | `Site` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceOutRestrictionToSitePool` | `SitePool` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `defaultConveyanceCategoryID` | `ID` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `probationPeriodDuration` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `dbTimeStamp` | `DateTime` | — |
| `isDeleted` | `Boolean` | — |

**Example**

```graphql
query Get_employees {
  get_employees {
      userID
      firstName
      lastName
      emailID
      createdTs
      countryCallingCode
      phoneNumber
      mobileNumber
      photoPath
      manufacturer
      modelNumber
      parentAdmin {
        internalAdminID
        email
        firstname
        lastname
        phoneNumber
        parentAdmin
      }
      active
      joiningDate
      profileName
      agencyName
      internalEmpID
      designationName
      imgUrl
      tz
      city
      targetCountry
      customFields
      userSettings {
        defaultTransportMode
        locBasedAutoAttEnabled
        odoEnabled
        baseLocationID
        linkedGeofenceID
        linkedGeofencePoolID
        autoTaskSitePoolID
        attendanceRestrictionToSiteID
        attendanceRestrictionToSitePoolID
        attendanceOutRestrictionToSiteID
        attendanceOutRestrictionToSitePoolID
        attendanceInRestrictionBasedOnClient
        attendanceOutRestrictionBasedOnClient
        workRestrictionGeofenceID
        workRestrictionGeofencePoolID
        workLocationGeofenceID
        workLocationGeofencePoolID
        defaultConveyanceCategoryID
        probationPeriodDuration
        dbTimeStamp
      }
      isDeleted
  }
}
```

---

### `get_last_location`

**Type:** query &nbsp;·&nbsp; **Returns:** `EmployeeLastLocation`

Returns the real-time last known location of a single employee. Returns null if no location has been recorded.

**What it does.** The most recent GPS fix recorded for one employee. Returns `null` if none has ever been recorded.

**When to use it.** Powering a 'where is this person' lookup on a detail screen.

> ⚠️ Single-employee only. For a live map, use the batched variant — do not loop this call.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalEmpID` | `String` | **Yes** | The unique ID for the employee |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `internalEmpID` | `String` | — |
| `firstName` | `String` | — |
| `lastName` | `String` | — |
| `lat` | `Float` | — |
| `lon` | `Float` | — |
| `timestamp` | `Long` | — |

**Example**

```graphql
query Get_last_location($internalEmpID: String!) {
  get_last_location(internalEmpID: $internalEmpID) {
      internalEmpID
      firstName
      lastName
      lat
      lon
      timestamp
  }
}
```

---

### `get_last_location_emp_batched`

**Type:** query &nbsp;·&nbsp; **Returns:** `[EmployeeLastLocation!]`

Returns the real-time last known location of a batch of employees. External callers filter by internalEmpIDs; admins filter by employeeIDs. Omit the filter to return every employee in the company that has a recorded location.

**What it does.** Last known location for many employees in one round trip. Omit `internalEmpIDs` to get everyone visible to your token.

**When to use it.** Live tracking dashboards, map views, periodic location snapshots. This is the correct endpoint for any multi-employee location need.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalEmpIDs` | `[String]` | No | The unique IDs for the employees |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `internalEmpID` | `String` | — |
| `firstName` | `String` | — |
| `lastName` | `String` | — |
| `lat` | `Float` | — |
| `lon` | `Float` | — |
| `timestamp` | `Long` | — |

**Example**

```graphql
query Get_last_location_emp_batched($internalEmpIDs: [String]) {
  get_last_location_emp_batched(internalEmpIDs: $internalEmpIDs) {
      internalEmpID
      firstName
      lastName
      lat
      lon
      timestamp
  }
}
```

---

### `get_attendance_status`

**Type:** query &nbsp;·&nbsp; **Returns:** `EmployeeAttendanceStatus`

Returns whether an employee is currently punched in or out, based on their most recent attendance event.

**What it does.** Whether one employee is currently punched in or out, derived from their latest attendance event.

**When to use it.** A quick 'is this person on duty' check before assigning urgent work.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalEmpID` | `String` | **Yes** | The unique ID for the employee |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `internalEmpID` | `String` | — |
| `isPunchedIn` | `Boolean` | True if the employee's most recent attendance event was a punch-in. False if their last event was a punch-out, or if they have no attendance record. |
| `timestamp` | `Long` | Timestamp (epoch ms) of the most recent attendance event. Null if the employee has no attendance record. |

**Example**

```graphql
query Get_attendance_status($internalEmpID: String!) {
  get_attendance_status(internalEmpID: $internalEmpID) {
      internalEmpID
      isPunchedIn
      timestamp
  }
}
```

---

### `get_attendance_status_emp_batched`

**Type:** query &nbsp;·&nbsp; **Returns:** `[EmployeeAttendanceStatus!]`

Returns whether a batch of employees are currently punched in or out, based on their most recent attendance event. External callers filter by internalEmpIDs; admins filter by employeeIDs. Omit the filter to return every employee in the company.

**What it does.** Punched-in/out status for a set of employees at once.

**When to use it.** Rendering an availability column across a team roster. Use instead of repeated single calls.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalEmpIDs` | `[String]` | No | The unique IDs for the employees |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `internalEmpID` | `String` | — |
| `isPunchedIn` | `Boolean` | True if the employee's most recent attendance event was a punch-in. False if their last event was a punch-out, or if they have no attendance record. |
| `timestamp` | `Long` | Timestamp (epoch ms) of the most recent attendance event. Null if the employee has no attendance record. |

**Example**

```graphql
query Get_attendance_status_emp_batched($internalEmpIDs: [String]) {
  get_attendance_status_emp_batched(internalEmpIDs: $internalEmpIDs) {
      internalEmpID
      isPunchedIn
      timestamp
  }
}
```

---

### `get_designations`

**Type:** query &nbsp;·&nbsp; **Returns:** `[Designation!]`

Returns all designations

**What it does.** Lists all designations (job titles) defined for the company.

**When to use it.** Call once at startup and cache. You need it to supply a valid `designationName` to `upsert_employee`.

**Inputs**

_None._

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `designationID` | `Int` | — |
| `designationName` | `String` | — |

**Example**

```graphql
query Get_designations {
  get_designations {
      designationID
      designationName
  }
}
```

---

### `get_teams`

**Type:** query &nbsp;·&nbsp; **Returns:** `[Profile!]`

Returns all teams

**What it does.** Lists all teams (internally called profiles).

**When to use it.** Same as designations — resolve the valid `profileName` values before writing employees.

**Inputs**

_None._

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `profileID` | `Int` | — |
| `profileName` | `String` | — |

**Example**

```graphql
query Get_teams {
  get_teams {
      profileID
      profileName
  }
}
```

---

### `get_geofences`

**Type:** query &nbsp;·&nbsp; **Returns:** `[Geofencev2!]`

Returns all geofences

**What it does.** All geofences: named virtual boundaries used for attendance and task rules.

**When to use it.** Building a picker, or resolving geofence IDs before attaching them to employees or territories.

**Inputs**

_None._

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `geofenceID` | `ID` | — |
| `name` | `String` | — |
| `type` | `GeofenceTypes` | Values: `POINT`, `REGION` |
| `address` | `String` | — |
| `radius` | `Float` | — |
| `centerLat` | `Float` | — |
| `centerLon` | `Float` | — |
| `polyline` | `String` | — |
| `tierCategory` | `Int` | — |
| `purpose` | `[String]` | — |
| `lastModifiedByAdminID` | `Int` | — |

**Example**

```graphql
query Get_geofences {
  get_geofences {
      geofenceID
      name
      type
      address
      radius
      centerLat
      centerLon
      polyline
      tierCategory
      purpose
      lastModifiedByAdminID
  }
}
```

---

### `get_geofence_pools`

**Type:** query &nbsp;·&nbsp; **Returns:** `[GeofencePoolv2!]`

Returns all geofence pools

**What it does.** Lists geofence pools — reusable groups of geofences.

**When to use it.** When you assign employees to a set of locations rather than one; reference the pool instead of enumerating geofences.

**Inputs**

_None._

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `geofencePoolID` | `ID` | — |
| `name` | `String` | — |
| `purpose` | `[String]` | — |

**Example**

```graphql
query Get_geofence_pools {
  get_geofence_pools {
      geofencePoolID
      name
      purpose
  }
}
```

---

### `geo_validate`

**Type:** query &nbsp;·&nbsp; **Returns:** `GeoValidationResponse`

Validate whether an employee is physically near a store/client. Used for ticket geo-validation.

**What it does.** Confirms an employee is physically near a given client/store, with an optional `maxLocationAgeMinutes` freshness bound.

**When to use it.** Server-side proof-of-presence — validating a support ticket, a check-in, or an expense claim before you accept it.

> ⚠️ Set `maxLocationAgeMinutes` explicitly. Without it a stale fix from hours earlier can pass validation.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalEmpID` | `String` | **Yes** | — |
| `internalClientID` | `String` | **Yes** | — |
| `maxLocationAgeMinutes` | `Int` | No | — |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `isValid` | `Boolean` | — |
| `checks` | `GeoValidationChecks` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userExists` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userIsActive` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `clientExists` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userIsAssignedToStore` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userIsWithinRadius` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `locationIsRecent` | `Boolean` | — |
| `distance` | `Float` | Distance in meters between employee and store |
| `lastLocationTimestamp` | `Long` | Epoch ms of employee's last GPS ping |
| `radius` | `Float` | The store's configured radius in meters |

**Example**

```graphql
query Geo_validate($internalEmpID: String!, $internalClientID: String!, $maxLocationAgeMinutes: Int) {
  geo_validate(internalEmpID: $internalEmpID, internalClientID: $internalClientID, maxLocationAgeMinutes: $maxLocationAgeMinutes) {
      isValid
      checks {
        userExists
        userIsActive
        clientExists
        userIsAssignedToStore
        userIsWithinRadius
        locationIsRecent
      }
      distance
      lastLocationTimestamp
      radius
  }
}
```

---

### `upsert_employee`

**Type:** mutation &nbsp;·&nbsp; **Returns:** `EmployeeUpsertResponse`

Create or update an employee. First call with an internalEmpID creates the employee; subsequent calls with the same internalEmpID update it.

**What it does.** Creates an employee if `internalEmpID` is new, updates them if it already exists.

**When to use it.** For onboarding from your HRMS and for any subsequent profile change. Because it is idempotent on `internalEmpID`, you can safely replay the same payload.

> ⚠️ `internalEmpID`, `parentInternalAdminID` and `profileName` are marked optional in the schema but are effectively required — the resolver rejects the call without them. `designationName`, `profileName` and `roleName` are matched by *name*, so the corresponding record must already exist (see `get_designations`, `get_teams`, `get_roles`).

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `input` | `UserInput` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstName` | `String` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastName` | `String` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `mobileNumber` | `String` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentInternalAdminID` | `String` | **Yes** | Reporting Admin ID - the unique ID of their reporting manager (required) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `profileName` | `String` | **Yes** | Team name (required) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalEmpID` | `String` | **Yes** | Employee ID - the unique ID for this employee (required) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designationName` | `String` | No | Designation (refer to @get_designations) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `tz` | `String` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `city` | `String` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `targetCountry` | `String` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `productID` | `Int` | No | Optional. Only required if your company has multiple Unolo subscriptions (1=Lite, 2=Essentials, 3=CRM, 4=Free, 5=Biometric, 6=Starter, 7=Basic, 8=Standard, 9=Professional) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFields` | `JSON` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userSettingsInput` | `UserSettingsInput` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `defaultTransportMode` | `Int` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `linkedGeofenceID` | `ID` | No | Get a notification whenever an employee goes in or out of this geofence (refer to @get_geofences). Mutually exclusive with linkedGeofencePoolID |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `linkedGeofencePoolID` | `ID` | No | Get a notification whenever an employee goes in or out of this geofence pool (refer to @get_geofence_pools). Mutually exclusive with linkedGeofenceID |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `baseLocationID` | `ID` | No | If your Employee normally works out of one location, create a site for them and you can automatically monitor their attendance using Site Attendance (refer to @get_sites) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `autoTaskSitePoolID` | `ID` | No | If your Employee normally works out of multiple sites, create a sitepool for them and you can automatically monitor their attendance using Site Attendance (refer to @get_site_pools) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceRestrictionToSiteID` | `ID` | No | Restrict punching in to this site (refer to @get_sites). Mutually exclusive with attendanceRestrictionToSitePoolID and attendanceInRestrictionBasedOnClient |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceRestrictionToSitePoolID` | `ID` | No | Restrict punching in to this site pool (refer to @get_site_pools). Mutually exclusive with attendanceRestrictionToSiteID and attendanceInRestrictionBasedOnClient |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceInRestrictionBasedOnClient` | `Int` | No | Restrict punching in to the locations of this employee's visible clients by setting this value to 1. Mutually exclusive with attendanceRestrictionToSiteID and attendanceRestrictionToSitePoolID |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceOutRestrictionToSiteID` | `ID` | No | Restrict punching out to this site (refer to @get_sites). Mutually exclusive with attendanceOutRestrictionToSitePoolID and attendanceOutRestrictionBasedOnClient |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceOutRestrictionToSitePoolID` | `ID` | No | Restrict punching out to this site pool (refer to @get_site_pools). Mutually exclusive with attendanceOutRestrictionToSiteID and attendanceOutRestrictionBasedOnClient |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `attendanceOutRestrictionBasedOnClient` | `Int` | No | Restrict punching out to the locations of this employee's visible clients by setting this value to 1. Mutually exclusive with attendanceOutRestrictionToSiteID and attendanceOutRestrictionToSitePoolID |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `userID` | `String` | — |
| `emailID` | `String` | — |
| `password` | `String` | — |
| `internalEmpID` | `String` | — |
| `created` | `Boolean` | — |

**Example**

```graphql
mutation Upsert_employee($input: UserInput!) {
  upsert_employee(input: $input) {
      userID
      emailID
      password
      internalEmpID
      created
  }
}
```

---

### `delete_employee`

**Type:** mutation &nbsp;·&nbsp; **Returns:** `EmployeeDeleteResponse`

Delete an employee via their unique ID. Optionally transfer data to another employee.

**What it does.** Permanently removes an employee, optionally reassigning their data to a colleague via `transferToInternalEmpID`.

**When to use it.** Only for records created in error or when a hard delete is legally required.

> ⚠️ Destructive and irreversible. Prefer `deactivate_employee`. Always pass `transferToInternalEmpID` if the employee has open tasks, or those tasks are orphaned.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalEmpID` | `String` | **Yes** | — |
| `transferToInternalEmpID` | `String` | No | — |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `success` | `Boolean` | — |
| `message` | `String` | — |

**Example**

```graphql
mutation Delete_employee($internalEmpID: String!, $transferToInternalEmpID: String) {
  delete_employee(internalEmpID: $internalEmpID, transferToInternalEmpID: $transferToInternalEmpID) {
      success
      message
  }
}
```

---

### `activate_employee`

**Type:** mutation &nbsp;·&nbsp; **Returns:** `EmployeeStatusResponse`

Activate an employee (allow them to use the application again)

**What it does.** Re-enables a previously deactivated employee.

**When to use it.** On return from leave or rehire. Restores access without recreating the record or losing history.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalEmpID` | `String` | **Yes** | The unique ID for the employee you want to activate |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `success` | `Boolean` | — |
| `message` | `String` | — |

**Example**

```graphql
mutation Activate_employee($internalEmpID: String!) {
  activate_employee(internalEmpID: $internalEmpID) {
      success
      message
  }
}
```

---

### `deactivate_employee`

**Type:** mutation &nbsp;·&nbsp; **Returns:** `EmployeeStatusResponse`

Deactivate an employee (prevent login, preserve data, auto log out)

**What it does.** Blocks login and force-logs-out the employee while preserving all their historical data.

**When to use it.** On resignation, long leave, or device loss. This is the reversible option and should be your default.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalEmpID` | `String` | **Yes** | The unique ID for the employee you want to deactivate |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `success` | `Boolean` | — |
| `message` | `String` | — |

**Example**

```graphql
mutation Deactivate_employee($internalEmpID: String!) {
  deactivate_employee(internalEmpID: $internalEmpID) {
      success
      message
  }
}
```

---

## 👤 Admins & Roles

Admins are reporting managers. They form a tree via `internalParentAdminID`. Every employee must point at an admin through `parentInternalAdminID`, so seed your admin hierarchy before bulk-loading employees.

### `get_admins`

**Type:** query &nbsp;·&nbsp; **Returns:** `[AdminInfo!]`

**What it does.** Every reporting manager, with their role, designation and parent admin.

**When to use it.** Mirror the management hierarchy, or discover the `internalAdminID` you need for `parentInternalAdminID` on an employee.

> ⚠️ Takes no arguments and returns the whole tree flat — rebuild the hierarchy client-side from `parentAdmin`.

**Inputs**

_None._

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `internalAdminID` | `String` | — |
| `email` | `String` | — |
| `firstname` | `String` | — |
| `lastname` | `String` | — |
| `phoneNumber` | `String` | — |
| `role` | `AdminRole` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `roleName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `roleDescription` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdTs` | `DateTime` | — |
| `parentAdmin` | `AdminInfo` | — |
| `designation` | `Designation` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designationID` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designationName` | `String` | — |

**Example**

```graphql
query Get_admins {
  get_admins {
      internalAdminID
      email
      firstname
      lastname
      phoneNumber
      role {
        roleName
        roleDescription
        createdTs
      }
      parentAdmin
      designation {
        designationID
        designationName
      }
  }
}
```

---

### `get_roles`

**Type:** query &nbsp;·&nbsp; **Returns:** `[AdminRole!]`

Returns all roles

**What it does.** All admin roles and their permission sets.

**When to use it.** Before creating admins, to pick a valid `roleName`.

**Inputs**

_None._

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `roleName` | `String` | — |
| `roleDescription` | `String` | — |
| `createdTs` | `DateTime` | — |

**Example**

```graphql
query Get_roles {
  get_roles {
      roleName
      roleDescription
      createdTs
  }
}
```

---

### `upsert_admin`

**Type:** mutation &nbsp;·&nbsp; **Returns:** `AdminUpsertResponse`

Create or update a reporting manager. First call with an internalAdminID creates the admin; subsequent calls with the same internalAdminID update it.

**What it does.** Creates or updates a reporting manager, idempotent on `internalAdminID`.

**When to use it.** Syncing your org chart. Create parents before children so `internalParentAdminID` resolves.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `input` | `AdminInput` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstname` | `String` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastname` | `String` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalParentAdminID` | `String` | **Yes** | Reporting Admin ID - the unique ID of their reporting manager (required) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalAdminID` | `String` | **Yes** | Admin ID - a unique ID to refer to this admin (required) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designationName` | `String` | No | Designation (refer to @get_designations) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `roleName` | `String` | No | Role name for this admin (refer to @get_roles). Required for external API. |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `adminID` | `Int` | — |
| `internalAdminID` | `String` | — |
| `created` | `Boolean` | — |

**Example**

```graphql
mutation Upsert_admin($input: AdminInput!) {
  upsert_admin(input: $input) {
      adminID
      internalAdminID
      created
  }
}
```

---

### `delete_admin`

**Type:** mutation &nbsp;·&nbsp; **Returns:** `AdminDeleteResponse`

Delete a reporting manager (reassigns children to parent)

**What it does.** Removes an admin and reassigns their direct reports up to their own parent.

**When to use it.** On a manager leaving. The automatic reparenting means you will not strand employees, but verify the resulting tree afterwards.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalAdminID` | `String` | **Yes** | — |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `success` | `Boolean` | — |
| `message` | `String` | — |

**Example**

```graphql
mutation Delete_admin($internalAdminID: String!) {
  delete_admin(internalAdminID: $internalAdminID) {
      success
      message
  }
}
```

---

## 🏢 Clients, Sites & Geofences

Two generations live side by side. `Client` (v1) is the legacy flat customer record; `Clientv2` is the newer model with sites, pools and richer visibility rules. **If you are migrating, build against the v2 endpoints.** `Site` is a physical location belonging to a client.

### `get_clients`

**Type:** query &nbsp;·&nbsp; **Returns:** `[Client!]`

Returns all clients (max 10000 per page)

**What it does.** Returns v1 clients with `skip`/`take` pagination, capped at 10,000 per page.

**When to use it.** Bulk export of the legacy client list.

> ⚠️ v1. For new integrations prefer the Clientv2 endpoints. Always page — do not assume one call returns everything.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `skip` | `Int` | No | — |
| `take` | `Int` | No | — |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `clientName` | `String` | — |
| `lat` | `Float` | — |
| `lng` | `Float` | — |
| `description` | `String` | — |
| `phoneNumber` | `String` | — |
| `address` | `String` | — |
| `proprietorName` | `String` | — |
| `email` | `String` | — |
| `internalClientID` | `String` | — |
| `city` | `String` | — |
| `pinCode` | `String` | — |
| `customFieldsJSON` | `JSON` | — |
| `isDeleted` | `Boolean` | — |
| `deletedAt` | `Long` | — |
| `deletionInfo` | `ClientDeletionInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedAt` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedByAdminID` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedByEmpID` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedByAdminName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedByEmpName` | `String` | — |

**Example**

```graphql
query Get_clients($skip: Int, $take: Int) {
  get_clients(skip: $skip, take: $take) {
      clientName
      lat
      lng
      description
      phoneNumber
      address
      proprietorName
      email
      internalClientID
      city
      pinCode
      customFieldsJSON
      isDeleted
      deletedAt
      deletionInfo {
        deletedAt
        deletedByAdminID
        deletedByEmpID
        deletedByAdminName
        deletedByEmpName
      }
  }
}
```

---

### `get_client_by_id`

**Type:** query &nbsp;·&nbsp; **Returns:** `Client`

**What it does.** Fetches a single v1 client by `internalClientID`.

**When to use it.** Point lookups against the legacy model.

> ⚠️ v1 — migrate to `get_clientv2_by_internalClientID`.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalClientID` | `String` | **Yes** | — |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `clientName` | `String` | — |
| `lat` | `Float` | — |
| `lng` | `Float` | — |
| `description` | `String` | — |
| `phoneNumber` | `String` | — |
| `address` | `String` | — |
| `proprietorName` | `String` | — |
| `email` | `String` | — |
| `internalClientID` | `String` | — |
| `city` | `String` | — |
| `pinCode` | `String` | — |
| `customFieldsJSON` | `JSON` | — |
| `isDeleted` | `Boolean` | — |
| `deletedAt` | `Long` | — |
| `deletionInfo` | `ClientDeletionInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedAt` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedByAdminID` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedByEmpID` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedByAdminName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedByEmpName` | `String` | — |

**Example**

```graphql
query Get_client_by_id($internalClientID: String!) {
  get_client_by_id(internalClientID: $internalClientID) {
      clientName
      lat
      lng
      description
      phoneNumber
      address
      proprietorName
      email
      internalClientID
      city
      pinCode
      customFieldsJSON
      isDeleted
      deletedAt
      deletionInfo {
        deletedAt
        deletedByAdminID
        deletedByEmpID
        deletedByAdminName
        deletedByEmpName
      }
  }
}
```

---

### `get_clientv2_by_internalClientID`

**Type:** query &nbsp;·&nbsp; **Returns:** `Clientv2`

**What it does.** Fetches a single v2 client, including its sites and visibility configuration.

**When to use it.** The correct single-client read for new code.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalClientID` | `String` | **Yes** | — |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `clientName` | `String` | — |
| `internalClientID` | `String` | — |
| `customFieldsJSON` | `JSON` | — |
| `isDeleted` | `Boolean` | — |
| `deletedAt` | `Long` | — |
| `deletionInfo` | `ClientDeletionInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedAt` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedByAdminID` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedByEmpID` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedByAdminName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedByEmpName` | `String` | — |

**Example**

```graphql
query Get_clientv2_by_internalClientID($internalClientID: String!) {
  get_clientv2_by_internalClientID(internalClientID: $internalClientID) {
      clientName
      internalClientID
      customFieldsJSON
      isDeleted
      deletedAt
      deletionInfo {
        deletedAt
        deletedByAdminID
        deletedByEmpID
        deletedByAdminName
        deletedByEmpName
      }
  }
}
```

---

### `get_site_pools`

**Type:** query &nbsp;·&nbsp; **Returns:** `[SitePoolInfo!]`

Returns all site pools

**What it does.** Lists site pools — named groups of sites.

**When to use it.** Assigning an employee or territory to a group of locations at once.

**Inputs**

_None._

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `sitePoolID` | `ID` | — |
| `name` | `String` | — |

**Example**

```graphql
query Get_site_pools {
  get_site_pools {
      sitePoolID
      name
  }
}
```

---

### `get_sites`

**Type:** query &nbsp;·&nbsp; **Returns:** `[Site!]`

**What it does.** Lists physical sites with `filters`, `skip` and `take`.

**When to use it.** Syncing store/branch/outlet master data, or resolving the site IDs referenced by tasks and guard assignments.

> ⚠️ The only list endpoint with a structured `filters` argument — use it to narrow server-side instead of filtering after the fetch.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `filters` | `[FilterMetadata!]` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `column` | `FilterColumn` | **Yes** | Values: `CLIENTID`, `INTERNALCLIENTID`, `CREATEDTS`, `CREATEDBYEMPID`, `EMPLOYEEID`, `LATITUDE`, `LONGITUDE`, `PROFILEID`, `CUSTOMENTITYID`, `CUSTOMENTITYNAME`, `ACTIVE`, `TASKID`, `ENTITYTYPE` |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `columnValue` | `[String]` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `comparisonOperator` | `FilterComparisonOperator` | **Yes** | Values: `GTE`, `GT`, `LTE`, `LT`, `EQ`, `NEQ`, `RANGE`, `OUTSIDE_RANGE`, `INCLUDES_LIST` |
| `skip` | `Int` | No | — |
| `take` | `Int` | No | — |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `clientID` | `ID` | — |
| `clientName` | `String` | — |
| `lat` | `Float` | — |
| `lng` | `Float` | — |
| `description` | `String` | — |
| `phoneNumber` | `String` | — |
| `address` | `String` | — |
| `proprietorName` | `String` | — |
| `radius` | `Float` | — |
| `email` | `String` | — |
| `internalClientID` | `String` | — |
| `city` | `String` | — |
| `pinCode` | `String` | — |
| `siteTypeName` | `String` | — |
| `createdTs` | `Long` | — |
| `lastModifiedTs` | `Long` | — |
| `latitude` | `Float` | — |
| `longitude` | `Float` | — |

**Example**

```graphql
query Get_sites($filters: [FilterMetadata!], $skip: Int, $take: Int) {
  get_sites(filters: $filters, skip: $skip, take: $take) {
      clientID
      clientName
      lat
      lng
      description
      phoneNumber
      address
      proprietorName
      radius
      email
      internalClientID
      city
      pinCode
      siteTypeName
      createdTs
      lastModifiedTs
      latitude
      longitude
  }
}
```

---

### `delete_client_external`

**Type:** mutation &nbsp;·&nbsp; **Returns:** `ClientDeleteResponse`

If a client is deleted then all the incomplete tasks associated with this client will be deleted.

**What it does.** Deletes a v1 client and cascades to its incomplete tasks.

**When to use it.** Rarely. Note the cascade: any open task attached to the client disappears with it.

> ⚠️ Destructive with a cascade. Reassign or close outstanding tasks first.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalClientID` | `String` | **Yes** | — |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `rowsDeleted` | `Int` | — |

**Example**

```graphql
mutation Delete_client_external($internalClientID: String!) {
  delete_client_external(internalClientID: $internalClientID) {
      rowsDeleted
  }
}
```

---

### `delete_client_by_id`

**Type:** mutation &nbsp;·&nbsp; **Returns:** `ClientDeleteResponse`

**What it does.** Alternate v1 client delete by `internalClientID`.

**When to use it.** Legacy code paths; behaves as `delete_client_external`.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalClientID` | `String` | **Yes** | — |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `rowsDeleted` | `Int` | — |

**Example**

```graphql
mutation Delete_client_by_id($internalClientID: String!) {
  delete_client_by_id(internalClientID: $internalClientID) {
      rowsDeleted
  }
}
```

---

### `upsert_client_by_id`

**Type:** mutation &nbsp;·&nbsp; **Returns:** `ClientUpsertResponse`

Create or update a client via the external API. First call with an internalClientID creates the client; subsequent calls with the same internalClientID update it.

**What it does.** Creates or updates a v1 client, keyed on `internalClientID`.

**When to use it.** Legacy CRM sync only.

> ⚠️ v1 — use `upsert_clientv2_external` for anything new.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `input` | `ClientInput` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `clientName` | `String` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lat` | `Float` | No | Latitude (required unless address) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lng` | `Float` | No | Longitude (required unless address) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `description` | `String` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `address` | `String` | No | Client address (required unless lat, lng) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `proprietorName` | `String` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `radius` | `Float` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalClientID` | `String` | **Yes** | Client's external identifier (required) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `city` | `String` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `pinCode` | `String` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `clientCat` | `Int` | No | Category of client. 0=End customer, 1=Distributor, 2=Dealer, 3=Supplier, 4=Retailer, 5=Others |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `visibility` | `[ClientVisibilityInput]` | **Yes** | Who can see this client (required) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `type` | `ClientVisibilityType` | **Yes** | Values: `EVERYONE`, `PROFILE`, `EMPLOYEE` |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `internalEmpID` | `String` | No | Employee internal ID (when type is EMPLOYEE) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `profileName` | `String` | No | Team name (when type is PROFILE) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFieldsJSON` | `JSON` | No | Custom fields as a flat JSON object (includes Contact field for V2 clients) |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `rowsInserted` | `Int` | — |
| `rowsUpdated` | `Int` | — |
| `data` | `Client` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `clientName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lat` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lng` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `description` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `address` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `proprietorName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalClientID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `city` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `pinCode` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFieldsJSON` | `JSON` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `isDeleted` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedAt` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletionInfo` | `ClientDeletionInfo` | — |
| `err` | `String` | — |

**Example**

```graphql
mutation Upsert_client_by_id($input: ClientInput!) {
  upsert_client_by_id(input: $input) {
      rowsInserted
      rowsUpdated
      data {
        clientName
        lat
        lng
        description
        phoneNumber
        address
        proprietorName
        email
        internalClientID
        city
        pinCode
        customFieldsJSON
        isDeleted
        deletedAt
      }
      err
  }
}
```

---

### `upsert_clientv2_external`

**Type:** mutation &nbsp;·&nbsp; **Returns:** `Clientv2UpsertResponse`

Create or update a V2 client via the external API (internalClientID omitted = create, provided = update)

**What it does.** Creates or updates a v2 client. Omitting `internalClientID` creates; supplying it updates.

**When to use it.** The primary client write path. Handles sites, custom fields and visibility rules that v1 cannot express.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `input` | `Clientv2Input` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `templateName` | `String` | No | Template name to identify which V2 client template to use (required for EXTERNAL_API) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `clientName` | `String` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalClientID` | `String` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFieldsJSON` | `JSON` | No | Custom fields as a flat JSON object keyed by field name (EXTERNAL_API only) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `visibility` | `[ClientVisibilityInput]` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `type` | `ClientVisibilityType` | **Yes** | Values: `EVERYONE`, `PROFILE`, `EMPLOYEE` |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `internalEmpID` | `String` | No | Employee internal ID (when type is EMPLOYEE) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `profileName` | `String` | No | Team name (when type is PROFILE) |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `rowsInserted` | `Int` | — |
| `rowsUpdated` | `Int` | — |
| `data` | `Clientv2` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `clientName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalClientID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFieldsJSON` | `JSON` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `isDeleted` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedAt` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletionInfo` | `ClientDeletionInfo` | — |
| `err` | `String` | — |

**Example**

```graphql
mutation Upsert_clientv2_external($input: Clientv2Input!) {
  upsert_clientv2_external(input: $input) {
      rowsInserted
      rowsUpdated
      data {
        clientName
        internalClientID
        customFieldsJSON
        isDeleted
        deletedAt
      }
      err
  }
}
```

---

### `delete_clientv2_external`

**Type:** mutation &nbsp;·&nbsp; **Returns:** `Clientv2DeleteResponse`

**What it does.** Deletes a v2 client.

**When to use it.** The v2 delete path. Same caution about dependent tasks and sites applies.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalClientID` | `String` | **Yes** | — |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `rowsDeleted` | `Int` | — |

**Example**

```graphql
mutation Delete_clientv2_external($internalClientID: String!) {
  delete_clientv2_external(internalClientID: $internalClientID) {
      rowsDeleted
  }
}
```

---

### `get_custom_field_upload_urls`

**Type:** mutation &nbsp;·&nbsp; **Returns:** `CustomFieldUploadUrlsResponse`

Get presigned S3 upload URLs for custom field file/image/audio attachments

**What it does.** Presigned S3 URLs for file, image and audio attachments on custom fields.

**When to use it.** When a task or client custom field holds a file. Request the URL, upload to S3, then submit the key in the upsert payload.

> ⚠️ A mutation despite the `get_` prefix.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `input` | `GetCustomFieldUploadUrlsInput` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `count` | `Int` | **Yes** | Number of upload URLs to generate (1-10) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `type` | `CustomFieldUploadType` | **Yes** | Type of upload — determines allowed extensions and size limit Values: `IMAGE`, `FILE`, `AUDIO` |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `extensions` | `[String]` | No | File extensions for each URL (e.g. ['jpg', 'png']). Must match the upload type. Defaults based on type. |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `urls` | `[CustomFieldUploadUrl!]` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `uploadUrl` | `String` | The S3 endpoint URL to POST the form-data to |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `fields` | `String` | JSON string of form fields to include in the POST request |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `fileUrl` | `String` | The full S3 URL of the file after upload — use this value in customFieldsJSON |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `expiresIn` | `Int` | URL expiry time in seconds |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `maxFileSize` | `Int` | Maximum file size in bytes |

**Example**

```graphql
mutation Get_custom_field_upload_urls($input: GetCustomFieldUploadUrlsInput!) {
  get_custom_field_upload_urls(input: $input) {
      urls {
        uploadUrl
        fields
        fileUrl
        expiresIn
        maxFileSize
      }
  }
}
```

---

## 📋 Tasks

Tasks are the unit of field work — a visit, a delivery, a service call. They carry a client, a schedule, an assignee and arbitrary custom fields.

### `get_tasks_by_empIDs_date_range`

**Type:** query &nbsp;·&nbsp; **Returns:** `[Task!]`

Retrieves tasks for employees within a date range. If no employee filter is provided, returns tasks for all employees in the company.

**What it does.** Tasks for employees over a date window. Omitting `internalEmpIDs` returns tasks for everyone.

**When to use it.** The main task read. Your workhorse for reporting and for syncing completed visits back into your system.

> ⚠️ `dateField` changes the meaning of the range entirely. `SCHEDULED` (the default) filters on the planned date; `ACTIVITY` filters on last-modified, which is what you want for incremental sync — it catches tasks edited today but scheduled last week.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalEmpIDs` | `[String]` | No | Filter by employee IDs (as set in your system) |
| `startDate` | `Date` | **Yes** | — |
| `endDate` | `Date` | **Yes** | — |
| `taskType` | `TaskType` | No | Values: `DEFAULT`, `CUSTOMTASK`, `BOTH` |
| `dateField` | `TaskDateField` | No | Which date field to filter by. SCHEDULED (default) uses processingDate; ACTIVITY uses lastModifiedTs to find tasks with employee activity in the date range. Values: `SCHEDULED`, `ACTIVITY` |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `internalTaskID` | `String` | — |
| `internalEmpID` | `String` | Employee ID as set in your system |
| `userInfo` | `User` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `emailID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdTs` | `DateTime` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `countryCallingCode` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `mobileNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `photoPath` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `manufacturer` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `modelNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `active` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `joiningDate` | `Date` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `profileName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `agencyName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalEmpID` | `String` | Employee ID |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designationName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `imgUrl` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `tz` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `city` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `targetCountry` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFields` | `JSON` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userSettings` | `UserSettings` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `isDeleted` | `Boolean` | — |
| `date` | `Date` | — |
| `endDate` | `Date` | — |
| `adminAssigned` | `Int` | — |
| `checkinTime` | `Long` | — |
| `checkoutTime` | `Long` | — |
| `lat` | `Float` | — |
| `lon` | `Float` | — |
| `finishLat` | `Float` | — |
| `finishLon` | `Float` | — |
| `taskDescription` | `String` | — |
| `startTime` | `Long` | — |
| `endTime` | `Long` | — |
| `exitTime` | `Long` | — |
| `address` | `String` | — |
| `timestamp` | `Long` | — |
| `lastUpdatedAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalAdminID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `role` | `AdminRole` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designation` | `Designation` | — |
| `customFieldsJSON` | `JSON` | Custom fields as a flat JSON object (external API only) |
| `createdByAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalAdminID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `role` | `AdminRole` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designation` | `Designation` | — |
| `createdByEmployee` | `User` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `emailID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdTs` | `DateTime` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `countryCallingCode` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `mobileNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `photoPath` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `manufacturer` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `modelNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `active` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `joiningDate` | `Date` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `profileName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `agencyName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalEmpID` | `String` | Employee ID |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designationName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `imgUrl` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `tz` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `city` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `targetCountry` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFields` | `JSON` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userSettings` | `UserSettings` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `isDeleted` | `Boolean` | — |
| `createdTs` | `Long` | — |
| `lastModifiedByEmployee` | `User` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `emailID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdTs` | `DateTime` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `countryCallingCode` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `mobileNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `photoPath` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `manufacturer` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `modelNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `active` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `joiningDate` | `Date` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `profileName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `agencyName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalEmpID` | `String` | Employee ID |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designationName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `imgUrl` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `tz` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `city` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `targetCountry` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFields` | `JSON` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userSettings` | `UserSettings` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `isDeleted` | `Boolean` | — |
| `lastModifiedByAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalAdminID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `role` | `AdminRole` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designation` | `Designation` | — |
| `lastModifiedTs` | `Long` | — |
| `clientInfo` | `Client` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `clientName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lat` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lng` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `description` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `address` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `proprietorName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalClientID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `city` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `pinCode` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFieldsJSON` | `JSON` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `isDeleted` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedAt` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletionInfo` | `ClientDeletionInfo` | — |
| `clientInfoV2` | `Clientv2` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `clientName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalClientID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFieldsJSON` | `JSON` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `isDeleted` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedAt` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletionInfo` | `ClientDeletionInfo` | — |
| `customEntity` | `CustomEntityMetadata` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `companyID` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customEntityName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `description` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `active` | `CustomEntityStatus` | Values: `INACTIVE`, `ACTIVE`, `DELETE` |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `allowRescheduleForEmp` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `allowRescheduleForSelfAssignedTask` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `canEmployeeStartTheTask` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `allowStartPastDateTask` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `allowFollowUpTaskCreation` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customEntitySections` | `[CustomEntitySection!]` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `visibility` | `[CustomEntityVisibility!]` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastModifiedTs` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdTs` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `entityType` | `CustomEntityType` | Values: `TASKS`, `CLIENTS` |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `reducedAuditFields` | `ClientAuditFieldReduced` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `defaultFields` | `[CustomEntityField!]` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customClientSpecificMetadata` | `CustomClientSpecificMetadata` | — |
| `taskCompletionStatus` | `TaskCompletionStatus` | Values: `ON_HOLD`, `COMPLETED`, `DELAYED`, `NOT_STARTED`, `IN_PROGRESS` |
| `holdOrReschedule` | `Int` | — |
| `holdOrRescheduleComment` | `String` | — |
| `lastAction` | `TaskAuditEvent` | Display-ready label for what happened on this audit row. Derived per-row from the audit lifecycle action + status transition + holdOrReschedule. Populated only by get_task_history_by_adminID_date_range. Values: `CREATED`, `MODIFIED`, `RESCHEDULED`, `ON_HOLD`, `COMPLETED`, `DELETED` |

**Example**

```graphql
query Get_tasks_by_empIDs_date_range($internalEmpIDs: [String], $startDate: Date!, $endDate: Date!, $taskType: TaskType, $dateField: TaskDateField) {
  get_tasks_by_empIDs_date_range(internalEmpIDs: $internalEmpIDs, startDate: $startDate, endDate: $endDate, taskType: $taskType, dateField: $dateField) {
      internalTaskID
      internalEmpID
      userInfo {
        userID
        firstName
        lastName
        emailID
        createdTs
        countryCallingCode
        phoneNumber
        mobileNumber
        photoPath
        manufacturer
        modelNumber
        active
        joiningDate
        profileName
        agencyName
        internalEmpID
        designationName
        imgUrl
        tz
        city
        targetCountry
        customFields
        isDeleted
      }
      date
      endDate
      adminAssigned
      checkinTime
      checkoutTime
      lat
      lon
      finishLat
      finishLon
      taskDescription
      startTime
      endTime
      exitTime
      address
      timestamp
      lastUpdatedAdmin {
        internalAdminID
        email
        firstname
        lastname
        phoneNumber
        parentAdmin
      }
      customFieldsJSON
      createdByAdmin {
        internalAdminID
        email
        firstname
        lastname
        phoneNumber
        parentAdmin
      }
      createdByEmployee {
        userID
        firstName
        lastName
        emailID
        createdTs
        countryCallingCode
        phoneNumber
        mobileNumber
        photoPath
        manufacturer
        modelNumber
        active
        joiningDate
        profileName
        agencyName
        internalEmpID
        designationName
        imgUrl
        tz
        city
        targetCountry
        customFields
        isDeleted
      }
      createdTs
      lastModifiedByEmployee {
        userID
        firstName
        lastName
        emailID
        createdTs
        countryCallingCode
        phoneNumber
        mobileNumber
        photoPath
        manufacturer
        modelNumber
        active
        joiningDate
        profileName
        agencyName
        internalEmpID
        designationName
        imgUrl
        tz
        city
        targetCountry
        customFields
        isDeleted
      }
      lastModifiedByAdmin {
        internalAdminID
        email
        firstname
        lastname
        phoneNumber
        parentAdmin
      }
      lastModifiedTs
      clientInfo {
        clientName
        lat
        lng
        description
        phoneNumber
        address
        proprietorName
        email
        internalClientID
        city
        pinCode
        customFieldsJSON
        isDeleted
        deletedAt
      }
      clientInfoV2 {
        clientName
        internalClientID
        customFieldsJSON
        isDeleted
        deletedAt
      }
      customEntity {
        companyID
        customEntityName
        description
        active
        allowRescheduleForEmp
        allowRescheduleForSelfAssignedTask
        canEmployeeStartTheTask
        allowStartPastDateTask
        allowFollowUpTaskCreation
        lastModifiedTs
        createdTs
        entityType
      }
      taskCompletionStatus
      holdOrReschedule
      holdOrRescheduleComment
      lastAction
  }
}
```

---

### `get_task_by_id`

**Type:** query &nbsp;·&nbsp; **Returns:** `Task`

Retrieves a task by it's ID

**What it does.** Retrieves one task by its `internalTaskID`.

**When to use it.** Detail views, or confirming the result of a write.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalTaskID` | `String` | **Yes** | ID of the task |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `internalTaskID` | `String` | — |
| `internalEmpID` | `String` | Employee ID as set in your system |
| `userInfo` | `User` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `emailID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdTs` | `DateTime` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `countryCallingCode` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `mobileNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `photoPath` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `manufacturer` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `modelNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `active` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `joiningDate` | `Date` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `profileName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `agencyName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalEmpID` | `String` | Employee ID |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designationName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `imgUrl` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `tz` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `city` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `targetCountry` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFields` | `JSON` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userSettings` | `UserSettings` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `isDeleted` | `Boolean` | — |
| `date` | `Date` | — |
| `endDate` | `Date` | — |
| `adminAssigned` | `Int` | — |
| `checkinTime` | `Long` | — |
| `checkoutTime` | `Long` | — |
| `lat` | `Float` | — |
| `lon` | `Float` | — |
| `finishLat` | `Float` | — |
| `finishLon` | `Float` | — |
| `taskDescription` | `String` | — |
| `startTime` | `Long` | — |
| `endTime` | `Long` | — |
| `exitTime` | `Long` | — |
| `address` | `String` | — |
| `timestamp` | `Long` | — |
| `lastUpdatedAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalAdminID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `role` | `AdminRole` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designation` | `Designation` | — |
| `customFieldsJSON` | `JSON` | Custom fields as a flat JSON object (external API only) |
| `createdByAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalAdminID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `role` | `AdminRole` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designation` | `Designation` | — |
| `createdByEmployee` | `User` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `emailID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdTs` | `DateTime` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `countryCallingCode` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `mobileNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `photoPath` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `manufacturer` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `modelNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `active` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `joiningDate` | `Date` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `profileName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `agencyName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalEmpID` | `String` | Employee ID |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designationName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `imgUrl` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `tz` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `city` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `targetCountry` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFields` | `JSON` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userSettings` | `UserSettings` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `isDeleted` | `Boolean` | — |
| `createdTs` | `Long` | — |
| `lastModifiedByEmployee` | `User` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `emailID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdTs` | `DateTime` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `countryCallingCode` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `mobileNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `photoPath` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `manufacturer` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `modelNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `active` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `joiningDate` | `Date` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `profileName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `agencyName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalEmpID` | `String` | Employee ID |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designationName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `imgUrl` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `tz` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `city` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `targetCountry` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFields` | `JSON` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userSettings` | `UserSettings` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `isDeleted` | `Boolean` | — |
| `lastModifiedByAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalAdminID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `role` | `AdminRole` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designation` | `Designation` | — |
| `lastModifiedTs` | `Long` | — |
| `clientInfo` | `Client` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `clientName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lat` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lng` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `description` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `address` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `proprietorName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalClientID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `city` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `pinCode` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFieldsJSON` | `JSON` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `isDeleted` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedAt` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletionInfo` | `ClientDeletionInfo` | — |
| `clientInfoV2` | `Clientv2` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `clientName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalClientID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFieldsJSON` | `JSON` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `isDeleted` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedAt` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletionInfo` | `ClientDeletionInfo` | — |
| `customEntity` | `CustomEntityMetadata` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `companyID` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customEntityName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `description` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `active` | `CustomEntityStatus` | Values: `INACTIVE`, `ACTIVE`, `DELETE` |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `allowRescheduleForEmp` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `allowRescheduleForSelfAssignedTask` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `canEmployeeStartTheTask` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `allowStartPastDateTask` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `allowFollowUpTaskCreation` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customEntitySections` | `[CustomEntitySection!]` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `visibility` | `[CustomEntityVisibility!]` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastModifiedTs` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdTs` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `entityType` | `CustomEntityType` | Values: `TASKS`, `CLIENTS` |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `reducedAuditFields` | `ClientAuditFieldReduced` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `defaultFields` | `[CustomEntityField!]` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customClientSpecificMetadata` | `CustomClientSpecificMetadata` | — |
| `taskCompletionStatus` | `TaskCompletionStatus` | Values: `ON_HOLD`, `COMPLETED`, `DELAYED`, `NOT_STARTED`, `IN_PROGRESS` |
| `holdOrReschedule` | `Int` | — |
| `holdOrRescheduleComment` | `String` | — |
| `lastAction` | `TaskAuditEvent` | Display-ready label for what happened on this audit row. Derived per-row from the audit lifecycle action + status transition + holdOrReschedule. Populated only by get_task_history_by_adminID_date_range. Values: `CREATED`, `MODIFIED`, `RESCHEDULED`, `ON_HOLD`, `COMPLETED`, `DELETED` |

**Example**

```graphql
query Get_task_by_id($internalTaskID: String!) {
  get_task_by_id(internalTaskID: $internalTaskID) {
      internalTaskID
      internalEmpID
      userInfo {
        userID
        firstName
        lastName
        emailID
        createdTs
        countryCallingCode
        phoneNumber
        mobileNumber
        photoPath
        manufacturer
        modelNumber
        active
        joiningDate
        profileName
        agencyName
        internalEmpID
        designationName
        imgUrl
        tz
        city
        targetCountry
        customFields
        isDeleted
      }
      date
      endDate
      adminAssigned
      checkinTime
      checkoutTime
      lat
      lon
      finishLat
      finishLon
      taskDescription
      startTime
      endTime
      exitTime
      address
      timestamp
      lastUpdatedAdmin {
        internalAdminID
        email
        firstname
        lastname
        phoneNumber
        parentAdmin
      }
      customFieldsJSON
      createdByAdmin {
        internalAdminID
        email
        firstname
        lastname
        phoneNumber
        parentAdmin
      }
      createdByEmployee {
        userID
        firstName
        lastName
        emailID
        createdTs
        countryCallingCode
        phoneNumber
        mobileNumber
        photoPath
        manufacturer
        modelNumber
        active
        joiningDate
        profileName
        agencyName
        internalEmpID
        designationName
        imgUrl
        tz
        city
        targetCountry
        customFields
        isDeleted
      }
      createdTs
      lastModifiedByEmployee {
        userID
        firstName
        lastName
        emailID
        createdTs
        countryCallingCode
        phoneNumber
        mobileNumber
        photoPath
        manufacturer
        modelNumber
        active
        joiningDate
        profileName
        agencyName
        internalEmpID
        designationName
        imgUrl
        tz
        city
        targetCountry
        customFields
        isDeleted
      }
      lastModifiedByAdmin {
        internalAdminID
        email
        firstname
        lastname
        phoneNumber
        parentAdmin
      }
      lastModifiedTs
      clientInfo {
        clientName
        lat
        lng
        description
        phoneNumber
        address
        proprietorName
        email
        internalClientID
        city
        pinCode
        customFieldsJSON
        isDeleted
        deletedAt
      }
      clientInfoV2 {
        clientName
        internalClientID
        customFieldsJSON
        isDeleted
        deletedAt
      }
      customEntity {
        companyID
        customEntityName
        description
        active
        allowRescheduleForEmp
        allowRescheduleForSelfAssignedTask
        canEmployeeStartTheTask
        allowStartPastDateTask
        allowFollowUpTaskCreation
        lastModifiedTs
        createdTs
        entityType
      }
      taskCompletionStatus
      holdOrReschedule
      holdOrRescheduleComment
      lastAction
  }
}
```

---

### `get_eligible_employees_for_custom_task`

**Type:** query &nbsp;·&nbsp; **Returns:** `[EligibleEmployee!]`

**What it does.** Lists employees permitted to take a named custom task, optionally scoped to a client.

**When to use it.** Populating an assignee dropdown so you never submit an invalid assignment.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `customTaskName` | `String` | **Yes** | — |
| `internalClientID` | `String` | No | — |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `internalEmpID` | `String` | Employee identifier as set in your system (the value to pass as internalEmpID). |
| `employeeName` | `String` | Display name (first + last). |
| `employeeID` | `Int` | Internal numeric employee ID. |

**Example**

```graphql
query Get_eligible_employees_for_custom_task($customTaskName: String!, $internalClientID: String) {
  get_eligible_employees_for_custom_task(customTaskName: $customTaskName, internalClientID: $internalClientID) {
      internalEmpID
      employeeName
      employeeID
  }
}
```

---

### `upsert_task_external`

**Type:** mutation &nbsp;·&nbsp; **Returns:** `TaskUpsertResponse`

Create or update a task via the external API (internalTaskID omitted = create, provided = update)

**What it does.** Creates or updates a task. Omit `internalTaskID` to create, supply it to update.

**When to use it.** Pushing work from your scheduler into Unolo. The standard task write when you already know the assignee.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `input` | `TaskInput` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalTaskID` | `String` | No | Task's external identifier. Required for external API create/edit — every task touched via external API must carry a unique partner-supplied reference. |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `date` | `Date` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `endDate` | `Date` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lat` | `Float` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lon` | `Float` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `startTime` | `Long` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `endTime` | `Long` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `address` | `String` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalEmpID` | `String` | **Yes** | Employee ID as set in your system (required) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customTaskName` | `String` | **Yes** | Custom task type name (required) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFieldsJSON` | `JSON` | No | Custom fields as a flat JSON object |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `rowsInserted` | `Int` | — |
| `rowsUpdated` | `Int` | — |
| `data` | `[Task]` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalTaskID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalEmpID` | `String` | Employee ID as set in your system |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userInfo` | `User` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `date` | `Date` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `endDate` | `Date` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `adminAssigned` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `checkinTime` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `checkoutTime` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lat` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lon` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `finishLat` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `finishLon` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `taskDescription` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `startTime` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `endTime` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `exitTime` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `address` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `timestamp` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastUpdatedAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFieldsJSON` | `JSON` | Custom fields as a flat JSON object (external API only) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdByAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdByEmployee` | `User` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdTs` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastModifiedByEmployee` | `User` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastModifiedByAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastModifiedTs` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `clientInfo` | `Client` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `clientInfoV2` | `Clientv2` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customEntity` | `CustomEntityMetadata` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `taskCompletionStatus` | `TaskCompletionStatus` | Values: `ON_HOLD`, `COMPLETED`, `DELAYED`, `NOT_STARTED`, `IN_PROGRESS` |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `holdOrReschedule` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `holdOrRescheduleComment` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastAction` | `TaskAuditEvent` | Display-ready label for what happened on this audit row. Derived per-row from the audit lifecycle action + status transition + holdOrReschedule. Populated only by get_task_history_by_adminID_date_range. Values: `CREATED`, `MODIFIED`, `RESCHEDULED`, `ON_HOLD`, `COMPLETED`, `DELETED` |

**Example**

```graphql
mutation Upsert_task_external($input: TaskInput!) {
  upsert_task_external(input: $input) {
      rowsInserted
      rowsUpdated
      data {
        internalTaskID
        internalEmpID
        date
        endDate
        adminAssigned
        checkinTime
        checkoutTime
        lat
        lon
        finishLat
        finishLon
        taskDescription
        startTime
        endTime
        exitTime
        address
        timestamp
        customFieldsJSON
        createdTs
        lastModifiedTs
        taskCompletionStatus
        holdOrReschedule
        holdOrRescheduleComment
        lastAction
      }
  }
}
```

---

### `delete_task_external`

**Type:** mutation &nbsp;·&nbsp; **Returns:** `TaskDeleteResponse`

Delete a task via the external API by its internalTaskID

**What it does.** Deletes a task by `internalTaskID`.

**When to use it.** Cancellations. There is no soft-delete — the record is gone.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalTaskID` | `String` | **Yes** | — |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `rowsDeleted` | `Int` | — |

**Example**

```graphql
mutation Delete_task_external($internalTaskID: String!) {
  delete_task_external(internalTaskID: $internalTaskID) {
      rowsDeleted
  }
}
```

---

### `upsert_task_to_best_employee`

**Type:** mutation &nbsp;·&nbsp; **Returns:** `[FindBestEmployeeResponse!]`

Creates or updates a task and auto-assigns the best-fit employee via the task type's Find Best Employee rules. Accepts a batch; per item: autoAssign true assigns and creates the task, autoAssign false only suggests, and a manual internalEmpID override always wins.

**What it does.** Accepts an array of tasks and auto-assigns each to the best-fit employee using the task type's Find Best Employee rules.

**When to use it.** Bulk dispatch where you do not want to pick the assignee yourself. Let Unolo apply proximity, skill and workload rules.

> ⚠️ Batch endpoint — the input is a list and the response is a list. Inspect each element for per-task success; a partial failure will not fail the whole call.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `input` | `[FindBestEmployeeTaskInput!]` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customTaskName` | `String` | **Yes** | Custom task type name (required) — the task type whose allocation rules drive the engine. |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `autoAssign` | `Boolean` | **Yes** | When true and the engine returns a winner, the task is created and assigned to that employee (atomic create-and-assign). When false, the best-fit employee is returned but no task is created. |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalEmpID` | `String` | No | Explicit employee override (as set in your system). When provided the engine is bypassed and the task is assigned to this employee — autoAssign is ignored. (when customTaskName is set) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalTaskID` | `String` | No | Task's external identifier. Required when a task is actually created. |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `endDate` | `Date` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `startTime` | `Long` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `endTime` | `Long` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFieldsJSON` | `JSON` | No | Custom fields as a flat JSON object. |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `index` | `Int` | Position of this result in the bulk input array (0-based), so callers can correlate. |
| `internalTaskID` | `String` | Echo of the input's internalTaskID, so bulk results can be matched back to requests. |
| `internalEmpID` | `String` | The matched employee (as set in your system), or null when no one qualified. |
| `employeeName` | `String` | The matched employee's display name (first + last), or null when no one qualified. |
| `reasonCode` | `String` | Machine-readable outcome: ASSIGNED, ASSIGNED_OVERRIDE, SUGGESTED, RULES_NOT_CONFIGURED, NO_VISIBLE_EMPLOYEES, ALL_OFF_SHIFT, ALL_OVERLOADED, NO_CANDIDATES, NO_RANKING_RULE, NO_TASK_LOCATION, ERROR (this input failed; others are unaffected). |
| `reason` | `String` | Human-readable reason, e.g. 'on-shift xb7 1.2 km xb7 2 open tasks'. On ERROR, the failure message. |
| `initialCandidateCount` | `Int` | The number of visible candidate employees before any rule ran (the initial pool size). |
| `attrition` | `[RuleAttrition!]` | Per-rule elimination counts (zero-candidate case). |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `ruleName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `eliminatedCount` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `remainingCount` | `Int` | — |
| `taskCreated` | `Boolean` | Whether a task row was actually created. |
| `data` | `[Task]` | The created task, when taskCreated is true. |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalTaskID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalEmpID` | `String` | Employee ID as set in your system |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userInfo` | `User` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `date` | `Date` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `endDate` | `Date` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `adminAssigned` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `checkinTime` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `checkoutTime` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lat` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lon` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `finishLat` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `finishLon` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `taskDescription` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `startTime` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `endTime` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `exitTime` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `address` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `timestamp` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastUpdatedAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFieldsJSON` | `JSON` | Custom fields as a flat JSON object (external API only) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdByAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdByEmployee` | `User` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdTs` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastModifiedByEmployee` | `User` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastModifiedByAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastModifiedTs` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `clientInfo` | `Client` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `clientInfoV2` | `Clientv2` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customEntity` | `CustomEntityMetadata` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `taskCompletionStatus` | `TaskCompletionStatus` | Values: `ON_HOLD`, `COMPLETED`, `DELAYED`, `NOT_STARTED`, `IN_PROGRESS` |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `holdOrReschedule` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `holdOrRescheduleComment` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastAction` | `TaskAuditEvent` | Display-ready label for what happened on this audit row. Derived per-row from the audit lifecycle action + status transition + holdOrReschedule. Populated only by get_task_history_by_adminID_date_range. Values: `CREATED`, `MODIFIED`, `RESCHEDULED`, `ON_HOLD`, `COMPLETED`, `DELETED` |

**Example**

```graphql
mutation Upsert_task_to_best_employee($input: [FindBestEmployeeTaskInput!]!) {
  upsert_task_to_best_employee(input: $input) {
      index
      internalTaskID
      internalEmpID
      employeeName
      reasonCode
      reason
      initialCandidateCount
      attrition {
        ruleName
        eliminatedCount
        remainingCount
      }
      taskCreated
      data {
        internalTaskID
        internalEmpID
        date
        endDate
        adminAssigned
        checkinTime
        checkoutTime
        lat
        lon
        finishLat
        finishLon
        taskDescription
        startTime
        endTime
        exitTime
        address
        timestamp
        customFieldsJSON
        createdTs
        lastModifiedTs
        taskCompletionStatus
        holdOrReschedule
        holdOrRescheduleComment
        lastAction
      }
  }
}
```

---

## 🛒 Orders

Read-only. Orders are created in the Unolo mobile app by field staff; the API exposes them for pulling into your ERP or billing system.

### `get_orders_by_date_range`

**Type:** query &nbsp;·&nbsp; **Returns:** `[Order]`

Get all orders in a specific date range

**What it does.** Orders in a date range, optionally filtered by employee and client.

**When to use it.** Nightly pull of field orders into your ERP, billing or inventory system.

> ⚠️ Read-only — there is no order-creation mutation. All arguments are optional, so an unfiltered call can return a very large set; always bound the dates.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalEmpIDs` | `[String]` | No | Filter by employee IDs (as set in your system) |
| `startDate` | `Date` | No | — |
| `endDate` | `Date` | No | — |
| `internalClientIDs` | `[String]` | No | Filter by client IDs (as set in your system) |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `internalOrderID` | `String` | — |
| `invoiceNumber` | `String` | — |
| `client` | `Client` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `clientName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lat` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lng` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `description` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `address` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `proprietorName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalClientID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `city` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `pinCode` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFieldsJSON` | `JSON` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `isDeleted` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedAt` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletionInfo` | `ClientDeletionInfo` | — |
| `clientv2` | `Clientv2` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `clientName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalClientID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFieldsJSON` | `JSON` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `isDeleted` | `Boolean` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletedAt` | `Long` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `deletionInfo` | `ClientDeletionInfo` | — |
| `isCustomClientsEnabled` | `Boolean` | — |
| `lat` | `Float` | — |
| `lon` | `Float` | — |
| `recipients` | `[OrderRecipient]` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | — |
| `internalEmpID` | `String` | Employee ID as set in your system |
| `processingDate` | `Date` | — |
| `orderItems` | `[OrderItem]` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `skuID` | `ID` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `sku` | `SKU` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `productDescription` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `quantity` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `price` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `listPrice` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `discAmt` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `amount` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `discountPercentage` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `discountAmount` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `totalTaxAmount` | `Float` | — |
| `orderValue` | `Float` | — |
| `taxValue` | `Float` | — |
| `payments` | `[OrderPayment]` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `amount` | `Float` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `paymentType` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `orderPaymentID` | `ID` | — |
| `paymentCollected` | `Float` | — |
| `customFields` | `JSON` | — |
| `userInfo` | `User` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `emailID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdTs` | `DateTime` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `countryCallingCode` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `mobileNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `photoPath` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `manufacturer` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `modelNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `active` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `joiningDate` | `Date` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `profileName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `agencyName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalEmpID` | `String` | Employee ID |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designationName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `imgUrl` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `tz` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `city` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `targetCountry` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFields` | `JSON` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userSettings` | `UserSettings` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `isDeleted` | `Boolean` | — |
| `createdTs` | `Long` | — |
| `lastModifiedTs` | `Long` | — |
| `otpVerified` | `Int` | — |

**Example**

```graphql
query Get_orders_by_date_range($internalEmpIDs: [String], $startDate: Date, $endDate: Date, $internalClientIDs: [String]) {
  get_orders_by_date_range(internalEmpIDs: $internalEmpIDs, startDate: $startDate, endDate: $endDate, internalClientIDs: $internalClientIDs) {
      internalOrderID
      invoiceNumber
      client {
        clientName
        lat
        lng
        description
        phoneNumber
        address
        proprietorName
        email
        internalClientID
        city
        pinCode
        customFieldsJSON
        isDeleted
        deletedAt
      }
      clientv2 {
        clientName
        internalClientID
        customFieldsJSON
        isDeleted
        deletedAt
      }
      isCustomClientsEnabled
      lat
      lon
      recipients {
        email
      }
      internalEmpID
      processingDate
      orderItems {
        skuID
        productDescription
        quantity
        price
        listPrice
        discAmt
        amount
        discountPercentage
        discountAmount
        totalTaxAmount
      }
      orderValue
      taxValue
      payments {
        amount
        paymentType
        orderPaymentID
      }
      paymentCollected
      customFields
      userInfo {
        userID
        firstName
        lastName
        emailID
        createdTs
        countryCallingCode
        phoneNumber
        mobileNumber
        photoPath
        manufacturer
        modelNumber
        active
        joiningDate
        profileName
        agencyName
        internalEmpID
        designationName
        imgUrl
        tz
        city
        targetCountry
        customFields
        isDeleted
      }
      createdTs
      lastModifiedTs
      otpVerified
  }
}
```

---

## 📦 Products (SKUs)

SKUs are the catalogue field staff pick from when raising an order. Images are uploaded to S3 out-of-band via presigned URLs.

### `get_skus`

**Type:** query &nbsp;·&nbsp; **Returns:** `[SKU!]`

Get all products (SKUs)

**What it does.** Returns the product catalogue, filterable by employee (who can sell what) or by specific SKU IDs.

**When to use it.** Syncing your catalogue, or checking which products a given rep is allowed to order.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalEmpIDs` | `[String]` | No | Filter by employee IDs (as set in your system) |
| `skuIDs` | `[String]` | No | Filter by SKU IDs. For external API callers, pass the SKU IDs as set in your system (internalSkuID); they are resolved internally. |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `skuName` | `String` | — |
| `skuDescription` | `String` | — |
| `internalSkuID` | `String` | — |
| `active` | `Boolean` | — |
| `category` | `String` | — |
| `listPrice` | `Float` | — |
| `gstRate` | `Float` | — |
| `discRate` | `Float` | — |
| `skuImage1` | `String` | — |
| `skuImage2` | `String` | — |
| `skuImage3` | `String` | — |
| `showGstRate` | `Int` | — |
| `showDiscAmt` | `Int` | — |
| `customFields` | `JSON` | — |
| `lastModifiedTs` | `Long` | — |
| `createdTs` | `Long` | — |
| `visibility` | `[SKUVisibility!]` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `type` | `visibilityType` | Values: `EVERYONE`, `PROFILE` |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `profileName` | `String` | Team name (when type is PROFILE) |

**Example**

```graphql
query Get_skus($internalEmpIDs: [String], $skuIDs: [String]) {
  get_skus(internalEmpIDs: $internalEmpIDs, skuIDs: $skuIDs) {
      skuName
      skuDescription
      internalSkuID
      active
      category
      listPrice
      gstRate
      discRate
      skuImage1
      skuImage2
      skuImage3
      showGstRate
      showDiscAmt
      customFields
      lastModifiedTs
      createdTs
      visibility {
        type
        profileName
      }
  }
}
```

---

### `upsert_skus`

**Type:** mutation &nbsp;·&nbsp; **Returns:** `BatchInputResponse`

Mutation to create Products (SKUs)

**What it does.** Bulk create/update of products. Takes an array of SKUs plus an `uploadFlag`.

**When to use it.** Catalogue sync from your PIM or ERP. Batch your changes rather than calling once per SKU.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `input` | `[SKUInput!]` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `skuName` | `String` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `skuDescription` | `String` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalSkuID` | `String` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `active` | `Boolean` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `category` | `String` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `listPrice` | `Float` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `gstRate` | `Float` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `discRate` | `Float` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `showGstRate` | `Int` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `showDiscAmt` | `Int` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `skuImage1` | `String` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `skuImage2` | `String` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `skuImage3` | `String` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFields` | `JSON` | No | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastModifiedTs` | `Long` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdTs` | `Long` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `visibility` | `[SKUVisibilityInput]` | **Yes** | Who can see this SKU (required) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `type` | `visibilityType` | **Yes** | Values: `EVERYONE`, `PROFILE` |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `profileName` | `String` | No | Team name (required when type is PROFILE) |
| `uploadFlag` | `Boolean` | No | — |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `failed` | `[String!]` | — |

**Example**

```graphql
mutation Upsert_skus($input: [SKUInput!]!, $uploadFlag: Boolean) {
  upsert_skus(input: $input, uploadFlag: $uploadFlag) {
      failed
  }
}
```

---

### `get_sku_image_upload_urls`

**Type:** mutation &nbsp;·&nbsp; **Returns:** `SKUImageUploadUrlsResponse`

Get presigned S3 URLs for uploading SKU images (External API only)

**What it does.** Returns presigned S3 URLs for product images.

**When to use it.** Step one of a two-step image flow: request URLs here, `PUT` the image bytes directly to S3, then reference the resulting key in `upsert_skus`.

> ⚠️ A mutation despite the `get_` prefix. The presigned URLs are short-lived — upload promptly.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `input` | `GetSKUImageUploadUrlsInput` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `count` | `Int` | **Yes** | Number of upload URLs to generate (1-3) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `extensions` | `[String]` | No | Optional file extensions for each image (e.g., ['jpg', 'png']). Defaults to 'jpg' |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `urls` | `[SKUImageUploadUrl!]` | List of presigned URLs and their corresponding keys |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `uploadUrl` | `String` | The S3 endpoint URL to POST the form-data to |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `fields` | `String` | JSON string of form fields to include in the POST request |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `imageKey` | `String` | The S3 key to use when referencing this image in upsert_skus (skuImage1/2/3) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `expiresIn` | `Int` | URL expiry time in seconds (180 = 3 minutes) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `maxFileSize` | `Int` | Maximum file size in bytes (500KB = 512000) |

**Example**

```graphql
mutation Get_sku_image_upload_urls($input: GetSKUImageUploadUrlsInput!) {
  get_sku_image_upload_urls(input: $input) {
      urls {
        uploadUrl
        fields
        imageKey
        expiresIn
        maxFileSize
      }
  }
}
```

---

## 🏖️ Leaves

Leave data is read-only over the external API. The hierarchy is policy → leave type → individual leave record.

### `get_leave_policies_by_companyID`

**Type:** query &nbsp;·&nbsp; **Returns:** `[LeavePolicy!]`

Returns all leave policies configured for your company, including policy details, associated leave types and their configurations (accrual rules, carry-forward settings, etc.).

**What it does.** All leave policies with their associated leave types and configuration.

**When to use it.** Understanding accrual and entitlement rules before you interpret leave records.

**Inputs**

_None._

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `policyName` | `String` | Name of the leave policy |
| `policyPeriod` | `PolicyPeriod` | Period type the policy follows — CALENDAR_YEAR, FINANCIAL_YEAR, or CUSTOM Values: `CALENDAR_YEAR`, `FINANCIAL_YEAR`, `CUSTOM` |
| `startMonth` | `Int` | Month (1-12) when the policy period starts |
| `startYear` | `Int` | Year when the policy period starts |
| `policyDescription` | `String` | Optional description of the leave policy |
| `policyDocs` | `[policyDoc!]` | Documents attached to this policy |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `url` | `String` | URL of the document |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `description` | `String` | Description of the document |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `name` | `String` | File name of the document |
| `isSoftDeleted` | `Boolean` | — |
| `createdTs` | `Long` | Epoch milliseconds timestamp of when the policy was created |
| `lastModifiedTs` | `Long` | Epoch milliseconds timestamp of when the policy was last modified |
| `policyLeaveTypes` | `[PolicyLeaveType!]` | Leave types configured under this policy with their accrual, restriction, and other settings |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdTs` | `Long` | Epoch milliseconds timestamp of when this policy-leave-type association was created |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastModifiedTs` | `Long` | Epoch milliseconds timestamp of when this policy-leave-type association was last modified |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `leaveType` | `LeaveTypeV2` | The leave type details (name, category, description) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `accrualConfig` | `PolicyLeaveTypeAccrual` | Accrual/allocation configuration — yearly quota, frequency, custom monthly allocation, etc. |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `applicationConfig` | `PolicyLeaveTypeApplication` | Application rules — half-day allowed, backdated limit, prior notice requirements, etc. |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `restrictionConfigs` | `[PolicyLeaveTypeRestriction!]` | Restrictions on leave applications — max consecutive days, monthly limits, mandatory gap days, etc. |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `sandwichConfig` | `PolicyLeaveTypeSandwich` | Sandwich rule configuration — whether weekly-offs/holidays between leaves are counted as leave days |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `eoyConfig` | `PolicyLeaveTypeEOY` | End-of-year configuration — carry-forward rules and limits |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `carryForwardOverflowRules` | `[PolicyLeaveTypeCarryForwardOverflow!]` | Rules for overflowing excess carry-forward balance into other leave types |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `probationConfig` | `PolicyLeaveTypeProbation` | Probation period configuration — accrual rates and restrictions during probation |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `compOffConfig` | `PolicyLeaveTypeCompOff` | Comp-off configuration — auto-grant rules, employee request settings, etc. |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `combinedThresholdLimits` | `[CombinedThresholdLimit!]` | Combined threshold limits across multiple leave types for balance or carry-forward caps |
| `employees` | `[User]` | Employees assigned to this policy |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `emailID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdTs` | `DateTime` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `countryCallingCode` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `mobileNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `photoPath` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `manufacturer` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `modelNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `active` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `joiningDate` | `Date` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `profileName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `agencyName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalEmpID` | `String` | Employee ID |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designationName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `imgUrl` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `tz` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `city` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `targetCountry` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `customFields` | `JSON` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userSettings` | `UserSettings` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `isDeleted` | `Boolean` | — |
| `createdByAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalAdminID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `role` | `AdminRole` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designation` | `Designation` | — |
| `lastModifiedByAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalAdminID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `role` | `AdminRole` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designation` | `Designation` | — |

**Example**

```graphql
query Get_leave_policies_by_companyID {
  get_leave_policies_by_companyID {
      policyName
      policyPeriod
      startMonth
      startYear
      policyDescription
      policyDocs {
        url
        description
        name
      }
      isSoftDeleted
      createdTs
      lastModifiedTs
      policyLeaveTypes {
        createdTs
        lastModifiedTs
      }
      employees {
        userID
        firstName
        lastName
        emailID
        createdTs
        countryCallingCode
        phoneNumber
        mobileNumber
        photoPath
        manufacturer
        modelNumber
        active
        joiningDate
        profileName
        agencyName
        internalEmpID
        designationName
        imgUrl
        tz
        city
        targetCountry
        customFields
        isDeleted
      }
      createdByAdmin {
        internalAdminID
        email
        firstname
        lastname
        phoneNumber
        parentAdmin
      }
      lastModifiedByAdmin {
        internalAdminID
        email
        firstname
        lastname
        phoneNumber
        parentAdmin
      }
  }
}
```

---

### `get_leave_typesv2_by_companyID`

**Type:** query &nbsp;·&nbsp; **Returns:** `[LeaveTypeV2!]`

Returns all leave types defined for your company (e.g. Casual Leave, Sick Leave, Comp-off). Each entry includes the type name, category (REGULAR, INCIDENT, UNPAID, COMPOFF) and description.

**What it does.** All leave types — Casual, Sick, Comp-off and so on.

**When to use it.** Resolving the type IDs that appear on individual leave records.

**Inputs**

_None._

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `leaveType` | `String` | Name of the leave type (e.g. Casual Leave, Sick Leave) |
| `leaveCategory` | `LeaveCategory` | Category — REGULAR, INCIDENT, UNPAID, or COMPOFF Values: `REGULAR`, `INCIDENT`, `UNPAID`, `COMPOFF`, `EARNED_LEAVE` |
| `description` | `String` | Optional description of the leave type |
| `createdTs` | `Long` | Epoch milliseconds timestamp of when the leave type was created |
| `lastModifiedTs` | `Long` | Epoch milliseconds timestamp of when the leave type was last modified |
| `createdByAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalAdminID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `role` | `AdminRole` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designation` | `Designation` | — |
| `lastModifiedByAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalAdminID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `email` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `firstname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastname` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `phoneNumber` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `role` | `AdminRole` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `parentAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `designation` | `Designation` | — |

**Example**

```graphql
query Get_leave_typesv2_by_companyID {
  get_leave_typesv2_by_companyID {
      leaveType
      leaveCategory
      description
      createdTs
      lastModifiedTs
      createdByAdmin {
        internalAdminID
        email
        firstname
        lastname
        phoneNumber
        parentAdmin
      }
      lastModifiedByAdmin {
        internalAdminID
        email
        firstname
        lastname
        phoneNumber
        parentAdmin
      }
  }
}
```

---

### `get_leavesv2_for_employees`

**Type:** query &nbsp;·&nbsp; **Returns:** `LeavesResponseV2`

Retrieves leave records for employees within a date range. Supports filtering by leave status (PENDING, APPROVED, REJECTED, WITHDRAW) and request type. If no employee filter is provided, returns leaves for all employees in the company.

**What it does.** Leave records for a date range, filterable by employee, status (`PENDING`/`APPROVED`/`REJECTED`) and request type.

**When to use it.** Payroll runs and availability checks.

> ⚠️ Read-only — leaves cannot be created or approved through this API. Filter on `leaveStatus` server-side rather than pulling everything.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalEmpIDs` | `[String]` | No | Filter by employee IDs (as set in your system) |
| `fromDate` | `Date` | **Yes** | Start of date range (inclusive) |
| `toDate` | `Date` | **Yes** | End of date range (inclusive) |
| `leaveStatus` | `[LeaveStatusV2]` | No | Filter by leave status Values: `PENDING`, `APPROVED`, `REJECTED`, `WITHDRAW` |
| `leaveRequestTypes` | `[LeaveRequestType]` | No | Filter by request type Values: `LEAVE_APPLICATION_REQUEST`, `LEAVE_COMOFF_CREDIT_REQUEST` |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `success` | `Boolean` | Whether the request was successful |
| `message` | `String` | Error or informational message |
| `data` | `[LeaveV2]` | List of leave records |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `startDate` | `String` | Start date of the leave (YYYY-MM-DD) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `startSession` | `Int` | Start session — 1 for first-half, 2 for second-half |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `endDate` | `String` | End date of the leave (YYYY-MM-DD) |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `endSession` | `Int` | End session — 1 for first-half, 2 for second-half |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `leaveRequestType` | `LeaveRequestType` | Type of request — LEAVE_APPLICATION_REQUEST or LEAVE_COMOFF_CREDIT_REQUEST Values: `LEAVE_APPLICATION_REQUEST`, `LEAVE_COMOFF_CREDIT_REQUEST` |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `status` | `LeaveStatusV2` | Current status — PENDING, APPROVED, REJECTED, or WITHDRAW Values: `PENDING`, `APPROVED`, `REJECTED`, `WITHDRAW` |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `leavesTaken` | `Float` | Number of leave days consumed by this request |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `remarks` | `String` | Remarks added by the approver/admin |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `reason` | `String` | Reason provided by the employee for the leave |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `attachmentDetails` | `[LeaveAttachementDetail]` | Files or photos attached to the leave request |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdTs` | `Long` | Epoch milliseconds timestamp of when the leave request was created |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastModifiedTs` | `Long` | Epoch milliseconds timestamp of when the leave request was last modified |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `policyLeaveTypeInfo` | `PolicyLeaveType` | Leave type and policy configuration details for this leave |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userInfo` | `User` | Employee who applied for the leave |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdByEmployee` | `User` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastModifiedByEmployee` | `User` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `createdByAdmin` | `AdminInfo` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `lastModifiedByAdmin` | `AdminInfo` | — |

**Example**

```graphql
query Get_leavesv2_for_employees($internalEmpIDs: [String], $fromDate: Date!, $toDate: Date!, $leaveStatus: [LeaveStatusV2], $leaveRequestTypes: [LeaveRequestType]) {
  get_leavesv2_for_employees(internalEmpIDs: $internalEmpIDs, fromDate: $fromDate, toDate: $toDate, leaveStatus: $leaveStatus, leaveRequestTypes: $leaveRequestTypes) {
      success
      message
      data {
        startDate
        startSession
        endDate
        endSession
        leaveRequestType
        status
        leavesTaken
        remarks
        reason
        createdTs
        lastModifiedTs
      }
  }
}
```

---

## ⏰ Attendance

Raw punch events for the whole company. Higher-level status (`is X punched in right now?`) lives in the Employees module.

### `get_attendances_by_companyID`

**Type:** query &nbsp;·&nbsp; **Returns:** `[Attendance!]`

All attendance punches for every employee in your company within a date range. eventTypeID 8 = punch-in, 9 = punch-out. Dates are inclusive and compared against the attendance processing date. Maximum range is 31 days.

**What it does.** Every raw attendance punch for the whole company in a date range.

**When to use it.** Payroll exports and timesheet reconciliation, where you need the individual events rather than a summary.

> ⚠️ `eventTypeID` 8 = punch-in, 9 = punch-out. Pair them yourself to compute shifts. Volume grows with headcount × days — keep the window tight.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `startDate` | `Date` | **Yes** | Start of date range, YYYY-MM-DD (inclusive) |
| `endDate` | `Date` | **Yes** | End of date range, YYYY-MM-DD (inclusive) |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `eventTypeID` | `Int` | 8 = punch-in, 9 = punch-out |
| `lat` | `Float` | — |
| `lon` | `Float` | — |
| `timestamp` | `Long` | Time of the punch as epoch milliseconds |
| `src` | `Int` | Source of the punch: 0 = automatic (auto-attendance), 2 = manual entry; other values are regular mobile-app punches |
| `siteName` | `String` | Name of the site the punch was made at, when matched |
| `photoURL` | `String` | Path of the punch selfie photo, relative to the S3 base URL; null when no selfie was taken |
| `processingDate` | `Date` | The working day this punch is attributed to (YYYY-MM-DD) |
| `address` | `String` | — |
| `tz` | `String` | Timezone of the punch, e.g. Asia/Kolkata |
| `internalEmpID` | `String` | Employee ID as set in your system |

**Example**

```graphql
query Get_attendances_by_companyID($startDate: Date!, $endDate: Date!) {
  get_attendances_by_companyID(startDate: $startDate, endDate: $endDate) {
      eventTypeID
      lat
      lon
      timestamp
      src
      siteName
      photoURL
      processingDate
      address
      tz
      internalEmpID
  }
}
```

---

## 💂 Guards

Security-guard-specific module: posts, shift assignments and a per-site attendance rollup. Both date-range endpoints are capped at 7 days.

### `get_guard_posts`

**Type:** query &nbsp;·&nbsp; **Returns:** `[GuardPost!]`

**What it does.** Lists all guard posts (fixed duty positions).

**When to use it.** Resolving post identifiers before reading assignments.

**Inputs**

_None._

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `postID` | `String` | — |
| `siteID` | `String` | — |
| `siteName` | `String` | — |
| `postName` | `String` | — |
| `lat` | `Float` | — |
| `lon` | `Float` | — |
| `buName` | `String` | — |

**Example**

```graphql
query Get_guard_posts {
  get_guard_posts {
      postID
      siteID
      siteName
      postName
      lat
      lon
      buName
  }
}
```

---

### `get_guard_assignments`

**Type:** query &nbsp;·&nbsp; **Returns:** `GuardAssignmentPage`

Guard shift assignments for a date range. Maximum range is 7 days.

**What it does.** Guard shift assignments over a date range, optionally scoped to one or many sites.

**When to use it.** Building rosters and duty charts.

> ⚠️ Hard maximum of 7 days per call — chunk longer ranges into weekly windows.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `startDate` | `Date` | **Yes** | Start of the date range (inclusive) |
| `endDate` | `Date` | **Yes** | End of the date range (inclusive) |
| `siteID` | `String` | No | — |
| `siteIDs` | `[String!]` | No | — |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `assignments` | `[GuardAssignment!]` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `date` | `Date` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `postID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `postName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `siteID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `siteName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `priority` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `guardID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `userID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalEmpID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `guardName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `shiftName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `shiftStart` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `shiftEnd` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `escalationReason` | `String` | — |

**Example**

```graphql
query Get_guard_assignments($startDate: Date!, $endDate: Date!, $siteID: String, $siteIDs: [String!]) {
  get_guard_assignments(startDate: $startDate, endDate: $endDate, siteID: $siteID, siteIDs: $siteIDs) {
      assignments {
        date
        postID
        postName
        siteID
        siteName
        priority
        guardID
        userID
        internalEmpID
        guardName
        shiftName
        shiftStart
        shiftEnd
        escalationReason
      }
  }
}
```

---

### `get_attendance_rollup`

**Type:** query &nbsp;·&nbsp; **Returns:** `AttendanceRollupReport`

Per-site attendance rollup for a date range. Maximum range is 7 days.

**What it does.** Pre-aggregated per-site attendance figures for a date range.

**When to use it.** Site-level compliance dashboards, where you want the summary rather than raw punches.

> ⚠️ Also capped at 7 days.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `startDate` | `Date` | **Yes** | Start of the date range (inclusive) |
| `endDate` | `Date` | **Yes** | End of the date range (inclusive) |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `sites` | `[AttendanceRollupSiteRow!]` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `siteID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `siteName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `buName` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `presentCount` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `leaveCount` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `weeklyOffCount` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `totalGuards` | `Int` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `punchCount` | `Int` | — |

**Example**

```graphql
query Get_attendance_rollup($startDate: Date!, $endDate: Date!) {
  get_attendance_rollup(startDate: $startDate, endDate: $endDate) {
      sites {
        siteID
        siteName
        buName
        presentCount
        leaveCount
        weeklyOffCount
        totalGuards
        punchCount
      }
  }
}
```

---

## 📁 Territory

Territories group geofences/sites for assignment and reporting. Writes are bulk-only and keyed exclusively on `internalTerritoryID`.

### `check_geofence_overlap`

**Type:** query &nbsp;·&nbsp; **Returns:** `GeofenceOverlapResult`

**What it does.** Reports whether a geofence overlaps others.

**When to use it.** A validation step before saving a new geofence — overlapping fences cause ambiguous attendance and task rules.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `geofenceID` | `ID` | **Yes** | — |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `overlaps` | `Boolean` | — |
| `conflictingTerritoryID` | `ID` | — |
| `conflictingGeofenceName` | `String` | — |

**Example**

```graphql
query Check_geofence_overlap($geofenceID: ID!) {
  check_geofence_overlap(geofenceID: $geofenceID) {
      overlaps
      conflictingTerritoryID
      conflictingGeofenceName
  }
}
```

---

### `upsert_territory_by_id`

**Type:** mutation &nbsp;·&nbsp; **Returns:** `TerritoryBulkResponse`

Territory — External API (EXTERNAL_API): create/update/delete keyed on internalTerritoryID only

**What it does.** Bulk create, update or delete of territories, keyed only on `internalTerritoryID`.

**When to use it.** Syncing sales or service territory definitions.

> ⚠️ Bulk-only — the input is always an array, even for a single territory. Check each element of the response for per-item errors.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `input` | `[TerritoryApiInput!]` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalTerritoryID` | `String` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `geofenceID` | `ID` | **Yes** | The geofence to turn into a territory (pick one from get_geofences). |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `visibility` | `[TerritoryVisibilityInput]` | **Yes** | — |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `type` | `TerritoryVisibilityType` | **Yes** | Values: `EVERYONE`, `PROFILE`, `EMPLOYEE` |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `profileName` | `String` | No | Team name (required when type is PROFILE) — external API. |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `internalEmpID` | `String` | No | Employee stable id (required when type is EMPLOYEE) — external API. |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `failed` | `[TerritoryUpsertFailure!]` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `internalTerritoryID` | `String` | — |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `reason` | `String` | Human-readable failure reason. |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ `code` | `String` | Machine-readable code, e.g. TERRITORY_OVERLAP, TERRITORY_NO_ASSIGNEE, GEOFENCE_NOT_FOUND. |

**Example**

```graphql
mutation Upsert_territory_by_id($input: [TerritoryApiInput!]!) {
  upsert_territory_by_id(input: $input) {
      failed {
        internalTerritoryID
        reason
        code
      }
  }
}
```

---

### `delete_territory_by_id`

**Type:** mutation &nbsp;·&nbsp; **Returns:** `TerritoryDeleteResponse`

**What it does.** Deletes territories by a list of `internalTerritoryIDs`.

**When to use it.** Territory restructuring. Reassign the affected employees first.

**Inputs**

| Field | Type | Required | Notes |
|---|---|---|---|
| `internalTerritoryIDs` | `[String!]` | **Yes** | — |

**Key output fields**

| Field | Type | Notes |
|---|---|---|
| `rowsDeleted` | `Int` | — |

**Example**

```graphql
mutation Delete_territory_by_id($internalTerritoryIDs: [String!]!) {
  delete_territory_by_id(internalTerritoryIDs: $internalTerritoryIDs) {
      rowsDeleted
  }
}
```

---
## 4. Migration guide (old API → this API)

### 4.1 The mental shift

| Old-style REST thinking | Unolo GraphQL |
|---|---|
| Many URLs, one per resource | **One URL** for everything |
| `GET` / `POST` / `PUT` / `DELETE` | Always `POST` |
| `Authorization: Bearer …` | `token: …` header |
| Server decides the response shape | **You** declare the fields you want |
| `4xx` / `5xx` signals failure | Always `200`; check the `errors` array |
| `?page=2&limit=100` | `skip` / `take` arguments, where supported |
| Separate create and update calls | Single `upsert_*` mutation, idempotent on your ID |

### 4.2 Recommended migration order

1. **Auth first.** Swap your header to `token` and confirm one trivial query (`get_designations`) returns data. Nothing else works until this does.
2. **Reference data.** Pull `get_roles`, `get_designations`, `get_teams`, `get_geofences`, `get_sites`. Cache them. Several write endpoints match on *name*, not ID, so you need these lists to build valid payloads.
3. **Org hierarchy.** Sync admins (`upsert_admin`) top-down, then employees (`upsert_employee`). Employees reference admins, so order matters.
4. **Masters.** Clients (`upsert_clientv2_external`) and products (`upsert_skus`).
5. **Transactional.** Tasks (`upsert_task_external`), then read paths for orders, attendance and leaves.
6. **Backfill and reconcile.** Re-run reads and diff against your own database before cutting traffic over.

### 4.3 Choose v2 wherever a choice exists

Several v1 endpoints are still live for backward compatibility. Do not build new code against them.

| Don't use | Use instead |
|---|---|
| `get_users_by_company_id` | `get_employees` |
| `get_clients`, `get_client_by_id` | `get_clientv2_by_internalClientID` |
| `upsert_client_by_id` | `upsert_clientv2_external` |
| `delete_client_external`, `delete_client_by_id` | `delete_clientv2_external` |
| Looping `get_last_location` | `get_last_location_emp_batched` |
| Looping `get_attendance_status` | `get_attendance_status_emp_batched` |

### 4.4 Traps that will bite you

- **`internalEmpID` / `internalClientID` / `internalTaskID` are *your* IDs.** Unolo keys its records on the identifiers you supply. Set them from your source system on first write and you never need an ID mapping table. Get them wrong and you create duplicates instead of updates.
- **Upserts are idempotent, so retries are safe.** Replaying the same payload updates rather than duplicates — lean on this for at-least-once delivery.
- **7-day caps.** `get_guard_assignments` and `get_attendance_rollup` reject longer ranges. Chunk into weekly windows.
- **`get_employees` has no pagination.** It returns the whole roster. Cache it; don't call it per request.
- **`dateField` on `get_tasks_by_empIDs_date_range`.** Use `ACTIVITY` for incremental sync — `SCHEDULED` will silently miss tasks edited today but planned for another week.
- **Two mutations are named `get_*`.** `get_sku_image_upload_urls` and `get_custom_field_upload_urls` are mutations, not queries. Sending them as a `query` fails.
- **Batch mutations return per-item results.** `upsert_task_to_best_employee`, `upsert_skus` and `upsert_territory_by_id` can partially succeed. Iterate the response array; a `200` with no top-level `errors` does not mean every item landed.
- **Deletes cascade.** Deleting a client removes its incomplete tasks. Deleting an employee without `transferToInternalEmpID` orphans theirs. Prefer `deactivate_employee` over `delete_employee`.
- **File uploads are two-step.** Request a presigned S3 URL, `PUT` the bytes to S3 directly, then reference the returned key in your upsert. Never send file bytes through the GraphQL endpoint.
- **Request only the fields you need.** Deeply nested selections on `Task` or `Clientv2` get expensive quickly. This is the main lever you have over response time.

---

## 5. Working examples

### cURL

```bash
curl -X POST https://apollo-lb-ext-ns.unolo.com/graphql \
  -H "Content-Type: application/json" \
  -H "token: YOUR_API_KEY" \
  -d '{
    "query": "query GetEmployees { get_employees { internalEmpID firstName lastName email } }",
    "variables": {}
  }'
```

### JavaScript / Node

```js
const ENDPOINT = 'https://apollo-lb-ext-ns.unolo.com/graphql';

async function unolo(query, variables = {}) {
  const res = await fetch(ENDPOINT, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      token: process.env.UNOLO_API_KEY,
    },
    body: JSON.stringify({ query, variables }),
  });

  const { data, errors } = await res.json();
  if (errors?.length) {
    throw new Error(`Unolo API: ${errors.map(e => e.message).join('; ')}`);
  }
  return data;
}

// Read
const { get_employees } = await unolo(`
  query {
    get_employees { internalEmpID firstName lastName email }
  }
`);

// Write
const result = await unolo(
  `mutation UpsertEmployee($input: UserInput!) {
     upsert_employee(input: $input) { userID emailID }
   }`,
  {
    input: {
      internalEmpID: 'EMP-1042',
      firstName: 'Rahul',
      lastName: 'Sharma',
      mobileNumber: '+919876543210',
      parentInternalAdminID: 'ADM-7',
      profileName: 'Field Sales',
      designationName: 'Sales Executive',
    },
  }
);
```

### Python

```python
import os, requests

ENDPOINT = "https://apollo-lb-ext-ns.unolo.com/graphql"
HEADERS = {"Content-Type": "application/json", "token": os.environ["UNOLO_API_KEY"]}

def unolo(query, variables=None):
    r = requests.post(ENDPOINT, headers=HEADERS,
                      json={"query": query, "variables": variables or {}}, timeout=30)
    r.raise_for_status()
    payload = r.json()
    if payload.get("errors"):
        raise RuntimeError("; ".join(e["message"] for e in payload["errors"]))
    return payload["data"]

employees = unolo("query { get_employees { internalEmpID firstName lastName } }")["get_employees"]
```

### Paginating a list endpoint

```python
def all_sites(page_size=500):
    skip, out = 0, []
    q = """query($skip: Int, $take: Int) {
             get_sites(skip: $skip, take: $take) { siteID siteName }
           }"""
    while True:
        batch = unolo(q, {"skip": skip, "take": page_size})["get_sites"]
        out.extend(batch)
        if len(batch) < page_size:
            return out
        skip += page_size
```

### Chunking a 7-day-capped endpoint

```python
from datetime import date, timedelta

def guard_assignments(start: date, end: date):
    q = """query($s: Date!, $e: Date!) {
             get_guard_assignments(startDate: $s, endDate: $e) { ... }
           }"""
    cur = start
    while cur <= end:
        chunk_end = min(cur + timedelta(days=6), end)
        yield unolo(q, {"s": cur.isoformat(), "e": chunk_end.isoformat()})
        cur = chunk_end + timedelta(days=1)
```