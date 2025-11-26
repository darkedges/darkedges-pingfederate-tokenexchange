# PingFederate AWS Connect Authentication Functions

AWS Lambda functions for headless authentication flow between AWS Connect and PingFederate, implementing OAuth2 with OTP verification.

## Overview

This project provides two AWS Lambda functions that enable a secure, multi-step authentication flow:

1. **initiate-auth**: Start OAuth flow and trigger OTP via SMS
2. **verify-token**: Verify OTP and exchange authorization code for access token

### Architecture Flow

```text
AWS Connect Call
    ↓
[initiate-auth] Lambda
    ├─ GET /as/authorization.oauth2 → PingFederate
    ├─ POST /pf-ws/authn/flows/{flowId} → Submit phone number
    └─ Return: flowId, status="OTP_SENT"
    ↓
User enters OTP in IVR
    ↓
[verify-token] Lambda
    ├─ POST /pf-ws/authn/flows/{flowId} → Submit OTP
    ├─ GET resumeUrl (manual redirect) → Extract authorization code
    ├─ POST /as/token.oauth2 → Exchange code for token
    └─ Return: accessToken, idToken, expiresIn
    ↓
AWS Connect receives access token
```

## Prerequisites

- Node.js 18.x or later
- AWS Account with Lambda permissions
- Serverless Framework CLI: `npm install -g serverless`
- AWS credentials configured locally or via IAM role

## Installation

```bash
# Install dependencies
npm install

# Create .env file (copy from .env.example)
cp .env.example .env

# Edit .env with your PingFederate and OAuth client credentials
nano .env
```

## Configuration

Required environment variables in `.env`:

| Variable        | Description                  | Example                              |
| --------------- | ---------------------------- | ------------------------------------ |
| `PF_BASE_URL`   | PingFederate engine base URL | `https://engine.ping.darkedges.com`  |
| `CLIENT_ID`     | OAuth client ID              | `tokenexchangeclient`                |
| `CLIENT_SECRET` | OAuth client secret          | `2FederateM0re`                      |
| `REDIRECT_URI`  | OAuth redirect URI           | `https://myapp.example.com/callback` |
| `AWS_REGION`    | AWS region for deployment    | `us-east-1`                          |
| `STAGE`         | Deployment stage             | `dev` or `prod`                      |

## Function Details

### Function 1: initiate-auth

**Purpose**: Start OAuth flow and send OTP to user's phone number

**Input** (from AWS Connect):

```json
{
  "Details": {
    "Parameters": {
      "phoneNumber": "+1234567890"
    }
  }
}
```

**Output**:

```json
{
  "statusCode": 200,
  "body": {
    "status": "OTP_SENT",
    "flowId": "abc123def456",
    "message": "OTP sent to +1234567890"
  }
}
```

**Logic**:

1. Initiates OAuth authorization flow with PingFederate
2. Submits phone number identifier (triggers SMS OTP)
3. Returns flowId for use in verify-token

**Error Response**:

```json
{
  "statusCode": 500,
  "body": {
    "status": "FAIL",
    "message": "Error description"
  }
}
```

---

### Function 2: verify-token

**Purpose**: Verify OTP and exchange authorization code for access token

**Input** (from AWS Connect):

```json
{
  "Details": {
    "Parameters": {
      "flowId": "abc123def456",
      "userCode": "123456"
    }
  }
}
```

**Output**:

```json
{
  "statusCode": 200,
  "body": {
    "status": "SUCCESS",
    "accessToken": "eyJhbGciOiJSUzI1NiIsImt...",
    "tokenType": "Bearer",
    "expiresIn": 7199,
    "idToken": "eyJhbGciOiJSUzI1NiIsImt...",
    "scope": "openid profile email"
  }
}
```

**Logic**:

1. Submits OTP code to PingFederate
2. Extracts authorization code from resume URL (without following redirect)
3. Exchanges code for access token using client credentials
4. Returns token and token metadata

**Error Response**:

```json
{
  "statusCode": 401,
  "body": {
    "status": "FAIL",
    "message": "Invalid OTP or OTP verification failed"
  }
}
```

---

## Deployment

### Deploy to AWS

```bash
# Deploy to dev stage
npm run deploy:dev

# Deploy to prod stage
npm run deploy:prod

# Deploy specific function
serverless deploy function -f initiate-auth --stage prod
```

### Local Development

```bash
# Start local API server (requires serverless-offline)
npm run offline

# Invoke function locally
npm run invoke:initiate

# View logs
npm run logs:initiate
```

## Testing

### Test initiate-auth with curl

```bash
curl -X POST http://localhost:3000/auth/initiate \
  -H "Content-Type: application/json" \
  -d '{
    "Details": {
      "Parameters": {
        "phoneNumber": "+1234567890"
      }
    }
  }'
```

### Test verify-token with curl

