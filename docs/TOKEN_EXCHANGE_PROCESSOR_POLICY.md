# PingFederate Token Exchange Processor Policy — PROCESSORPOLICIES

**Document Version**: 1.0  
**Last Updated**: 2026-04-20  
**PingFederate Version**: 12.3.3.1  
**Configuration Source**: `profiles/pingfederate/bulk-export/shared/data.json`  
**RFC Reference**: [RFC 8693 — OAuth 2.0 Token Exchange](https://datatracker.ietf.org/doc/html/rfc8693)

---

## Table of Contents

1. [Overview](#overview)
2. [Complete Configuration Dependency Map](#complete-configuration-dependency-map)
3. [PROCESSORPOLICIES Policy](#processorpolicies-policy)
4. [Processor Mapping 1 — PingFederate ↔ PingFederate](#processor-mapping-1--pingfederate--pingfederate)
5. [Processor Mapping 2 — Microsoft Entra ID ↔ PingFederate](#processor-mapping-2--microsoft-entra-id--pingfederate)
6. [Token Processor Comparison Matrix](#token-processor-comparison-matrix)
7. [Access Token Mapping — Token Exchange Context](#access-token-mapping--token-exchange-context)
8. [OGNL Expression — Actor Claim Transformation](#ognl-expression--actor-claim-transformation)
9. [AccessTokenManagement Configuration](#accesstokenmanagement-configuration)
10. [Real-World Example — HR Chatbot Token Exchange](#real-world-example--hr-chatbot-token-exchange)
11. [Token Lifecycle Sequence](#token-lifecycle-sequence)
12. [Configuration File Locations](#configuration-file-locations)
13. [Validation Checklist](#validation-checklist)
14. [Troubleshooting](#troubleshooting)
15. [References](#references)

---

## Overview

`PROCESSORPOLICIES` is the **default** PingFederate Token Exchange Processor Policy implementing **RFC 8693 delegation semantics**. When a client submits a token exchange request, this policy:

1. Selects the correct **processor mapping** based on the token types presented
2. **Validates** both subject and actor tokens using the configured token processors
3. **Extracts claims** and maps them to a standardised attribute contract
4. Passes the fulfilled attributes to the **Access Token Mapping** which produces the final JWT

**Supported exchange patterns:**

| Pattern | Subject Token Type | Actor Token Type |
|---|---|---|
| PingFederate ↔ PingFederate | `urn:ietf:params:oauth:token-type:access_token` | `urn:ietf:params:oauth:token-type:access_token` |
| Microsoft Entra ID ↔ PingFederate | `urn:ietf:params:oauth:token-type:access_token:msft` | `urn:ietf:params:oauth:token-type:access_token` |

**Semantic**: RFC 8693 **delegation** — the actor (`contact-hr-client`) acts on behalf of the subject (`user.1`). The issued token contains an `actor` claim (RFC 8693 §4.1) recording this explicitly.

---

## Complete Configuration Dependency Map

```
Token Exchange HTTP Request
POST /as/token.oauth2
grant_type=urn:ietf:params:oauth:grant-type:token-exchange
│
├── subject_token      (user's access token)
├── subject_token_type
├── actor_token        (chatbot's client credentials token)
├── actor_token_type
├── client_id          (contact-oauth-client)
├── client_secret
└── scope
         │
         ▼
┌─────────────────────────────────────────────────┐
│  /oauth/tokenExchange/processor/settings        │
│  defaultProcessorPolicyRef: PROCESSORPOLICIES   │
└───────────────────┬─────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│  /oauth/tokenExchange/processor/policies        │
│  PROCESSORPOLICIES                              │
│  actorTokenRequired: true                       │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ Processor Mapping 1                     │    │
│  │ subjectTokenType: access_token (PF)     │    │
│  │ actorTokenType:   access_token (PF)     │    │
│  │ subjectProcessor: PFSubjectProcessor    │    │
│  │ actorProcessor:   PFActorSubject        │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ Processor Mapping 2                     │    │
│  │ subjectTokenType: access_token:msft     │    │
│  │ actorTokenType:   access_token (PF)     │    │
│  │ subjectProcessor: MSFTTOKENPROCESSOR    │    │
│  │ actorProcessor:   PFTOKENPROCESSOR      │    │
│  └─────────────────────────────────────────┘    │
└───────────────────┬─────────────────────────────┘
                    │
         ┌──────────┴──────────┐
         ▼                     ▼
  Token Processors         Token Processors
  (validate subject)       (validate actor)
  ┌───────────────┐        ┌────────────────┐
  │PFSubjectProc  │        │PFActorSubject  │
  │MSFTTOKENPROC  │        │PFTOKENPROCESSOR│
  └───────┬───────┘        └───────┬────────┘
          │                        │
          └──────────┬─────────────┘
                     │
                     ▼
         Attribute Contract Fulfillment
         (map claims from both tokens)
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│  /oauth/accessTokenMappings                     │
│  Context: TOKEN_EXCHANGE_PROCESSOR_POLICY       │
│  Policy:  PROCESSORPOLICIES                     │
│  Manager: AccessTokenManagement                 │
│                                                 │
│  actor      ← OGNL expression (JSON object)     │
│  vaultloc.  ← TOKEN_EXCHANGE_PROCESSOR_POLICY   │
│  aud        ← CONTEXT (ClientId)                │
│  sub        ← TOKEN_EXCHANGE_PROCESSOR_POLICY   │
│  scope      ← TOKEN_EXCHANGE_PROCESSOR_POLICY   │
│  groups     ← TOKEN_EXCHANGE_PROCESSOR_POLICY   │
└───────────────────┬─────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│  /oauth/accessTokenManagers                     │
│  AccessTokenManagement                          │
│                                                 │
│  Algorithm:  RS256                              │
│  Lifetime:   120 seconds                        │
│  SigningKey:  5jqt7j8mxbwl2awtpc465yzx1         │
│  Issuer:     https://id.ping.darkedges.com      │
│  Adds:  iss, iat, exp, jti                      │
└───────────────────┬─────────────────────────────┘
                    │
                    ▼
           Issued JWT Access Token
```

---

## PROCESSORPOLICIES Policy

### Core Configuration

| Property | Value |
|---|---|
| `id` | `PROCESSORPOLICIES` |
| `name` | `PROCESSORPOLICIES` |
| `actorTokenRequired` | `true` — actor token is **mandatory** in all requests |
| Default Policy | Yes — set as `defaultProcessorPolicyRef` |

### Attribute Contract

The policy defines the attributes available for downstream mapping:

| Attribute | Type | Source (Mapping 1) | Required |
|---|---|---|---|
| `subject` | Core | SUBJECT_TOKEN → `sub` | Yes |
| `actor` | Extended | ACTOR_TOKEN → `client_id` | No |
| `vaultlocation` | Extended | SUBJECT_TOKEN → `vaultlocation` | No |
| `scope` | Extended | SUBJECT_TOKEN → `scope` | No |
| `groups` | Extended | SUBJECT_TOKEN → `groups` | No |
| `given_name` | Extended | SUBJECT_TOKEN → `given_name` | No |
| `family_name` | Extended | SUBJECT_TOKEN → `family_name` | No |
| `email` | Extended | SUBJECT_TOKEN → `email` | No |

### Processor Mapping Selection Logic

```
Request arrives with subject_token_type and actor_token_type
         │
         ├─ subject_token_type = urn:...:access_token   AND
         │  actor_token_type   = urn:...:access_token
         │        └─► Mapping 1 — PFSubjectProcessor + PFActorSubject
         │
         ├─ subject_token_type = urn:...:access_token:msft   AND
         │  actor_token_type   = urn:...:access_token
         │        └─► Mapping 2 — MSFTTOKENPROCESSOR + PFTOKENPROCESSOR
         │
         └─ No match
                  └─► HTTP 400 invalid_request
```

### Issuance Criteria

Both mappings have **empty** `conditionalCriteria`:

```json
"issuanceCriteria": { "conditionalCriteria": [] }
```

All token exchanges that pass processor validation are approved — no additional OGNL conditions are applied.

---

## Processor Mapping 1 — PingFederate ↔ PingFederate

### Overview

Used when both the subject and actor tokens were issued by **this PingFederate instance** (`https://id.ping.darkedges.com`). This is the primary path for the HR Chatbot integration.

```
subject_token  ──► PFSubjectProcessor  (validates user's access token)
actor_token    ──► PFActorSubject      (validates chatbot's client credentials token)
```

### PFSubjectProcessor

Validates the **user's access token** (subject token).

| Property | Value |
|---|---|
| ID | `PFSubjectProcessor` |
| Plugin Type | `com.pingidentity.pf.tokenprocessors.jwt.JwtTokenProcessor` |
| Allowed Issuer | `https://id.ping.darkedges.com` |
| JWKS URL | `https://id.ping.darkedges.com/pf/JWKS` |
| Require Audience | `true` |
| Required Audience | `contact-hr-client` |
| Require Expiration | `true` |
| Require Issued At | `true` |
| Clock Skew | 0 seconds |
| JWKS Cache Duration | 720 minutes |

**Attribute Contract Produced:**

| Claim | Type | Source |
|---|---|---|
| `sub` | Core | JWT `sub` claim |
| `vaultlocation` | Extended | JWT `vaultlocation` claim |
| `scope` | Extended | JWT `scope` claim |
| `groups` | Extended | JWT `groups` claim |
| `given_name` | Extended | JWT `given_name` claim |
| `family_name` | Extended | JWT `family_name` claim |
| `email` | Extended | JWT `email` claim |

**Example subject token claims validated by this processor:**

```json
{
  "scope": ["openid", "profile", "email"],
  "authorization_details": [],
  "client_id": "contact-hr-client",
  "iss": "https://id.ping.darkedges.com",
  "iat": 1776667958,
  "jti": "xExadYEtur8OlKf9NW3pVI",
  "vaultlocation": "referenceid/msentraid/0BUTfOKfKbCi2Rf4S-krNcFQUAJ2R4YDIqf8Xvl5nK4",
  "aud": "contact-hr-client",
  "sub": "user.1",
  "groups": ["Administrators"],
  "family_name": "Seawell",
  "email": "nirvinguk@hotmail.com",
  "exp": 1776675158
}
```

### PFActorSubject

Validates the **chatbot's client credentials token** (actor token).

| Property | Value |
|---|---|
| ID | `PFActorSubject` |
| Plugin Type | `com.pingidentity.pf.tokenprocessors.jwt.JwtTokenProcessor` |
| Allowed Issuer | `https://id.ping.darkedges.com` |
| JWKS URL | `https://id.ping.darkedges.com/pf/JWKS` |
| Require Audience | `false` — no audience check |
| Require Expiration | `true` |
| Require Issued At | `true` |
| Clock Skew | 0 seconds |
| JWKS Cache Duration | 720 minutes |

**Attribute Contract Produced:**

| Claim | Type | Source |
|---|---|---|
| `sub` | Core | JWT `sub` claim |
| `scope` | Extended | JWT `scope` claim |
| `client_id` | Extended | JWT `client_id` claim — **used as `actor` in output** |

**Example actor token claims validated by this processor:**

```json
{
  "scope": "",
  "authorization_details": [],
  "client_id": "contact-hr-client",
  "iss": "https://id.ping.darkedges.com",
  "iat": 1776667937,
  "jti": "ujPePxrAUOLlrj03ORmPe1",
  "exp": 1776675137
}
```

> **Note**: The actor token has an empty `scope` because it was obtained via Client Credentials grant — the chatbot is authenticating as itself, not as a user.

### Attribute Fulfillment — Mapping 1

| Output Attribute | Source | Input Claim |
|---|---|---|
| `actor` | `ACTOR_TOKEN` | `client_id` |
| `vaultlocation` | `SUBJECT_TOKEN` | `vaultlocation` |
| `subject` | `SUBJECT_TOKEN` | `sub` |
| `scope` | `SUBJECT_TOKEN` | `scope` |
| `groups` | `SUBJECT_TOKEN` | `groups` |
| `given_name` | `SUBJECT_TOKEN` | `given_name` |
| `family_name` | `SUBJECT_TOKEN` | `family_name` |
| `email` | `SUBJECT_TOKEN` | `email` |

---

## Processor Mapping 2 — Microsoft Entra ID ↔ PingFederate

### Overview

Used when the subject token originated from **Microsoft Entra ID / Azure AD** (identified by `subject_token_type: urn:ietf:params:oauth:token-type:access_token:msft`), while the actor token is still a PingFederate bearer token.

```
subject_token  ──► MSFTTOKENPROCESSOR  (validates Entra ID JWT)
actor_token    ──► PFTOKENPROCESSOR    (validates PF bearer token)
```

### MSFTTOKENPROCESSOR

Validates tokens issued by **Microsoft Azure AD / Entra ID**.

| Property | Value |
|---|---|
| ID | `MSFTTOKENPROCESSOR` |
| Plugin Type | `com.pingidentity.pf.tokenprocessors.jwt.JwtTokenProcessor` |
| Tenant ID | `4161be3f-bf2b-41d4-a02b-e6f82b529d53` |

**Allowed Issuers:**

| Issuer | JWKS URL | Protocol |
|---|---|---|
| `https://sts.windows.net/4161be3f-bf2b-41d4-a02b-e6f82b529d53/` | `https://login.microsoftonline.com/common/discovery/keys` | ADFS / v1 |
| `https://login.microsoftonline.com/4161be3f-bf2b-41d4-a02b-e6f82b529d53/v2.0` | `https://login.microsoftonline.com/4161be3f-bf2b-41d4-a02b-e6f82b529d53/discovery/v2.0/keys` | OIDC v2 |

**Allowed Audiences:**

| Audience |
|---|
| `https://fram.connectid.darkedges.com/openam/oauth2` |
| `e83c2af3-43d1-4f62-8bff-e619c29b5026` |

| Property | Value |
|---|---|
| Require Audience | `true` |
| Require Expiration | `true` |
| Require Issued At | `false` |
| Clock Skew | 0 seconds |

**Attribute Contract Produced:**

| Claim | Type | Source |
|---|---|---|
| `sub` | Core | JWT `sub` |
| `email` | Extended | JWT `email` |

### PFTOKENPROCESSOR

Validates **PingFederate bearer access tokens** by introspecting against the `AccessTokenManagement` token manager.

| Property | Value |
|---|---|
| ID | `PFTOKENPROCESSOR` |
| Plugin Type | `org.sourceid.wstrust.processor.oauth.BearerAccessTokenTokenProcessor` |
| Access Token Manager | `AccessTokenManagement` |
| Scope as single string | `false` |

**Attribute Contract Produced (from AccessTokenManagement introspection):**

| Claim | Type | Source |
|---|---|---|
| `aud` | Core | Token `aud` claim |
| `expires_at` | Core | Token expiry |
| `authorization_details` | Core | Token claim |
| `scope` | Core | Token scope |
| `iss` | Core | Token issuer |
| `client_id` | Core | Token client |
| `sub` | Extended | Token subject |
| `email` | Extended | Token email |

### Attribute Fulfillment — Mapping 2

| Output Attribute | Source | Input Claim |
|---|---|---|
| `actor` | `NO_MAPPING` | (not included) |
| `vaultlocation` | `NO_MAPPING` | (not included) |
| `subject` | `SUBJECT_TOKEN` | `sub` |
| `scope` | `NO_MAPPING` | (not included) |
| `groups` | `NO_MAPPING` | (not included) |
| `given_name` | `NO_MAPPING` | (not included) |
| `family_name` | `NO_MAPPING` | (not included) |
| `email` | `SUBJECT_TOKEN` | `email` |

> Most attributes are `NO_MAPPING` because Microsoft tokens do not contain PingFederate-specific claims such as `vaultlocation` or `groups`.

---

## Token Processor Comparison Matrix

| Property | PFSubjectProcessor | PFActorSubject | MSFTTOKENPROCESSOR | PFTOKENPROCESSOR |
|---|---|---|---|---|
| **Role** | Subject validator | Actor validator | Subject validator | Actor validator |
| **Token Format** | JWT (PF-issued) | JWT (PF-issued) | JWT (Azure-issued) | Opaque Bearer |
| **Issuer** | `id.ping.darkedges.com` | `id.ping.darkedges.com` | Azure AD (v1 + v2) | (any PF-issued) |
| **JWKS Source** | `pf/JWKS` | `pf/JWKS` | Azure Discovery | AccessTokenManagement |
| **Require Audience** | ✅ Yes | ❌ No | ✅ Yes | N/A |
| **Required Audience** | `contact-hr-client` | — | Azure app audiences | N/A |
| **Require Expiration** | ✅ Yes | ✅ Yes | ✅ Yes | N/A |
| **Require Issued At** | ✅ Yes | ✅ Yes | ❌ No | N/A |
| **Clock Skew** | 0s | 0s | 0s | N/A |
| **Key Claims Extracted** | `sub`, `scope`, `groups`, `vaultlocation`, names, `email` | `client_id` | `sub`, `email` | `sub`, `scope`, `client_id` |

---

## Access Token Mapping — Token Exchange Context

### Mapping Identity

```
ID:      urn:ietf:params:oauth:grant-type:token-exchange|PROCESSORPOLICIES|AccessTokenManagement
Context: TOKEN_EXCHANGE_PROCESSOR_POLICY → PROCESSORPOLICIES
Manager: AccessTokenManagement
```

### Attribute Sources

| Output Claim | Source Type | Value |
|---|---|---|
| `actor` | `EXPRESSION` | OGNL — builds JSON object `{ "sub": tepp.actor }` |
| `vaultlocation` | `TOKEN_EXCHANGE_PROCESSOR_POLICY` | `vaultlocation` |
| `aud` | `CONTEXT` | `ClientId` — the requesting client ID |
| `sub` | `TOKEN_EXCHANGE_PROCESSOR_POLICY` | `subject` |
| `scope` | `TOKEN_EXCHANGE_PROCESSOR_POLICY` | `scope` |
| `groups` | `TOKEN_EXCHANGE_PROCESSOR_POLICY` | `given_name` ⚠️ |
| `given_name` | `NO_MAPPING` | — |
| `family_name` | `NO_MAPPING` | — |
| `email` | `NO_MAPPING` | — |

> ⚠️ **Note**: In the current configuration, `groups` in the Access Token Mapping reads from `given_name` in the processor policy contract. Verify this is intentional if groups are required in the issued token.

---

## OGNL Expression — Actor Claim Transformation

### The Expression

```java
#jsonObj = new org.json.simple.JSONObject(),
#jsonObj.put("sub", #this.get("tepp.actor")),
#jsonObj
```

### Step-by-Step Breakdown

| Step | Code | Action |
|---|---|---|
| 1 | `new org.json.simple.JSONObject()` | Create empty JSON object |
| 2 | `#this.get("tepp.actor")` | Read `actor` from processor policy output |
| 3 | `#jsonObj.put("sub", ...)` | Set the `sub` field of the JSON object |
| 4 | `#jsonObj` | Return the constructed object as the claim value |

### Input → Output

```
tepp.actor = "contact-hr-client"
                   │
                   ▼
      { "sub": "contact-hr-client" }
                   │
                   ▼
  Issued JWT contains:
  "actor": { "sub": "contact-hr-client" }
```

### Why a JSON Object?

RFC 8693 §4.1 defines the `act` (actor) claim as a **JSON object**, not a string:

```
❌  "actor": "contact-hr-client"
✅  "actor": { "sub": "contact-hr-client" }
```

This enables:
- **Chain of delegation**: nested `act` objects for multi-hop scenarios
- **Additional actor identity**: can include `iss`, `email`, etc.
- **Standards compliance**: downstream services can parse it uniformly

---

## AccessTokenManagement Configuration

### Overview

`AccessTokenManagement` is the JWT Access Token Manager that **signs and issues the final token** after all processor policy and attribute mapping work is complete.

### Settings

| Setting | Value | Notes |
|---|---|---|
| `id` | `AccessTokenManagement` | |
| `name` | `AccessTokenManagement` | |
| Plugin | `JwtBearerAccessTokenManagementPlugin` | |
| **Token Lifetime** | 120 seconds | ~2 minutes |
| **Use Centralized Signing Key** | `true` | Uses PF global signing key |
| **JWS Algorithm** | `RS256` | RSA + SHA-256 |
| **Include Key ID (`kid`)** | `true` | Enables key rotation discovery |
| **Include X.509 Thumbprint** | `false` | |
| **JWKS Cache Duration** | 720 minutes | 12 hours |
| **Enable Token Revocation** | `false` | No revocation endpoint |
| **JWT ID Length** | 22 characters | Unique per token |
| **Include Issued At** | `true` | `iat` always present |
| **Issuer Claim Value** | `https://id.ping.darkedges.com` | |
| **Client ID Claim Name** | `client_id` | |
| **Scope Claim Name** | `scope` | |
| **Space Delimit Scope Values** | `true` | |
| **Authorization Details Claim** | `authorization_details` | |

### Signing Key

| Property | Value |
|---|---|
| Key Pair ID | `5jqt7j8mxbwl2awtpc465yzx1` |
| Algorithm | RSA 2048-bit |
| Signature Algorithm | RS256 |
| Usage | Token signing (all JWT tokens) |
| Public JWKS | `https://id.ping.darkedges.com/pf/JWKS` |

### Attribute Contract

Claims the manager can include in issued tokens:

| Attribute | Multi-Valued | Notes |
|---|---|---|
| `vaultlocation` | No | Custom — credential vault reference |
| `actor` | No | RFC 8693 delegation claim (JSON object) |
| `sub` | No | Subject identifier |
| `aud` | No | Audience (requesting client) |
| `scope` | No | Granted scopes |
| `groups` | Yes | Multi-valued — user's group memberships |
| `given_name` | No | User's first name |
| `family_name` | No | User's surname |
| `email` | No | User's email address |

### Always-Added Standard Claims

Regardless of attribute mapping, these claims are always added automatically:

```json
{
  "iss": "https://id.ping.darkedges.com",
  "iat": 1776667961,
  "exp": 1776675161,
  "jti": "XWcCCzPtj0OFR6HU8UA7Cw"
}
```

### Default Access Token Manager

```json
{
  "defaultAccessTokenManagerRef": {
    "id": "AccessTokenManagement"
  }
}
```

This is also the global default — used for all standard OAuth flows in addition to token exchange.

---

## Real-World Example — HR Chatbot Token Exchange

### Context

The `darkedges-hr-chatbot` application:
1. Obtains a **client credentials token** for itself (`actor_token`) at startup via `initialize_agent_token()`
2. Receives a **user access token** after OAuth callback (`subject_token`)
3. Performs a token exchange to obtain a **delegated token** that records both identities

### Token Exchange Request

```bash
curl -s -X POST 'https://id.ping.darkedges.com/as/token.oauth2' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'grant_type=urn:ietf:params:oauth:grant-type:token-exchange' \
  --data-urlencode 'subject_token=eyJhbGciOiJSUzI1NiIsImtpZCI6IlA1X1FfaDdqaGVpRkpWQnBVRlh6M2RPRmRGb19SUzI1NiIsInBpLmF0bSI6IjRld3AifQ.eyJzY29wZSI6WyJvcGVuaWQiLCJwcm9maWxlIiwiZW1haWwiXSwiYXV0aG9yaXphdGlvbl9kZXRhaWxzIjpbXSwiY2xpZW50X2lkIjoiY29udGFjdC1oci1jbGllbnQiLCJpc3MiOiJodHRwczovL2lkLnBpbmcuZGFya2VkZ2VzLmNvbSIsImlhdCI6MTc3NjY2Nzk1OCwianRpIjoieEV4YWRZRXR1cjhPbEtmOU5XM3BWSSIsInZhdWx0bG9jYXRpb24iOiJyZWZlcmVuY2VpZC9tc2VudHJhaWQvMEJVVGZPS2ZLYkNpMlJmNFMta3JOY0ZRVUFKMlI0WURJcWY4WHZsNW5LNCIsImF1ZCI6ImNvbnRhY3QtaHItY2xpZW50Iiwic3ViIjoidXNlci4xIiwiZ3JvdXBzIjpbIkFkbWluaXN0cmF0b3JzIl0sImZhbWlseV9uYW1lIjoiU2Vhd2VsbCIsImVtYWlsIjoibmlydmluZ3VrQGhvdG1haWwuY29tIiwiZXhwIjoxNzc2Njc1MTU4fQ.Cwk_hCqTocEZoE0yYOFnTjMd6UYBE5BToVOpj51GvNQcHAS76sw0p7pygqm5ze9kxntgyG6OQ8KjKxMUwRmCfC4wZimVRW32-1wTt7UNgKxZcCEAw23VO9XNVgCGdQBShWcqpla8-4cSxU0VIqZJQroVsP9L_hy8mUrRmN7dLWAt2f4KkgNuZmWK7xPbhRUQeIkOcjHhc9FQN4MB08O_DU0on6RbeW54pD0ndsviwMAV3MLLh898DkVSzy2_PpPNr8jgRWPBgcjmAuH2h5a_mcjr6Ei6c0tGOZchS05BwA2qjvWI8w9_C-7Ucn3_GIycIbPCh2ni9dAM9e_CjNfpdg' \
  --data-urlencode 'subject_token_type=urn:ietf:params:oauth:token-type:access_token' \
  --data-urlencode 'actor_token=eyJhbGciOiJSUzI1NiIsImtpZCI6IlA1X1FfaDdqaGVpRkpWQnBVRlh6M2RPRmRGb19SUzI1NiIsInBpLmF0bSI6IjRld3AifQ.eyJzY29wZSI6IiIsImF1dGhvcml6YXRpb25fZGV0YWlscyI6W10sImNsaWVudF9pZCI6ImNvbnRhY3QtaHItY2xpZW50IiwiaXNzIjoiaHR0cHM6Ly9pZC5waW5nLmRhcmtlZGdlcy5jb20iLCJpYXQiOjE3NzY2Njc5MzcsImp0aSI6InVqUGVQeHJBVU9MbHJqMDNPUm1QZTEiLCJleHAiOjE3NzY2NzUxMzd9.OEXjyYbBb4KmVMlBZJ8ucnn5_CacufyKL3-E_XsBcQWMhxhm_W9eCOpG3y_xmFGy9wSSNGpPzgVBzeHZ5xyYlSgt2fpBcA2UolQLNT0MKJrbqpJZicqmUh5HalGv6rXG4iuRjpFJ3_-N8zLUrk1t8puZYsSTPaYCrSb1K37_3moPzaNxIgrFplXftax5ez9kgu0QqtA3WyYNJUHAHdFv8cyBbOUy7MMdzTdMlZFaOoO7JHEdFpCzzTkuhtC1D95AADTApvJGsy6Lo4llnJoofnJmmXEjWaAY3hEm2kbXW1he2nR1fZtYQa-_-LxfwR6X5BAxrn96G8JWpc5Y2KKKFw' \
  --data-urlencode 'actor_token_type=urn:ietf:params:oauth:token-type:access_token' \
  --data-urlencode 'requested_token_type=urn:ietf:params:oauth:token-type:access_token' \
  --data-urlencode 'client_id=contact-oauth-client' \
  --data-urlencode 'client_secret=2FederateM0re' \
  --data-urlencode 'scope=openid profile email'
```

### Actor Token Claims (Chatbot — Client Credentials)

```json
{
  "scope": "",
  "authorization_details": [],
  "client_id": "contact-hr-client",
  "iss": "https://id.ping.darkedges.com",
  "iat": 1776667937,
  "jti": "ujPePxrAUOLlrj03ORmPe1",
  "exp": 1776675137
}
```

> Actor token has **empty scope** — obtained via Client Credentials, representing the application identity, not a user.

### Subject Token Claims (User — Authorization Code)

```json
{
  "scope": ["openid", "profile", "email"],
  "authorization_details": [],
  "client_id": "contact-hr-client",
  "iss": "https://id.ping.darkedges.com",
  "iat": 1776667958,
  "jti": "xExadYEtur8OlKf9NW3pVI",
  "vaultlocation": "referenceid/msentraid/0BUTfOKfKbCi2Rf4S-krNcFQUAJ2R4YDIqf8Xvl5nK4",
  "aud": "contact-hr-client",
  "sub": "user.1",
  "groups": ["Administrators"],
  "family_name": "Seawell",
  "email": "nirvinguk@hotmail.com",
  "exp": 1776675158
}
```

> Subject token has **full user scopes and claims** — obtained via Authorization Code flow, representing the user's identity.

### Exchanged Token Claims (Issued by PingFederate)

```json
{
  "scope": ["openid", "profile", "email"],
  "authorization_details": [],
  "client_id": "contact-oauth-client",
  "iss": "https://id.ping.darkedges.com",
  "iat": 1776667961,
  "jti": "XWcCCzPtj0OFR6HU8UA7Cw",
  "actor": {
    "sub": "contact-hr-client"
  },
  "vaultlocation": "referenceid/msentraid/0BUTfOKfKbCi2Rf4S-krNcFQUAJ2R4YDIqf8Xvl5nK4",
  "aud": "contact-oauth-client",
  "sub": "user.1",
  "exp": 1776675161
}
```

### What Changed Between Input and Output

| Property | Subject Token | Actor Token | Exchanged Token | Notes |
|---|---|---|---|---|
| `sub` | `user.1` | — | `user.1` | Preserved from subject |
| `client_id` | `contact-hr-client` | `contact-hr-client` | `contact-oauth-client` | Requesting client replaces original |
| `aud` | `contact-hr-client` | — | `contact-oauth-client` | Audience = requesting client |
| `actor` | — | — | `{ "sub": "contact-hr-client" }` | **Added** — records delegation |
| `scope` | `["openid","profile","email"]` | `""` | `["openid","profile","email"]` | Preserved from subject |
| `vaultlocation` | present | — | preserved | Passed through |
| `iat` | `1776667958` | `1776667937` | `1776667961` | New issuance time |
| `exp` | `1776675158` | `1776675137` | `1776675161` | New: iat + 120s |
| `jti` | unique | unique | unique | Fresh JWT ID |

### Chatbot Log Output

```
DEBUG: Initiating token exchange - actor: eyJhbGciOi..., subject: eyJhbGciOi...
✓ Token exchange successful for user
2026-04-20 16:52:41 - ✓ Token exchange completed for nirvinguk@hotmail.com
```

---

## Token Lifecycle Sequence

```
T0   User authenticates via PingFederate (Authorization Code flow)
     ├─ client_id: contact-hr-client
     ├─ Response: subject_token (user's access token)
     ├─ Lifetime: 120 seconds
     └─ Contains: sub, scope, vaultlocation, groups, email, names

T1   HR Chatbot app starts — initialize_agent_token() called
     ├─ POST /as/token.oauth2
     ├─ grant_type: client_credentials
     ├─ client_id: contact-hr-client
     ├─ Response: actor_token (chatbot's application token)
     ├─ Lifetime: 120 seconds
     └─ Cached globally in app memory + Redis

T2   OAuth callback fires — user token received in session
     ├─ actor_token available (from T1)
     └─ subject_token available (from OAuth callback)

T3   Token exchange request sent to PingFederate
     ├─ /as/token.oauth2
     ├─ grant_type: urn:ietf:params:oauth:grant-type:token-exchange
     ├─ subject_token: user's token (from T0)
     ├─ subject_token_type: urn:ietf:params:oauth:token-type:access_token
     ├─ actor_token: chatbot's token (from T1)
     ├─ actor_token_type: urn:ietf:params:oauth:token-type:access_token
     ├─ client_id: contact-oauth-client
     └─ scope: openid profile email

T4   PingFederate — policy selection
     ├─ PROCESSORPOLICIES selected (default policy)
     └─ Mapping 1 selected (both token types = access_token)

T5   PingFederate — token validation
     ├─ PFSubjectProcessor validates subject_token
     │   ├─ Verify RS256 signature against pf/JWKS
     │   ├─ Check issuer = https://id.ping.darkedges.com ✓
     │   ├─ Check audience = contact-hr-client ✓
     │   ├─ Check exp not reached ✓
     │   └─ Extract: sub, scope, groups, vaultlocation, email, names
     └─ PFActorSubject validates actor_token
         ├─ Verify RS256 signature against pf/JWKS
         ├─ Check issuer = https://id.ping.darkedges.com ✓
         ├─ Check exp not reached ✓
         └─ Extract: client_id

T6   PingFederate — attribute fulfillment
     ├─ actor        ← actor_token.client_id    = "contact-hr-client"
     ├─ subject      ← subject_token.sub        = "user.1"
     ├─ scope        ← subject_token.scope      = ["openid","profile","email"]
     ├─ vaultlocation← subject_token.vaultlocation
     ├─ groups       ← subject_token.groups     = ["Administrators"]
     ├─ given_name   ← subject_token.given_name
     ├─ family_name  ← subject_token.family_name = "Seawell"
     └─ email        ← subject_token.email      = "nirvinguk@hotmail.com"

T7   Access Token Mapping — OGNL transformation
     └─ actor → { "sub": "contact-hr-client" }  (JSON object per RFC 8693)

T8   AccessTokenManagement — JWT issuance
     ├─ Sign with RS256, key 5jqt7j8mxbwl2awtpc465yzx1
     ├─ Add: iss, iat, exp (iat+120), jti
     └─ Issued token returned

T9   Chatbot receives exchanged token
     └─ Stored in session metadata as "access_token"

T9+120s  Exchanged token expires
          └─ Next user action triggers new token exchange
```

---

## Configuration File Locations

| Component | Resource Type in data.json |
|---|---|
| Token Exchange Policy | `/oauth/tokenExchange/processor/policies` |
| Default Policy Setting | `/oauth/tokenExchange/processor/settings` |
| All Token Processors | `/idp/tokenProcessors` |
| Access Token Managers | `/oauth/accessTokenManagers` |
| Default ATM Setting | `/oauth/accessTokenManagers/settings` |
| Access Token Mappings | `/oauth/accessTokenMappings` |
| Signing Key Pair | `/keyPairs/signing` |
| OIDC Policy | `/oauth/openIdConnect/policies` |

**Source file**: [profiles/pingfederate/bulk-export/shared/data.json](../profiles/pingfederate/bulk-export/shared/data.json)

---

## Validation Checklist

### Pre-Exchange

```
PingFederate Configuration:
☐ PROCESSORPOLICIES exists and is set as default processor policy
☐ Both processor mappings configured (Mapping 1 + Mapping 2)
☐ actorTokenRequired = true
☐ AccessTokenManagement token manager exists
☐ Signing key 5jqt7j8mxbwl2awtpc465yzx1 is valid and not expired
☐ JWKS endpoint accessible: https://id.ping.darkedges.com/pf/JWKS

PFSubjectProcessor:
☐ Issuer: https://id.ping.darkedges.com
☐ Audience check enabled, value: contact-hr-client
☐ Expiration + Issued At checks enabled
☐ JWKS URL reachable

PFActorSubject:
☐ Issuer: https://id.ping.darkedges.com
☐ Audience check disabled
☐ Expiration + Issued At checks enabled
☐ client_id in attribute contract

MSFTTOKENPROCESSOR:
☐ Both Azure issuers configured
☐ Both JWKS URLs reachable
☐ Required audience values present

PFTOKENPROCESSOR:
☐ References AccessTokenManagement
☐ Scope handling configured
```

### Per-Request

```
Subject Token:
☐ JWT (3 dot-separated parts)
☐ RS256 signature valid
☐ iss = https://id.ping.darkedges.com
☐ aud = contact-hr-client
☐ exp > now (not expired)
☐ iat present and reasonable
☐ sub claim present
☐ scope claim present

Actor Token:
☐ JWT (3 dot-separated parts)
☐ RS256 signature valid
☐ iss = https://id.ping.darkedges.com
☐ exp > now (not expired)
☐ client_id claim present

Request Parameters:
☐ grant_type = urn:ietf:params:oauth:grant-type:token-exchange
☐ subject_token_type = urn:ietf:params:oauth:token-type:access_token
☐ actor_token_type = urn:ietf:params:oauth:token-type:access_token
☐ actor_token present (required by policy)
☐ client_id = contact-oauth-client (or other authorised client)
```

### Issued Token

```
☐ JWT signed RS256
☐ kid header = 5jqt7j8mxbwl2awtpc465yzx1
☐ iss = https://id.ping.darkedges.com
☐ sub preserved from subject_token
☐ actor present and is a JSON object: { "sub": "<client_id>" }
☐ aud = requesting client_id
☐ exp = iat + 120
☐ jti unique 22-character value
☐ vaultlocation preserved (if present in subject token)
☐ scope matches requested scopes
```

---

## Troubleshooting

| Symptom | Likely Cause | Resolution |
|---|---|---|
| `Agent access token not available, skipping token exchange` | `initialize_agent_token()` failed at startup | Check Redis connectivity; verify PF `/as/token.oauth2` is reachable; check `contact-hr-client` credentials |
| `invalid_request` on token exchange | Missing required parameter or wrong token type | Confirm `actor_token` and `actor_token_type` present; verify token type URNs |
| `invalid_token` on subject or actor | JWT validation failed | Check token not expired; verify issuer; confirm audience matches processor config |
| `actor` claim missing from issued token | OGNL expression failed | Check `org.json.simple` library available; verify `tepp.actor` is populated |
| `actor` claim is string not object | Wrong mapping — not using OGNL | Ensure Access Token Mapping uses EXPRESSION source for `actor` |
| `vaultlocation` missing from issued token | Attribute fulfillment issue | Confirm subject token contains `vaultlocation`; check Mapping 1 contract |
| Token exchange succeeds but groups empty | `groups` maps from `given_name` in current config | Review Access Token Mapping — `groups` attribute source currently points to `given_name` ⚠️ |
| Timeout acquiring actor token | PingFederate slow or unreachable | 10-second timeout in chatbot; check network/TLS; check PF health |

---

## References

- **RFC 8693** — [OAuth 2.0 Token Exchange](https://datatracker.ietf.org/doc/html/rfc8693)
  - §1.1: Delegation vs. Impersonation Semantics
  - §4.1: `act` (Actor) Claim
  - §4.2: `scope` Claim
  - §4.3: `client_id` Claim

- **PingFederate 12.3 Documentation**
  - [Token Exchange Processor Policies](https://docs.pingidentity.com/pingfederate/12.3/administrators_reference_guide/pf_config_oauth_token_exchange.html)
  - [Access Token Managers](https://docs.pingidentity.com/pingfederate/12.3/administrators_reference_guide/pf_access_token_managers.html)
  - [Token Processors](https://docs.pingidentity.com/pingfederate/12.3/administrators_reference_guide/pf_token_processors.html)

- **Project Files**
  - [TOKENEXCHANGE.md](../TOKENEXCHANGE.md) — Token exchange curl examples
  - [data.json](../profiles/pingfederate/bulk-export/shared/data.json) — Full PingFederate configuration export
  - [darkedges-hr-chatbot/app.py](../../chatbot/darkedges-hr-chatbot/app.py) — Chatbot token exchange implementation
  - [darkedges-hr-chatbot/auth_handler.py](../../chatbot/darkedges-hr-chatbot/auth_handler.py) — `perform_token_exchange()` method
