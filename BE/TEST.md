# API Test Results

Base URL: http://localhost:3000
Test time: 2026-02-04 00:44:55

## GET /

- Method: GET
- URL: http://localhost:3000/
- Status: 200

Payload:
```
<none>
```

Response:
```
{"message":"API Event App berjalan"}
```

## GET /api-docs.json

- Method: GET
- URL: http://localhost:3000/api-docs.json
- Status: 200

Payload:
```
<none>
```

Response:
```
{"openapi":"3.0.3","info":{"title":"Event Organizer API","version":"1.0.0","description":"API for auth, events, and users"},"servers":[{"url":"http://localhost:3000","description":"Local"}],"components":{"securitySchemes":{"bearerAuth":{"type":"http","scheme":"bearer","bearerFormat":"JWT"}},"schemas":{"User":{"type":"object","properties":{"id":{"type":"integer"},"name":{"type":"string"},"email":{"type":"string","format":"email"}}},"Event":{"type":"object","properties":{"id":{"type":"integer"},"user_id":{"type":"integer"},"title":{"type":"string"},"date":{"type":"string","example":"2026-02-03"},"startTime":{"type":"string","example":"09:00"},"endTime":{"type":"string","example":"10:00"},"image":{"type":"string","nullable":true},"location":{"type":"string","nullable":true},"description":{"type":"string","nullable":true},"created_at":{"type":"string"}}},"Message":{"type":"object","properties":{"message":{"type":"string"}}}}},"paths":{"/":{"get":{"summary":"Health check","responses":{"200":{"description":"OK"}}}},"/api/auth/register":{"post":{"summary":"Register","requestBody":{"required":true,"content":{"application/json":{"schema":{"type":"object","required":["name","email","password"],"properties":{"name":{"type":"string"},"email":{"type":"string","format":"email"},"password":{"type":"string"}}}}}},"responses":{"201":{"description":"Created","content":{"application/json":{"schema":{"$ref":"#/components/schemas/Message"}}}},"400":{"description":"Bad request"}}}},"/api/auth/login":{"post":{"summary":"Login","requestBody":{"required":true,"content":{"application/json":{"schema":{"type":"object","required":["email","password"],"properties":{"email":{"type":"string","format":"email"},"password":{"type":"string"}}}}}},"responses":{"200":{"description":"OK","content":{"application/json":{"schema":{"type":"object","properties":{"message":{"type":"string"},"token":{"type":"string"},"user":{"$ref":"#/components/schemas/User"}}}}}},"401":{"description":"Unauthorized"}}}},"/api/...
```

## POST /api/auth/register

- Method: POST
- URL: http://localhost:3000/api/auth/register
- Status: 201

Payload:
```
{"email":"test20260204004454@example.com","name":"Test User 20260204004454","password":"Password123"}
```

Response:
```
{"message":"Registrasi berhasil"}
```

## POST /api/auth/login

- Method: POST
- URL: http://localhost:3000/api/auth/login
- Status: 200

Payload:
```
{"password":"Password123","email":"test20260204004454@example.com"}
```

Response:
```
{"message":"Login berhasil","token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NywiZW1haWwiOiJ0ZXN0MjAyNjAyMDQwMDQ0NTRAZXhhbXBsZS5jb20iLCJpYXQiOjE3NzAxNDA2OTQsImV4cCI6MTc3MDIyNzA5NH0.jpcc7DdOJw7ZBbos4uoVc3xq5FTI2uIpBxQ6pBZVeQU","user":{"id":7,"name":"Test User 20260204004454","email":"test20260204004454@example.com"}}
```

## GET /api/events (no token)

- Method: GET
- URL: http://localhost:3000/api/events
- Status: 401

Payload:
```
<none>
```

Response:
```
{"message":"Token tidak ditemukan"}
```

## GET /api/users (no token)

- Method: GET
- URL: http://localhost:3000/api/users
- Status: 401

Payload:
```
<none>
```

Response:
```
{"message":"Token tidak ditemukan"}
```

## GET /api/users

- Method: GET
- URL: http://localhost:3000/api/users
- Status: 200

Payload:
```
<none>
```

Response:
```
[{"id":1,"name":"Hadi","email":"hadi@gmail.com"},{"id":2,"name":"Test User 20260204003236","email":"test20260204003236@example.com"},{"id":3,"name":"Test User 20260204003307","email":"test20260204003307@example.com"},{"id":4,"name":"Test User 20260204003320","email":"test20260204003320@example.com"},{"id":5,"name":"Test User 20260204003602","email":"test20260204003602@example.com"},{"id":6,"name":"Test User 20260204003657","email":"test20260204003657@example.com"},{"id":7,"name":"Test User 20260204004454","email":"test20260204004454@example.com"}]
```

## GET /api/users/me

- Method: GET
- URL: http://localhost:3000/api/users/me
- Status: 200

Payload:
```
<none>
```

Response:
```
{"id":7,"name":"Test User 20260204004454","email":"test20260204004454@example.com"}
```

## PUT /api/users/me

- Method: PUT
- URL: http://localhost:3000/api/users/me
- Status: 200

Payload:
```
{"name":"Updated Test User 20260204004454"}
```

Response:
```
{"message":"User berhasil diupdate"}
```

## GET /api/users/{id}

- Method: GET
- URL: http://localhost:3000/api/users/7
- Status: 200

Payload:
```
<none>
```

Response:
```
{"id":7,"name":"Updated Test User 20260204004454","email":"test20260204004454@example.com"}
```

## PUT /api/users/{id}

- Method: PUT
- URL: http://localhost:3000/api/users/7
- Status: 200

Payload:
```
{"name":"Updated By ID Test User 20260204004454"}
```

Response:
```
{"message":"User berhasil diupdate"}
```

## POST /api/events

- Method: POST
- URL: http://localhost:3000/api/events
- Status: 201

Payload:
```
{"endTime":"10:00","location":"Kampus","startTime":"09:00","description":"Uji coba","date":"2026-02-04","title":"Demo Event 20260204004454"}
```

Response:
```
{"message":"Event berhasil dibuat"}
```

## GET /api/events

- Method: GET
- URL: http://localhost:3000/api/events
- Status: 200

Payload:
```
<none>
```

Response:
```
[{"id":5,"title":"Demo Event 20260204004454","date":"2026-02-04","startTime":"09:00","endTime":"10:00","image":null,"userId":7,"location":null,"description":null}]
```

## GET /api/events/{id}

- Method: GET
- URL: http://localhost:3000/api/events/5
- Status: 200

Payload:
```
<none>
```

Response:
```
{"id":5,"title":"Demo Event 20260204004454","date":"2026-02-04","startTime":"09:00","endTime":"10:00","image":null,"userId":7,"location":null,"description":null}
```

## PUT /api/events/{id}

- Method: PUT
- URL: http://localhost:3000/api/events/5
- Status: 200

Payload:
```
{"endTime":"11:00","location":"Ruang 1","startTime":"10:00","description":"Update","date":"2026-02-04","title":"Updated Event 20260204004454"}
```

Response:
```
{"message":"Event berhasil diupdate"}
```

## DELETE /api/events/{id}

- Method: DELETE
- URL: http://localhost:3000/api/events/5
- Status: 200

Payload:
```
<none>
```

Response:
```
{"message":"Event berhasil dihapus"}
```

## DELETE /api/users/me

- Method: DELETE
- URL: http://localhost:3000/api/users/me
- Status: 200

Payload:
```
<none>
```

Response:
```
{"message":"User berhasil dihapus"}
```