```bash
curl -X POST http://localhost:3000/auth/verify \
  -H "Content-Type: application/json" \
  -d '{
    "Details": {
      "Parameters": {
        "flowId": "abc123def456",
        "userCode": "123456"
      }
    }
  }'
```

## AWS Connect Integration

### Example Connect Contact Flow

1. **Collect phone number** via IVR
2. **Invoke Lambda** (initiate-auth)
   - Pass: `phoneNumber` parameter
   - Receive: `flowId`
3. **Play message**: "An OTP has been sent to your phone"
4. **Collect DTMF input** (OTP code, 6 digits)
5. **Invoke Lambda** (verify-token)
   - Pass: `flowId`, `userCode` parameters
   - Receive: `accessToken`
6. **Use accessToken** for downstream systems

### Connect Flow JSON Example

```json
{
  "StartAction": "12345678-abcd-1234-abcd-123456789012",
  "Modules": [
    {
      "Id": "12345678-abcd-1234-abcd-123456789012",
      "Type": "SetAttributes",
      "Branches": [
        {
          "Condition": "Success",
          "NextAction": "invoke-initiate-auth"
        }
      ]
    },
    {
      "Id": "invoke-initiate-auth",
      "Type": "InvokeLambdaFunction",
      "Parameters": {
        "LambdaFunctionARN": "arn:aws:lambda:us-east-1:ACCOUNT:function:pingfederate-auth-flow-dev-initiate-auth"
      },
      "Branches": [
        {
          "Condition": "Success",
          "NextAction": "collect-otp"
        }
      ]
    }
  ]
}
```

## Security Considerations

### Sensitive Data

- **CLIENT_SECRET**: Never commit to version control; use environment variables
- **Phone numbers**: Use HTTPS/TLS for all communications
- **OTP codes**: Never log OTP values in production
- **Access tokens**: Use short expiration times (default: 2 hours)

### Best Practices

1. **Use IAM Roles**: Deploy Lambda with minimal required permissions
2. **VPC Integration**: If PingFederate is on private network, deploy Lambda in VPC
3. **Encryption**: Enable encryption for Lambda environment variables
4. **Monitoring**: Enable CloudWatch logs and set up alarms for failures
5. **Rate Limiting**: Implement rate limiting for OTP submission attempts
6. **HTTPS Only**: Ensure all PingFederate URLs use HTTPS

### SSL/TLS Certificate Validation

Both functions use Node.js's native `fetch()` which validates SSL certificates by default. For self-signed certificates in development:

```javascript
// NOT RECOMMENDED FOR PRODUCTION
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';
```

## Troubleshooting

### Common Issues

#### "Missing environment variables"

- Ensure `.env` file exists and is properly formatted
- For deployed functions, verify environment variables in Lambda console

#### "Authorization endpoint returned 401"

- Check CLIENT_ID and CLIENT_SECRET
- Verify PingFederate client is configured correctly

#### "No Location header found"

- Ensure `redirect: 'manual'` is set (critical for code extraction)
- Verify resumeUrl is valid and returns a redirect

#### "Token endpoint returned 400: invalid_grant"

- Authorization code may have expired (typically 10 minutes)
- Verify code is correctly extracted from Location header
- Check CLIENT_ID, CLIENT_SECRET, and REDIRECT_URI match PingFederate config

### Debugging

Enable debug logging:

```javascript
// Add to function
console.log = (...args) => {
  process.stdout.write(JSON.stringify({
    timestamp: new Date().toISOString(),
    level: 'DEBUG',
    message: args.join(' ')
  }) + '\n');
};
```

View CloudWatch logs:

```bash
npm run logs:initiate
npm run logs:verify
```

## Dependencies

- **Node.js built-in**: fetch, URLSearchParams (Node 18+)
- **Serverless Framework**: Infrastructure as Code
- **serverless-offline**: Local testing
- **serverless-dotenv-plugin**: Environment variable management

No external HTTP libraries required - uses native Node.js fetch API.

## Project Structure

```text
lambda/
├── src/
│   ├── initiate-auth.js      # Step 1: Start OAuth flow
│   └── verify-token.js       # Step 2: Verify OTP & exchange token
├── .env.example              # Environment variable template
├── .env                       # Local environment (gitignored)
├── .gitignore                # Git ignore rules
├── package.json              # Dependencies
├── serverless.yml            # Serverless Framework config
└── README.md                 # This file
```

## License

ISC

## Resources

- [PingFederate OAuth Token Exchange](https://docs.pingidentity.com/pingfederate/12.3/administrators_reference_guide/pf_config_oauth_token_exchange.html)
- [RFC 8693 - Token Exchange](https://datatracker.ietf.org/doc/html/rfc8693)
- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [AWS Connect Integration](https://docs.aws.amazon.com/connect/)
- [Serverless Framework](https://www.serverless.com/)

## Support

For issues or questions:

1. Check CloudWatch logs: `npm run logs:initiate`
2. Test locally: `npm run offline`
3. Review TOKENEXCHANGE.md in project root for PingFederate specifics
